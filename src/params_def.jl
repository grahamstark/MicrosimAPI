#=


=#

@enum CheckLevel error warn

struct OneCheck{T} where T <: Number
    min :: T
    max :: T
    next :: T
    check :: CheckLevel
    precision :: Int
end

struct ArrayGroup{T} where T <: Number
    maxsize :: Int
    params :: 
end