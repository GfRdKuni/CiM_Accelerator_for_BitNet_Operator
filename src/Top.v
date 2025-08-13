`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/12 16:46:17
// Design Name: 
// Module Name: Top
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


module Top(
    // 全局信号
    input  wire          clk           ,  // 时钟信号
    input  wire          rst_n_i       ,  // 异步复位信号（低有效）
    
    // 外部输入信号
    input  wire          valid_in_i    ,  // 输入有效信号
    input  wire          ready_out_i   ,  // 外部就绪信号
    input  wire  [255:0] data_i_act    ,  // 激活数据输入
    input  wire  [255:0] data_i_wm     ,  // 权重矩阵数据输入
    input  wire  [255:0] data_i_ws     ,  // 权重标量数据输入
    
    // 外部输出信号
    output wire          valid_out_o   ,  // 输出有效信号
    output wire          ready_in_o    ,  // 内部就绪信号
    output wire  [31:0]  result_0_o    ,  // 运算结果输出0
    output wire  [31:0]  result_1_o    ,  // 运算结果输出1
    output wire  [31:0]  result_2_o    ,  // 运算结果输出2
    output wire  [31:0]  result_3_o    ,  // 运算结果输出3
    output wire  [31:0]  result_4_o    ,  // 运算结果输出4
    output wire  [31:0]  result_5_o    ,  // 运算结果输出5
    output wire  [31:0]  result_6_o    ,  // 运算结果输出6
    output wire  [31:0]  result_7_o    ,  // 运算结果输出7
    output wire  [31:0]  result_8_o    ,  // 运算结果输出8
    output wire  [31:0]  result_9_o    ,  // 运算结果输出9
    output wire  [31:0]  result_10_o   ,  // 运算结果输出10
    output wire  [31:0]  result_11_o   ,  // 运算结果输出11
    output wire  [31:0]  result_12_o   ,  // 运算结果输出12
    output wire  [31:0]  result_13_o   ,  // 运算结果输出13
    output wire  [31:0]  result_14_o   ,  // 运算结果输出14
    output wire  [31:0]  result_15_o   ,  // 运算结果输出15
    output wire  [31:0]  result_16_o   ,  // 运算结果输出16
    output wire  [31:0]  result_17_o   ,  // 运算结果输出17
    output wire  [31:0]  result_18_o   ,  // 运算结果输出18
    output wire  [31:0]  result_19_o   ,  // 运算结果输出19
    output wire  [31:0]  result_20_o   ,  // 运算结果输出20
    output wire  [31:0]  result_21_o   ,  // 运算结果输出21
    output wire  [31:0]  result_22_o   ,  // 运算结果输出22
    output wire  [31:0]  result_23_o   ,  // 运算结果输出23
    output wire  [31:0]  result_24_o   ,  // 运算结果输出24
    output wire  [31:0]  result_25_o   ,  // 运算结果输出25
    output wire  [31:0]  result_26_o   ,  // 运算结果输出26
    output wire  [31:0]  result_27_o   ,  // 运算结果输出27
    output wire  [31:0]  result_28_o   ,  // 运算结果输出28
    output wire  [31:0]  result_29_o   ,  // 运算结果输出29
    output wire  [31:0]  result_30_o   ,  // 运算结果输出30
    output wire  [31:0]  result_31_o     // 运算结果输出31
);

// 内部连接信号（控制模块到数据模块）
wire          dff_en_i      ;  // D触发器使能信号
wire          dff_en_i_q_o  ;  // D触发器使能信号的延迟输出
wire          acc_dff_en_i  ;  // Acc D触发器使能信号
wire          out_dff_en_i  ;  // 输出D触发器使能信号
wire          ASRAM_wen0    ;  // ASRAM写使能0
wire          ASRAM_wen1    ;  // ASRAM写使能1
wire          ASRAM_wen2    ;  // ASRAM写使能2
wire [1:0]    ASRAM_waddr0  ;  // ASRAM写地址0
wire [1:0]    ASRAM_waddr1  ;  // ASRAM写地址1
wire [1:0]    ASRAM_waddr2  ;  // ASRAM写地址2
wire          ASRAM_ren_in  ;  // ASRAM输入读使能
wire          ASRAM_ren_out ;  // ASRAM输出读使能
wire [1:0]    ASRAM_raddr   ;  // ASRAM读地址
wire          WMSRAM_wen0   ;  // WMSRAM写使能0
wire          WMSRAM_wen1   ;  // WMSRAM写使能1
wire          WMSRAM_wen2   ;  // WMSRAM写使能2
wire          WMSRAM_wen3   ;  // WMSRAM写使能3
wire [4:0]    WMSRAM_waddr0 ;  // WMSRAM写地址0
wire [4:0]    WMSRAM_waddr1 ;  // WMSRAM写地址1
wire [4:0]    WMSRAM_waddr2 ;  // WMSRAM写地址2
wire [4:0]    WMSRAM_waddr3 ;  // WMSRAM写地址3
wire          WMSRAM_ren_in ;  // WMSRAM输入读使能
wire          WMSRAM_ren_out;  // WMSRAM输出读使能
wire [4:0]    WMSRAM_raddr  ;  // WMSRAM读地址
wire          WSSRAM_wen    ;  // WSSRAM写使能
wire          WSSRAM_ren_in ;  // WSSRAM输入读使能
wire          WSSRAM_ren_out;  // WSSRAM输出读使能
wire [4:0]    WSSRAM_raddr  ;  // WSSRAM读地址
wire [4:0]    WSSRAM_waddr  ;  // WSSRAM写地址
wire          oprand_sel    ;  // 操作数选择信号

// 实例化控制模块
Ctrl_top u_Ctrl_top(
    .clk           (clk           ),
    .rst_n_i       (rst_n_i       ),
    .valid_in_i    (valid_in_i    ),
    .ready_out_i   (ready_out_i   ),
    
    .valid_out_o   (valid_out_o   ),
    .ready_in_o    (ready_in_o    ),
    .dff_en_i      (dff_en_i      ),
    .dff_en_i_q_o  (dff_en_i_q_o  ),
    .acc_dff_en_i  (acc_dff_en_i  ),
    .out_dff_en_i  (out_dff_en_i  ),
    .ASRAM_wen0    (ASRAM_wen0    ),
    .ASRAM_wen1    (ASRAM_wen1    ),
    .ASRAM_wen2    (ASRAM_wen2    ),
    .ASRAM_waddr0  (ASRAM_waddr0  ),
    .ASRAM_waddr1  (ASRAM_waddr1  ),
    .ASRAM_waddr2  (ASRAM_waddr2  ),
    .ASRAM_ren_in  (ASRAM_ren_in  ),
    .ASRAM_ren_out (ASRAM_ren_out ),
    .ASRAM_raddr   (ASRAM_raddr   ),
    .WMSRAM_wen0   (WMSRAM_wen0   ),
    .WMSRAM_wen1   (WMSRAM_wen1   ),
    .WMSRAM_wen2   (WMSRAM_wen2   ),
    .WMSRAM_wen3   (WMSRAM_wen3   ),
    .WMSRAM_waddr0 (WMSRAM_waddr0 ),
    .WMSRAM_waddr1 (WMSRAM_waddr1 ),
    .WMSRAM_waddr2 (WMSRAM_waddr2 ),
    .WMSRAM_waddr3 (WMSRAM_waddr3 ),
    .WMSRAM_ren_in (WMSRAM_ren_in ),
    .WMSRAM_ren_out(WMSRAM_ren_out),
    .WMSRAM_raddr  (WMSRAM_raddr  ),
    .WSSRAM_wen    (WSSRAM_wen    ),
    .WSSRAM_ren_in (WSSRAM_ren_in ),
    .WSSRAM_ren_out(WSSRAM_ren_out),
    .WSSRAM_raddr  (WSSRAM_raddr  ),
    .WSSRAM_waddr  (WSSRAM_waddr  ),
    .oprand_sel    (oprand_sel    )
);

// 实例化数据模块
Data_top u_Data_top(
    .clk           (clk           ),
    .rst_n_i       (rst_n_i       ),
    .data_i_act    (data_i_act    ),
    .data_i_wm     (data_i_wm     ),
    .data_i_ws     (data_i_ws     ),
    .dff_en_i      (dff_en_i      ),
    .dff_en_i_q_o  (dff_en_i_q_o  ),
    .acc_dff_en_i  (acc_dff_en_i  ),
    .out_dff_en_i  (out_dff_en_i  ),
    .ASRAM_wen0    (ASRAM_wen0    ),
    .ASRAM_wen1    (ASRAM_wen1    ),
    .ASRAM_wen2    (ASRAM_wen2    ),
    .ASRAM_waddr0  (ASRAM_waddr0  ),
    .ASRAM_waddr1  (ASRAM_waddr1  ),
    .ASRAM_waddr2  (ASRAM_waddr2  ),
    .ASRAM_ren_in  (ASRAM_ren_in  ),
    .ASRAM_ren_out (ASRAM_ren_out ),
    .ASRAM_raddr   (ASRAM_raddr   ),
    .WMSRAM_wen0   (WMSRAM_wen0   ),
    .WMSRAM_wen1   (WMSRAM_wen1   ),
    .WMSRAM_wen2   (WMSRAM_wen2   ),
    .WMSRAM_wen3   (WMSRAM_wen3   ),
    .WMSRAM_waddr0 (WMSRAM_waddr0 ),
    .WMSRAM_waddr1 (WMSRAM_waddr1 ),
    .WMSRAM_waddr2 (WMSRAM_waddr2 ),
    .WMSRAM_waddr3 (WMSRAM_waddr3 ),
    .WMSRAM_ren_in (WMSRAM_ren_in ),
    .WMSRAM_ren_out(WMSRAM_ren_out),
    .WMSRAM_raddr  (WMSRAM_raddr  ),
    .WSSRAM_wen    (WSSRAM_wen    ),
    .WSSRAM_ren_in (WSSRAM_ren_in ),
    .WSSRAM_ren_out(WSSRAM_ren_out),
    .WSSRAM_raddr  (WSSRAM_raddr  ),
    .WSSRAM_waddr  (WSSRAM_waddr  ),
    .oprand_sel    (oprand_sel    ),
    
    .result_0_o    (result_0_o    ),
    .result_1_o    (result_1_o    ),
    .result_2_o    (result_2_o    ),
    .result_3_o    (result_3_o    ),
    .result_4_o    (result_4_o    ),
    .result_5_o    (result_5_o    ),
    .result_6_o    (result_6_o    ),
    .result_7_o    (result_7_o    ),
    .result_8_o    (result_8_o    ),
    .result_9_o    (result_9_o    ),
    .result_10_o   (result_10_o   ),
    .result_11_o   (result_11_o   ),
    .result_12_o   (result_12_o   ),
    .result_13_o   (result_13_o   ),
    .result_14_o   (result_14_o   ),
    .result_15_o   (result_15_o   ),
    .result_16_o   (result_16_o   ),
    .result_17_o   (result_17_o   ),
    .result_18_o   (result_18_o   ),
    .result_19_o   (result_19_o   ),
    .result_20_o   (result_20_o   ),
    .result_21_o   (result_21_o   ),
    .result_22_o   (result_22_o   ),
    .result_23_o   (result_23_o   ),
    .result_24_o   (result_24_o   ),
    .result_25_o   (result_25_o   ),
    .result_26_o   (result_26_o   ),
    .result_27_o   (result_27_o   ),
    .result_28_o   (result_28_o   ),
    .result_29_o   (result_29_o   ),
    .result_30_o   (result_30_o   ),
    .result_31_o   (result_31_o   )
);

endmodule

