module DCELs

using RecipesBase
using ResumableFunctions
using UUIDs

export AbstractGeometry, AbstractVertex, AbstractEdge, AbstractFace, AbstractTessellation
export Vertex, Edge, Face, Tessellation
export edge_path, edge_loop
export vertices, edges, faces
export connect
export find_outer_face
export fix_faces!
export validate_geometry

#= Abstract Types =#
"""
    AbstractGeometry

Abstract supertype for all geometry objects.
"""
abstract type AbstractGeometry end

"""
    AbstractVertex

Abstract supertype for all vertex objects.
"""
abstract type AbstractVertex <: AbstractGeometry end

"""
    AbstractEdge

Abstract supertype for all edge objects.
"""
abstract type AbstractEdge <: AbstractGeometry end

"""
    AbstractFace

Abstract supertype for all face objects.
"""
abstract type AbstractFace <: AbstractGeometry end

"""
    AbstractTessellation

Abstract supertype for all tessellations.
"""
abstract type AbstractTessellation <: AbstractGeometry end


#= Basic types =#
@inline sid(s::String) = s * "-" * string(uuid4())

"""
    Edge <: AbstractEdge

Edge between two vertices.

# Fields
- `id::String`: Unique ID.
- `next`::Union{Edge, Nothing}`: Next edge alongside the corresponding face
(counterclockwise).
- `prev`::Union{Edge, Nothing}`: Previous edge alongside the corresponding face
(counterclockwise).
- `twin`::Union{Edge, Nothing}`: Twin edge.
- `prev`: Vertex that the edge points to.
- `face`: Face bounded by the edge.
"""
mutable struct Edge <: AbstractEdge
    id::String
    next::Union{Edge, Nothing}
    prev::Union{Edge, Nothing}
    twin::Union{Edge, Nothing}
    dest
    face
end

"""
    Edge()

Create an `Edge` with a random UUID4 ID prefixed by "E-", and all other fields set to `nothing`.
"""
Edge() = Edge(sid("E"), nothing, nothing, nothing, nothing, nothing)

"""
    Vertex <: AbstractVertex

2D point in the plane.

# Fields
- `id::String`: Unique ID.
- `x::Real`: x coordinate.
- `y::Real`: y coordinate.
- `edge::Union{Edge, Nothing}`: Arbitrary edge that points towards this vertex.
"""
mutable struct Vertex <: AbstractVertex
    id::String
    x::Real
    y::Real
    edge::Union{Edge, Nothing}
end

"""
    Vertex()

Create a `Vertex` with a random UUID4 ID prefixed by "V-", with coordinates `(NaN, NaN)`,
and `edge=nothing`.
"""
Vertex() = Vertex(sid("V"), NaN, NaN, nothing)

"""
    Vertex(x::Real, y::Real)

Create a `Vertex` with a random UUID4 ID prefixed by "V-", with coordinates `(x, y)`,
and `edge=nothing`.
"""
Vertex(x::Real, y::Real) = Vertex(sid("V"), x, y, nothing)

"""
    Face <: AbstractFace

Area in the plane bounded by edges.

# Fields
- `id::String`: Unique ID.
- `edge::Union{Edge, Nothing}`: Arbitrary edge that bounds this face.
"""
mutable struct Face <: AbstractFace
    id::String
    edge::Union{Edge, Nothing}
end

"""
    Face()

Create a `Face` with a random UUID4 ID prefixed by "F-", and `edge=nothing`.
"""
Face() = Face(sid("F"), nothing)

"""
    Tessellation <: AbstractTessellation

Collection of vertices, edges and faces.

# Fields
- `edges::Set{Edge}`: Set of edges belonging to the tessellation.
- `vertices::Set{Vertex}`: Set of vertices.
- `faces::Set{Face}`: Set of faces.
"""
mutable struct Tessellation <: AbstractTessellation
    edges::Set{Edge}
    vertices::Set{Vertex}
    faces::Set{Face}
end

"""
    Tessellation()

Create a `Tessellation` with no edges, vertices or faces.
"""
Tessellation() = Tessellation(Set(), Set(), Set())


#= Exceptions =#
"""
    GeometryError(msg::String)

Geometry is inconsistent.
"""
mutable struct GeometryError <: Exception
    msg::String
end


