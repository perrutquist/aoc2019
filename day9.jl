using OffsetArrays
using SparseArrays

program = parse.(Int, split(readline("input9.txt"),","))

oplen = Dict(
    1 => 4,
    2 => 4,
    3 => 2,
    4 => 2,
    5 => 3,
    6 => 3,
    7 => 4,
    8 => 4,
    9 => 2,
    99 => 1,
)

function intcode!(p, input, output)
    sp = spzeros(Int, typemax(Int))
    sp[1:length(p)] = p
    p = OffsetVector(sp, 0:length(sp)-1)

    i = 0
    rb = 0
    function a(k)
        mode = p[i]÷10^(k+1) % 10
        if mode == 0
            p[i+k]
        elseif mode == 1
            i+k
        else
            rb+p[i+k]
        end
    end
    m(k) = p[a(k)]
    while true
        op = p[i] % 100
        if op == 99
            break
        elseif op == 1
            p[a(3)] = m(1) + m(2)
        elseif op == 2
            p[a(3)] = m(1) * m(2)
        elseif op == 3
            p[a(1)] = take!(input)
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
            p[a(3)] = m(1) < m(2)
        elseif op == 8
            p[a(3)] = m(1) == m(2)
        elseif op == 9
            rb += m(1)
        else
            error("Invalid instruction: ", p[i], " at ", i)
        end
        i += oplen[op]
    end
    nothing
end

intcode(p, input, output) = intcode!(copy(p), input, output)

function intcode(p, input::Integer)
   i = Channel{Int}(32)
   o = Channel{Int}(32)
   put!(i, input)
   @async intcode(p, i, o)
   take!(o)
end

@show intcode.((program,), (1, 2))
