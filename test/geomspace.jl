using Test
using FytcUtilities

@testset "geomspace generates geometric sequences" begin
    result = FytcUtilities.geomspace(1, 1000, 4)

    @test length(result) == 4
    @test result[1] == 1.0
    @test result[end] == 1000.0
    @test result ≈ [1.0, 10.0, 100.0, 1000.0]
    @test result[2] / result[1] ≈ result[3] / result[2]
    @test result[3] / result[2] ≈ result[4] / result[3]
end

@testset "geomspace handles negative ranges" begin
    result = FytcUtilities.geomspace(-1, -1000, 4)

    @test result ≈ [-1.0, -10.0, -100.0, -1000.0]
end

@testset "geomspace handles the minimum point count" begin
    result = FytcUtilities.geomspace(2, 8, 2)

    @test result == [2.0, 8.0]
end

@testset "geomspace validates inputs" begin
    @test_throws AssertionError FytcUtilities.geomspace(1, -10, 4)
    @test_throws AssertionError FytcUtilities.geomspace(1, 10, 1)
end