#= Printing =#
function Base.show(io::IO, edge::Edge)
    print(io,
    """
    ID: $(edge.id)
    Next: $(edge.next === nothing ? nothing : edge.next.id)
    Prev: $(edge.prev === nothing ? nothing : edge.prev.id)
    Twin: $(edge.twin === nothing ? nothing : edge.twin.id)
    Dest: $(edge.dest === nothing ? nothing : edge.dest.id)
    Face: $(edge.face === nothing ? nothing : edge.face.id)
    """
    )
end

function Base.show(io::IO, vertex::Vertex)
    print(io,
    """
    ID: $(vertex.id)
    Coords: ($(vertex.x), $(vertex.y))
    Edge: $(vertex.edge === nothing ? nothing : vertex.edge.id)
    """
    )
end

function Base.show(io::IO, face::Face)
    print(io,
    """
    ID: $(face.id)
    Edge: $(face.edge === nothing ? nothing : face.edge.id)
    """
    )
end

function Base.show(io::IO, tess::Tessellation)
    print(io,
    """
    Tessellation with:
    $(length(tess.vertices)) vertices
    $(length(tess.edges)) edges
    $(length(tess.faces)) faces
    """
    )
end

function Base.showerror(io::IO, e::GeometryError)
    print(io,
    """
    GeometryError\n$(e.msg)
    """
    )
end


#= Algebra =#
Base.:+(a::T, b::T) where {T <: AbstractVertex} = T(a.x+b.x, a.y+b.y)
Base.:-(a::T, b::T) where {T <: AbstractVertex} = T(a.x-b.x, a.y-b.y)


#= Iterators =#
@doc """
    edge_path(start::AbstractEdge, finish::AbstractEdge; reverse::Bool=false)

Yield all edges in the list `[start, start.next, start.next.next, ..., finish.prev]`. If
`start` and `finish` do not bound the same face, this will never terminate.

If `reverse=true`, the order will be `[start, start.prev, ..., finish.next]`.
"""
edge_path(start::AbstractEdge, finish::AbstractEdge; reverse::Bool=false)

@resumable function edge_path(start::AbstractEdge, finish::AbstractEdge; reverse::Bool=false)
    @yield start
    edge = start
    if reverse
        while edge.prev != finish
            edge = edge.prev
            @yield edge
        end
    else
        while edge.next != finish
            edge = edge.next
            @yield edge
        end
    end
end

@doc """
    edge_loop(start::AbstractEdge; reverse::Bool=false)

Yield all edges in the list `[start, start.next, start.next.next, ..., start.prev]. If
`reverse=true`, this will instead be `[start, start.prev, ..., start.next]`.
"""
edge_loop(start::AbstractEdge; reverse::Bool=false)

@resumable function edge_loop(start::AbstractEdge; reverse::Bool=false)
    for edge in edge_path(start, start, reverse=reverse)
        @yield edge
    end
end


@doc """
    edges(vertex::AbstractVertex; reverse::Bool=false)

Yield all edges that point to `vertex`, in counterclockwise order
(or clockwise if `reverse=true`).
"""
edges(vertex::AbstractVertex; reverse::Bool=false)

@resumable function edges(vertex::AbstractVertex; reverse::Bool=false)
    start = edge = vertex.edge
    @yield start
    if reverse
        while edge.next.twin != start
            edge = edge.next.twin
            @yield edge
        end
    else
        while edge.twin.prev != start
            edge = edge.twin.prev
            @yield edge
        end
    end
end


@doc """
    edges(face::AbstractFace; reverse::Bool=false)

Yield all edges that bound `face`, in counterclockwise order
(or clockwise if `reverse=true`).
"""
edges(face::AbstractFace; reverse::Bool=false)

@resumable function edges(face::AbstractFace; reverse::Bool=false)
    for edge in edge_loop(face.edge, reverse=reverse)
        @yield edge
    end
end


@doc """
    vertices(edge::AbstractEdge; reverse::Bool=false)

Yield both endpoints of `edge`, starting at the destination (or origin if `reverse=true`).
"""
vertices(edge::AbstractEdge; reverse::Bool=false)

@resumable function vertices(edge::AbstractEdge; reverse::Bool=false)
    if reverse
        @yield edge.twin.dest
        @yield edge.dest
    else
        @yield edge.dest
        @yield edge.twin.dest
    end
end


@doc """
    vertices(face::AbstractFace; reverse::Bool=false)

Yield all vertices that touch `face`, in counterclockwise order
(or clockwise if `reverse=true`).
"""
vertices(face::AbstractFace; reverse::Bool=false)

