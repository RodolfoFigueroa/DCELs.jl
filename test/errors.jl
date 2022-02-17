@testset "GeometryError" begin
    @test_throws GeometryError throw(GeometryError("Hi"))
end

@testset "Printing" begin
    e = GeometryError("Test message")
    @test sprint(showerror, e) == "GeometryError\nTest message\n"
end
