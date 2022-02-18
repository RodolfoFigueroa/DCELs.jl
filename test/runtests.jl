using DCELs
using Test

@testset "Unit tests" begin
    include("connecting.jl")
    include("errors.jl")
    include("geometry.jl")
    include("iterators.jl")
    include("printing.jl")
    include("sorting.jl")
    include("squeezing.jl")
end
