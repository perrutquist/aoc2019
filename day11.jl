include("day9.jl") # reuse intcode computer

program = parse.(Int, split(readline("input11.txt"),","))

function paint(program, p0)
    can = zeros(Bool,200,200)
    ptd = zeros(Bool,200,200)
    pos = 100 + 100im
    ptd[real(pos), imag(pos)] = true
    can[real(pos), imag(pos)] = p0
    h = -im
    i = Channel{Int}(32)
    o = Channel{Int}(32)
    t = @async intcode(program, i, o)
    while !istaskdone(t)
        put!(i, can[real(pos), imag(pos)])
        can[real(pos), imag(pos)] = take!(o)
        ptd[real(pos), imag(pos)] = true
        h *= im*(2*take!(o)-1)
        pos += h
    end
    ix = vec(any(ptd, dims=2))
    jx = vec(any(ptd, dims=1))
    (sum(ptd), UnicodePlots.spy(can[ix,jx]'))
end

@show paint(program, 0)[1]
@show paint(program, 1)[2]
