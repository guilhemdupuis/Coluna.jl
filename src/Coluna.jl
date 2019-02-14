module Coluna

import Parameters.@with_kw
import HighLevelTypes.@hl
import HighLevelTypes.tuplejoin
import MathOptInterface
import MathOptInterface.Utilities
import DataStructures
import GLPK
import JuMP

using Base.CoreLogging
import TimerOutputs
import TimerOutputs.@timeit

global const Float = Float64
global const MOI = MathOptInterface
global const MOIU = MathOptInterface.Utilities
global const DS = DataStructures
global __initial_solve_time = 0.0

# We should not need to import this here
@MOIU.model(ModelForCachingOptimizer,
        (MOI.ZeroOne, MOI.Integer),
        (MOI.EqualTo, MOI.GreaterThan, MOI.LessThan, MOI.Interval),
        (),
        (),
        (MOI.SingleVariable,),
        (MOI.ScalarAffineFunction,),
        (),
        ())

# include("/Users/vitornesello/.julia/dev/SimpleDebugger/src/SimpleDebugger.jl")

include("parameters.jl")
include("utils.jl")
include("varconstr.jl")
include("variables.jl")
include("constraints.jl")
include("solution.jl")
include("mastercolumn.jl")
include("problem.jl")
include("node.jl")
include("nodealgs/algsetupnode.jl")
include("nodealgs/algpreprocessnode.jl")
include("nodealgs/algevalnode.jl")
include("nodealgs/algprimalheurinnode.jl")
include("nodealgs/alggeneratechildrennodes.jl")
include("model.jl")


##### Wrapper functions
include("MOIWrapper.jl")
include("decomposition.jl")

end # module
