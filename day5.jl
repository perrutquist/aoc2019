using OffsetArrays
using Test

input = readlines("input5.txt")

data = parse.(Int, split(input[1],","))

oplen = Dict(
    1 => 4,
    2 => 4,
    3 => 2,
    4 => 2,
    5 => 3,
    6 => 3,
    7 => 4,
    8 => 4,
    99 => 1,
)

function intcode!(p, input)
    p = OffsetVector(p, 0:length(p)-1)
    output = Int[]

    i = 0
    m(i,k) = p[i]÷10^(k+1) % 10 == 0 ? p[p[i+k]] : p[i+k]
    while true
        op = p[i] % 100
        if op == 99
            break
        elseif op == 1
            p[p[i+3]] = m(i,1) + m(i,2)
        elseif op == 2
            p[p[i+3]] = m(i,1) * m(i,2)
        elseif op == 3
            p[p[i+1]] = pop!(input)
        elseif op == 4
            push!(output, m(i,1))
        elseif op == 5
            if m(i,1) != 0
                i = m(i,2)
                continue
            end
        elseif op == 6
            if m(i,1) == 0
                i = m(i,2)
                continue
            end
        elseif op == 7
            p[p[i+3]] = m(i,1) < m(i,2)
        elseif op == 8
            p[p[i+3]] = m(i,1) == m(i,2)
        else
            error("Invalid instruction: ", p[i], " at ", i)
        end
        i += oplen[op]
    end
    output
end

intcode(p, input) = intcode!(copy(p), copy(input))

@show intcode(data, [1])[end]

p = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
@test intcode(p, [7]) == [999]
@test intcode(p, [8]) == [1000]
@test intcode(p, [9]) == [1001]

@show intcode(data, [5])[1]
