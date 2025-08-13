`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/13 16:34:40
// Design Name: 
// Module Name: Adder_Tree_8_to_1
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


module Adder_Tree_8_to_1 (
    input  wire [127:0] in_vec,  // 8个16位输入合并为128位向量（[15:0]~[127:112]）
    output wire [15:0]  out      // 累加结果
);

// 内部拆分：将128位向量拆分为8个16位数据（对应原in[0]~in[7]）
wire [15:0] in [7:0];
assign in[0] = in_vec[15:0];    // 第0个输入
assign in[1] = in_vec[31:16];   // 第1个输入
assign in[2] = in_vec[47:32];   // 第2个输入
assign in[3] = in_vec[63:48];   // 第3个输入
assign in[4] = in_vec[79:64];   // 第4个输入
assign in[5] = in_vec[95:80];   // 第5个输入
assign in[6] = in_vec[111:96];  // 第6个输入
assign in[7] = in_vec[127:112]; // 第7个输入

// 内部中间级信号
wire [15:0] level0 [3:0];  // 第0级：4个中间结果（8→4）
wire [15:0] level1 [1:0];  // 第1级：2个中间结果（4→2）

// 第0级加法器
Signed_Adder #(.WIDTH(16)) u_Adder_L0_0 (
    .in1(in[0]), .in2(in[1]), .out(level0[0])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_1 (
    .in1(in[2]), .in2(in[3]), .out(level0[1])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_2 (
    .in1(in[4]), .in2(in[5]), .out(level0[2])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_3 (
    .in1(in[6]), .in2(in[7]), .out(level0[3])
);

// 第1级加法器
Signed_Adder #(.WIDTH(16)) u_Adder_L1_0 (
    .in1(level0[0]), .in2(level0[1]), .out(level1[0])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L1_1 (
    .in1(level0[2]), .in2(level0[3]), .out(level1[1])
);

// 第2级加法器（最终结果）
Signed_Adder #(.WIDTH(16)) u_Adder_L2 (
    .in1(level1[0]), .in2(level1[1]), .out(out)
);

endmodule
