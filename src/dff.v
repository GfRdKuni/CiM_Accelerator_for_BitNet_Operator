`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 14:45:03
// Design Name: 
// Module Name: dff
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


module dff#(
    parameter WIDTH = 1
)(
    input  wire                clk      ,
    input  wire                rst_n_i  ,
    input  wire                en_i     ,
    input  wire    [WIDTH-1:0] d_i      ,
    output reg     [WIDTH-1:0] q_o      
    );

    always @(posedge clk or negedge rst_n_i) begin
        if(!rst_n_i) begin
            q_o <= 0;
        end 
        else if(en_i) begin
            q_o <= d_i;
        end
        else begin
            q_o <= q_o;
        end
    end

endmodule
