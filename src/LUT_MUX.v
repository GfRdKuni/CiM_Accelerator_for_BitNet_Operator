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
    input  wire [31:0] lut_0_0_i   ,
    input  wire [31:0] lut_0_1_i   ,
    input  wire [31:0] lut_0_2_i   ,
    input  wire [31:0] lut_0_3_i   ,
    input  wire [31:0] lut_0_4_i   ,
    input  wire [31:0] lut_0_5_i   ,
    input  wire [31:0] lut_0_6_i   ,
    input  wire [31:0] lut_0_7_i   ,
    /*
    input  wire [15:0] lut_0_8_i   ,
    input  wire [15:0] lut_0_9_i   ,
    input  wire [15:0] lut_0_10_i  ,
    input  wire [15:0] lut_0_11_i  ,
    input  wire [15:0] lut_0_12_i  ,
    input  wire [15:0] lut_0_13_i  ,
    input  wire [15:0] lut_0_14_i  ,
    input  wire [15:0] lut_0_15_i  ,
    */
    input  wire [3:0]  weight_i    ,
    output reg [15:0] lut_o
);
    wire [31:0] mux_o;
    wire [31:0] lut_o_int;
    wire [31:0] adder_o;
    // MUX old version
    // // 中间信号定义（每级MUX输出）
    // wire [15:0] lut_1_0, lut_1_1, lut_1_2, lut_1_3, lut_1_4, lut_1_5, lut_1_6, lut_1_7;
    // wire [15:0] lut_2_0, lut_2_1, lut_2_2, lut_2_3;
    // wire [15:0] lut_3_0, lut_3_1;
    // wire [15:0] lut_4_0;

    // // 第一级MUX：16输入 → 8输出（使用weight_i[0]选择）
    // oprand_mux #(.WIDTH(16)) mux1_0 (
    //     .opA(lut_0_0_i),  .opB(lut_0_1_i),  .sel(weight_i[0]), .out(lut_1_0)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_1 (
    //     .opA(lut_0_2_i),  .opB(lut_0_3_i),  .sel(weight_i[0]), .out(lut_1_1)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_2 (
    //     .opA(lut_0_4_i),  .opB(lut_0_5_i),  .sel(weight_i[0]), .out(lut_1_2)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_3 (
    //     .opA(lut_0_6_i),  .opB(lut_0_7_i),  .sel(weight_i[0]), .out(lut_1_3)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_4 (
    //     .opA(lut_0_8_i),  .opB(lut_0_9_i),  .sel(weight_i[0]), .out(lut_1_4)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_5 (
    //     .opA(lut_0_10_i), .opB(lut_0_11_i), .sel(weight_i[0]), .out(lut_1_5)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_6 (
    //     .opA(lut_0_12_i), .opB(lut_0_13_i), .sel(weight_i[0]), .out(lut_1_6)
    // );
    // oprand_mux #(.WIDTH(16)) mux1_7 (
    //     .opA(lut_0_14_i), .opB(lut_0_15_i), .sel(weight_i[0]), .out(lut_1_7)
    // );

    // // 第二级MUX：8输入 → 4输出（使用weight_i[1]选择）
    // oprand_mux #(.WIDTH(16)) mux2_0 (
    //     .opA(lut_1_0), .opB(lut_1_1), .sel(weight_i[1]), .out(lut_2_0)
    // );
    // oprand_mux #(.WIDTH(16)) mux2_1 (
    //     .opA(lut_1_2), .opB(lut_1_3), .sel(weight_i[1]), .out(lut_2_1)
    // );
    // oprand_mux #(.WIDTH(16)) mux2_2 (
    //     .opA(lut_1_4), .opB(lut_1_5), .sel(weight_i[1]), .out(lut_2_2)
    // );
    // oprand_mux #(.WIDTH(16)) mux2_3 (
    //     .opA(lut_1_6), .opB(lut_1_7), .sel(weight_i[1]), .out(lut_2_3)
    // );

    // // 第三级MUX：4输入 → 2输出（使用weight_i[2]选择）
    // oprand_mux #(.WIDTH(16)) mux3_0 (
    //     .opA(lut_2_0), .opB(lut_2_1), .sel(weight_i[2]), .out(lut_3_0)
    // );
    // oprand_mux #(.WIDTH(16)) mux3_1 (
    //     .opA(lut_2_2), .opB(lut_2_3), .sel(weight_i[2]), .out(lut_3_1)
    // );

    // // 第四级MUX：2输入 → 1输出（使用weight_i[3]选择）
    // oprand_mux #(.WIDTH(16)) mux4_0 (
    //     .opA(lut_3_0), .opB(lut_3_1), .sel(weight_i[3]), .out(lut_4_0)
    // );

    // // 最终输出
    // assign lut_o = lut_4_0;

    // MUX new version
    // LUT MUX
    assign lut_o_int = (weight_i == 4'b0001) ? lut_0_0_i :
                       (weight_i == 4'b0010) ? lut_0_1_i :
                       (weight_i == 4'b0100) ? lut_0_2_i :
                       (weight_i == 4'b0111) ? lut_0_3_i :
                       (weight_i == 4'b1000) ? lut_0_4_i :
                       (weight_i == 4'b1101) ? lut_0_5_i :
                       (weight_i == 4'b1110) ? lut_0_6_i :
                       (weight_i == 4'b1111) ? lut_0_7_i :
                       32'h0000_0000;

    // Adder
    wire [31:0] oprand_1, oprand_2;
    assign oprand_1 = (weight_i == 4'b1001 | weight_i == 4'b1010) ? lut_0_4_i :
                      (weight_i == 4'b0101 | weight_i == 4'b0110) ? lut_0_2_i :
                      (weight_i == 4'b0011) ? lut_0_1_i : 32'h0000_0000;

    assign oprand_2 = (weight_i == 4'b1001 | weight_i == 4'b0011 | weight_i == 4'b0101) ? lut_0_0_i :
                      (weight_i == 4'b1010 | weight_i == 4'b0110) ? lut_0_1_i : 32'h0000_0000;

    Signed_Adder #(32) u_Signed_Adder (
        .in1 (oprand_1),
        .in2 (oprand_2),
        .out (adder_o )
    );


    assign mux_o = (weight_i == 4'b0000) ? 32'h0000_0000 :
                   ((^weight_i) | (&weight_i)) ? lut_o_int              :
                   adder_o;

    always @(*) begin
        if(~mux_o[31] && |mux_o[30:15]) lut_o = 16'b0111_1111_1111_1111;
        else if (mux_o[31] && ~(&mux_o[30:15])) lut_o = 16'b1000_0000_0000_0000;
        else lut_o = mux_o[15:0];
    end


endmodule

