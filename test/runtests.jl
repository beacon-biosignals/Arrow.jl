using Test, Arrow, Tables, Dates, PooledArrays

include("testtables.jl")

@testset "Arrow" begin

@testset "table roundtrips" begin

for case in testtables
    testtable(case...)
end

end # @testset "table roundtrips"

@testset "misc" begin

# multiple record batches
t = Tables.partitioner(((col1=Union{Int64, Missing}[1,2,3,4,5,6,7,8,9,missing],), (col1=Union{Int64, Missing}[1,2,3,4,5,6,7,8,9,missing],)))
io = IOBuffer()
Arrow.write(io, t)
seekstart(io)
tt = Arrow.Table(io)
@test length(tt) == 1
@test isequal(tt.col1, vcat([1,2,3,4,5,6,7,8,9,missing], [1,2,3,4,5,6,7,8,9,missing]))
@test eltype(tt.col1) === Union{Int64, Missing}

# Arrow.Stream
seekstart(io)
str = Arrow.Stream(io)
state = iterate(str)
@test state !== nothing
tt, st = state
@test length(tt) == 1
@test isequal(tt.col1, [1,2,3,4,5,6,7,8,9,missing])

state = iterate(str, st)
@test state !== nothing
tt, st = state
@test length(tt) == 1
@test isequal(tt.col1, [1,2,3,4,5,6,7,8,9,missing])

@test iterate(str, st) === nothing

t = (col1=Int64[1,2,3,4,5,6,7,8,9,10],)
meta = Dict("key1" => "value1", "key2" => "value2")
Arrow.setmetadata!(t, meta)
meta2 = Dict("colkey1" => "colvalue1", "colkey2" => "colvalue2")
Arrow.setmetadata!(t.col1, meta2)
io = IOBuffer()
Arrow.write(io, t)
seekstart(io)
tt = Arrow.Table(io)
@test length(tt) == length(t)
@test tt.col1 == t.col1
@test eltype(tt.col1) === Int64
@test Arrow.getmetadata(tt) == meta
@test Arrow.getmetadata(tt.col1) == meta2

end # @testset "misc"

end
