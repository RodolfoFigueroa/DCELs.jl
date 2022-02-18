import DCELs.squeeze_edge

@testset "Squeezing - empty" begin
    u, v = Vertex(0, 0), Vertex(1, 0)
    a1, a2 = Edge(), Edge()
    a1.twin, a2.twin = a2, a1
    a1.dest, a2.dest = u, v

    @test squeeze_edge(u, a1) == a1
end

@testset "Squeezing - line" begin
    u, v = Vertex(0, 0), Vertex(1, 0)
    a1, a2 = Edge(), Edge()

    a1.twin, a2.twin = a2, a1
    a1.prev, a2.prev = a2, a1
    a1.next, a2.next = a2, a1
    a1.dest, a2.dest = u, v

    u.edge, v.edge = a1, a2

    z = Vertex(2, 0)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = v, z
    @test squeeze_edge(v, h1) == a2
end

@testset "Squeezing - cross" begin
    u, v, w, x, c = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0), Vertex(0, -1), Vertex(0, 0)
    a1, a2, b1, b2, c1, c2, d1, d2 = [Edge() for _ in 1:8]

    a1.twin, a2.twin = a2, a1
    b1.twin, b2.twin = b2, b1
    c1.twin, c2.twin = c2, c1
    d1.twin, d2.twin = d2, d1

    a1.dest, a2.dest = u, c
    b1.dest, b2.dest = v, c
    c1.dest, c2.dest = w, c
    d1.dest, d2.dest = x, c

    a1.prev, a2.prev = b2, a1
    b1.prev, b2.prev = c2, b1
    c1.prev, c2.prev = d2, c1
    d1.prev, d2.prev = a2, d1

    a1.next, a2.next = a2, d1
    b1.next, b2.next = b2, a1
    c1.next, c2.next = c2, b1
    d1.next, d2.next = d2, c1

    u.edge, v.edge, w.edge, x.edge = a1, b1, c1, d1
    c.edge = a2

    z = Vertex(1, -1)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = c, z
    @test squeeze_edge(c, h1) == a2
end

@testset "Squeezing - triangle" begin
    u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
    a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]

    u.edge, v.edge, w.edge = a1, b1, c1

    a1.twin, a2.twin = a2, a1
    b1.twin, b2.twin = b2, b1
    c1.twin, c2.twin = c2, c1

    a1.dest, b1.dest, c1.dest = u, v, w
    a2.dest, b2.dest, c2.dest = w, u, v

    a1.next, b1.next, c1.next = b1, c1, a1
    a1.prev, b1.prev, c1.prev = c1, a1, b1

    a2.next, b2.next, c2.next = c2, a2, b2
    a2.prev, b2.prev, c2.prev = b2, c2, a2

    x = Vertex(2, 0)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = u, x
    @test squeeze_edge(u, h1) == b2

    x = Vertex(0, 0.5)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = u, x
    @test squeeze_edge(u, h1) == a1
end
