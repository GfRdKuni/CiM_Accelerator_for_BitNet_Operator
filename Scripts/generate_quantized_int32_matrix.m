function mat = generate_quantized_int32_matrix(K, M)
% GENERATE_QUANTIZED_INT32_MATRIX 生成K×M的int32矩阵，元素范围[-127,127]
%   模拟量化过程：随机浮点数 → 计算缩放因子 → 量化为整数
%   输入参数：
%       K - 矩阵行数（正整数）
%       M - 矩阵列数（正整数）
%   输出参数：
%       mat - K×M的int32矩阵，元素范围[-127,127]

    % 输入参数校验
    if ~isscalar(K) || ~isscalar(M) || K<=0 || M<=0 || mod(K,1)~=0 || mod(M,1)~=0
        error('K和M必须为正整数');
    end
    
    % 1. 生成随机浮点数矩阵（模拟原始浮点数据）
    % 这里生成范围在[-1,1]的随机浮点数，可根据实际需求调整
    float_mat = rand(K, M) * 2 - 1;  % 范围[-1,1]
    
    % 2. 计算量化缩放因子（类似per_tensor_quant逻辑）
    max_abs_val = max(abs(float_mat(:)));  % 全局绝对值最大值
    
    % 处理最大值为0的特殊情况（避免除零）
    if max_abs_val < eps
        scales = 0;
    else
        scales = 127 / max_abs_val;  % 缩放因子，使最大值量化后为127
    end
    
    % 3. 缩放并四舍五入为整数（模拟量化过程）
    quantized_vals = round(float_mat * scales);
    
    % 4. 限制范围（确保在[-127,127]内，处理浮点误差）
    quantized_vals = max(quantized_vals, -127);
    quantized_vals = min(quantized_vals, 127);
    
    % 5. 转换为int32类型
    mat = int32(quantized_vals);
end
