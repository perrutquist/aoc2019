function countpasswords(range)
    s1 = 0
    s2 = 0
    for i in range
        digit(k) = i ÷ 10^k % 10
        d = digit.((5,4,3,2,1,0))
        if all(d[2:6] .>= d[1:5])
            if any(d[1:5] .== d[2:6])
                s1 += 1
                v = (-1, d..., -1)
                p(k) = v[k] != v[k+1] && v[k+1] == v[k+2] && v[k+2] != v[k+3]
                s2 += any(p.(1:5))
            end
        end
    end
    (s1, s2)
end

data = parse.(Int, split(readline("input4.txt"), "-"))

@show countpasswords(data[1]:data[2])

# Note: This is a bit slow due to type inference issues.
# It will be faster once this is merged into Julia:
# https://github.com/JuliaLang/julia/pull/31138
