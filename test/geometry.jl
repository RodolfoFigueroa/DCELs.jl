using DCELs

@testset "Vertex" begin
    v = Vertex()
    @test v.id[1] == 'V'
    @test isnan(v.x)
    @test isnan(v.y)
    @test v.edge === nothing

    v = Vertex(1, -1)
    @test v.id[1] == 'V'
    @test v.x == 1
    @test v.y == -1
    @test v.edge === nothing
end

@testset "Edge" begin
    h = Edge()
    @test h.id[1] == 'E'
    @test h.next === nothing
    @test h.prev === nothing
    @test h.twin === nothing
    @test h.dest === nothing
    @test h.face === nothing
end

@testset "Face" begin
    f = Face()
    @test f.id[1] == 'F'
    @test f.edge === nothing
end

@testset "Tessellation" begin
    tess = Tessellation()
    @test tess.vertices isa AbstractSet{Vertex}
    @test tess.edges isa AbstractSet{Edge}
    @test tess.faces isa AbstractSet{Face}
    @test isempty(tess.vertices)
    @test isempty(tess.edges)
    @test isempty(tess.faces)
end

@testset "Arithmetic" begin
    u, v = Vertex(0, 0), Vertex(1, 1)
    a, b = u + v, u - v
    @test a.x == 1 && a.y == 1
    @test b.x == -1 && b.y == -1
end
