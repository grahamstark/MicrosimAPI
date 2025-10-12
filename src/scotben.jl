#

#

function list_default_systems()
    choices=OrderedDict()
    for financial_year in 2025:-1:2019
        for scottish in [true,false]
            sn = scottish ? "Scotland" : "rUK"
            default = financial_year == 2025 && scottish ? true : false
            name = "System FY $(financial_year)-$(financial_year+1); $sn"
            choices[name] = (;name,financial_year,scottish,default)
        end
    end
    choices 
end

const DEFAULT_SYSTEMS = list_default_systems()

"""

"""
function params_list_available(req::HTTP.Request)
    return json(DEFAULT_SYSTEMS)
end

"""

"""
function params_initialise(req::HTTP.Request)
    session_id = req.context[:session_id]
    data = json(req)    
    prs = SESSIONS[session_id].params_and_settings
    prs.params[2]=deepcopy(DEFAULT_SIMPLE_PARAMS)
    SESSIONS[session_id].h = riskyhash( prs )
    return json( SESSIONS[session_id].params_and_settings.params[2] )
end

"""

"""
function params_set(req::HTTP.Request)
    session_id = req.context[:session_id]
    sp = json( req, SimpleParams )
    errs = validate( sp )
    if length( errs ) == 0
        SESSIONS[session_id].params_and_settings.params[2] = sp
        SESSIONS[session_id].h = riskyhash( SESSIONS[session_id].params_and_settings )
        return json(sp)
    else
        return json( errs )
    end
end

"""

"""
function params_validate(req::HTTP.Request)
    sp = json( req, SimpleParams )
    errs = validate( sp )
    return json( errs )
end

const TEXT_DESC = md"""

    taxrates :: Vector{T} :: min 0 max 100 pct
    taxbands :: Vector{T} :: min 0 max unlimited
    nirates :: Vector{T} :: min 0 max 100 pct
    nibands :: Vector{T} :: min 0 max 100 annual
    taxallowance :: T min 0 max 100_000 annual
    child_benefit :: T min 0 max 1000 weekly
    pension :: T  min 0 max 1000 weekly
    scottish_child_payment :: T  min 0 max 1000 weekly
    scp_age :: Int min 0 max 21 
    uc_single :: T  min 0 max 1000 weekly
    uc_taper :: T  min 0 max 100 pct

"""

const OUTPUT_ITEMS = OrderedDict([
    "headline_figures"=>"Headline Summary (json)",
    "quantiles"=>"Quantiles (50 rows, 4 cols) (csv)", 
    "deciles" => "Quantiles (10 rows, 4 cols) (csv)",
    "income_summary" => "Income Summary (csv)", 
    "poverty" => "Poverty Measures (json)", 
    "inequality" => "Inequality Measures (json)", 
    "metrs" => "Marginal Effective Tax Rates histogram (csv)", 
    "child_poverty" => "Child Poverty Count (json)",
    "gain_lose/ten_gl" => "Gain Lose by Tenure (csv)",
    "gain_lose/dec_gl" => "Gain Lose by Decile (csv)",
    "gain_lose/children_gl" => "Gain Lose by Number of Children (csv)",
    "gain_lose/hhtype_gl" => "Gain Lose by Household Size (csv)",
    "poverty_lines" => "Computed Poverty Lines (json)",
    "short_income_summary"=>"Short Income Summary (csv)",
    "income_hists"=>"Histogram of Incomes (csv)",
    "povtrans_matrix"=>"Poverty Transitions Matrix (csv)",
    "examples"=>"Simple Examples (json)"
])

const CSV_ITEMS = [
    "quantiles",
    "deciles",
    "income_summary", 
    "metrs", 
    "gain_lose",
    "short_income_summary",
    "income_hists",
    "povtrans_matrix"]


const LABELS = OrderedDict([
    "taxrates" => "Tax Rates (%)",
    "taxbands" => "Tax Bands (£pa)",
    "nirates" => "NI Rates (%)",
    "nibands" => "NI Bands (£pa)",
    "taxallowance" => "Tax Allowance (£pa)",
    "child_benefit" => "Child Benefit (£pw)",
    "pension" => "Pension  (£pa)",
    "scottish_child_payment" => "Scottish Child Payment (£pa)",
    "scp_age" => "Scottish Child Payment Maximum Age (years)",
    "uc_single" => "Universal Credit Single Person (£pm)",
    "uc_taper" => "Universal Credit Taper (pct)"])

const RUN_STATUSES = OrderedDict([
    "submitted" => "Job Submitted",
    "do-one-run-start" => "Run Started",
    "weights" => "Weights Calculation",
    "disability_eligibility" => "Calibrating Disability Eligibility",
    "starting" => "Main Calculations Starting",
    "run" => "Running Through Households",
    "dumping_frames" => "Dumping Data to Files",
    "do-one-run-end" => "Run Ended",
    "completed" => "Task Completed - Output is Ready"])


"""

"""
function params_describe(req::HTTP.Request)
    return string(TEXT_DESC) # server objects to md"...
  
end

"""

"""
function params_subsys(req::HTTP.Request)
    @show "/scotben/params/subsys"
    return "Subsys"
