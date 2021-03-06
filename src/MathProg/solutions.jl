# new structures for solutions

# Constructors for Primal & Dual Solutions
const PrimalSolution{M} = Solution{M, VarId, Float64}
const DualSolution{M} = Solution{M, ConstrId, Float64}

function PrimalSolution(form::M) where {M}
    return Solution{M,VarId,Float64}(form)
end

function PrimalSolution(
    form::M, decisions::Vector{De}, vals::Vector{Va}, val::Float64
) where {M<:AbstractFormulation,De,Va}
    return Solution{M,De,Va}(form, decisions, vals, val)
end

function DualSolution(form::M) where {M}
    return Solution{M,ConstrId,Float64}(form)
end

function DualSolution(
    form::M, decisions::Vector{De}, vals::Vector{Va}, val::Float64
) where {M<:AbstractFormulation,De,Va}
    return Solution{M,De,Va}(form, decisions, vals, val)
end

function Base.isinteger(sol::Solution)
    for (vc_id, val) in sol
        #if getperenekind(sol.model, vc_id) != Continuous
            !isinteger(val) && return false
        #end
    end
    return true
end

isfractional(sol::Solution) = !Base.isinteger(sol)

function contains(sol::PrimalSolution, f::Function)
    for (varid, val) in sol
        f(varid) && return true
    end
    return false
end

function contains(sol::DualSolution, f::Function)
    for (constrid, val) in sol
        f(constrid) && return true
    end
    return false
end

function Base.print(io::IO, form::AbstractFormulation, sol::Solution)
    println(io, "Solution")
    for (id, val) in sol
        println(io, getname(form, id), " = ", val)
    end
    return
end