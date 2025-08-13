`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/13 16:42:01
// Design Name: 
// Module Name: Accumulator
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


module Accumulator (
    input  wire        clk,          // 时钟信号
    input  wire        rst_n_i,      // 异步复位信号（低有效）
    input  wire        acc_dff_en_i, // 累加器寄存器使能
    input  wire        oprand_sel,   // 操作数选择：1-使用上一次结果，0-清零
    input  wire [15:0] tree_data,    // 输入16位数据（来自tree_result）
    output wire [31:0] acc_out       // 32位累积结果输出
);

// 内部信号
wire [31:0] sign_ext_data;  // 符号扩展后的32位数据
wire [31:0] adder_in1;      // 加法器输入1（选择后的值）
wire [31:0] adder_out;      // 加法器输出

// 16位数据符号扩展到32位
assign sign_ext_data = {{16{tree_data[15]}}, tree_data};

// 选择加法器输入1：oprand_sel=1时用寄存器输出，=0时用0
assign adder_in1 = oprand_sel ? acc_out : 32'd0;

// 32位有符号加法器（累加运算）
Signed_Adder #(32) u_adder (
    .in1 (adder_in1),
    .in2 (sign_ext_data),
    .out (adder_out)
);

// 累加结果寄存器（带使能和复位）
dff #(32) u_acc_dff (
    .clk     (clk),
    .rst_n_i (rst_n_i),
    .en_i    (acc_dff_en_i),
    .d_i     (adder_out),
    .q_o     (acc_out)
);

endmodule

