function C = matrix_multiply(A, B)
    % MATRIX_MULTIPLY_EXPANDED 展开式矩阵乘法（纯整数运算，不转换为浮点）
    % 输入：
    %   A - m×n的整数矩阵（如三进制矩阵，元素-1/0/1）
    %   B - n×p的整数矩阵（如int32矩阵）
    % 输出：
    %   C - m×p的整数矩阵，C(i,j) = sum(A(i,k)*B(k,j) for k=1..n)
    
    % 检查维度匹配
    [m, n] = size(A);
    [nB, p] = size(B);
    if n ~= nB
        error('A的列数必须等于B的行数');
    end
    
    % 初始化结果矩阵（用int32类型，避免溢出，范围足够容纳计算结果）
    C = zeros(m, p, 'int32');
    
    % 逐行逐列计算每个元素（完全展开点积过程）
    for i = 1:m          % 遍历结果矩阵的行
        for j = 1:p      % 遍历结果矩阵的列
            sum_val = int32(0);  % 累加器（用int32避免溢出）
            for k = 1:n  % 计算A的第i行与B的第j列的点积
                % 直接用整数乘法和加法（MATLAB支持标量整数运算）
                sum_val = sum_val + int32(A(i,k)) * int32(B(k,j));
            end
            C(i,j) = sum_val;  % 存储结果
        end
    end
end