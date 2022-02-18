u, v, w = Vertex(), Vertex(), Vertex()
a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]
f1, f2 = Face(), Face()

u.edge, v.edge, w.edge = a1, b1, c1

a1.dest, b1.dest, c1.dest = u, v, w
a2.dest, b2.dest, c2.dest = w, u, v

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

@testset "Edges - vertex" begin
    el = collect(edges(u))
    @test el == [a1, b2]

    el = collect(edges(u, reverse=true))
    @test el == [a1, b2]
end

@testset "Edges - face" begin
    el = collect(edges(f1))
    @test el == [a1, b1, c1]

    el = collect(edges(f1, reverse=true))
    @test el == [a1, c1, b1]
end

@testset "Vertices - edge" begin
    vl = collect(vertices(a1))
    @test vl == [u, w]

    vl = collect(vertices(a1, reverse=true))
    @test vl == [w, u]
end

@testset "Vertices - face" begin
    vl = collect(vertices(f1))
    @test vl == [u, v, w]

    vl = collect(vertices(f1, reverse=true))
    @test vl == [u, w, v]
end

@testset "Faces - edge" begin
    fl = collect(faces(a1))
    @test fl == [f1, f2]

    fl = collect(faces(a1, reverse=true))
    @test fl == [f2, f1]
end

@testset "Faces - vertex" begin
    fl = collect(faces(u))
    @test fl == [f1, f2]

    fl = collect(faces(u, reverse=true))
    @test fl == [f1, f2]
end

@testset "Faces - face" begin
    fl = collect(faces(f1))
    @test fl == [f2, f2, f2]

    fl = collect(faces(f1, reverse=true))
    @test fl == [f2, f2, f2]
end
