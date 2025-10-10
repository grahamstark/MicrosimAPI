const SESSION_TIMEOUT = Minute(240)

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

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
            SESSIONS[session_id] = SessionEntry()
            #=
                Dict{String, Any}(
                "created_at" => now(),
                "last_accessed" => now(),
                "data" => Dict{String, Any}()
            )
            =#
        else
            # Update last accessed time
            SESSIONS[session_id].last_accessed = now()
            
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
function get_session_data(req::HTTP.Request)
    @show typeof( req.context )
    return Base.get(req.context, :session, Dict{String,Any}())
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