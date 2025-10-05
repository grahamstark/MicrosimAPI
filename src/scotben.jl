#

#

@with_kw mutable struct SBRunData
    owner::String
    thing::String
end

SB_RUNS = Dict{String,SBRunData}()

module Params
    using HTTP
    """

    """
    function list_available(req::HTTP.Request)
        return "List Available"
    end

    """

    """
    function initialise(req::HTTP.Request)
        return "Initialise"
    end

    """

    """
    function set(req::HTTP.Request)
        return "Set"
    end

    """

    """
    function validate(req::HTTP.Request)
        return "Validate"
    end

    """

    """
    function describe(req::HTTP.Request)
        return "Describe"
    end

    """

    """
    function subsys(req::HTTP.Request)
        @show "/scotben/params/subsys"
        return "Subsys"
    end

    """

    """
    function helppage( req::HTTP.Request )
        return "HelpPage"
    end

    """

    """
    function labels(req::HTTP.Request)
        return "Labels"
    end

end # module Params


@get "/scotben/params/list-available" Params.list_available
@put "/scotben/params/list-available" Params.list_available
@get "/scotben/params/initialise/" Params.initialise
@put "/scotben/params/initialise/" Params.initialise
@get "/scotben/params/set" Params.set
@put "/scotben/params/set" Params.set
@get "/scotben/params/validate" Params.validate
@put "/scotben/params/validate" Params.validate
@get "/scotben/params/describe" Params.describe 
@put "/scotben/params/describe" Params.describe 
@get "/scotben/params/subsys" Params.subsys
@put "/scotben/params/subsys" Params.subsys
@get "/scotben/params/helppage" Params.helppage
@put "/scotben/params/helppage" Params.helppage
@get "/scotben/params/labels" Params.labels
@put "/scotben/params/labels" Params.labels

#=
or /params@get "/scotben/[subsys]/set ... for individual pages" function(req::HTTP.Request)

end
=#

module Settings
    using HTTP

    """

    """
    function set(req::HTTP.Request)
        return "Set Settings"
    end

    """

    """
    function validate(req::HTTP.Request)
        return "Validate Settings"
    end

end # Module Settings

@get "/scotben/settings/set" Settings.set
@put "/scotben/settings/set" Settings.set
@get "/scotben/settings/validate" Settings.validate
@put "/scotben/settings/validate" Settings.validate

module Run
using HTTP
    """

    """
    function submit(req::HTTP.Request)
        return "Submit"
    end

    """

    """
    function status(req::HTTP.Request)
        return "Status"
    end

    """

    """
    function abort(req::HTTP.Request)
        return "Abort"
    end

end # module Run

@get "/scotben/run/status" Run.status
@put "/scotben/run/status" Run.status
@get "/scotben/run/submit" Run.submit
@put "/scotben/run/submit" Run.submit
@get "/scotben/run/abort" Run.abort
@put "/scotben/run/abort" Run.abort

module Output
using HTTP
using MicrosimAPI

    """

    """
    function items(req::HTTP.Request)
        @show MicrosimAPI.SESSIONS
        return "Items"
    end

    """

    """
    function phunpak(req::HTTP.Request)
        return "Phunpak"
    end

    """

    """
    function labels(req::HTTP.Request)
        return "Labels"
    end

    """

    """
    function fetch_item(req::HTTP.Request)
        return "Fetch Item"
    end

end # module Output

@get "/scotben/output/items" Output.items
@put "/scotben/output/items" Output.items
@get "/scotben/output/phunpak" Output.phunpak
@put "/scotben/output/phunpak" Output.phunpak
@get "/scotben/output/labels" Output.labels
@put "/scotben/output/labels" Output.labels
@get "/scotben/output/fetch/item" Output.fetch_item
@put "/scotben/output/fetch/item" Output.fetch_item