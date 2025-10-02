using JSON3
using Parameters

it = JSON3.read("""
{
    "logicaltypes":{
        "taxband":{
            "units":"annual",
            "editinfo":{"min": 0, "max":100000}
        },
        "taxrate":{
            "units":"percent",
            "editinfo":{"min": 0, "max":100}
        },
        "taxallowance":{
            "units":"annual",
            "editinfo":{"min": 0, "max":1000000}
        }
    },
    "params":{
        "personal_allowance":{
            "units": "year",
            "type": "real",
            "editinfo":{"logicaltype": "taxallowance"}
        },
        "ratebands": {
            "rates": {
                "units":"percent",
                "type":"real",
                "editinfo":{"min": 0, "max":100}
            },
            "bands":{
                "logicaltype":"taxband" 
            }
        }
    }
}

""")

it2 = """



"""

@enum UprateType dont_uprate rooker_wise standard_uprate
@enum DisplayType hidden normal_display password_display label_only
@enum checkType dont_check warn halt
@enum Units timeless day_period week_period month_period year_period  percent_unit level_unit counts_unit money_unit rate_unit no_unit
@with_kw struct EditInfo
    min = 0
    max = 99999999
    next = 0
    uprate = normal_uprate
    display = normal_display
    check = halt
end

const ALLOWANCE_INFO = EditInfo(
    0, 999999999, 10, rooker_wise, normal_display
)

@with_kw struct ParameterInfo
    name = ""
    unit = no_unit 
    label = ""
    journalese = ""
    description = ""
    edit_info = EditInfo()
end

@with_kw struct ArrayGroup
    name = ""
    unit = no_unit 
    label = ""
    journalese = ""
    description = ""
    topset = false
    array_length = -1
    variables = Vector{ParameterInfo}(undef,0)    
end

it = (;
    name = "",
    label = "",
    journalese = "",
    description = "",
    reference = "",
    ratebands = ArrayGroup( )
    allowance = ParameterInfo( "allowance",year_period,"Tax Allowance","","")

)

# not needed?
@with_kw mutable struct ParameterSystem
    name = ""
    label = ""
    journalese = ""
    description = ""
    reference = ""
    variables = Dict{String,ParameterInfo}()
    subsystems = Dict{String,ParameterSystem}()
end
