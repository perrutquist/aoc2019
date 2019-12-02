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
    i ∈ s && return s
    push!(s, i)
    p[i] ∉ keys(oplen) && return s
    if(p[i] != 99)
        opix!(s, p, i+oplen[p[i]])
    end
    s
end
opix(p, i) = opix!(Set{Int}(), p, i)

function dstix!(s, p, oi)
    for i in oi
        p[i] ∉ keys(opdst) && continue
        dst = opdst[p[i]]
        if dst isa Int
            push!(s, p[i+dst])
        end
    end
    s
end
dstix(p, oi) = dstix!(Set{Int}(), p, oi)

function intcode_parser(p::OffsetArray, i0=0)
    oi = opix(p, i0)
    di = dstix(p, oi)

    c = Any[]

    if allow_ptr
        dst = i -> :( p[$i] )
        idst = i -> :( p[p[$i]] )
        checkconst! = i -> push!(c, :( $(dst(i)) == $(p[i]) || return runat!(p, $i) ))
    else
        dst = i -> i == 1 ? :n : i == 2 ? :v : i ∈ di ? Symbol("m", i) : p[i]
        idst = i -> i == 1 ? :pn : i == 2 ? :pv : dst(p[i])
        checkconst! = i -> i ∈ di && push!(c, :( $(dst(i)) == $(p[i]) || return runat!(rev(), $i) ))
    end

    if !allow_ptr
        r = Any[]
        push!(r, :( p = $(copy(p)) ))
        for i in sort(collect(di))
            push!(c, :( $(dst(i)) = $(p[i]) ))
            push!(r, :( p[$i] = $(dst(i)) ))
        end
        push!(c, :( rev() = $(Expr(:block, r..., :p)) ))
    end

    push!(c, :( @goto start ))
    for i in sort(collect(oi))
        push!(c, LineNumberNode(i, :address))
        i == i0 && push!(c, :( @label start ))
        checkconst!(i)
        if p[i] == 1
            !allow_ptr && checkconst!.(i+1:i+3)
            push!(c, :( $(idst(i+3)) = $(idst(i+1)) + $(idst(i+2)) ))
        elseif p[i] == 2
            !allow_ptr && checkconst!.(i+1:i+3)
            push!(c, :( $(idst(i+3)) = $(idst(i+1)) * $(idst(i+2)) ))
        elseif p[i] == 99
            if allow_ptr
                push!(c, :( return p ))
            else
                push!(c, :( return rev() ))
            end
        else
            push!(c, :( throw($(ErrorException(string("Invalid opcode: ", p[i])))) ))
        end
    end
    push!(c, :( throw($(ErrorException("End of code reached."))) ))
    Expr(:block, c...)
end

intcode_parser(p) = intcode_parser(OffsetVector(p, 0:length(p)-1))

function programhash!(program::OffsetVector, i0=0)
    if allow_ptr
        oi=opix(program, i0)
        ci=sort(collect(oi))
    else
        oi=opix(program, i0)
        di = dstix(program, oi)
        ci = setdiff(1:length(program)-1, di)
    end
    hash((ci, program[ci], i0))
end

const compiled_programs = Set{UInt64}()

function runat!(p, i)
    h = compile_intcode(p, i)
    if allow_ptr
        Base.invokelatest(run_intcode!, h, p)
    else
        Base.invokelatest(run_intcode, h, p[1], p[2], p[p[1]], p[p[2]])
    end
end

function compile_intcode(program::OffsetVector, i0=0)
    h = programhash!(program, i0)
    if h ∉ compiled_programs
        println("Compiling ", string(h, base=16))
        e = intcode_parser(program, i0)
        #println(e)
        if allow_ptr
            @eval run_intcode!(::Val{$h}, p) = $e
        else
            @eval run_intcode(::Val{$h}, n, v, pn, pv) = $e
        end
        push!(compiled_programs, h)
    end
    Val(h)
end

function run_intcode(program::OffsetVector, n, v, i0::Int=0)
    h = programhash!(program, i0)
    h ∈ compiled_programs || compile_intcode(program, i0)
    if allow_ptr
        Base.invokelatest(run_intcode, Val(h), n, v, program)
    else
        Base.invokelatest(run_intcode, Val(h), n, v, program[n], program[v])
    end
end

function run_intcode(h::Val, n, v, p::OffsetVector)
    if allow_ptr
        p = copy(p)
        p[1] = n
        p[2] = v
        run_intcode!(h, p)
    else
        run_intcode(h, n, v, p[n], p[v])
    end
end

# Test using day 2's example (works with or without pointers)

zerobased(p) = OffsetVector(p, 0:length(p)-1)

day2example = zerobased([1,0,0,3,2,3,11,0,99,30,40,50])

@show intcode_parser( day2example )

h = compile_intcode(day2example)

@test run_intcode(day2example, 9, 10)[0] == 3500
@test run_intcode(h, 9, 10, day2example)[0] == 3500
@show run_intcode(day2example, 9, 10)

if !allow_ptr
    println("Try this: \n   @code_native IntCode.run_intcode(Val(hash(IntCode.day2example)), 12, 2, IntCode.day2example[12], IntCode.day2example[2])")
end

# Test self-modifying code

modifytest = zerobased([1,0,0,4,0,4,4,0,99])

@show intcode_parser( modifytest )
@show run_intcode(modifytest, 0, 0)
#@test run_intcode(modifytest, 0, 0)[0] == 4

end # module
