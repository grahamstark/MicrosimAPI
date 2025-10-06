module MicrosimAPI

using Reexport
using JSON3
using Oxygen
using HTTP
using Random
using Parameters
using Dates
using UUIDs
using ScottishTaxBenefitModel
using .STBParameters

@oxidise

export cors_middleware, session_middleware, SESSIONS

const SESSION_TIMEOUT = Minute(240)

# Simple in-memory session store
const SESSIONS = Dict{String, Dict{String, Any}}()

include("middleware.jl")
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