@resumable function vertices(face::AbstractFace; reverse::Bool=false)
    for edge in edges(face, reverse=reverse)
        @yield edge.dest
    end
end


@doc """
    faces(edge::AbstractEdge; reverse::Bool=false)

Yield both faces that `edge` touches, starting by the left one (or right if `reverse=true`).
"""
faces(edge::AbstractEdge; reverse::Bool=false)

@resumable function faces(edge::AbstractEdge; reverse::Bool=false)
    if reverse
        @yield edge.twin.face
        @yield edge.face
    else
        @yield edge.face
        @yield edge.twin.face
    end
end


@doc """
    faces(vertex::AbstractVertex; reverse::Bool=false)

Yield all of the faces that touch `vertex`, in counterclockwise order
(or clockwise if `reverse=true`).
"""
faces(vertex::AbstractVertex; reverse::Bool=false)

@resumable function faces(vertex::AbstractVertex; reverse::Bool=false)
    for edge in edges(vertex, reverse=reverse)
        @yield edge.face
    end
end


@doc """
    faces(face::AbstractFace; reverse::Bool=false)

Yield all faces that share an edge with `face`, in counterclockwise order
(or clockwise if `reverse=true`).
"""
faces(face::AbstractFace; reverse::Bool=false)

@resumable function faces(face::AbstractFace; reverse::Bool=false)
    for edge in edges(face, reverse=reverse)
        @yield edge.twin.face
    end
end


#= Sorting =#
@inline function _pseudoangle(dx::Real, dy::Real)
    p = dx / (abs(dx) + abs(dy))
    return dy < 0 ? p - 1 : 1 - p
end

@inline function _pseudoangle_unsigned(dx::Real, dy::Real)
    r = _pseudoangle(dx, dy)
    r = r < 0 ? r + 4 : r
end

function _is_sorted_ccw(a::AbstractVertex, b::AbstractVertex, c::AbstractVertex, center::AbstractVertex)
    ang_a = _pseudoangle_unsigned(a.x - center.x, a.y - center.y)
    ang_b = _pseudoangle_unsigned(b.x - center.x, b.y - center.y)
    ang_c = _pseudoangle_unsigned(c.x - center.x, c.y - center.y)
    return (ang_a <= ang_b <= ang_c) || (ang_b <= ang_c <= ang_a) || (ang_c <= ang_a <= ang_b)
end

function squeeze_edge(vertex::AbstractVertex, edge::AbstractEdge)
    if vertex.edge === nothing
        return edge
    end

    iter = edges(vertex)
    res1 = iterate(iter)
    res2 = iterate(iter)
    if res2 === nothing
        return res1[1]
    end

    e1, e2 = res1[1], res2[1]
    v1, v2, u = e1.twin.dest, e2.twin.dest, edge.twin.dest

    while !_is_sorted_ccw(v1, u, v2, vertex)
        res2 = iterate(iter)
        if res2 === nothing
            return vertex.edge
        end
        e1 = e2
        e2 = res2[1]
        v1, v2 = e1.twin.dest, e2.twin.dest
    end
    return e2
end


#= Topological operations =#
function _connect_vertices!(u::AbstractVertex, v::AbstractVertex)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = v, u

    ha = squeeze_edge(v, h1)
    hb = squeeze_edge(u, h2)

    u.edge, v.edge = h2, h1
    h1.face = h2.face = hb.face

    h1.prev, h1.next = hb, ha.next
    h2.prev, h2.next = ha, hb.next
    ha.next, hb.next = h2, h1
    h1.next.prev, h2.next.prev = h1, h2
    return h1
end

function _update_edges_face!(edge::AbstractEdge, f::AbstractFace)
    for e in edge_loop(edge)
        e.face = f
    end
end

function _split_face!(u::AbstractVertex, v::AbstractVertex)
    h1 = _connect_vertices!(u, v)
    h2 = h1.twin

    f = h1.face
    f1, f2 = Face(), Face()
    f1.edge, f2.edge = h1, h2

    _update_edges_face!(h2, f2)
    _update_edges_face!(h1, f1)

    return h1, f
end

function _connect_manual!(
    tess::AbstractTessellation,
    u::AbstractVertex,
    v::AbstractVertex,
    split::Bool
)
    if split
        h, f = _split_face!(u, v)
        delete!(tess.faces, f)
        push!(tess.faces, h.face)
    else
        h = _connect_vertices!(u, v)
    end

    push!(tess.edges, h)
    return h
