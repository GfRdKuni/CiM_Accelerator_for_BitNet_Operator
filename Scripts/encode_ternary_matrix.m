function [low4_mat, high1_mat] = encode_ternary_matrix(ternary_mat)
    % ENCODE_TERNARY_MATRIX 三进制矩阵（每行3的倍数个元素）分组编码
    % 输入：ternary_mat - N×C矩阵，C为3的倍数，元素为-1、0、1
    % 输出：
    %   low4_mat - N×(C/3)矩阵，每行存储各组的低4位（0-15）
    %   high1_mat - N×(C/3)矩阵，每行存储各组的高1位（0或1）

    % 输入参数校验：检查列数是否为3的倍数
    [N, C] = size(ternary_mat);
    if mod(C, 3) ~= 0
        error('输入矩阵列数必须是3的倍数（每3个元素为一组）');
    end
    group_num = C / 3;  % 计算每组数量（总列数÷3）

    % 建立三进制三元组到5位编码的映射（字符串键）
    weight2code = containers.Map(...
        { '0,0,0', '0,0,1', '0,1,-1', '0,1,0', '0,1,1', ...
          '1,-1,-1', '1,-1,0', '1,-1,1', '1,0,-1', '1,0,0', ...
          '1,0,1', '1,1,-1', '1,1,0', '1,1,1', ...
          '0,0,-1', '0,-1,1', '0,-1,0', '0,-1,-1', ...
          '-1,1,1', '-1,1,0', '-1,1,-1', '-1,0,1', '-1,0,0', ...
          '-1,0,-1', '-1,-1,1', '-1,-1,0', '-1,-1,-1' }, ...
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29] ...
    );

    % 初始化输出矩阵（行数=N，列数=group_num）
    low4_mat = zeros(N, group_num, 'uint8');   % 低4位矩阵
    high1_mat = zeros(N, group_num, 'uint8');  % 高1位矩阵

    % 逐行、逐组编码
    for i = 1:N                  % 遍历每行
        for j = 0:group_num-1    % 遍历每组（0到group_num-1）
            % 计算当前组的起始列索引（MATLAB索引从1开始）
            col_start = j * 3 + 1;
            % 提取当前组的3个元素
            a = ternary_mat(i, col_start);
            b = ternary_mat(i, col_start + 1);
            c = ternary_mat(i, col_start + 2);
            % 生成映射表的键（字符串格式）
            key_str = sprintf('%d,%d,%d', a, b, c);

            % 编码并存储结果
            if isKey(weight2code, key_str)
                code = weight2code(key_str);       % 获取5位编码的十进制值
                high1_mat(i, j+1) = bitshift(code, -4);  % 高1位（右移4位）
                low4_mat(i, j+1) = bitand(code, 15);     % 低4位（与0b1111按位与）
            else
                error(['第', num2str(i), '行，第', num2str(j+1), '组存在无效组合：[', ...
                    num2str(a), ',', num2str(b), ',', num2str(c), ']']);
            end
        end
    end
end
