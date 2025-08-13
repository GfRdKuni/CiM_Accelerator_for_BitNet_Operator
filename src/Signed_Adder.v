`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 16:14:43
// Design Name: 
// Module Name: Signed_Adder
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


module Signed_Adder#(
    parameter WIDTH = 16
)
(
    input  wire [WIDTH-1:0] in1 ,
    input  wire [WIDTH-1:0] in2 ,
    output wire [WIDTH-1:0] out
    );
    assign out = in1 + in2;
endmodule
