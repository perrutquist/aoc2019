data = [c - '0' for c in readline("input8.txt")]

data = reshape(data, 25, 6, :)
i = findmin([sum(data[:,:,k].==0) for k in axes(data,3)])[2]
@show sum(data[:,:,i].==1) * sum(data[:,:,i].==2)

function decode(data)
    first(i,j,k) = data[i,j,k] == 2 ? first(i,j,k+1) : data[i,j,k]
    first.(axes(data,1), axes(data,2)', 1)'
end
display(decode(data))
