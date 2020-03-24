function _welcome_message()
    welcome = """
    Coluna
    Version 0.3 - https://github.com/atoptima/Coluna.jl
    """
    print(welcome)
end

function _adjust_params(params, init_pb)
    if params.global_art_var_cost === nothing
        if init_pb != Inf && init_pb != -Inf
            exp = ceil(log(10, init_pb))
            params.global_art_var_cost = 10^(exp + 1)
        else
            params.global_art_var_cost = 100000.0
            msg = """
            No initial primal bound and no cost for global artificial variables.
            Cost of global artificial variables set to 100000.0
            """
            @warn(msg)
        end
    end
    if params.local_art_var_cost === nothing
        if init_pb != Inf && init_pb != -Inf
            exp = ceil(log(10, init_pb))
            params.local_art_var_cost = 10^exp
        else
            params.local_art_var_cost = 10000.0
            msg = """
            No initial primal bound and no cost for local artificial variables.
            Cost of local artificial variables set to 10000.0
            """
            @warn(msg)
        end
    end
    return
end

"""
Starting point of the solver.
"""
function optimize!(prob::MathProg.Problem, annotations::MathProg.Annotations, params::Params)
    _welcome_message()

    # Adjust parameters
    ## Retrieve initial bounds on the objective given by the user
    init_pb = get_initial_primal_bound(prob)
    init_db = get_initial_dual_bound(prob)
    _adjust_params(params, init_pb)

    _set_global_params(params)

    # Apply decomposition
    prob.re_formulation = nothing
    reformulate!(prob, annotations)

    println("\e[41m ************************** \e[00m")
    @show prob.original_formulation
    println("\e[41m ************************** \e[00m")
    @show prob.re_formulation.master
    println("\e[41m ************************** \e[00m")
    @show prob.re_formulation.dw_pricing_subprs
    println("\e[41m ************************** \e[00m")

    # Coluna ready to start
    _globals_.initial_solve_time = time()
    @info "Coluna ready to start."
    @info _params_

    relax_integrality!(prob.re_formulation.master) # TODO : remove

    TO.@timeit _to "Coluna" begin
        opt_result = optimize!(
            prob.re_formulation, params.solver, init_pb, init_db
        )
    end
    println(_to)
    TO.reset_timer!(_to)
    @logmsg LogLevel(1) "Terminated"
    @logmsg LogLevel(1) string("Primal bound: ", get_ip_primal_bound(opt_result))
    @logmsg LogLevel(1) string("Dual bound: ", get_ip_dual_bound(opt_result))
    return opt_result
end

"""
Solve a reformulation
"""
function optimize!(
    reform::MathProg.Reformulation, algorithm::Algorithm.AbstractOptimizationAlgorithm,
    initial_primal_bound, initial_dual_bound
)
    slaves = Vector{Tuple{AbstractFormulation, Type{<:ColunaBase.AbstractAlgorithm}}}()
    push!(slaves,(reform, typeof(algorithm)))
    Algorithm.getslavealgorithms!(algorithm, reform, slaves)

    for (form, algotype) in slaves
        MathProg.initstorage(form, Algorithm.getstoragetype(algotype))
    end

    master = getmaster(reform)
    init_result = OptimizationState(
        master,
        ip_primal_bound = initial_primal_bound,
        ip_dual_bound = initial_dual_bound,
        lp_dual_bound = initial_dual_bound
    )

    output = run!(algorithm, reform, Algorithm.NewOptimizationInput(init_result))
    opt_result = Algorithm.getresult(output)
    
    result = OptimizationState(
        master, 
        feasibility_status = getfeasibilitystatus(opt_result),
        termination_status = getterminationstatus(opt_result),
        ip_primal_bound = get_ip_primal_bound(opt_result),
        ip_dual_bound = get_ip_dual_bound(opt_result),
        lp_primal_bound = get_lp_primal_bound(opt_result),
        lp_dual_bound = get_lp_dual_bound(opt_result)
    )

    ip_primal_sols = get_ip_primal_sols(opt_result)
    if ip_primal_sols !== nothing  
        for sol in ip_primal_sols
            add_ip_primal_sol!(result, proj_cols_on_rep(sol, master))
        end
    end
    return result
end
