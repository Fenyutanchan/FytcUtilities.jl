# Copyright (c) 2026 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

export geomspace

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
