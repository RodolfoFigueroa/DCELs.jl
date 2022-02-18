import DCELs._pseudoangle, DCELs._pseudoangle_unsigned, DCELs._is_sorted_ccw

@testset "Pseudoangle" begin
    @test _pseudoangle(1, 0) == 0
    @test _pseudoangle(1, 1) == 0.5
    @test _pseudoangle(0, 1) == 1
    @test _pseudoangle(-1, 1) == 1.5
    @test _pseudoangle(-1, 0) == 2
    @test _pseudoangle(-1, -1) == -1.5
    @test _pseudoangle(0, -1) == -1
    @test _pseudoangle(1, -1) == -0.5
end

@testset "Pseudoangle unsigned" begin
    @test _pseudoangle_unsigned(1, 0) == 0
    @test _pseudoangle_unsigned(1, 1) == 0.5
    @test _pseudoangle_unsigned(0, 1) == 1
    @test _pseudoangle_unsigned(-1, 1) == 1.5
    @test _pseudoangle_unsigned(-1, 0) == 2
    @test _pseudoangle_unsigned(-1, -1) == 2.5
    @test _pseudoangle_unsigned(0, -1) == 3
    @test _pseudoangle_unsigned(1, -1) == 3.5
end

@testset "Sorting" begin
    u = Vertex(1, 0)
    v = Vertex(0, 1)
    w = Vertex(-1, 0)
    center = Vertex(0, 0)

    @test _is_sorted_ccw(u, v, w, center)
    @test !_is_sorted_ccw(u, w, v, center)
end
