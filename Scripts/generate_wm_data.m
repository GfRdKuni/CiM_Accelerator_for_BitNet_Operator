function generate_wm_data(WM_Matrix, wm_file_name)
[WM_Matrix_H,WM_Matrix_W] = size(WM_Matrix);
if mod(WM_Matrix_H,32) ~= 0
    error("Weight_Matrix的行数应为32的倍数");
end
if mod(WM_Matrix_W,8) ~= 0
    error("Weight_Matrix的列数应为24的倍数");
end
H_Block = WM_Matrix_H / 32;
W_Block = WM_Matrix_W / 8;
% 打开文件写入
fid = fopen(wm_file_name, 'w');
if fid == -1
    error('无法创建文件：%s', wm_file_name);
end
for Hth = 1 : H_Block
    for Wth = 1 : W_Block
        for BH_Block = 1:4
            start_pos_H =  1 + (Hth - 1) * 32 + (BH_Block - 1) * 8;
            start_pos_W =  1 + (Wth - 1) * 8;
            datastr     = repmat('0', 1, 256);
            for block_row = 1 : 8
                now_H       = start_pos_H + block_row - 1              ;
                now_W_start = start_pos_W                              ;
                now_W_end   = start_pos_W + 8 - 1                      ;
                data        = WM_Matrix(now_H, now_W_start:now_W_end)  ;

                for block_col = 1:8
                    bindata = mynum2bin(data(block_col),5);
                    datastr(256-4*(block_col-1) - 32 *(block_row-1)-3:256-4*(block_col-1)- 32 *(block_row-1)) = bindata(2:5);
                end
            end
            if (Hth ~= H_Block || Wth ~= W_Block || BH_Block ~= 4)
                fprintf(fid, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n", bin2hexstr(datastr), bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr));
            else
                fprintf(fid, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", bin2hexstr(datastr), bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr),bin2hexstr(datastr));
            end
        end
    end
end
fclose(fid);
fprintf('%s is generated successfully!\n', wm_file_name);
end
