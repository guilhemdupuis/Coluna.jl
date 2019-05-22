struct MasterIpHeuristic <: AbstractAlgorithm end

struct MasterIpHeuristicData
    incumbents::Incumbents
end
MasterIpHeuristicData(S::Type{<:AbstractObjSense}) = MasterIpHeuristicData(Incumbents(S))

struct MasterIpHeuristicRecord <: AbstractAlgorithmRecord
    incumbents::Incumbents
end

function prepare!(::Type{MasterIpHeuristic}, form, node, strategy_rec, params)
    @logmsg LogLevel(-1) "Prepare MasterIpHeuristic."
    return
end

function run!(::Type{MasterIpHeuristic}, form, node, strategy_rec, params)
    @logmsg LogLevel(1) "Applying Master IP heuristic"
    master = getmaster(form)
    algorithm_data = MasterIpHeuristicData(getobjsense(master))
    enforce_integrality!(master)
    status, value, p_sols, d_sol = optimize!(master)
    relax_integrality!(master)
    set_ip_primal_sol!(algorithm_data.incumbents, p_sols[1])
    @logmsg LogLevel(1) string("Found primal solution of ", get_ip_primal_bound(algorithm_data.incumbents))
    @logmsg LogLevel(-3) get_ip_primal_sol(algorithm_data.incumbents)
    # Record data 
    set_ip_primal_sol!(node.incumbents, get_ip_primal_sol(algorithm_data.incumbents))
    return MasterIpHeuristicRecord(algorithm_data.incumbents)
end