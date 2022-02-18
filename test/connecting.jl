import DCELs._connect_vertices!, DCELs._split_face!
import DCELs._connect_manual!, DCELs._connect_automatic!

@testset "Connecting - primitive" begin
    u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
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

    z = Vertex(2, 0)

    # No splitting
    h1 = _connect_vertices!(u, z)
    h2 = h1.twin

    @test h1.next == h2
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h1

    @test h1.face == h2.face == f2

    # Splitting
    h3, f_del = _split_face!(z, v)
    h4 = h3.twin

    @test h1.next == h3
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h4
    @test h3.next == b2
    @test h3.prev == h1
    @test h4.next == h2
    @test h4.prev == c2

    @test h1.face == h3.face == b2.face
    @test h4.face == h2.face == a2.face == c2.face

    @test f_del == f2
end

@testset "Connecting - manual" begin
    tess = Tessellation()

    u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
    a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]
    f1, f2 = Face(), Face()

    push!(tess.vertices, u, v, w)
    push!(tess.edges, a1, a2, b1, b2, c1, c2)
    push!(tess.faces, f1, f2)

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

    z = Vertex(2, 0)

    # No splitting
    h1 = _connect_manual!(tess, u, z, false)
    h2 = h1.twin

    @test h1.next == h2
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h1

    @test h1.face == h2.face == f2

    # Splitting
    h3 = _connect_manual!(tess, z, v, true)
    h4 = h3.twin

    @test h1.next == h3
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h4
    @test h3.next == b2
    @test h3.prev == h1
    @test h4.next == h2
    @test h4.prev == c2

    @test h1.face == h3.face == b2.face
    @test h4.face == h2.face == a2.face == c2.face
end

@testset "Connecting - automatic" begin
    tess = Tessellation()

    u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
    a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]
    f1, f2 = Face(), Face()

    push!(tess.vertices, u, v, w)
    push!(tess.edges, a1, a2, b1, b2, c1, c2)
    push!(tess.faces, f1, f2)

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

    z = Vertex(2, 0)

    # No splitting
    h1 = _connect_automatic!(tess, u, z)
    h2 = h1.twin

    @test h1.next == h2
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h1

    @test h1.face == h2.face == f2

    # Splitting
    h3 = _connect_automatic!(tess, z, v)
    h4 = h3.twin

    @test h1.next == h3
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h4
    @test h3.next == b2
    @test h3.prev == h1
    @test h4.next == h2
    @test h4.prev == c2

    @test h1.face == h3.face == b2.face
    @test h4.face == h2.face == a2.face == c2.face
end

@testset "Connecting - final" begin
    tess = Tessellation()

    u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
    a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]
    f1, f2 = Face(), Face()

    push!(tess.vertices, u, v, w)
    push!(tess.edges, a1, a2, b1, b2, c1, c2)
    push!(tess.faces, f1, f2)

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

    z = Vertex(2, 0)

    # No splitting
    h1 = connect(tess, u, z)
    h2 = h1.twin

    @test h1.next == h2
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h1

    @test h1.face == h2.face == f2

    # Splitting
    h3 = connect(tess, z, v, split=true)
    h4 = h3.twin

    @test h1.next == h3
    @test h1.prev == b2
    @test h2.next == a2
    @test h2.prev == h4
    @test h3.next == b2
    @test h3.prev == h1
    @test h4.next == h2
    @test h4.prev == c2

    @test h1.face == h3.face == b2.face
    @test h4.face == h2.face == a2.face == c2.face
end
