`timescale 1ns / 1ps
module tb_portable;
    parameter LANES = 2;
    parameter JOBS = 3;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n_i = 0;
    reg [LANES-1:0] valid_in_i_act = 0, valid_in_i_wm = 0, valid_in_i_ws = 0;
    reg [LANES-1:0] ready_out_i = 0;
    reg [LANES*256-1:0] data_i_act = 0, data_i_wm = 0, data_i_ws = 0;
    wire [LANES-1:0] valid_out_o, ready_in_o_act, ready_in_o_wm, ready_in_o_ws;
    wire [LANES*32-1:0] result [0:31];
    reg [255:0] act [0:LANES*JOBS*12-1];
    reg [255:0] wm [0:LANES*JOBS*128-1];
    reg [255:0] ws [0:LANES*JOBS*32-1];
    reg [31:0] expected [0:LANES*JOBS*256-1];
    integer received [0:LANES-1];
    reg [LANES-1:0] done = 0, stalled = 0;
    reg [31:0] held [0:LANES-1][0:31];
    integer cycles = 0, stall_mode = 0;

    Para_Top #(.PARA_WIDTH(LANES)) dut (
        .clk(clk), .rst_n_i(rst_n_i),
        .valid_in_i_act(valid_in_i_act), .valid_in_i_wm(valid_in_i_wm),
        .valid_in_i_ws(valid_in_i_ws), .ready_out_i(ready_out_i),
        .data_i_act(data_i_act), .data_i_wm(data_i_wm), .data_i_ws(data_i_ws),
        .valid_out_o(valid_out_o), .ready_in_o_act(ready_in_o_act),
        .ready_in_o_wm(ready_in_o_wm), .ready_in_o_ws(ready_in_o_ws),
        .result_0_o(result[0]), .result_1_o(result[1]),
        .result_2_o(result[2]), .result_3_o(result[3]),
        .result_4_o(result[4]), .result_5_o(result[5]),
        .result_6_o(result[6]), .result_7_o(result[7]),
        .result_8_o(result[8]), .result_9_o(result[9]),
        .result_10_o(result[10]), .result_11_o(result[11]),
        .result_12_o(result[12]), .result_13_o(result[13]),
        .result_14_o(result[14]), .result_15_o(result[15]),
        .result_16_o(result[16]), .result_17_o(result[17]),
        .result_18_o(result[18]), .result_19_o(result[19]),
        .result_20_o(result[20]), .result_21_o(result[21]),
        .result_22_o(result[22]), .result_23_o(result[23]),
        .result_24_o(result[24]), .result_25_o(result[25]),
        .result_26_o(result[26]), .result_27_o(result[27]),
        .result_28_o(result[28]), .result_29_o(result[29]),
        .result_30_o(result[30]), .result_31_o(result[31])
    );

    initial begin
        if ($value$plusargs("STALL=%d", stall_mode)) begin end
        $readmemh("act.hex", act);
        $readmemh("wm.hex", wm);
        $readmemh("ws.hex", ws);
        $readmemh("expected.hex", expected);
        for (integer i = 0; i < LANES*JOBS*12; i = i+1)
            if ((^act[i]) === 1'bx) $fatal(1, "Unknown activation vector %0d", i);
        for (integer i = 0; i < LANES*JOBS*128; i = i+1)
            if ((^wm[i]) === 1'bx) $fatal(1, "Unknown weight vector %0d", i);
        for (integer i = 0; i < LANES*JOBS*32; i = i+1)
            if ((^ws[i]) === 1'bx) $fatal(1, "Unknown weight sign vector %0d", i);
        for (integer i = 0; i < LANES*JOBS*256; i = i+1)
            if ((^expected[i]) === 1'bx) $fatal(1, "Unknown expectation %0d", i);
        for (integer lane = 0; lane < LANES; lane = lane+1) received[lane] = 0;
        repeat (3) @(negedge clk);
        rst_n_i = 1;
        wait (&done);
        repeat (10) @(negedge clk);
        if (valid_out_o !== 0 || ready_in_o_act !== {LANES{1'b1}})
            $fatal(1, "Controller did not return to idle after repeated transactions");
        rst_n_i = 0;
        #1;
        if (valid_out_o !== 0) $fatal(1, "Output valid did not clear on reset");
        for (integer row = 0; row < 32; row = row+1)
            if (result[row] !== 0) $fatal(1, "Output data did not clear on reset");
        $display("PASS public Para_Top: lanes=%0d jobs=%0d checked=%0d stalled=%0d cycles=%0d",
                 LANES, JOBS, LANES*JOBS*256, stall_mode, cycles);
        $finish;
    end

    always @(negedge clk) begin
        for (integer lane = 0; lane < LANES; lane = lane+1)
            ready_out_i[lane] = rst_n_i &&
                (!stall_mode || ((cycles + lane*7) % 11 == 0));
    end

    always @(posedge clk) begin : monitor
        integer index;
        cycles = cycles + 1;
        if (cycles > JOBS*(1000+LANES*100)+1000)
            $fatal(1, "Timeout: missing input/output completion");
        if (rst_n_i) begin
            for (integer lane = 0; lane < LANES; lane = lane+1) begin
                if (stalled[lane]) begin
                    if (valid_out_o[lane] !== 1) $fatal(1, "Valid dropped during stall");
                    for (integer row = 0; row < 32; row = row+1)
                        if (result[row][lane*32 +: 32] !== held[lane][row])
                            $fatal(1, "Output changed during backpressure lane=%0d", lane);
                end
                stalled[lane] = valid_out_o[lane] && !ready_out_i[lane];
                for (integer row = 0; row < 32; row = row+1)
                    held[lane][row] = result[row][lane*32 +: 32];
                if (valid_out_o[lane] && ready_out_i[lane]) begin
                    if (received[lane] >= JOBS*8) $fatal(1, "Unexpected extra result");
                    index = ((received[lane]/8)*LANES + lane)*256 + (received[lane]%8)*32;
                    for (integer row = 0; row < 32; row = row+1)
                        if (result[row][lane*32 +: 32] !== expected[index+row])
                            $fatal(1, "Mismatch lane=%0d batch=%0d row=%0d got=%h expected=%h",
                                   lane, received[lane], row,
                                   result[row][lane*32 +: 32], expected[index+row]);
                    received[lane] = received[lane]+1;
                end
            end
        end
    end

    // Each lane runs independently. Drive only on falling edges and sample
    // acceptance on rising edges, including real gaps between input beats.
    for (genvar lane = 0; lane < LANES; lane = lane+1) begin : drivers
        initial begin
            wait (rst_n_i);
            for (integer job = 0; job < JOBS; job = job+1) begin
                for (integer word = 0; word < 12; word = word+1) begin
                    if ((word+lane+job)%5 == 0) repeat (2+lane) @(negedge clk);
                    @(negedge clk);
                    data_i_act[lane*256 +: 256] = act[(job*LANES+lane)*12+word];
                    valid_in_i_act[lane] = 1;
                    @(posedge clk);
                    while (!ready_in_o_act[lane]) @(posedge clk);
                    @(negedge clk);
                    valid_in_i_act[lane] = 0;
                end
                for (integer word = 0; word < 128; word = word+1) begin
                    if ((word+lane+job)%7 == 0) repeat (1+lane) @(negedge clk);
                    @(negedge clk);
                    data_i_wm[lane*256 +: 256] = wm[(job*LANES+lane)*128+word];
                    valid_in_i_wm[lane] = 1;
                    @(posedge clk);
                    while (!ready_in_o_wm[lane]) @(posedge clk);
                    @(negedge clk);
                    valid_in_i_wm[lane] = 0;
                end
                for (integer word = 0; word < 32; word = word+1) begin
                    if ((word+lane+job)%3 == 0) repeat (1+lane) @(negedge clk);
                    @(negedge clk);
                    data_i_ws[lane*256 +: 256] = ws[(job*LANES+lane)*32+word];
                    valid_in_i_ws[lane] = 1;
                    @(posedge clk);
                    while (!ready_in_o_ws[lane]) @(posedge clk);
                    @(negedge clk);
                    valid_in_i_ws[lane] = 0;
                end
                wait (received[lane] == (job+1)*8);
            end
            done[lane] = 1;
        end
    end
endmodule
