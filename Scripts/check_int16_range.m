function [is_valid, out_of_range] = check_int16_range(mat)
    % CHECK_INT16_RANGE 检查矩阵元素是否全部在int16范围内
    %   输入：mat - 任意数值矩阵（支持整数、浮点等类型）
    %   输出：
    %       is_valid - 逻辑值，true表示所有元素在int16范围内，false表示存在超出范围的元素
    %       out_of_range - 结构体，包含超出范围的元素信息（值和位置）
    
    % int16的取值范围
    int16_min = int16(-32768);
    int16_max = int16(32767);
    min_val = double(int16_min);
    max_val = double(int16_max);
    
    % 检查输入是否为数值矩阵
    if ~isnumeric(mat)
        error('输入必须是数值矩阵');
    end
    
    % 找到所有超出范围的元素
    below_min = mat < min_val;
    above_max = mat > max_val;
    out_of_range_mask = below_min | above_max;
    
    % 提取超出范围的元素值和位置
    [rows, cols] = find(out_of_range_mask);
    values = mat(out_of_range_mask);
    
    % 构建结果结构体
    out_of_range.count = length(values);
    out_of_range.values = values;
    out_of_range.rows = rows;
    out_of_range.cols = cols;
    
    % 判断是否所有元素都在范围内
    is_valid = (out_of_range.count == 0);
    
    % 显示检查结果信息（用if-else替代三元运算符）
    if is_valid
        disp('所有元素均在int16范围内（-32768至32767）。');
    else
        warning('存在%d个元素超出int16范围：', out_of_range.count);
        for i = 1:out_of_range.count
            % 用if-else判断超出方向
            if out_of_range.values(i) < min_val
                range_str = '（小于-32768）';
            else
                range_str = '（大于32767）';
            end
            fprintf('位置(%d, %d)：值 = %g %s\n', ...
                out_of_range.rows(i), out_of_range.cols(i), ...
                out_of_range.values(i), range_str);
        end
    end
end