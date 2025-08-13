`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 15:51:55
// Design Name: 
// Module Name: LUT_MUX
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


module LUT_MUX(
    input  wire [15:0] lut_0_0_i   ,
    input  wire [15:0] lut_0_1_i   ,
    input  wire [15:0] lut_0_2_i   ,
    input  wire [15:0] lut_0_3_i   ,
    input  wire [15:0] lut_0_4_i   ,
    input  wire [15:0] lut_0_5_i   ,
    input  wire [15:0] lut_0_6_i   ,
    input  wire [15:0] lut_0_7_i   ,
    input  wire [15:0] lut_0_8_i   ,
    input  wire [15:0] lut_0_9_i   ,
    input  wire [15:0] lut_0_10_i  ,
    input  wire [15:0] lut_0_11_i  ,
    input  wire [15:0] lut_0_12_i  ,
    input  wire [15:0] lut_0_13_i  ,
    input  wire [15:0] lut_0_14_i  ,
    input  wire [15:0] lut_0_15_i  ,
    input  wire [3:0]  weight_i    ,
    output wire [15:0] lut_o
);

    // 中间信号定义（每级MUX输出）
    wire [15:0] lut_1_0, lut_1_1, lut_1_2, lut_1_3, lut_1_4, lut_1_5, lut_1_6, lut_1_7;
    wire [15:0] lut_2_0, lut_2_1, lut_2_2, lut_2_3;
    wire [15:0] lut_3_0, lut_3_1;
    wire [15:0] lut_4_0;

    // 第一级MUX：16输入 → 8输出（使用weight_i[0]选择）
    oprand_mux #(.WIDTH(16)) mux1_0 (
        .opA(lut_0_0_i),  .opB(lut_0_1_i),  .sel(weight_i[0]), .out(lut_1_0)
    );
    oprand_mux #(.WIDTH(16)) mux1_1 (
        .opA(lut_0_2_i),  .opB(lut_0_3_i),  .sel(weight_i[0]), .out(lut_1_1)
    );
    oprand_mux #(.WIDTH(16)) mux1_2 (
        .opA(lut_0_4_i),  .opB(lut_0_5_i),  .sel(weight_i[0]), .out(lut_1_2)
    );
    oprand_mux #(.WIDTH(16)) mux1_3 (
        .opA(lut_0_6_i),  .opB(lut_0_7_i),  .sel(weight_i[0]), .out(lut_1_3)
    );
    oprand_mux #(.WIDTH(16)) mux1_4 (
        .opA(lut_0_8_i),  .opB(lut_0_9_i),  .sel(weight_i[0]), .out(lut_1_4)
    );
    oprand_mux #(.WIDTH(16)) mux1_5 (
        .opA(lut_0_10_i), .opB(lut_0_11_i), .sel(weight_i[0]), .out(lut_1_5)
    );
    oprand_mux #(.WIDTH(16)) mux1_6 (
        .opA(lut_0_12_i), .opB(lut_0_13_i), .sel(weight_i[0]), .out(lut_1_6)
    );
    oprand_mux #(.WIDTH(16)) mux1_7 (
        .opA(lut_0_14_i), .opB(lut_0_15_i), .sel(weight_i[0]), .out(lut_1_7)
    );

    // 第二级MUX：8输入 → 4输出（使用weight_i[1]选择）
    oprand_mux #(.WIDTH(16)) mux2_0 (
        .opA(lut_1_0), .opB(lut_1_1), .sel(weight_i[1]), .out(lut_2_0)
    );
    oprand_mux #(.WIDTH(16)) mux2_1 (
        .opA(lut_1_2), .opB(lut_1_3), .sel(weight_i[1]), .out(lut_2_1)
    );
    oprand_mux #(.WIDTH(16)) mux2_2 (
        .opA(lut_1_4), .opB(lut_1_5), .sel(weight_i[1]), .out(lut_2_2)
    );
    oprand_mux #(.WIDTH(16)) mux2_3 (
        .opA(lut_1_6), .opB(lut_1_7), .sel(weight_i[1]), .out(lut_2_3)
    );

    // 第三级MUX：4输入 → 2输出（使用weight_i[2]选择）
    oprand_mux #(.WIDTH(16)) mux3_0 (
        .opA(lut_2_0), .opB(lut_2_1), .sel(weight_i[2]), .out(lut_3_0)
    );
    oprand_mux #(.WIDTH(16)) mux3_1 (
        .opA(lut_2_2), .opB(lut_2_3), .sel(weight_i[2]), .out(lut_3_1)
    );

    // 第四级MUX：2输入 → 1输出（使用weight_i[3]选择）
    oprand_mux #(.WIDTH(16)) mux4_0 (
        .opA(lut_3_0), .opB(lut_3_1), .sel(weight_i[3]), .out(lut_4_0)
    );

    // 最终输出
    assign lut_o = lut_4_0;

endmodule