end

"""

"""
function params_helppage( req::HTTP.Request )
    return string(TEXT_DESC)
end

"""

"""
function params_labels(req::HTTP.Request)
    return json( LABELS )
end


@get "/scotben/params/list-available" params_list_available
@put "/scotben/params/list-available" params_list_available
@get "/scotben/params/initialise/" params_initialise
@put "/scotben/params/initialise/" params_initialise
@get "/scotben/params/set" params_set
@put "/scotben/params/set" params_set
@get "/scotben/params/validate" params_validate
@put "/scotben/params/validate" params_validate
@get "/scotben/params/describe" params_describe 
@put "/scotben/params/describe" params_describe 
@get "/scotben/params/subsys" params_subsys
@put "/scotben/params/subsys" params_subsys
@get "/scotben/params/helppage" params_helppage
@put "/scotben/params/helppage" params_helppage
@get "/scotben/params/labels" params_labels
@put "/scotben/params/labels" params_labels

#=
or /params@get "/scotben/[subsys]/set ... for individual pages" function(req::HTTP.Request)

end
=#


"""

"""
function settings_set(req::HTTP.Request)
    return "Set Settings"
end

"""

"""
function settings_initialise(req::HTTP.Request)
    return "Initialise"
end

"""

"""
function settings_validate(req::HTTP.Request)
    return "Validate"
end

"""

"""
function settings_describe(req::HTTP.Request)
    return "Describe"
end
"""

"""
function settings_helppage( req::HTTP.Request )
    return "HelpPage"
end

"""

"""
function settings_labels(req::HTTP.Request)
    return "Labels"
end

@get "/scotben/settings/initialise/" settings_initialise
@put "/scotben/settings/initialise/" settings_initialise
@get "/scotben/settings/set" settings_set
@put "/scotben/settings/set" settings_set
@get "/scotben/settings/validate" settings_validate
@put "/scotben/settings/validate" settings_validate
@get "/scotben/settings/describe" settings_describe 
@put "/scotben/settings/describe" settings_describe 
@get "/scotben/settings/helppage" settings_helppage
@put "/scotben/settings/helppage" settings_helppage
@get "/scotben/settings/labels" settings_labels
@put "/scotben/settings/labels" settings_labels

"""

"""
function run_submit(req::HTTP.Request)
    session_id = req.context[:session_id]
    prs = SESSIONS[session_id].params_and_settings
    h = SESSIONS[session_id].h
    res = Base.get(CACHED_RESULTS, h, nothing )
    if isnothing( res )
        try
            submit_job( h, prs )
            return json((; error="ok", info=Progress( BASE_UUID, "submitted", 0, 0, 0, 0 ) ))
        catch e
            return json((; error="error", info=""))
        end
    else
        return json((; error="ok", info=res.progress ))
    end
    return "Submit"
end

"""

"""
function run_status(req::HTTP.Request)
    session_id = req.context[:session_id]
    h = SESSIONS[session_id].h
    @show h
    # print( SESSIONS )
    # @show CACHED_RESULTS
    # @show JOB_QUEUE
    res = Base.get(CACHED_RESULTS, h, nothing )
    if isnothing( res )
        return json((; error="no_run", info="" ))
    else
        return json((; error="ok", info=res.progress ))
    end
    return "Status"
end

"""

"""
function run_abort(req::HTTP.Request)
    return "We Can't Abort.."
end


"""

"""
function run_statuses(req::HTTP.Request)
    return json( RUN_STATUSES )
end


@get "/scotben/run/status" run_status
@put "/scotben/run/status" run_status
@get "/scotben/run/statuses" run_statuses
@put "/scotben/run/statuses" run_statuses
@get "/scotben/run/submit" run_submit
@put "/scotben/run/submit" run_submit
@get "/scotben/run/abort" run_abort
@put "/scotben/run/abort" run_abort

"""

"""
function output_items(req::HTTP.Request)
    return json(OUTPUT_ITEMS)
end

"""

"""
function output_phunpak(req::HTTP.Request)
    output_zipfile="" # TODO
    return HTTP.Response(
        200,
        ["Content-Type" => "application/zip"],
        body=output_zipfile )
end

"""

"""
function output_labels(req::HTTP.Request)
    return "Labels, possibly."
end

"""

"""
function output_fetch_item(req::HTTP.Request, name, subname )
    session_id = req.context[:session_id]
    h = SESSIONS[session_id].h
    res = Base.get(CACHED_RESULTS, h, nothing )
    if ! isnothing( res )
        ns = Symbol( name )
        item = nothing
        ctype = if name in CSV_ITEMS
            "text/csv"
        else
            "application/json"
        end
        if name == "gain_lose"
            sns = Symbol( subname )            
        end
    end
end


@get "/scotben/output/items" output_items
@put "/scotben/output/items" output_items
@get "/scotben/output/phunpak" output_phunpak
@put "/scotben/output/phunpak" output_phunpak
@get "/scotben/output/labels" output_labels
@put "/scotben/output/labels" output_labels
@get "/scotben/output/fetch/item/{name}/{subname}" output_fetch_item
@put "/scotben/output/fetch/item/{name}/{subname}" output_fetch_item