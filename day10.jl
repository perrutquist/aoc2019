lines = readlines("input10.txt")

function scan(l)
    [c for c in l]
end

d = hcat(scan.(lines)...)

cc(i) = i[1]-1 + (i[2]-1)im
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

function vaporize(obs, as, n)
    v = allvisible(obs, as)
    if length(v) < n
        vaporize(obs, setdiff(as, v), n-length(v))
    else
        sort!(v, by = a -> mod(angle(a-obs).+pi/2, 2π))
        100real(v[n]) + imag(v[n])
    end
end

@show vaporize(obs, a, 200)
