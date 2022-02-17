using DCELs
using Test

@testset "Unit tests" begin
    include("geometry.jl")
    include("printing.jl")
    include("errors.jl")
    include("iterators.jl")
    include("connectivity.jl")
end
