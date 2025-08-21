function generate_ws_data(WS_Matrix,ws_file_name)
[WS_Matrix_H,WS_Matrix_W] = size(WS_Matrix);
if mod(WS_Matrix_H,32) ~= 0
    error("Weight_Matrix的行数应为32的倍数");
end
if mod(WS_Matrix_W,8) ~= 0
    error("Weight_Matrix的列数应为24的倍数");
end
H_Block = WS_Matrix_H / 32;
W_Block = WS_Matrix_W / 8;
% 打开文件写入
fid = fopen(ws_file_name, 'w');
if fid == -1
    error('无法创建文件：%s', ws_file_name);
end
for Hth = 1 : H_Block
    for Wth = 1 : W_Block
        start_pos_H =  1 + (Hth - 1) * 32;
        start_pos_W =  1 + (Wth - 1) * 8 ;
        datastr     = repmat('0', 1, 256);
        for block_row = 1:32
            now_H_start = start_pos_H + block_row - 1;
            end_pos_W   = start_pos_W + 8 - 1;
            data        = WS_Matrix(now_H_start, start_pos_W:end_pos_W);
            for k = 1:8
                bindata = mynum2bin(data(k),2);
                datastr(256 - (k-1) - 8*(block_row - 1)) = bindata(2);
            end
        end
        if (Hth ~= H_Block || Wth ~= W_Block)
            fprintf(fid, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n", bin2hexstr(datastr), bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr));
        else
            fprintf(fid, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", bin2hexstr(datastr), bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr));
        end
    end
end
fclose(fid);
fprintf('%s is generated successfully!\n', ws_file_name);
end