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


module Adder_Tree_8_to_1 ( // Dual Adder Tree
    input  wire [127:0] in_vec,     // 8个16位输入合并为128位向量（[15:0]~[127:112]）
    input  wire [7:0]   sign_vec,   // 符号位（未使用）
    output wire [15:0]  out         // 累加结果
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


wire [15:0] pos_in [7:0];
wire [15:0] neg_in [7:0];

genvar i;  // 声明generate循环变量（必须在generate外声明）
// generate循环：批量生成8组pos_in/neg_in的赋值语句
generate
    for(i = 0; i < 8; i = i + 1) begin : gen_pos_neg_in  // 循环必须加标签（gen_pos_neg_in）
        // pos_in[i]：sign_vec[i]=0 → 取in[i]，否则取16位0
        assign pos_in[i] = (sign_vec[i] == 1'b0) ? in[i] : 16'b0;
        // neg_in[i]：sign_vec[i]=1 → 取in[i]，否则取16位0
        assign neg_in[i] = (sign_vec[i] == 1'b1) ? in[i] : 16'b0;
    end
endgenerate



// POS Tree
// 内部中间级信号
wire [15:0] pos_level0 [3:0];  // 第0级：4个中间结果（8→4）
wire [15:0] pos_level1 [1:0];  // 第1级：2个中间结果（4→2）
wire [15:0] pos_out;           // 第2级：最终结果（2→1）

// 第0级加法器
Signed_Adder #(.WIDTH(16)) u_Adder_L0_0 (
    .in1(pos_in[0]), .in2(pos_in[1]), .out(pos_level0[0])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_1 (
    .in1(pos_in[2]), .in2(pos_in[3]), .out(pos_level0[1])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_2 (
    .in1(pos_in[4]), .in2(pos_in[5]), .out(pos_level0[2])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L0_3 (
    .in1(pos_in[6]), .in2(pos_in[7]), .out(pos_level0[3])
);

// 第1级加法器
Signed_Adder #(.WIDTH(16)) u_Adder_L1_0 (
    .in1(pos_level0[0]), .in2(pos_level0[1]), .out(pos_level1[0])
);
Signed_Adder #(.WIDTH(16)) u_Adder_L1_1 (
    .in1(pos_level0[2]), .in2(pos_level0[3]), .out(pos_level1[1])
);

// 第2级加法器（最终结果）
Signed_Adder #(.WIDTH(16)) u_Adder_L2 (
    .in1(pos_level1[0]), .in2(pos_level1[1]), .out(pos_out)
);

// NEG Tree
// 内部中间级信号
wire [15:0] neg_level0 [3:0];  // 第0级
wire [15:0] neg_level1 [1:0];  // 第1级
wire [15:0] neg_out;           // 第2级
// 第0级加法器
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L0_0 (
    .in1(neg_in[0]), .in2(neg_in[1]), .out(neg_level0[0])
);
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L0_1 (
    .in1(neg_in[2]), .in2(neg_in[3]), .out(neg_level0[1])
);
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L0_2 (
    .in1(neg_in[4]), .in2(neg_in[5]), .out(neg_level0[2])
);
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L0_3 (
    .in1(neg_in[6]), .in2(neg_in[7]), .out(neg_level0[3])
);  
// 第1级加法器
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L1_0 (
    .in1(neg_level0[0]), .in2(neg_level0[1]), .out(neg_level1[0])
);
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L1_1 (
    .in1(neg_level0[2]), .in2(neg_level0[3]), .out(neg_level1[1])
);
// 第2级加法器（最终结果）
Signed_Adder #(.WIDTH(16)) u_Neg_Adder_L2 (
    .in1(neg_level1[0]), .in2(neg_level1[1]), .out(neg_out)
);  

// 最终输出
wire [15:0] out_magnitude;
wire out_sign;
assign out_magnitude = (pos_out >= neg_out) ? (pos_out - neg_out) : (neg_out - pos_out);
assign out_sign = (pos_out >= neg_out) ? 1'b0 : 1'b1;
assign out = out_sign ? (~out_magnitude + 1'b1) : out_magnitude;

endmodule
