module SplitApplyCombine

using Base: @propagate_inbounds, @pure, promote_op
using Indexing

# mini-compat (more for my knowledge than anything)
@static if VERSION < v"0.7-"
    const AbstractDict = Associative
    const axes = indices
    const ht_keyindex2! = Base.ht_keyindex2
    const CartesianIndices = CartesianRange

    Base.keys(v::AbstractVector) = indices(v)[1]
    Base.keys(a::AbstractArray) = CartesianRange(indices(a)...)
    Base.keys(::NTuple{N,Any}) where {N} = Base.OneTo(N)
    Base.keys(::Number) = Base.OneTo(1)

    # A Nullable is a container with 0 or 1 values... so...
    Base.start(::Nullable) = false
    Base.done(n::Nullable, i::Bool) = isnull(n) | i
    Base.next(n::Nullable, i::Bool) = (n.valie, true)
    Base.first(n::Nullable) = get(n)
    Base.last(n::Nullable) = get(n)
    @propagate_inbounds function Base.getindex(n::Nullable)
        @boundscheck if !n.hasvalue
            return NullException()
        end
        return n.value
    end

    @pure Base.Val(x) = Val{x}()
    @inline Base.ntuple(f, ::Val{x}) where {x} = ntuple(f, Val{x})
else
    import Base: axes, ht_keyindex2!
end

# Syntax
export @_

# collections -> scalar
export single

# collections -> collections
import Base: merge, merge!
export mapmany

# collections -> collections of collections
export group, groupinds, Groups, groupview, groupreduce
export splitdims, splitdimsview, SplitDimsArray

# colletions of collections -> collections
export flatten #, flattenview
export combinedims, combinedimsview, CombineDimsArray

# collections of collections -> collections of collections
export innerjoin, ⨝, leftgroupjoin
# `pivot` or similar - like transpose, but nested.

include("single.jl")
include("merge.jl")
include("map.jl")
include("group.jl")
include("innerjoin.jl")
include("leftgroupjoin.jl")
include("splitdims.jl")
include("combinedims.jl")

# Syntax
include("underscore.jl")


# Silly definitions missing from Base
# ===================================
# this should always work
Base.haskey(a, i) = i ∈ keys(a) 


end # module