end

function _connect_automatic!(
    tess::AbstractTessellation,
    u::AbstractVertex,
    v::AbstractVertex
)
    h1, h2 = Edge(), Edge()
    h1.twin, h2.twin = h2, h1
    h1.dest, h2.dest = v, u

    ha = squeeze_edge(v, h1)
    hb = squeeze_edge(u, h2)

    edges_connected = false
    if ha != h1
        for h in edge_loop(ha)
            if h == hb
                edges_connected = true
                break
            end
        end
    end

    u.edge, v.edge = h2, h1
    h1.face = h2.face = hb.face

    h1.prev, h1.next = hb, ha.next
    h2.prev, h2.next = ha, hb.next
    ha.next, hb.next = h2, h1
    h1.next.prev, h2.next.prev = h1, h2

    if edges_connected
        f = h1.face
        f1, f2 = Face(), Face()
        f1.edge, f2.edge = h1, h2

        _update_edges_face!(h2, f2)
        _update_edges_face!(h1, f1)

        delete!(tess.faces, f)
        push!(tess.faces, f1, f2)
    end

    push!(tess.edges, h1)
    return h1
end

"""
    connect(args...; kwargs...)

Connect two vertices.

# Arguments
- `tess::AbstractTessellation`: Tessellation to update.
- `u::AbstractVertex`: First vertex to connect.
- `v::AbstractVertex`: Second vertex to connect.

# Keywords
- `split::Union{Bool, Nothing}=nothing`: Whether connecting `u` and `v` will create a new
face. If `nothing`, it will be determined automatically, at the cost of more operations.

# Returns
- `h`: The newly created edge from `u` to `v`.`
"""
function connect(
    tess::AbstractTessellation,
    u::AbstractVertex,
    v::AbstractVertex;
    split::Union{Bool, Nothing}=nothing
)
    if split === nothing
        h = _connect_automatic!(tess, u, v)
    else
        h = _connect_manual!(tess, u, v, split)
    end
    return h
end

# TODO: Add special case for triangulation? (All faces are triangular except outer)
"""
    find_outer_face(tess::AbstractTessellation)

Return the unbounded face of `tess`.
"""
function find_outer_face(tess::AbstractTessellation)
    min_y, min_vertex = Inf, nothing
    for vertex in tess.vertices
        if vertex.edge !== nothing && vertex.y < min_y
            min_y = vertex.y
            min_vertex = vertex
        end
    end

    min_angle, min_edge = Inf, nothing
    for edge in edges(min_vertex)
        other = edge.twin.dest
        vec = other - min_vertex
        ang = _pseudoangle_unsigned(vec.x, vec.y)
        if ang < min_angle
            min_angle = ang
            min_edge = edge
        end
    end

    return min_edge.face
end

#= Fixing =#
"""
    fix_faces!(tess::AbstractTessellation)

Create the missing faces between the edges of `tess`. It is assumed that the `prev` and
`next` fields are consistent.
"""
function fix_faces!(tess::AbstractTessellation)
    if !isempty(tess.faces)
        throw(GeometryError("Set of faces must be empty."))
    end

    visited = Set()
    for full_edge in tess.edges
        for edge in [full_edge, full_edge.twin]
            if !(edge in visited)
                face = Face()
                face.edge = edge
                push!(tess.faces, face)

                for e in edge_loop(edge)
                    e.face = face
                    push!(visited, e)
                end
            end
        end
    end
end


#= Validity =#
# TODO: Simplify this.
function validate_geometry(edges::AbstractVector{<:AbstractEdge})
    for edge_pair in edges
        for edge in [edge_pair, edge_pair.twin]
            if edge.twin === nothing
                throw(GeometryError("Edge has no twin, $(edge.id)."))
            end

            if edge.next === nothing
                throw(GeometryError("Edge has no next, $(edge.id)."))
            end

            if edge.prev === nothing
                throw(GeometryError("Edge has no prev, $(edge.id)."))
            end

            if edge != edge.twin.twin
                throw(GeometryError("twin violation at $(edge.id), $(edge.twin.id)."))
            end

            if edge.prev.next != edge
                throw(GeometryError("prev-next violation at $(edge.id)."))
            end

            if edge.next.prev != edge
                throw(GeometryError("next-prev violation at $(edge.id)."))
            end

            count = 1
            temp = edge
            while temp.next != edge
                temp = temp.next
                count += 1
                if count > 2 * length(edges)
                    throw(GeometryError("Open edge loop starting at $(edge.id)."))
                end
            end

            count = 1
            temp = edge
            while temp.prev != edge
                temp = temp.prev
                count += 1
                if count > 2 * length(edges)
                    throw(GeometryError("Open edge loop starting at $(edge.id)."))
                end
            end
        end
    end
