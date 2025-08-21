function generate_act_data(quant_matrix, data_file)
% 生成格式为"[i][j] data"的数据文件，确保数据多样性
% 输入：
%   quant_matrix - 量化后的int32矩阵（R×PARA_WIDTH，R为8的倍数）
%   data_file    - 输出的数据文件名（如'act_data.hex'）

[R, PARA_WIDTH] = size(quant_matrix);
if mod(R, 8) ~= 0
    error('矩阵行数必须是8的倍数（每8行1个256位块）');
end
blocks_per_col = R / 8;  % 每个实例的总块数

% 打开文件写入
fid = fopen(data_file, 'w');
if fid == -1
    error('无法创建文件：%s', data_file);
end

% 逐实例、逐块生成数据

for j = 1:blocks_per_col  % j：块号（1-based）
    % 提取当前实例、当前块的8行数据
    row_start = (j-1)*8 + 1;
    row_end = j*8;
    for i_inte = 0:PARA_WIDTH-1  % i：实例号
        i = PARA_WIDTH - i_inte - 1;
        col = i + 1;  % MATLAB列索引（1-based）
        block_rows = row_start:row_end;

        % 拼接256位数据（行号小的在低位，确保顺序正确）
        block_256 = repmat('0', 1, 256);
        for k = 1:8  % 8行×32位=256位（k=1对应最低32位）
            val = mynum2bin(quant_matrix(block_rows(k), col),32);  % 32位元素（int32转uint32，保留位模式）
            % 拼接：第k行数据左移(k-1)*32位（低位在前）
            block_256(256-32*(k-1)-31:256-32*(k-1))=val;
        end

        % 按格式"[i][j] data"写入
        fprintf(fid, '%s', bin2hexstr(block_256));
    end
    if (j ~= blocks_per_col)
        fprintf(fid, '\n');
    end
end
fprintf('%s is generated successfully!\n', data_file);
end