u, v, w = Vertex(), Vertex(), Vertex()
a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]
f1, f2 = Face(), Face()

a1.twin, a2.twin = a2, a1
b1.twin, b2.twin = b2, b1
c1.twin, c2.twin = c2, c1

a1.next, b1.next, c1.next = b1, c1, a1
a1.prev, b1.prev, c1.prev = c1, a1, b1

a2.next, b2.next, c2.next = c2, a2, b2
a2.prev, b2.prev, c2.prev = b2, c2, a2

a1.face = b1.face = c1.face = f1
a2.face = b2.face = c2.face = f2

f1.edge, f2.edge = a1, a2

@testset "Edge path" begin
    el = collect(edge_path(a1, b1))
    @test el == [a1]

    el = collect(edge_path(a1, c1))
    @test el == [a1, b1]

    el = collect(edge_path(a1, c1, reverse=true))
    @test el == [a1]

    el = collect(edge_path(a1, b1, reverse=true))
    @test el == [a1, c1]
end

@testset "Edge loop" begin
    el = collect(edge_loop(a1))
    @test el == [a1, b1, c1]

    el = collect(edge_loop(a1, reverse=true))
    @test el == [a1, c1, b1]
end
