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
function params_initialise(req::HTTP.Request, JsonFragment)
    session_id = req.context[:session_id]
    data = json(req)    
    SESSIONS[session_id].params[2]=deepcopy(DEFAULT_SIMPLE_PARAMS)
    return json( SESSIONS[session_id].params[2] )
end

"""

"""
function params_set(req::HTTP.Request)
    session_id = req.context[:session_id]
    sp = json( req, SimpleParams )
    errs = validate( sp )
    if length( errs ) == 0
        SESSIONS[session_id].params_and_settings.params[2] = sp
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

"""

"""
function params_describe(req::HTTP.Request)
    return "Describe"
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
    return "HelpPage"
end

"""

"""
function params_labels(req::HTTP.Request)
    return "Labels"
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
    submit_job( prs )
    return "Submit"
end

"""

"""
function run_status(req::HTTP.Request)
    return "Status"
end

"""

"""
function run_abort(req::HTTP.Request)
    return "Abort"
end


"""

"""
function run_statuses(req::HTTP.Request)
    return HTTP.Response(
        200,
        ["Content-Type" => "text/markdown"],
        body=STBOutput.DUMP_FILE_DESCRIPTION )

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
    @show MicrosimAPI.SESSIONS    
    return HTTP.Response(
        200,
        ["Content-Type" => "text/markdown"],
        body=STBOutput.DUMP_FILE_DESCRIPTION )
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
    return "Labels"
end

"""

"""
function output_fetch_item(req::HTTP.Request)

    return "Fetch Item"
end


@get "/scotben/output/items" output_items
@put "/scotben/output/items" output_items
@get "/scotben/output/phunpak" output_phunpak
@put "/scotben/output/phunpak" output_phunpak
@get "/scotben/output/labels" output_labels
@put "/scotben/output/labels" output_labels
@get "/scotben/output/fetch/item" output_fetch_item
@put "/scotben/output/fetch/item" output_fetch_item