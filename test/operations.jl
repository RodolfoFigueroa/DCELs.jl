@testset "Outer face" begin
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
    f = find_outer_face(tess)
    @test f == f2
end

@testset "Fix faces" begin
    @testset "Error" begin
        tess = Tessellation()
        f = Face()
        push!(tess.faces, f)
        @test_throws GeometryError fix_faces!(tess)
    end

    @testset "Results" begin
        tess = Tessellation()

        u, v, w = Vertex(1, 0), Vertex(0, 1), Vertex(-1, 0)
        a1, a2, b1, b2, c1, c2 = [Edge() for _ in 1:6]

        push!(tess.vertices, u, v, w)
        push!(tess.edges, a1, a2, b1, b2, c1, c2)

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

        fix_faces!(tess)
        @test a1.face == b1.face == c1.face
        @test a2.face == b2.face == c2.face
    end
end
