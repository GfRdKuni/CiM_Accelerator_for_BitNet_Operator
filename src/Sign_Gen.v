`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 16:03:57
// Design Name: 
// Module Name: Sign_Gen
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


module Sign_Gen(
    input  wire [15:0]partial_result  ,
    input  wire       sign            ,
    output wire [15:0]signed_result   
    );
    assign signed_result = sign ? (~partial_result + 1'b1) : partial_result;
endmodule
