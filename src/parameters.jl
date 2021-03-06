Base.@kwdef mutable struct Params
    tol::Float64 = 1e-8 # if - ϵ_tol < val < ϵ_tol, we consider val = 0
    tol_digits::Int = 8 # because round(val, digits = n) where n is from 1e-n
    cut_up::Float64 = Inf
    cut_lo::Float64 = -Inf
    global_art_var_cost::Union{Float64, Nothing} = nothing
    local_art_var_cost::Union{Float64, Nothing} = nothing
    force_copy_names::Bool = false
    solver = nothing
    max_nb_processes::Int = 100
    max_nb_formulations::Int = 100
end

update_field!(f_v::Tuple{Symbol,Any}) = setfield!(_params_, f_v[1], f_v[2])
_set_global_params(p::Params) = map(update_field!, [(f, getfield(p, f)) for f in fieldnames(Params)])
