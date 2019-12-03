using OffsetArrays
using SparseArrays
using Test

function scan(line)
    dl(s) = (s[1], parse(Int,s[2:end]))
    dl.(split(line, ","))
end

data = scan.(readlines("input3.txt"))

dr(a,b) = a <= b ? 1 : -1

function wirepath(ps)
    N = 10000
    z = OffsetArray(spzeros(Int, 2N+1, 2N+1), -N:N, -N:N)
    x = 0
    y = 0
    q = 0
    for (d, l) in ps
        (xn, yn) = if d == 'L'
            (x - l, y)
        elseif d == 'U'
            (x, y - l)
        elseif d == 'R'
            (x + l, y)
        elseif d == 'D'
            (x, y + l)
        end
        z[x:dr(x,xn):xn, y:dr(y,yn):yn] = q:q+l
        x = xn
        y = yn
        q = q+l
    end
    z
end

manhattan(v) = sum(abs.(v))

function solve(data)
    q1 = wirepath(data[1])
    q2 = wirepath(data[2])

    # i = findall((q1 .> 0) .& (q2 .> 0)) # TODO: Make a PR to OffsetArrays.jl to make this as fast as the below code.

    offset(ix) = CartesianIndex(Tuple(ix) .+ first.(axes(q1)) .- 1)
    i = offset.(findall((parent(q1) .> 0) .& (parent(q2) .> 0)))

    (minimum(manhattan.(Tuple.(i))), minimum(q1[i] .+ q2[i]))
end

data1 = scan.(["R8,U5,L5,D3", "U7,R6,D4,L4"])
@test solve(data1) == (6, 30)
data2 = scan.(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
@test solve(data2) == (135, 410)

@show solve(data)
