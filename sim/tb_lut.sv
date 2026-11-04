`timescale 1ns / 1ps
module tb_lut;
    parameter CASES = 216;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n_i = 0, en = 0;
    reg [31:0] a = 0, b = 0, c = 0;
    reg [4:0] code = 0;
    wire [31:0] lut [0:7];
    wire [15:0] partial, magnitude;
    wire sign;
    reg [119:0] cases [0:CASES-1];
    reg [15:0] expected;
    reg [31:0] held;
    Preprocesser pre (
        .clk(clk), .rst_n_i(rst_n_i), .Act0_i(a), .Act1_i(b), .Act2_i(c),
        .dff_en_i(en), .LUT_entries_0_o(lut[0]), .LUT_entries_1_o(lut[1]),
        .LUT_entries_2_o(lut[2]), .LUT_entries_3_o(lut[3]),
        .LUT_entries_4_o(lut[4]), .LUT_entries_5_o(lut[5]),
        .LUT_entries_6_o(lut[6]), .LUT_entries_7_o(lut[7])
    );
    LUT_MUX mux (
        .lut_0_0_i(lut[0]), .lut_0_1_i(lut[1]), .lut_0_2_i(lut[2]),
        .lut_0_3_i(lut[3]), .lut_0_4_i(lut[4]), .lut_0_5_i(lut[5]),
        .lut_0_6_i(lut[6]), .lut_0_7_i(lut[7]),
        .weight_i(code[3:0]), .lut_o(partial)
    );
    Sign_Gen signs (.partial_result(partial), .sign(code[4]),
                    .result_magnitude(magnitude), .result_sign(sign));
    initial begin
        $readmemh("lut_cases.hex", cases);
        for (integer i = 0; i < CASES; i = i+1)
            if ((^cases[i]) === 1'bx) $fatal(1, "Unknown or missing LUT vector %0d", i);
        repeat (2) @(negedge clk);
        rst_n_i = 1;
        for (integer i = 0; i < CASES; i = i+1) begin
            @(negedge clk);
            a = cases[i][31:0]; b = cases[i][63:32]; c = cases[i][95:64];
            code = cases[i][100:96]; expected = cases[i][116:101]; en = 1;
            @(posedge clk); #1;
            if ((sign ? (~magnitude+16'd1) : magnitude) !== expected)
                $fatal(1, "LUT/sign mismatch case=%0d code=%h got_sign=%b magnitude=%h expected=%h",
                       i, code, sign, magnitude, expected);
        end
        @(negedge clk);
        en = 0; held = lut[7]; a = 12345; b = 6789; c = 42;
        @(posedge clk); #1;
        if (lut[7] !== held) $fatal(1, "LUT register ignored enable");
        $display("PASS LUT/sign: %0d cases (all 27 ternary triples, saturation, register hold)", CASES);
        $finish;
    end
endmodule
