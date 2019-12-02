module IntCode

using OffsetArrays
using Test

const allow_ptr = false

oplen = Dict{Int, Int}(
    1 => 4,
    2 => 4,
    99 => 1,
)

opdst = Dict{Int, Union{Int, Nothing}}(
    1 => 3,
    2 => 3,
    99 => nothing,
)

function opix!(s, p, i)
    i ∈ s && return
    push!(s, i)
    if(p[i] != 99)
        opix!(s, p, i+oplen[p[i]])
    end
    s
end
opix(p, i) = opix!(Set{Int}(), p, i)

function dstix!(s, p, oi)
    for i in sort(collect(oi))
        dst = opdst[p[i]]
        if dst isa Int
            push!(s, p[i+dst])
        end
    end
    s
end
dstix(p, oi) = dstix!(Set{Int}(), p, oi)

function intcode_parser(p::OffsetArray)
    oi = opix(p, 0)
    di = dstix(p, oi)

    @assert 0 ∈ oi
    @assert 0 ∈ di

    c = Any[]

    if allow_ptr
        dst = i -> :( p[$i] )
        idst = i -> :( p[p[$i]] )
        checkconst! = i -> push!(c, :( $(dst(i)) == $(p[i]) || throw($(ErrorException(string("modified code: ", i)))) ))
        push!(c, :( p[1] = n ))
        push!(c, :( p[2] = v ))
    else
        dst = i -> i == 1 ? :n : i == 2 ? :v : i ∈ di ? Symbol("m", i) : p[i]
        idst = i -> i == 1 ? :pn : i == 2 ? :pv : dst(p[i])
        checkconst! = i -> i ∈ di && push!(c, :( $(dst(i)) == $(p[i]) || throw($(ErrorException(string("modified code: ", i)))) ))
    end

    if !allow_ptr
        for i in sort(collect(di))
            push!(c, :( $(dst(i)) = $(p[i]) ))
        end
    end

    for i in sort(collect(oi))
        push!(c, LineNumberNode(i, :address))
        checkconst!(i)
        if p[i] == 1
            !allow_ptr && checkconst!.(i+1:i+3)
            push!(c, :( $(idst(i+3)) = $(idst(i+1)) + $(idst(i+2)) ))
        elseif p[i] == 2
            !allow_ptr && checkconst!.(i+1:i+3)
            push!(c, :( $(idst(i+3)) = $(idst(i+1)) * $(idst(i+2)) ))
        elseif p[i] == 99
            push!(c, :( return $(dst(0)) ))
        else
            push!(c, :( throw($(ErrorException(string("Invalid opcode: ", p[i])))) ))
        end
    end
    Expr(:block, c...)
end

intcode_parser(p) = intcode_parser(OffsetVector(p, 0:length(p)-1))

function programhash!(program::OffsetVector)
    program[1] = 0
    program[2] = 0
    hash(program)
end

function compile_intcode(program::OffsetVector)
    h = programhash!(program)
    if allow_ptr
        @eval run_intcode!(::Val{$h}, n, v, p) = $(intcode_parser(program))
    else
        @eval run_intcode(::Val{$h}, n, v, pn, pv) = $(intcode_parser(program))
    end
    Val(h)
end

function run_intcode(program::OffsetVector, n, v)
    h = programhash!(program)
    if allow_ptr
        run_intcode(Val(h), n, v, program)
    else
        run_intcode(Val(h), n, v, program[n], program[v])
    end
end

if allow_ptr
    run_intcode(h::Val, n, v, p::OffsetVector) = run_intcode!(h, n, v, copy(p))
else
    run_intcode(h::Val, n, v, p::OffsetVector) = run_intcode(h, n, v, p[n], p[v])
end

# Test using day 2's example (works with or without pointers)

day2example = [1,0,0,3,2,3,11,0,99,30,40,50]
day2example = OffsetVector(day2example, 0:length(day2example)-1)

@show intcode_parser( day2example )

h = compile_intcode(day2example)

@test run_intcode(day2example, 9, 10) == 3500
@test run_intcode(h, 9, 10, day2example) == 3500
@show run_intcode(day2example, 9, 10)

if !allow_ptr
    println("Try this: \n   @code_native IntCode.run_intcode(Val(hash(IntCode.day2example)), 12, 2, IntCode.day2example[12], IntCode.day2example[2])")
end

end # module