end

# TODO: Simplify this.
function validate_geometry(vertices::AbstractVector{<:AbstractVertex})
    for vertex in vertices
        if vertex.edge === nothing
            return nothing
        end
        iter = edges(vertex)
        r1 = iterate(iter)
        r2 = iterate(iter)
        if r2 === nothing
            return nothing
        end
        r3 = iterate(iter)
        while r3 !== nothing
            v1, v2, v3 = r1[1].twin.dest, r2[1].twin.dest, r3[1].twin.dest
            if !_is_sorted_ccw(v1, v2, v3, vertex)
                throw(GeometryError("Vertices not in clockwise order: $(v1.id), $(v2.id), $(v3.id)."))
            end
            r1, r2 = r2, r3
            r3 = iterate(iter)
        end
    end
end


#= Plotting =#
@recipe function f(vertex::AbstractVertex; vertex_labels=false)
    if vertex_labels
        series_annotations := vertex.id[end-2:end]
    end
    seriestype := :scatter
    legend := false
    color --> "black"
    return [vertex.x], [vertex.y]
end



@recipe function f(
    vertices::AbstractVector{<:AbstractVertex};
    vertex_labels=false,
)
    l = length(vertices)

    if l == 0
        return nothing
    end

    x, y = Vector{Real}(undef, l), Vector{Real}(undef, l)
    if vertex_labels
        z = Vector{String}(undef, l)
    end
    for i in 1:l
        x[i], y[i] = vertices[i].x, vertices[i].y
        if vertex_labels
            z[i] = vertices[i].id[end-2:end]
        end
    end

    seriestype := :scatter
    legend := false
    color --> "black"
    if vertex_labels
        series_annotations := z
    end
    return x, y
end

@recipe function f(
    edges::AbstractVector{<:AbstractEdge};
    endpoints = false,
    edge_labels = false,
    vertex_labels = false,
)
    l = length(edges)

    x, y = Vector{Real}(undef, 3*l), Vector{Real}(undef, 3*l)
    if endpoints || vertex_labels
        vertices = Set{Vertex}()
    end
    if edge_labels
        xl, yl, zl = Vector{Real}(undef, l), Vector{Real}(undef, l), Vector{String}(undef, l)
    end

    for (i, edge) in enumerate(edges)
        a, b = edge.dest, edge.twin.dest
        x[3*i-2], y[3*i-2] = a.x, a.y
        x[3*i-1], y[3*i-1] = b.x, b.y
        x[3*i], y[3*i] = NaN, NaN
        if edge_labels
            xl[i], yl[i] = (a.x + b.x)/2, (a.y + b.y)/2
            zl[i] = "$(edge.twin.id[end-2:end])/$(edge.id[end-2:end])"
        end
        if endpoints || vertex_labels
            push!(vertices, a, b)
        end
    end

    if edge_labels
        @series begin
            seriestype := :scatter
            markeralpha := 0
            series_annotations := zl
            return xl, yl
        end
    end

    if endpoints || vertex_labels
        lv = length(vertices)
        xv, yv = Vector{Float64}(undef, lv), Vector{Float64}(undef, lv)
        if vertex_labels
            zv = Vector{String}(undef, lv)
        end

        for (i, vertex) in enumerate(vertices)
            xv[i], yv[i] = vertex.x, vertex.y
            if vertex_labels
                zv[i] = vertex.id[end-2:end]
            end
        end

        @series begin
            seriestype := :scatter
            color --> "black"
            if !endpoints
                markeralpha := 0
            end
            if vertex_labels
                series_annotations := zv
            end
            return xv, yv
        end
    end

    seriestype := :path
    color --> "black"
    legend := false
    return x, y
end

@recipe function f(vertices::AbstractSet{<:AbstractVertex})
    return collect(vertices)
end

@recipe function f(edges::AbstractSet{<:AbstractEdge})
    return collect(edges)
end

end
