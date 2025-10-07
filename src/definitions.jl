# get around weird bug similar to: https://github.com/GenieFramework/Genie.jl/issues/433
# __precompile__(false)

const BASE_UUID = UUID("985c312f-129b-4acd-9e40-cb629d184183")

const BIG_A = 9999999999
struct SimpleParams{T}
    taxrates :: Vector{T}
    taxbands :: Vector{T}
    nirates :: Vector{T}
    nibands :: Vector{T}
    taxallowance :: T
    child_benefit :: T
    pension :: T
    scottish_child_payment :: T
    scp_age :: Int
    uc_single :: T
    uc_taper :: T
end
StructTypes.StructType(::Type{SimpleParams}) = StructTypes.Struct()

function validate_value!( d::Dict, name::String, v :: Real ; min=0, max=1000 )
    if (v < min) || (v > max)
        d[name] = "$(name) is outside the range $(min) - $(max)"
    end
    d
end

function validate_ratebands!( d::Dict, name::String, rates::Vector, bands::Vector)
    nr = length( rates )
    nb = length( bands )
    if nr - nb > 1
        errs["$(name)rates"] = "Length of $name rates and bands should match."
    end
    for t in 1:nr
        if 0 <= rates[t] >= 100
            errs["$(name)rates[$t]"] = "Rate should be between 0 and 100."
        end
    end
    for t in 1:nb-1
        if bands[t+1] <= bands[t]
            errs["$(name)bands[$t]"] = "Bands should be in ascending order."
        end
    end
end

function validate( sp :: SimpleParams )::Dict
    errs = Dict()
    validate_ratebands!( errs, "tax", sp.taxrates, sb.taxbands )
    validate_ratebands!( errs, "ni", sp.nirates, sb.nibands )
    validate_value!(errs, "taxallowance", sp.taxallowance; max=100_000)
    validate_value!(errs, "child_benefit", sp.child_benefit)
    validate_value!(errs, "pension", sp.pension)
    validate_value!(errs, "scottish_child_payment", sp.scottish_child_payment)
    validate_value!(errs, "scp_age", sp.scp_age; min=0, max=21 )
    validate_value!(errs, "uc_single", sp.uc_single)
    validate_value!(errs, "uc_single", sp.uc_single)
    validate_value!(errs, "uc_taper", sp.uc_taper; min=0, max=100)
    errs
end

function loaddefs() :: TaxBenefitSystem 
    return get_default_system_for_fin_year( 
        2025; 
        scotland = true,
        autoweekly = false )    
end

function weeklyparams() :: TaxBenefitSystem
   pars = deepcopy( DEFAULT_PARAMS )
   weeklyise!( pars )
   pars
end

const DEF_PROGRESS = Progress( BASE_UUID, "na", 0, 0, 0, 0 )
const NO_PROGRESS = ( progress=DEF_PROGRESS, total=-1)

const DEFAULT_PARAMS ::  TaxBenefitSystem = loaddefs()

const DEFAULT_WEEKLY_PARAMS :: TaxBenefitSystem = weeklyparams()

"""
Chop off top band if needed 
"""
function copyArrays( r :: Vector, b :: Vector ) :: Tuple
    ar = copy(r)
    ab = copy(b)
    start = firstindex(ar)
    tstop = lastindex(ab)
    rstop = lastindex(ar)
    @assert (rstop - tstop) <= 1
    if rstop == tstop
        tstop -= 1
    end    
    (ar,ab[start:tstop])
end

function map_full_to_simple( sys :: TaxBenefitSystem )::SimpleParams
    itr, itb = copyArrays( 
        sys.it.non_savings_rates, 
        sys.it.non_savings_thresholds )
    nr, nb = copyArrays(
        sys.ni.primary_class_1_rates,
        sys.ni.primary_class_1_bands )
    return SimpleParams(
        itr,
        itb,
        nr,
        nb,
        sys.it.personal_allowance,
    	sys.nmt_bens.child_benefit.first_child,
		sys.nmt_bens.pensions.new_state_pension,
		sys.scottish_child_payment.amount,
		sys.scottish_child_payment.maximum_age,
	    sys.uc.age_25_and_over,
		sys.uc.taper )
end

function roundm( v::T, m::T, digits=2)::T where T<:Number
    v *= m
    round(v,digits=digits)
end

function nearest( a :: AbstractArray, v :: Number)
    m = 999999999999999 
    p = 0
    n = length(a)
    for i in 1:n
        d = abs( a[i]-v )      
        if d <= m # <= is a bit of a hack - suppose you have 2 20s...
            m = d
            p = i
        end
    end
    return p
end

