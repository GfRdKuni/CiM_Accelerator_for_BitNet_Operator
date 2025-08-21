`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/08 21:27:09
// Design Name: 
// Module Name: Preprocesser
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


module Preprocesser(
    input  wire               clk                 ,
    input  wire               rst_n_i             ,
    input  wire signed [31:0] Act0_i              ,
    input  wire signed [31:0] Act1_i              ,
    input  wire signed [31:0] Act2_i              ,
    input  wire               dff_en_i            ,
    output wire  signed [15:0] LUT_entries_0_o     ,
    output wire  signed [15:0] LUT_entries_1_o     ,
    output wire  signed [15:0] LUT_entries_2_o     ,
    output wire  signed [15:0] LUT_entries_3_o     ,
    output wire  signed [15:0] LUT_entries_4_o     ,
    output wire  signed [15:0] LUT_entries_5_o     ,
    output wire  signed [15:0] LUT_entries_6_o     ,
    output wire  signed [15:0] LUT_entries_7_o     ,
    output wire  signed [15:0] LUT_entries_8_o     ,
    output wire  signed [15:0] LUT_entries_9_o     ,
    output wire  signed [15:0] LUT_entries_10_o    ,
    output wire  signed [15:0] LUT_entries_11_o    ,
    output wire  signed [15:0] LUT_entries_12_o    ,
    output wire  signed [15:0] LUT_entries_13_o    ,
    output wire  signed [15:0] LUT_entries_14_o    ,
    output wire  signed [15:0] LUT_entries_15_o
    );

    wire [31:0] LUT_entries_0     ;
    wire [31:0] LUT_entries_1     ;
    wire [31:0] LUT_entries_2     ;
    wire [31:0] LUT_entries_3     ;
    wire [31:0] LUT_entries_4     ;
    wire [31:0] LUT_entries_5     ;
    wire [31:0] LUT_entries_6     ;
    wire [31:0] LUT_entries_7     ;
    wire [31:0] LUT_entries_8     ;
    wire [31:0] LUT_entries_9     ;
    wire [31:0] LUT_entries_10    ;
    wire [31:0] LUT_entries_11    ;
    wire [31:0] LUT_entries_12    ;
    wire [31:0] LUT_entries_13    ;
    wire [31:0] LUT_entries_14    ;
    wire [31:0] LUT_entries_15    ;
    reg  [15:0] LUT_entries_0_sat ;
    reg  [15:0] LUT_entries_1_sat ;
    reg  [15:0] LUT_entries_2_sat ;
    reg  [15:0] LUT_entries_3_sat ;
    reg  [15:0] LUT_entries_4_sat ;
    reg  [15:0] LUT_entries_5_sat ;
    reg  [15:0] LUT_entries_6_sat ;
    reg  [15:0] LUT_entries_7_sat ;
    reg  [15:0] LUT_entries_8_sat ;
    reg  [15:0] LUT_entries_9_sat ;
    reg  [15:0] LUT_entries_10_sat;
    reg  [15:0] LUT_entries_11_sat;
    reg  [15:0] LUT_entries_12_sat;
    reg  [15:0] LUT_entries_13_sat;
    reg  [15:0] LUT_entries_14_sat;
    reg  [15:0] LUT_entries_15_sat;

    assign LUT_entries_15  = 16'b0000_0000_0000_0000 ;
    assign LUT_entries_14  = 16'b0000_0000_0000_0000 ;
    assign LUT_entries_13  = Act0_i + Act1_i + Act2_i;
    assign LUT_entries_12  = Act0_i + Act1_i         ;
    assign LUT_entries_11  = Act0_i + Act1_i - Act2_i;
    assign LUT_entries_10  = Act0_i          + Act2_i;
    assign LUT_entries_9   = Act0_i                  ;
    assign LUT_entries_8   = Act0_i          - Act2_i;
    assign LUT_entries_7   = Act0_i - Act1_i + Act2_i;
    assign LUT_entries_6   = Act0_i - Act1_i         ;
    assign LUT_entries_5   = Act0_i - Act1_i - Act2_i;
    assign LUT_entries_4   =          Act1_i + Act2_i;
    assign LUT_entries_3   =          Act1_i         ;
    assign LUT_entries_2   =          Act1_i - Act2_i;
    assign LUT_entries_1   =                   Act2_i;
    assign LUT_entries_0   = 16'b0000_0000_0000_0000 ;
    /*************************************************************
    *      Entries   Weight     Code       Weight_n     Code     *     
    *      0         0  0  0   0 0000      0  0  0     1 0000    *
    *      1         0  0  1   0 0001      0  0 -1     1 0001    *
    *      2         0  1 -1   0 0010      0 -1  1     1 0010    *
    *      3         0  1  0   0 0011      0 -1  0     1 0011    *
    *      4         0  1  1   0 0100      0 -1 -1     1 0100    *
    *      5         1 -1 -1   0 0101     -1  1  1     1 0101    *
    *      6         1 -1  0   0 0110     -1  1  0     1 0110    *
    *      7         1 -1  1   0 0111     -1  1 -1     1 0111    *
    *      8         1  0 -1   0 1000     -1  0  1     1 1000    *
    *      9         1  0  0   0 1001     -1  0  0     1 1001    *
    *      10        1  0  1   0 1010     -1  0 -1     1 1010    *
    *      11        1  1 -1   0 1011     -1 -1  1     1 1011    *
    *      12        1  1  0   0 1100     -1 -1  0     1 1100    *
    *      13        1  1  1   0 1101     -1 -1 -1     1 1101    *
    *      14        NULL      0 1110       NULL       1 1110    *
    *      15        NULL      0 1111       NULL       1 1111    *
    **************************************************************/
    // Saturation
    always @(*) begin
        if(~LUT_entries_0[31] && |LUT_entries_0[30:15]) LUT_entries_0_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_0[31] && ~(&LUT_entries_0[30:15])) LUT_entries_0_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_0_sat = LUT_entries_0[15:0];
    end

    always @(*) begin
        if(~LUT_entries_1[31] && |LUT_entries_1[30:15]) LUT_entries_1_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_1[31] && ~(&LUT_entries_1[30:15])) LUT_entries_1_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_1_sat = LUT_entries_1[15:0];
    end

    always @(*) begin
        if(~LUT_entries_2[31] && |LUT_entries_2[30:15]) LUT_entries_2_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_2[31] && ~(&LUT_entries_2[30:15])) LUT_entries_2_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_2_sat = LUT_entries_2[15:0];
    end

    always @(*) begin
        if(~LUT_entries_3[31] && |LUT_entries_3[30:15]) LUT_entries_3_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_3[31] && ~(&LUT_entries_3[30:15])) LUT_entries_3_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_3_sat = LUT_entries_3[15:0];
    end

    always @(*) begin
        if(~LUT_entries_4[31] && |LUT_entries_4[30:15]) LUT_entries_4_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_4[31] && ~(&LUT_entries_4[30:15])) LUT_entries_4_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_4_sat = LUT_entries_4[15:0];
    end

    always @(*) begin
        if(~LUT_entries_5[31] && |LUT_entries_5[30:15]) LUT_entries_5_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_5[31] && ~(&LUT_entries_5[30:15])) LUT_entries_5_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_5_sat = LUT_entries_5[15:0];
    end

    always @(*) begin
        if(~LUT_entries_6[31] && |LUT_entries_6[30:15]) LUT_entries_6_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_6[31] && ~(&LUT_entries_6[30:15])) LUT_entries_6_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_6_sat = LUT_entries_6[15:0];
    end

    always @(*) begin
        if(~LUT_entries_7[31] && |LUT_entries_7[30:15]) LUT_entries_7_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_7[31] && ~(&LUT_entries_7[30:15])) LUT_entries_7_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_7_sat = LUT_entries_7[15:0];
    end

    always @(*) begin
        if(~LUT_entries_8[31] && |LUT_entries_8[30:15]) LUT_entries_8_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_8[31] && ~(&LUT_entries_8[30:15])) LUT_entries_8_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_8_sat = LUT_entries_8[15:0];
    end

    always @(*) begin
        if(~LUT_entries_9[31] && |LUT_entries_9[30:15]) LUT_entries_9_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_9[31] && ~(&LUT_entries_9[30:15])) LUT_entries_9_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_9_sat = LUT_entries_9[15:0];
    end

    always @(*) begin
        if(~LUT_entries_10[31] && |LUT_entries_10[30:15]) LUT_entries_10_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_10[31] && ~(&LUT_entries_10[30:15])) LUT_entries_10_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_10_sat = LUT_entries_10[15:0];
    end

    always @(*) begin
        if(~LUT_entries_11[31] && |LUT_entries_11[30:15]) LUT_entries_11_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_11[31] && ~(&LUT_entries_11[30:15])) LUT_entries_11_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_11_sat = LUT_entries_11[15:0];
    end

    always @(*) begin
        if(~LUT_entries_12[31] && |LUT_entries_12[30:15]) LUT_entries_12_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_12[31] && ~(&LUT_entries_12[30:15])) LUT_entries_12_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_12_sat = LUT_entries_12[15:0];
    end

    always @(*) begin
        if(~LUT_entries_13[31] && |LUT_entries_13[30:15]) LUT_entries_13_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_13[31] && ~(&LUT_entries_13[30:15])) LUT_entries_13_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_13_sat = LUT_entries_13[15:0];
    end

    always @(*) begin
        if(~LUT_entries_14[31] && |LUT_entries_14[30:15]) LUT_entries_14_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_14[31] && ~(&LUT_entries_14[30:15])) LUT_entries_14_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_14_sat = LUT_entries_14[15:0];
    end

    always @(*) begin
        if(~LUT_entries_15[31] && |LUT_entries_15[30:15]) LUT_entries_15_sat = 16'b0111_1111_1111_1111;
        else if (LUT_entries_15[31] && ~(&LUT_entries_15[30:15])) LUT_entries_15_sat = 16'b1000_0000_0000_0000;
        else LUT_entries_15_sat = LUT_entries_15[15:0];
    end
    
    dff #(16) dff_LUT_entries_0  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_0_sat) , .q_o(LUT_entries_0_o) );
    dff #(16) dff_LUT_entries_1  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_1_sat) , .q_o(LUT_entries_1_o) );
    dff #(16) dff_LUT_entries_2  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_2_sat) , .q_o(LUT_entries_2_o) );
    dff #(16) dff_LUT_entries_3  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_3_sat) , .q_o(LUT_entries_3_o) );
    dff #(16) dff_LUT_entries_4  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_4_sat) , .q_o(LUT_entries_4_o) );
    dff #(16) dff_LUT_entries_5  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_5_sat) , .q_o(LUT_entries_5_o) );
    dff #(16) dff_LUT_entries_6  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_6_sat) , .q_o(LUT_entries_6_o) );
    dff #(16) dff_LUT_entries_7  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_7_sat) , .q_o(LUT_entries_7_o) );
    dff #(16) dff_LUT_entries_8  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_8_sat) , .q_o(LUT_entries_8_o) );
    dff #(16) dff_LUT_entries_9  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_9_sat) , .q_o(LUT_entries_9_o) );
    dff #(16) dff_LUT_entries_10 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_10_sat), .q_o(LUT_entries_10_o));
    dff #(16) dff_LUT_entries_11 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_11_sat), .q_o(LUT_entries_11_o));
    dff #(16) dff_LUT_entries_12 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_12_sat), .q_o(LUT_entries_12_o));
    dff #(16) dff_LUT_entries_13 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_13_sat), .q_o(LUT_entries_13_o));
    dff #(16) dff_LUT_entries_14 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_14_sat), .q_o(LUT_entries_14_o));
    dff #(16) dff_LUT_entries_15 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i), .d_i(LUT_entries_15_sat), .q_o(LUT_entries_15_o));

endmodule
