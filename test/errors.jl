@testset "GeometryError" begin
    @test_throws GeometryError throw(GeometryError("Hi"))
end

@testset "Printing" begin
    e = GeometryError("Test message")
    er = sprint(showerror, e)
    @test occursin("GeometryError\nTest message\n", er)
end
