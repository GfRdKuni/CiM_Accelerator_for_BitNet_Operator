`timescale 1ns/1ps

module tb_top #(
    parameter DATA_WIDTH    = 256,      // 每个单元的数据位宽（256位）
    parameter PARA_WIDTH    = 16,       // 并行运算单元数量（与Para_Top保持�?致）
    parameter VECTOR_WIDTH  = DATA_WIDTH * PARA_WIDTH,  // 顶层向量总位宽（4096位）
    parameter MAX_LINE_COUNT= 2048,     // 单个文件�?大行数（可调整）
    parameter RESPONSE_DELAY= 1         // ready_out_i响应延迟（单位：时钟周期�?
) ();

// -------------------------- 时钟与复位信�? --------------------------
reg                     clk;
reg                     rst_n_i;

// -------------------------- 顶层接口信号（匹配Para_Top�? --------------------------
// 输入到Para_Top的信�?
reg  [PARA_WIDTH-1:0]     valid_in_i_act;
reg  [PARA_WIDTH-1:0]     valid_in_i_wm;
reg  [PARA_WIDTH-1:0]     valid_in_i_ws;
reg  [PARA_WIDTH-1:0]     ready_out_i;                 // TB驱动的外部ready信号
reg  [VECTOR_WIDTH-1:0]   data_i_act;                  // Act文件数据向量�?4096位）
reg  [VECTOR_WIDTH-1:0]   data_i_wm;                   // WM文件数据向量�?4096位）
reg  [VECTOR_WIDTH-1:0]   data_i_ws;                   // WS文件数据向量�?4096位）

// 从Para_Top输出的信�?
wire [PARA_WIDTH-1:0]     valid_out_o;
wire [PARA_WIDTH-1:0]     ready_in_o_act;
wire [PARA_WIDTH-1:0]     ready_in_o_wm;
wire [PARA_WIDTH-1:0]     ready_in_o_ws;
wire [PARA_WIDTH*32-1:0]  result_0_o;
wire [PARA_WIDTH*32-1:0]  result_1_o;
wire [PARA_WIDTH*32-1:0]  result_2_o;
wire [PARA_WIDTH*32-1:0]  result_3_o;
wire [PARA_WIDTH*32-1:0]  result_4_o;
wire [PARA_WIDTH*32-1:0]  result_5_o;
wire [PARA_WIDTH*32-1:0]  result_6_o;
wire [PARA_WIDTH*32-1:0]  result_7_o;
wire [PARA_WIDTH*32-1:0]  result_8_o;
wire [PARA_WIDTH*32-1:0]  result_9_o;
wire [PARA_WIDTH*32-1:0]  result_10_o;
wire [PARA_WIDTH*32-1:0]  result_11_o;
wire [PARA_WIDTH*32-1:0]  result_12_o;
wire [PARA_WIDTH*32-1:0]  result_13_o;
wire [PARA_WIDTH*32-1:0]  result_14_o;
wire [PARA_WIDTH*32-1:0]  result_15_o;
wire [PARA_WIDTH*32-1:0]  result_16_o;
wire [PARA_WIDTH*32-1:0]  result_17_o;
wire [PARA_WIDTH*32-1:0]  result_18_o;
wire [PARA_WIDTH*32-1:0]  result_19_o;
wire [PARA_WIDTH*32-1:0]  result_20_o;
wire [PARA_WIDTH*32-1:0]  result_21_o;
wire [PARA_WIDTH*32-1:0]  result_22_o;
wire [PARA_WIDTH*32-1:0]  result_23_o;
wire [PARA_WIDTH*32-1:0]  result_24_o;
wire [PARA_WIDTH*32-1:0]  result_25_o;
wire [PARA_WIDTH*32-1:0]  result_26_o;
wire [PARA_WIDTH*32-1:0]  result_27_o;
wire [PARA_WIDTH*32-1:0]  result_28_o;
wire [PARA_WIDTH*32-1:0]  result_29_o;
wire [PARA_WIDTH*32-1:0]  result_30_o;
wire [PARA_WIDTH*32-1:0]  result_31_o;

// -------------------------- 内部信号（拆分后的数据） --------------------------
reg  [DATA_WIDTH-1:0]   data_i_act_split[PARA_WIDTH-1:0];  // 拆分后的Act数据
reg  [DATA_WIDTH-1:0]   data_i_wm_split[PARA_WIDTH-1:0];   // 拆分后的WM数据
reg  [DATA_WIDTH-1:0]   data_i_ws_split[PARA_WIDTH-1:0];   // 拆分后的WS数据

// -------------------------- 文件读取相关变量 --------------------------
reg  [DATA_WIDTH-1:0]   act_buffer[MAX_LINE_COUNT-1:0][PARA_WIDTH-1:0];
reg  [DATA_WIDTH-1:0]   wm_buffer[MAX_LINE_COUNT-1:0][PARA_WIDTH-1:0];
reg  [DATA_WIDTH-1:0]   ws_buffer[MAX_LINE_COUNT-1:0][PARA_WIDTH-1:0];

integer                 act_total_lines;
integer                 wm_total_lines;
integer                 ws_total_lines;

// 每个单元的独立行索引
integer                 act_line_idx[PARA_WIDTH-1:0];
integer                 wm_line_idx[PARA_WIDTH-1:0];
integer                 ws_line_idx[PARA_WIDTH-1:0];

// 结果日志文件句柄
integer                 result_log_file;
integer                 file_handle;
integer                 read_status;
reg                     files_read_complete;

// 结果计数（用于日志）
integer                 result_count[PARA_WIDTH-1:0];

// -------------------------- 实例化Para_Top模块 --------------------------
Para_Top #(
    .PARA_WIDTH(PARA_WIDTH)
) u_para_top (
    .clk           (clk),
    .rst_n_i       (rst_n_i),

    .valid_in_i_act(valid_in_i_act),
    .valid_in_i_wm (valid_in_i_wm),
    .valid_in_i_ws (valid_in_i_ws),
    .ready_out_i   (ready_out_i),
    .data_i_act    (data_i_act),
    .data_i_wm     (data_i_wm),
    .data_i_ws     (data_i_ws),

    .valid_out_o   (valid_out_o),
    .ready_in_o_act(ready_in_o_act),
    .ready_in_o_wm (ready_in_o_wm),
    .ready_in_o_ws (ready_in_o_ws),
    .result_0_o    (result_0_o),
    .result_1_o    (result_1_o),
    .result_2_o    (result_2_o),
    .result_3_o    (result_3_o),
    .result_4_o    (result_4_o),
    .result_5_o    (result_5_o),
    .result_6_o    (result_6_o),
    .result_7_o    (result_7_o),
    .result_8_o    (result_8_o),
    .result_9_o    (result_9_o),
    .result_10_o   (result_10_o),
    .result_11_o   (result_11_o),
    .result_12_o   (result_12_o),
    .result_13_o   (result_13_o),
    .result_14_o   (result_14_o),
    .result_15_o   (result_15_o),
    .result_16_o   (result_16_o),
    .result_17_o   (result_17_o),
    .result_18_o   (result_18_o),
    .result_19_o   (result_19_o),
    .result_20_o   (result_20_o),
    .result_21_o   (result_21_o),
    .result_22_o   (result_22_o),
    .result_23_o   (result_23_o),
    .result_24_o   (result_24_o),
    .result_25_o   (result_25_o),
    .result_26_o   (result_26_o),
    .result_27_o   (result_27_o),
    .result_28_o   (result_28_o),
    .result_29_o   (result_29_o),
    .result_30_o   (result_30_o),
    .result_31_o   (result_31_o)
);

// -------------------------- 时钟生成 --------------------------
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns周期�?100MHz�?
end

// -------------------------- ready_out_i 延迟响应逻辑 --------------------------
reg [PARA_WIDTH-1:0] prev_valid_out;
int pending_delay [PARA_WIDTH-1:0];  // 每个通道的延迟计数器

always @(posedge clk or negedge rst_n_i) begin
    if (!rst_n_i) begin
        ready_out_i <= {PARA_WIDTH{1'b0}};
        prev_valid_out <= {PARA_WIDTH{1'b0}};
        foreach(pending_delay[i]) pending_delay[i] = 0;
    end else begin
        prev_valid_out <= valid_out_o;  // 锁存上一拍valid_out_o
        
        // �?测valid_out_o上升沿，初始化延迟计数器
        for (int i = 0; i < PARA_WIDTH; i++) begin
            if (valid_out_o[i] && !prev_valid_out[i]) begin
                pending_delay[i] = RESPONSE_DELAY;  // �?始�?�计�?
            end else if (pending_delay[i] > 0) begin
                pending_delay[i]--;  // 倒计时�?�减
            end

            // 延迟结束后拉高ready_out_i（保�?1拍）
            ready_out_i[i] <= (pending_delay[i] == 1) ? 1'b1 : 1'b0;
        end
    end
end

// -------------------------- 输出结果�?测与日志记录 --------------------------
always @(posedge clk) begin
    if (rst_n_i) begin
        // �?测输出握手（valid_out_o & ready_out_i�?
        for (int i = 0; i < PARA_WIDTH; i++) begin
            if (valid_out_o[i] && ready_out_i[i]) begin
                // 递增结果计数
                result_count[i]++;
                
                // 输出到控制台
                $display("[%0t] Unit %0d output handshake (result count: %0d)", 
                         $time, i, result_count[i]);
                
                // 写入日志文件
                $fdisplay(result_log_file, "=== Unit %0d Result %0d (Time: %0t) ===", 
                         i, result_count[i], $time);
                $fdisplay(result_log_file, "result_0: 0x%08h", result_0_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_1: 0x%08h", result_1_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_2: 0x%08h", result_2_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_3: 0x%08h", result_3_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_4: 0x%08h", result_4_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_5: 0x%08h", result_5_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_6: 0x%08h", result_6_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_7: 0x%08h", result_7_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_8: 0x%08h", result_8_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_9: 0x%08h", result_9_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_10: 0x%08h", result_10_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_11: 0x%08h", result_11_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_12: 0x%08h", result_12_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_13: 0x%08h", result_13_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_14: 0x%08h", result_14_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_15: 0x%08h", result_15_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_16: 0x%08h", result_16_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_17: 0x%08h", result_17_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_18: 0x%08h", result_18_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_19: 0x%08h", result_19_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_20: 0x%08h", result_20_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_21: 0x%08h", result_21_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_22: 0x%08h", result_22_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_23: 0x%08h", result_23_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_24: 0x%08h", result_24_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_25: 0x%08h", result_25_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_26: 0x%08h", result_26_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_27: 0x%08h", result_27_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_28: 0x%08h", result_28_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_29: 0x%08h", result_29_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_30: 0x%08h", result_30_o[i*32 +: 32]);
                $fdisplay(result_log_file, "result_31: 0x%08h", result_31_o[i*32 +: 32]);
                $fdisplay(result_log_file, "-----------------------------------------\n");
            end
        end
    end
end

// -------------------------- 主测试流�? --------------------------
initial begin
    // 初始化信�?
    rst_n_i = 1'b0;
    files_read_complete = 1'b0;
    act_total_lines = 0;
    wm_total_lines = 0;
    ws_total_lines = 0;
    data_i_act = {VECTOR_WIDTH{1'b0}};
    data_i_wm = {VECTOR_WIDTH{1'b0}};
    data_i_ws = {VECTOR_WIDTH{1'b0}};
    valid_in_i_act = {PARA_WIDTH{1'b0}};
    valid_in_i_wm = {PARA_WIDTH{1'b0}};
    valid_in_i_ws = {PARA_WIDTH{1'b0}};
    ready_out_i = {PARA_WIDTH{1'b0}};
    
    // 初始化结果计数和日志文件
    result_log_file = $fopen("result_output.log", "w");
    if (result_log_file == 0) begin
        $error("Failed to open result log file!");
        $finish;
    end
    $fdisplay(result_log_file, "=== Result Log File ===\n");
    $fdisplay(result_log_file, "Simulation start time: %0t\n", $time);
    
    // 初始化所有单元的索引和拆分信�?
    for (int i = 0; i < PARA_WIDTH; i++) begin
        act_line_idx[i] = 0;
        wm_line_idx[i] = 0;
        ws_line_idx[i] = 0;
        data_i_act_split[i] = {DATA_WIDTH{1'b0}};
        data_i_wm_split[i] = {DATA_WIDTH{1'b0}};
        data_i_ws_split[i] = {DATA_WIDTH{1'b0}};
        pending_delay[i] = 0;
        result_count[i] = 0;
    end
    
    // 打印配置信息
    $display("=== Testbench Configuration ===");
    $display("  Data width per unit: %0d bits", DATA_WIDTH);
    $display("  Parallel units: %0d", PARA_WIDTH);
    $display("  Top vector width: %0d bits", VECTOR_WIDTH);
    $display("  Max lines per file: %0d", MAX_LINE_COUNT);
    $display("  Ready response delay: %0d cycles", RESPONSE_DELAY);
    $display("  Result log file: result_output.log");
    $display("===============================");
    
    // 复位释放
    #100;
    rst_n_i = 1'b1;
    $display("[%0t] Reset released", $time);
    
    // 读取三个文件
    read_hex_file("D:/Xilinx_Vivado_SDK_2019.1_0524_1430/CiM/CiM.srcs/sim_1/new/Act_file.hex", "act", act_buffer, act_total_lines);
    read_hex_file("D:/Xilinx_Vivado_SDK_2019.1_0524_1430/CiM/CiM.srcs/sim_1/new/WM_file.hex", "wm", wm_buffer, wm_total_lines);
    read_hex_file("D:/Xilinx_Vivado_SDK_2019.1_0524_1430/CiM/CiM.srcs/sim_1/new/WS_file.hex", "ws", ws_buffer, ws_total_lines);
    files_read_complete = 1'b1;
    
    $display("File read summary:");
    $display("  Act lines: %0d, WM lines: %0d, WS lines: %0d", 
             act_total_lines, wm_total_lines, ws_total_lines);
    
    // �?始发送数�?
    send_independent_data();
    
    // 结束仿真前关闭日志文�?
    #10000;
    $fdisplay(result_log_file, "\nSimulation end time: %0t", $time);
    $fdisplay(result_log_file, "=== End of Result Log ===");
    $fclose(result_log_file);
    
    $display("[%0t] All data transmission completed. Simulation finished.", $time);
    $finish;
end

// -------------------------- 读取hex文件并拆分数�? --------------------------
task read_hex_file(
    input string          filename,
    input string          data_type,
    output reg [DATA_WIDTH-1:0] buffer[MAX_LINE_COUNT-1:0][PARA_WIDTH-1:0],
    output integer        total_lines
);
    reg [VECTOR_WIDTH-1:0] line_data;  // �?行完整数据（4096位）
begin
    total_lines = 0;
    file_handle = $fopen(filename, "r");
    
    if (file_handle == 0) begin
        $error("Failed to open %s file: %s", data_type, filename);
        $finish;
    end
    $display("Reading %s file: %s ...", data_type, filename);
    
    // 逐行读取并拆�?
    while (!$feof(file_handle) && total_lines < MAX_LINE_COUNT) begin
        read_status = $fscanf(file_handle, "%h", line_data);
        
        if (read_status != 1) begin
            $warning("Invalid data at line %0d in %s file, skipping", total_lines, data_type);
        end 
        else begin
            // 拆分4096位数据到16个单�?
            for (int i = 0; i < PARA_WIDTH; i++) begin
                buffer[total_lines][i] = line_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            end
            total_lines = total_lines + 1;
        end
    end
    
    $fclose(file_handle);
    $display("Finished reading %s file, total lines: %0d", data_type, total_lines);
end
endtask

// -------------------------- 独立发�?�数据（适配长向量接口） --------------------------
task send_independent_data;
    reg all_act_done, all_wm_done, all_ws_done;
begin
    all_act_done = 1'b0;
    all_wm_done = 1'b0;
    all_ws_done = 1'b0;
    
    wait(files_read_complete && rst_n_i);
    @(posedge clk);
    $display("[%0t] Start data transmission with vector interface...", $time);
    for (int i = 0; i < PARA_WIDTH; i++) begin
            if (act_line_idx[i] < act_total_lines) begin
                // 准备当前单元数据
                data_i_act_split[i] = act_buffer[act_line_idx[i]][i];
                // 构建长向量（按单元索引拼接）
                data_i_act[i*DATA_WIDTH +: DATA_WIDTH] = data_i_act_split[i];
                // 拉高valid
                valid_in_i_act[i] = 1'b1;
                all_act_done = 1'b0;
            end

            if (wm_line_idx[i] < wm_total_lines) begin
                data_i_wm_split[i] = wm_buffer[wm_line_idx[i]][i];
                data_i_wm[i*DATA_WIDTH +: DATA_WIDTH] = data_i_wm_split[i];
                valid_in_i_wm[i] = 1'b1;
                all_wm_done = 1'b0;
            end

            if (ws_line_idx[i] < ws_total_lines) begin
                data_i_ws_split[i] = ws_buffer[ws_line_idx[i]][i];
                data_i_ws[i*DATA_WIDTH +: DATA_WIDTH] = data_i_ws_split[i];
                valid_in_i_ws[i] = 1'b1;
                all_ws_done = 1'b0;
            end
    end
    
    // 循环发�?�直到全部完�?
    while (!(all_act_done && all_wm_done && all_ws_done)) begin
        @(posedge clk);
        
        // -------------------------- 处理Act数据（长向量输出�? --------------------------
        all_act_done = 1'b1;
        for (int i = 0; i < PARA_WIDTH; i++) begin
            if (act_line_idx[i] < act_total_lines) begin
                if (ready_in_o_act[i]) begin
                    $display("[%0t] Unit %0d Act (line %0d) transmitted: 0x%0h", 
                             $time, i, act_line_idx[i], data_i_act_split[i][DATA_WIDTH-1:DATA_WIDTH-32]);
                    act_line_idx[i] = act_line_idx[i] + 1;
                end

                data_i_act_split[i] = act_buffer[act_line_idx[i]][i];
                data_i_act[i*DATA_WIDTH +: DATA_WIDTH] = data_i_act_split[i];
                valid_in_i_act[i] = 1'b1;
                all_act_done = 1'b0;
            end 
            else begin
                valid_in_i_act[i] = 1'b0;
            end
        end
        
        // -------------------------- 处理WM数据（长向量输出�? --------------------------
        all_wm_done = 1'b1;
        for (int i = 0; i < PARA_WIDTH; i++) begin
            if (wm_line_idx[i] < wm_total_lines) begin
                if (ready_in_o_wm[i]) begin
                    $display("[%0t] Unit %0d WM (line %0d) transmitted: 0x%0h", 
                             $time, i, wm_line_idx[i], data_i_wm_split[i][DATA_WIDTH-1:DATA_WIDTH-32]);
                    wm_line_idx[i] = wm_line_idx[i] + 1;
                end
                data_i_wm_split[i] = wm_buffer[wm_line_idx[i]][i];
                data_i_wm[i*DATA_WIDTH +: DATA_WIDTH] = data_i_wm_split[i];
                valid_in_i_wm[i] = 1'b1;
                all_wm_done = 1'b0;
            end 
            else begin
                valid_in_i_wm[i] = 1'b0;
            end
        end
        
        // -------------------------- 处理WS数据（长向量输出�? --------------------------
        all_ws_done = 1'b1;
        for (int i = 0; i < PARA_WIDTH; i++) begin
            if (ws_line_idx[i] < ws_total_lines) begin
                if (ready_in_o_ws[i]) begin
                    $display("[%0t] Unit %0d WS (line %0d) transmitted: 0x%0h", 
                             $time, i, ws_line_idx[i], data_i_ws_split[i][DATA_WIDTH-1:DATA_WIDTH-32]);
                    ws_line_idx[i] = ws_line_idx[i] + 1;
                end
                data_i_ws_split[i] = ws_buffer[ws_line_idx[i]][i];
                data_i_ws[i*DATA_WIDTH +: DATA_WIDTH] = data_i_ws_split[i];
                valid_in_i_ws[i] = 1'b1;
                all_ws_done = 1'b0;
            end 
            else begin
                valid_in_i_ws[i] = 1'b0;
            end
        end
    end
    
    // �?有传输完�?
    @(posedge clk);
    for (int i = 0; i < PARA_WIDTH; i++) begin
        valid_in_i_act[i] = 1'b0;
        valid_in_i_wm[i] = 1'b0;
        valid_in_i_ws[i] = 1'b0;
    end
    data_i_act = {VECTOR_WIDTH{1'b0}};
    data_i_wm = {VECTOR_WIDTH{1'b0}};
    data_i_ws = {VECTOR_WIDTH{1'b0}};
    $display("[%0t] All units completed all data transmission", $time);
end
endtask

endmodule


