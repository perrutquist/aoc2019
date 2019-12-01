# Problem description: https://adventofcode.com/2019/day/1

# Part 1
masses = parse.(Int, readlines("input1.txt"))
fuel(m) = m ÷ 3 - 2
@assert fuel(1969) == 654
@show sum(fuel.(masses))

# Part 2
totalfuel(m) = fuel(m) < 0 ? 0 : fuel(m) + totalfuel(fuel(m))
@assert totalfuel(1969) == 966
@show sum(totalfuel.(masses))
