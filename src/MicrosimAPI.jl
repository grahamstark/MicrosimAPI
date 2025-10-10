module MicrosimAPI

using DataStructures
using Dates
using HTTP
using JSON3
using LoggingExtras
using Observables
using Oxygen
using Parameters
using Random
using Reexport
using StructTypes
using UUIDs

import Base.get # Dunno why I need this ... 

using ScottishTaxBenefitModel
using .BCCalcs
using .Definitions
using .ExampleHelpers
using .FRSHouseholdGetter
using .GeneralTaxComponents
using .LocalLevelCalculations
using .ModelHousehold
using .Monitor
using .Runner
using .RunSettings
using .SimplePovertyCounts: GroupPoverty
using .SingleHouseholdCalculations
using .STBIncomes
using .STBOutput
using .STBParameters
using .Utils

@oxidise

export cors_middleware, session_middleware, SESSIONS

include("definitions.jl")
include("middleware.jl")
include("examples.jl")
include("scotben.jl")

dynamicfiles( "web", "web" )

#=
use:

using MicrosimAPI
MicrosimAPI.serve( 
    # host="localhost", 
    port=8089,
    revise=:eager,
    middleware = [cors_middleware, session_middleware])

=#

#
# Set up job queues 
# Don't understand this, but see:
# https://discourse.julialang.org/t/errorexception-task-cannot-be-serialized-with-taskwrapper-struct/26617/4
# 
function __init__()
    global t
    t = @async calc_one()
    for i in 1:NUM_HANDLERS # start n tasks to process requests in parallel
        @info "starting handler $i" 
        errormonitor(t)
    end
end

end # module