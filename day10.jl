using LinearAlgebra

lines = readlines("input10.txt")

function scan(l)
    [c for c in l]
end

d = hcat(scan.(lines)...)

cc(i) = i[1] + i[2]im
a = cc.(findall(==('#'), d))

function blk(a, b, c)
    c == a && return true
    v1 = c - a
    v2 = b - a
    r = v2 / v1
    imag(r) ≈ 0 && 0 < real(r) < 1
end

isvisible(a, bs, c) = !any(blk.(a, bs, c))

allvisible(a, as) = filter(c -> isvisible(a, as, c), as)

function bestblk(as)
    (m, i) = findmax(length.(allvisible.(as, (as,))))
    (m, as[i])
end

(m, obs) = bestblk(a)

@show m

r = a .- obs

ang = sort(unique(rationalize.(angle.(r) ./ pi .+ 1)))
