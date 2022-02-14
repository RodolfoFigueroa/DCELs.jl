@testset "Vertex" begin
    v = Vertex(1, -1)
    vr = repr(v)
    @test occursin("ID: $(v.id)\n", vr)
    @test occursin("Coords: ($(v.x), $(v.y))\n", vr)
    @test occursin("Edge: $(v.edge)\n", vr)
end

@testset "Edge" begin
    e = Edge()
    er = repr(e)
    @test occursin("ID: $(e.id)\n", er)
    @test occursin("Next: $(e.next)\n", er)
    @test occursin("Prev: $(e.prev)\n", er)
    @test occursin("Twin: $(e.twin)\n", er)
    @test occursin("Dest: $(e.dest)\n", er)
    @test occursin("Face: $(e.face)\n", er)
end

@testset "Face" begin
    f = Face()
    fr = repr(f)
    @test occursin("ID: $(f.id)\n", fr)
    @test occursin("Edge: $(f.edge)\n", fr)
end

@testset "Tessellation" begin
    tess = Tessellation()
    tr = repr(tess)
    @test occursin("$(length(tess.vertices)) vertices\n", tr)
    @test occursin("$(length(tess.edges)) edges\n", tr)
    @test occursin("$(length(tess.faces)) faces\n", tr)
end
