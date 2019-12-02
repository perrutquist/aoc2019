using OffsetArrays

program = parse.(Int,split(readline("input2.txt"), ","))

function intcode!(p, n, v)
    p = OffsetVector(p, 0:length(p)-1)
    p[1] = n
    p[2] = v

    i = 0
    while(p[i] != 99)
        if p[i] == 1
            p[p[i+3]] = p[p[i+1]] + p[p[i+2]]
        elseif p[i] == 2
            p[p[i+3]] = p[p[i+1]] * p[p[i+2]]
        else
            error("Invalid opcode: ", p[i])
        end
        i += 4
    end
    p[0]
end

intcode(p, n, v) = intcode!(copy(p), n, v)

@show intcode(program, 12, 2)

function inverse_intcode(p, a)
    for n=0:99, v=0:99
        if intcode(p, n, v) == a
            return 100n + v
        end
    end
end

@show inverse_intcode(program, 19690720)
