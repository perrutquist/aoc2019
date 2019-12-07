using OffsetArrays
using Test

input = readlines("input7.txt")

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

function intcode!(p, input, output)
    p = OffsetVector(p, 0:length(p)-1)

    i = 0
    m(k) = p[i]÷10^(k+1) % 10 == 0 ? p[p[i+k]] : p[i+k]
    while true
        op = p[i] % 100
        if op == 99
            break
        elseif op == 1
            p[p[i+3]] = m(1) + m(2)
        elseif op == 2
            p[p[i+3]] = m(1) * m(2)
        elseif op == 3
            p[p[i+1]] = take!(input)
        elseif op == 4
            put!(output, m(1))
        elseif op == 5
            if m(1) != 0
                i = m(2)
                continue
            end
        elseif op == 6
            if m(1) == 0
                i = m(2)
                continue
            end
        elseif op == 7
            p[p[i+3]] = m(1) < m(2)
        elseif op == 8
            p[p[i+3]] = m(1) == m(2)
        else
            error("Invalid instruction: ", p[i], " at ", i)
        end
        i += oplen[op]
    end
    nothing
end

intcode(p, input, output) = intcode!(copy(p), input, output)

function thrust(p, as)
    t = 0
    ch = Channel{Int}.(fill(32,length(as)))
    put!.(ch, as)
    put!(ch[1], 0)

    ts = [@async intcode(p, ch[i], ch[i==length(as) ? 1 : i+1]) for i in 1:length(as)]
    wait(ts[end])
    take!(ch[1])
end

p1 =[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]

@test thrust(p1, (4,3,2,1,0)) == 43210

p2 = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]

@test thrust(p2, (1,0,4,3,2)) == 65210

function maxthrust(p, part=1)
    m = typemin(Int)
    for a=0:4, b=0:4, c=0:4, d=0:4, e=0:4
        as = (a,b,c,d,e) .+ 5 .* (part==2)
        if allunique(as)
            t = thrust(p, as)
            m = max(m, t)
        end
    end
    m
end

@test maxthrust(p2) == 65210

@show maxthrust(data)

p3 =[3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]

@test maxthrust(p3, 2) == 18216

@show maxthrust(data, 2)
