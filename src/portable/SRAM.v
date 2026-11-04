`timescale 1ns / 1ps

// Portable alternative to the missing generated SRAM IP. Select this file OR
// vendor modules with these names. Read/write collisions are outside the contract.
module CiM_SRAM #(
    parameter ADDR_WIDTH = 2
) (
    input wire clka, ena, wea,
    input wire [ADDR_WIDTH-1:0] addra,
    input wire [255:0] dina,
    input wire clkb, enb, regceb,
    input wire [ADDR_WIDTH-1:0] addrb,
    output reg [255:0] doutb
);
    reg [255:0] memory [0:(1 << ADDR_WIDTH)-1];
    reg [255:0] read_data;
    always @(posedge clka)
        if (ena && wea) memory[addra] <= dina;
    always @(posedge clkb) begin
        if (enb) read_data <= memory[addrb];
        if (regceb) doutb <= read_data;
    end
endmodule

module SRAM_D4W256 (
    input wire clka, ena, wea,
    input wire [1:0] addra,
    input wire [255:0] dina,
    input wire clkb, enb, regceb,
    input wire [1:0] addrb,
    output wire [255:0] doutb
);
    CiM_SRAM #(.ADDR_WIDTH(2)) memory (
        .clka(clka), .ena(ena), .wea(wea), .addra(addra), .dina(dina),
        .clkb(clkb), .enb(enb), .regceb(regceb), .addrb(addrb), .doutb(doutb)
    );
endmodule

module SRAM_D32W256 (
    input wire clka, ena, wea,
    input wire [4:0] addra,
    input wire [255:0] dina,
    input wire clkb, enb, regceb,
    input wire [4:0] addrb,
    output wire [255:0] doutb
);
    CiM_SRAM #(.ADDR_WIDTH(5)) memory (
        .clka(clka), .ena(ena), .wea(wea), .addra(addra), .dina(dina),
        .clkb(clkb), .enb(enb), .regceb(regceb), .addrb(addrb), .doutb(doutb)
    );
endmodule
