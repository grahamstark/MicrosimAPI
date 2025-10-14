# module MicrosimAPI
using DataStructures
using Dates
using HTTP
using JSON3
using LoggingExtras
using Observables
using Oxygen # : @get, @put, json, dynamicfiles, serve
using Parameters
using Random
using Reexport
using StructTypes
using UUIDs

using Markdown

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

# Oxygen.@oxidise

# export cors_middleware, session_middleware, SESSIONS

include("definitions.jl")
include("middleware.jl")
include("examples.jl")
include("scotben.jl")

#=
use:

using MicrosimAPI
MicrosimAPI.serve( 
    # host="localhost", 
    port=8089,
    # revise=:eager,
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

function svr()
    __init__()
    dynamicfiles( "web", "web" )
    serve( 
        # host="localhost", 
        port=8089,
        # revise=:eager,
        middleware = [cors_middleware, session_middleware])
end

# end # module