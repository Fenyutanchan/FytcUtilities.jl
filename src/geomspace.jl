# Copyright (c) 2026 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

export geomspace

"""
    geomspace(start_point, end_point, num::Int)

Generate `num` points spaced evenly on a logarithmic scale between
`start_point` and `end_point` (both endpoints included).

The returned sequence has a constant multiplicative step:
`result[i + 1] / result[i] == constant` for valid `i`.

# Arguments
- `start_point`: First value of the sequence.
- `end_point`: Last value of the sequence.
- `num::Int`: Number of points to generate. Must satisfy `num >= 2`.

# Returns
- A vector of length `num`.
- `result[1] == start_point` and `result[end] == end_point`.

# Constraints
- `start_point` and `end_point` must have the same sign.
- `num` must be at least `2`.

If constraints are violated, an `AssertionError` is thrown.

# Examples
```jldoctest
julia> using FytcUtilities

julia> xs = geomspace(1.0, 1000.0, 4);

julia> xs ≈ [1.0, 10.0, 100.0, 1000.0]
true

julia> ys = geomspace(-1.0, -1000.0, 4);

julia> ys ≈ [-1.0, -10.0, -100.0, -1000.0]
true
```
"""
function geomspace(start_point, end_point, num::Int)
    total_ratio = end_point / start_point
    @assert total_ratio > 0 "End points should be the same sign!"
    @assert num ≥ 2 "Number of points should be greater than 1!"

    step_multiplier = exp(log(total_ratio) / (num - 1))
    result_list = [
        start_point * step_multiplier^(ii - 1)
        for ii ∈ 1:num-1
    ]
    push!(result_list, end_point)

    return result_list
end
