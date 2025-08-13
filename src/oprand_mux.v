`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 16:35:14
// Design Name: 
// Module Name: oprand_mux
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


module oprand_mux#(
    parameter WIDTH = 32
)
(
    input  wire [WIDTH-1:0] opA,
    input  wire [WIDTH-1:0] opB,
    input  wire             sel,
    output wire [WIDTH-1:0] out
    );
    assign out = sel ? opB : opA;
endmodule
