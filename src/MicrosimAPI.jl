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

include("scotben.jl")

"""
Check if part of a session and start one if not.
"""
function session_middleware( handler )
    return function( req :: HTTP.Request )
        jp = Dict()
        try
            pl = IOBuffer(HTTP.payload(req))
            jp = JSON3.parse(pl)
        catch e
            ;
        end
        session_token = get(jp,"session_token",nothing)
        if isnothing( session_token )
            session_token = generateSessionToken()
            session = Session( 
                now(),
                now() + SESSION_TIMEOUT,
                now()
            )
            sessions[session_token] = session
            jp[session_token] = session

        else
            session = sessions[session_token]
            session.expires += SESSION_TIMEOUT # extend the session
            session.last_activity = now()
        end
        return handler( req ) 
        #=
        json( (; 
            session_token, 
            success = true, 
            expires_in = SESSION_TIMEOUT ))
        =#
    end # function
end

function cors_middleware( handler )
    return function( req::HTTP.Request )
        return handler( req )
    end
end

Oxygen.serve( middleware = [cors_middleware, session_middleware])

end