function map_simple_to_full!( sys ::  TaxBenefitSystem, sm :: SimpleParams )
    sys.it.non_savings_rates = copy(sm.taxrates)
    br = sys.it.non_savings_basic_rate
    orig = DEFAULT_PARAMS.it.non_savings_rates[br]
    sys.it.non_savings_basic_rate = nearest( sys.it.non_savings_rates, orig )
    @info " setting sys.it.non_savings_basic_rate to " sys.it.non_savings_basic_rate " orig = " orig
    sys.it.non_savings_thresholds = copy(sm.taxbands)
    sys.ni.primary_class_1_rates = copy(sm.nirates)
    sys.ni.primary_class_1_bands = copy(sm.nibands)
    sys.it.personal_allowance = sm.taxallowance

    p = sm.child_benefit/sys.nmt_bens.child_benefit.first_child
    sys.nmt_bens.child_benefit.first_child = sm.child_benefit
    sys.nmt_bens.child_benefit.other_children = roundm( sys.nmt_bens.child_benefit.other_children, p)

    p = sm.pension / sys.nmt_bens.pensions.new_state_pension
    sys.nmt_bens.pensions.new_state_pension = sm.pension
    sys.nmt_bens.pensions.cat_a  = roundm( sys.nmt_bens.pensions.cat_a, p )
    sys.nmt_bens.pensions.cat_b  = roundm( sys.nmt_bens.pensions.cat_b, p )
    sys.nmt_bens.pensions.cat_d  = roundm( sys.nmt_bens.pensions.cat_d, p )
    sys.nmt_bens.pensions.cat_b_survivor  = roundm( sys.nmt_bens.pensions.cat_b_survivor, p )

    sys.scottish_child_payment.amount = sm.scottish_child_payment
    sys.scottish_child_payment.maximum_age = sm.scp_age

    sys.uc.taper = sm.uc_taper
    p = sm.uc_single/sys.uc.age_25_and_over
    sys.uc.age_25_and_over = sm.uc_single
    sys.uc.threshold = roundm( sys.uc.threshold, p )
    sys.uc.age_18_24  = roundm( sys.uc.age_18_24 , p )
    sys.uc.age_25_and_over  = roundm( sys.uc.age_25_and_over , p )
    sys.uc.couple_both_under_25  = roundm( sys.uc.couple_both_under_25 , p )
    sys.uc.couple_oldest_25_plus  = roundm( sys.uc.couple_oldest_25_plus , p )
    sys.uc.minimum_income_floor_hours = roundm( sys.uc.minimum_income_floor_hours, p )
    sys.uc.first_child   = roundm( sys.uc.first_child  , p )
    sys.uc.subsequent_child  = roundm( sys.uc.subsequent_child , p )
    sys.uc.disabled_child_lower  = roundm( sys.uc.disabled_child_lower , p )
    sys.uc.disabled_child_higher  = roundm( sys.uc.disabled_child_higher , p )
    sys.uc.limited_capcacity_for_work_activity = roundm( sys.uc.limited_capcacity_for_work_activity, p )
    sys.uc.carer  = roundm( sys.uc.carer , p )
    sys.uc.ndd = roundm( sys.uc.ndd, p )
    sys.uc.childcare_max_2_plus_children  = roundm( sys.uc.childcare_max_2_plus_children , p )
    sys.uc.childcare_max_1_child  = roundm( sys.uc.childcare_max_1_child , p )
    sys.uc.work_allowance_w_housing = roundm( sys.uc.work_allowance_w_housing, p )
    sys.uc.work_allowance_no_housing = roundm( sys.uc.work_allowance_no_housing, p )
end

const DEFAULT_SIMPLE_PARAMS :: SimpleParams = map_full_to_simple( DEFAULT_PARAMS )


function api_run( settings :: Settings, systems::Vector; supress_dumps=false )::Tuple
    # delete higher rates
    global running_total
    tot = 0
    results = nothing
    summaries = nothing 
    results = do_one_run( settings, systems, run_progress )
    summaries = summarise_frames!( results, settings )
    dump_summaries( settings, summaries )
    short_summary = make_short_summary( summaries )
    if ! supress_dumps
        dump_summaries( settings, summaries )
    end
    rname = basiccensor( settings.run_name )
    dirname = joinpath( settings.output_dir, rname ) 
    save_hbai_graph( settings, results, summaries ) 
    # zipname = zip_dump( settings )
    summaries, results, short_summary, dirname
end

struct ParamsAndSettings{T}
	simple   :: SimpleParams{T}
	session  :: String
end
#
# this many simultaneous (sp) runs
#
const NUM_HANDLERS = 4

const QSIZE = 32

IN_QUEUE = Channel{ParamsAndSettings}(QSIZE)

# configure logger; see: https://docs.julialang.org/en/v1/stdlib/Logging/index.html
# and: https://github.com/oxinabox/LoggingExtras.jl
logger = FileLogger("log/stb2_log.txt")
global_logger(logger)
LogLevel( Logging.Debug )

const MR_UP_GOOD = [1,0,0,0,0,0,0,-1,-1]
const COST_UP_GOOD = [1,1,1,1,-1,-1,-1,-1,-1,-1,-1]

struct AllOutput
	results
	summary
	gain_lose
	examples
end

