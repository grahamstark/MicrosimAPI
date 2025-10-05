module MicrosimAPI
using Reexport
@reexport using JSON3
@reexport using Oxygen
@reexport using HTTP
@reexport using Random
@reexport using Parameters
@reexport using Dates
@reexport using UUIDs
@reexport using ScottishTaxBenefitModel

@oxidise

export cors_middleware, session_middleware, SESSIONS, SB_RUNS, SBRunData

const SESSION_TIMEOUT = Minute(240)

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]


include("scotben.jl")

# Simple in-memory session store
const SESSIONS = Dict{String, Dict{String, Any}}()

"""
Session middleware that creates or retrieves sessions based on cookies
"""
function session_middleware(handler)
    return function(req::HTTP.Request)
        # Try to get session ID from cookie
        session_id = get_cookie(req, "session_id")
        @show "session_middleware called"
        
        # Create new session if none exists or session is invalid
        if isnothing(session_id) || !haskey(SESSIONS, session_id)
            session_id = string(uuid4())
            SESSIONS[session_id] = Dict{String, Any}(
                "created_at" => now(),
                "last_accessed" => now(),
                "data" => Dict{String, Any}()
            )
        else
            # Update last accessed time
            SESSIONS[session_id]["last_accessed"] = now()
            
            # Clean up expired sessions
            cleanup_sessions()
        end
        
        # Add session to request context
        req.context[:session_id] = session_id
        req.context[:session] = SESSIONS[session_id]["data"]
        
        # Call the actual handler
        response = handler(req)
        
        # Set session cookie in response
        HTTP.setheader(response, "Set-Cookie" => 
            "session_id=$session_id; Path=/; HttpOnly; SameSite=Lax; Max-Age=1800")
        
        return response
    end # function
end # session_middleware

"""
Helper function to get cookie value from request
"""
function get_cookie(req::HTTP.Request, name::String)
    cookies = HTTP.header(req, "Cookie")
    for cookie in split(cookies, "; ")
        parts = split(cookie, "=", limit=2)
        if length(parts) == 2 && parts[1] == name
            return parts[2]
        end
    end
    return nothing
end

"""
Clean up expired sessions
"""
function cleanup_sessions()
    current_time = now()
    expired_sessions = String[]
    
    for (sid, session) in SESSIONS
        if current_time - session["last_accessed"] > SESSION_TIMEOUT
            push!(expired_sessions, sid)
        end
    end
    
    for sid in expired_sessions
        delete!(SESSIONS, sid)
    end
end # cleanup

"""
Helper to get current session data from request
"""
function get_session(req::HTTP.Request)
    return get(req.context, :session, Dict{String, Any}())
end

function cors_middleware( handler )
    return function( req::HTTP.Request )
        @show "cors_middleware"
        if HTTP.method(req)=="OPTIONS"
            return HTTP.Response(200, CORS_HEADERS)  
        else         
            return handler( req )
        end        
    end # function
end # 

staticfiles( "web", "web" )

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
