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

# import Base.get # Dunno why I need this ... 

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

const SESSION_TIMEOUT = Minute(240)

include("definitions.jl")
include("middleware.jl")
include("examples.jl")
include("scotben.jl")

# staticfiles( "web", "web" )
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

end # module
