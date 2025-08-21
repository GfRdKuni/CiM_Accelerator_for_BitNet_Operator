function mat = generate_ternary_matrix(N, K)
% GENERATE_TERNARY_MATRIX 生成N×K的元素为-1、0、1的随机矩阵
%   输入参数：
%       N - 矩阵行数（正整数）
%       K - 矩阵列数（正整数）
%   输出参数：
%       mat - N×K的矩阵，元素仅为-1、0、1

    % 检查输入是否为正整数
    if ~isscalar(N) || ~isscalar(K) || N<=0 || K<=0 || mod(N,1)~=0 || mod(K,1)~=0
        error('N和K必须为正整数');
    end
    
    % 生成0、1、2的随机整数，减1后得到-1、0、1
    random_indices = randi([0, 2], N, K);
    mat = random_indices - 1;
end
