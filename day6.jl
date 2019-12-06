lines = readlines("input6.txt")

function scan(s)
    v = split(s, ")")
    v[2] => v[1]
end

function solve(lines)
    p = Dict(scan.(lines))
    e = setdiff(keys(p), values(p))

    function dist!(c, e)
        e ∈ keys(c) && return c[e]
        d = dist!(c, p[e])
        c[e] = d+1
    end
    c = Dict("COM" => 0)
    dist!.((c,), e)

    c2 = Dict("COM" => 0)
    s = dist!(c2, "SAN")
    first(e) = e ∈ keys(c2) ? c2[e] : first(p[e])
    y = first("YOU")

    (
    sum(values(c)), # part 1
    c["YOU"] + s - 2y - 2 # part 2
    )
end

@show solve(lines)
