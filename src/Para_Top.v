`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/14 15:17:35
// Design Name: 
// Module Name: Para_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Para_Top #(
    parameter PARA_WIDTH = 16 // 数据宽度，默认为256位
)
(
    // 全局信号
    input  wire          clk,           // 时钟信号
    input  wire          rst_n_i,       // 异步复位信号（低有效）
    
    // 外部输入信号（512个实例的输入）
    input  wire  [PARA_WIDTH-1:0]     valid_in_i_act,    // 512个输入有效信号
    input  wire  [PARA_WIDTH-1:0]     valid_in_i_wm,   // 512个输入有效信号
    input  wire  [PARA_WIDTH-1:0]     valid_in_i_ws,   // 512个输入有效信号
    input  wire  [PARA_WIDTH-1:0]     ready_out_i,   // 512个外部就绪信号
    input  wire  [PARA_WIDTH*256-1:0] data_i_act,    // 512×256位激活数据输入
    input  wire  [PARA_WIDTH*256-1:0] data_i_wm,     // 512×256位权重矩阵数据输入
    input  wire  [PARA_WIDTH*256-1:0] data_i_ws,     // 512×256位权重标量数据输入
    
    // 外部输出信号（512个实例的输出）
    output wire  [PARA_WIDTH-1:0] valid_out_o,   // 512个输出有效信号
    output wire  [PARA_WIDTH-1:0] ready_in_o_act,    // 512个内部就绪信号
    output wire  [PARA_WIDTH-1:0] ready_in_o_wm,     // 512个内部就绪信号
    output wire  [PARA_WIDTH-1:0] ready_in_o_ws,     // 512个内部就绪信号
    output wire  [PARA_WIDTH*32-1:0] result_0_o,  // 512×32位结果输出0
    output wire  [PARA_WIDTH*32-1:0] result_1_o,  // 512×32位结果输出1
    output wire  [PARA_WIDTH*32-1:0] result_2_o,  // 512×32位结果输出2
    output wire  [PARA_WIDTH*32-1:0] result_3_o,  // 512×32位结果输出3
    output wire  [PARA_WIDTH*32-1:0] result_4_o,  // 512×32位结果输出4
    output wire  [PARA_WIDTH*32-1:0] result_5_o,  // 512×32位结果输出5
    output wire  [PARA_WIDTH*32-1:0] result_6_o,  // 512×32位结果输出6
    output wire  [PARA_WIDTH*32-1:0] result_7_o,  // 512×32位结果输出7
    output wire  [PARA_WIDTH*32-1:0] result_8_o,  // 512×32位结果输出8
    output wire  [PARA_WIDTH*32-1:0] result_9_o,  // 512×32位结果输出9
    output wire  [PARA_WIDTH*32-1:0] result_10_o, // 512×32位结果输出10
    output wire  [PARA_WIDTH*32-1:0] result_11_o, // 512×32位结果输出11
    output wire  [PARA_WIDTH*32-1:0] result_12_o, // 512×32位结果输出12
    output wire  [PARA_WIDTH*32-1:0] result_13_o, // 512×32位结果输出13
    output wire  [PARA_WIDTH*32-1:0] result_14_o, // 512×32位结果输出14
    output wire  [PARA_WIDTH*32-1:0] result_15_o, // 512×32位结果输出15
    output wire  [PARA_WIDTH*32-1:0] result_16_o, // 512×32位结果输出16
    output wire  [PARA_WIDTH*32-1:0] result_17_o, // 512×32位结果输出17
    output wire  [PARA_WIDTH*32-1:0] result_18_o, // 512×32位结果输出18
    output wire  [PARA_WIDTH*32-1:0] result_19_o, // 512×32位结果输出19
    output wire  [PARA_WIDTH*32-1:0] result_20_o, // 512×32位结果输出20
    output wire  [PARA_WIDTH*32-1:0] result_21_o, // 512×32位结果输出21
    output wire  [PARA_WIDTH*32-1:0] result_22_o, // 512×32位结果输出22
    output wire  [PARA_WIDTH*32-1:0] result_23_o, // 512×32位结果输出23
    output wire  [PARA_WIDTH*32-1:0] result_24_o, // 512×32位结果输出24
    output wire  [PARA_WIDTH*32-1:0] result_25_o, // 512×32位结果输出25
    output wire  [PARA_WIDTH*32-1:0] result_26_o, // 512×32位结果输出26
    output wire  [PARA_WIDTH*32-1:0] result_27_o, // 512×32位结果输出27
    output wire  [PARA_WIDTH*32-1:0] result_28_o, // 512×32位结果输出28
    output wire  [PARA_WIDTH*32-1:0] result_29_o, // 512×32位结果输出29
    output wire  [PARA_WIDTH*32-1:0] result_30_o, // 512×32位结果输出30
    output wire  [PARA_WIDTH*32-1:0] result_31_o  // 512×32位结果输出31
);

// 实例化512个Top模块
genvar i;
generate
for (i = 0; i < PARA_WIDTH; i = i + 1) begin: top_instances
    // 实例化单个Top模块
    Top u_top (
        // 全局信号（共享）
        .clk          (clk),
        .rst_n_i      (rst_n_i),
        
        // 输入信号（每个实例独立）
        .valid_in_i_act(valid_in_i_act[i]),
        .valid_in_i_wm (valid_in_i_wm[i]),
        .valid_in_i_ws (valid_in_i_ws[i]),
        .ready_out_i   (ready_out_i[i]),
        .data_i_act    (data_i_act[i*256 +: 256]),
        .data_i_wm     (data_i_wm[i*256 +: 256]),
        .data_i_ws     (data_i_ws[i*256 +: 256]),
        
        // 输出信号（每个实例独立）
        .valid_out_o   (valid_out_o[i]),
        .ready_in_o_act(ready_in_o_act[i]),
        .ready_in_o_wm (ready_in_o_wm[i]),
        .ready_in_o_ws (ready_in_o_ws[i]),
        .result_0_o   (result_0_o[i*32 +: 32]),
        .result_1_o   (result_1_o[i*32 +: 32]),
        .result_2_o   (result_2_o[i*32 +: 32]),
        .result_3_o   (result_3_o[i*32 +: 32]),
        .result_4_o   (result_4_o[i*32 +: 32]),
        .result_5_o   (result_5_o[i*32 +: 32]),
        .result_6_o   (result_6_o[i*32 +: 32]),
        .result_7_o   (result_7_o[i*32 +: 32]),
        .result_8_o   (result_8_o[i*32 +: 32]),
        .result_9_o   (result_9_o[i*32 +: 32]),
        .result_10_o  (result_10_o[i*32 +: 32]),
        .result_11_o  (result_11_o[i*32 +: 32]),
        .result_12_o  (result_12_o[i*32 +: 32]),
        .result_13_o  (result_13_o[i*32 +: 32]),
        .result_14_o  (result_14_o[i*32 +: 32]),
        .result_15_o  (result_15_o[i*32 +: 32]),
        .result_16_o  (result_16_o[i*32 +: 32]),
        .result_17_o  (result_17_o[i*32 +: 32]),
        .result_18_o  (result_18_o[i*32 +: 32]),
        .result_19_o  (result_19_o[i*32 +: 32]),
        .result_20_o  (result_20_o[i*32 +: 32]),
        .result_21_o  (result_21_o[i*32 +: 32]),
        .result_22_o  (result_22_o[i*32 +: 32]),
        .result_23_o  (result_23_o[i*32 +: 32]),
        .result_24_o  (result_24_o[i*32 +: 32]),
        .result_25_o  (result_25_o[i*32 +: 32]),
        .result_26_o  (result_26_o[i*32 +: 32]),
        .result_27_o  (result_27_o[i*32 +: 32]),
        .result_28_o  (result_28_o[i*32 +: 32]),
        .result_29_o  (result_29_o[i*32 +: 32]),
        .result_30_o  (result_30_o[i*32 +: 32]),
        .result_31_o  (result_31_o[i*32 +: 32])
    );
end
endgenerate

endmodule
