module MicrosimAPI

using JSON3
using Oxygen
using HTTP
using Random
using Parameters
using Dates

const SESSION_TIMEOUT = Second(24 * 60 * 60) # 24 Hours

mutable struct Session
    created :: Date
    expires :: Date
    last_activity :: Date
end

sessions = Dict{String,Session}()

# Generate secure session token
function generateSessionToken()
  return randstring('0':'9', 32)
end


@get "/session/start" function(req::HTTP.Request)
    JsonFragment
    session_token = generateSessionToken()
    session = Session( 
        now(),
        now() + SESSION_TIMEOUT,
        now()
    )
    sessions[session_token] = session
    return json( (; 
        session_token, 
        success = true, 
        expires_in = SESSION_TIMEOUT ))
end

@get "/session/destroy" function(req::HTTP.Request)

end


include("scotben.jl")

Oxygen.serve()

end
