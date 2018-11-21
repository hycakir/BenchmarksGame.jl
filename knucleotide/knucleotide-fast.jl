# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# based on the Go version
# modified by Jarret Revels, Alex Arslan, Yichao Yu

using Printf

import Base.isless

function count_data(data::AbstractString, n::Int)
    counts = Dict{SubString{String}, Int}()
    top = length(data) - n + 1
    @inbounds for i = 1:top
        s = SubString(data, i, i+n-1)
        token = Base.ht_keyindex2!(counts, s)
        if token > 0
            counts.vals[token] += 1
        else
            Base._setindex!(counts, 1, s, -token)
        end
    end
    return counts
end

function count_one(data::AbstractString, s::AbstractString)
    d = count_data(data, length(s))
    return haskey(d, s) ? d[s] : 0
end

struct KNuc
    name::SubString{String}
    count::Int
end

# sort down
function isless(x::KNuc, y::KNuc)
    if x.count == y.count
        return x.name > y.name
    end
    x.count > y.count
end

function sorted_array(m::Dict{<:AbstractString, Int})
    kn = Vector{KNuc}(undef, length(m))
    i = 1
    for elem in m
        kn[i] = KNuc(elem...)
        i += 1
    end
    sort(kn)
end

function print_knucs(a::Array{KNuc, 1})
    sum = 0
    for kn in a
        sum += kn.count
    end
    for kn in a
        @printf("%s %.3f\n", kn.name, 100.0kn.count/sum)
    end
    println()
end

function perf_k_nucleotide(io = stdin)
    three = ">THREE "
    while true
        line = readline(io)
        if length(line) >= length(three) && line[1:length(three)] == three
            break
        end
    end
    data = collect(read(io, String))
    # delete the newlines and convert to upper case
    i, j = 1, 1
    while i <= length(data)
        if data[i] != '\n'
            data[j] = uppercase(data[i])
            j += 1
        end
        i += 1
    end
    str = join(data[1:j-1], "")

    arr1 = sorted_array(count_data(str, 1))
    arr2 = sorted_array(count_data(str, 2))

    print_knucs(arr1)
    print_knucs(arr2)

    v = ["GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"]
    counts = zeros(length(v))
    # Could threads this loop but seems slower?
    for i in 1:length(v)
        counts[i] = count_one(str, v[i])
    end
    for (chain, c) in zip(v, counts)
        @printf("%d\t%s\n", c, chain)
    end
end

perf_k_nucleotide()
#perf_k_nucleotide(open("knucleotide-input.txt"))
