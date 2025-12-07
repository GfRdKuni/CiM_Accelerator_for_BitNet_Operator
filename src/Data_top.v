`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/09 16:41:34
// Design Name: 
// Module Name: Data_top
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


module Data_top(
    input  wire          clk           ,
    input  wire          rst_n_i       ,
    input  wire  [255:0] data_i_act    ,
    input  wire  [255:0] data_i_wm     ,
    input  wire  [255:0] data_i_ws     ,
    input  wire          dff_en_i      ,
    input  wire          dff_en_i_q_o  ,
    input  wire          acc_dff_en_i  ,
    input  wire          out_dff_en_i  ,
    input  wire          ASRAM_wen0    ,  // ASRAM写使能0
    input  wire          ASRAM_wen1    ,  // ASRAM写使能1
    input  wire          ASRAM_wen2    ,  // ASRAM写使能2
    input  wire [1:0]    ASRAM_waddr0  ,  // ASRAM写地址0
    input  wire [1:0]    ASRAM_waddr1  ,  // ASRAM写地址1
    input  wire [1:0]    ASRAM_waddr2  ,  // ASRAM写地址2
    input  wire          ASRAM_ren_in  ,  // ASRAM输入读使能
    input  wire          ASRAM_ren_out ,  // ASRAM输出读使能
    input  wire [1:0]    ASRAM_raddr   ,  // ASRAM读地址
    input  wire          WMSRAM_wen0   ,  // WMSRAM写使能0
    input  wire          WMSRAM_wen1   ,  // WMSRAM写使能1
    input  wire          WMSRAM_wen2   ,  // WMSRAM写使能2
    input  wire          WMSRAM_wen3   ,  // WMSRAM写使能3
    input  wire [4:0]    WMSRAM_waddr0 ,  // WMSRAM写地址0
    input  wire [4:0]    WMSRAM_waddr1 ,  // WMSRAM写地址1
    input  wire [4:0]    WMSRAM_waddr2 ,  // WMSRAM写地址2
    input  wire [4:0]    WMSRAM_waddr3 ,  // WMSRAM写地址3
    input  wire          WMSRAM_ren_in ,  // WMSRAM输入读使能
    input  wire          WMSRAM_ren_out,  // WMSRAM输出读使能
    input  wire [4:0]    WMSRAM_raddr  ,  // WMSRAM读地址
    input  wire          WSSRAM_wen    ,  // WSSRAM写使能
    input  wire          WSSRAM_ren_in ,  // WSSRAM输入读使能
    input  wire          WSSRAM_ren_out,  // WSSRAM输出读使能
    input  wire [4:0]    WSSRAM_raddr  ,  // WSSRAM读地址
    input  wire [4:0]    WSSRAM_waddr  ,  // WSSRAM写地址
    input  wire          oprand_sel    ,   // 操作数选择信号（待补充逻辑）
    
    // output
    output wire  [31:0]  result_0_o    ,
    output wire  [31:0]  result_1_o    ,
    output wire  [31:0]  result_2_o    ,
    output wire  [31:0]  result_3_o    ,
    output wire  [31:0]  result_4_o    ,
    output wire  [31:0]  result_5_o    ,
    output wire  [31:0]  result_6_o    ,
    output wire  [31:0]  result_7_o    ,
    output wire  [31:0]  result_8_o    ,
    output wire  [31:0]  result_9_o    ,
    output wire  [31:0]  result_10_o   ,
    output wire  [31:0]  result_11_o   ,
    output wire  [31:0]  result_12_o   ,
    output wire  [31:0]  result_13_o   ,
    output wire  [31:0]  result_14_o   ,
    output wire  [31:0]  result_15_o   ,
    output wire  [31:0]  result_16_o   ,
    output wire  [31:0]  result_17_o   ,
    output wire  [31:0]  result_18_o   ,
    output wire  [31:0]  result_19_o   ,
    output wire  [31:0]  result_20_o   ,
    output wire  [31:0]  result_21_o   ,
    output wire  [31:0]  result_22_o   ,
    output wire  [31:0]  result_23_o   ,
    output wire  [31:0]  result_24_o   ,
    output wire  [31:0]  result_25_o   ,
    output wire  [31:0]  result_26_o   ,
    output wire  [31:0]  result_27_o   ,
    output wire  [31:0]  result_28_o   ,
    output wire  [31:0]  result_29_o   ,
    output wire  [31:0]  result_30_o   ,
    output wire  [31:0]  result_31_o
    );

    // All these control signals are empty, need to be filled in later
    // We must pay attention to the order of the data
    wire [/*256*3-1 = */ 767:0] ASRAM_dout;

    SRAM_D4W256 activation_memory_bank0(
        .clka  (clk)          ,             // Maybe need to change
        .ena   (ASRAM_wen0)   ,
        .wea   (1'b1)         ,
        .addra (ASRAM_waddr0) ,
        .dina  (data_i_act)   ,
        .clkb  (clk)          ,              // Maybe need to change
        .enb   (ASRAM_ren_in) ,
        .regceb(ASRAM_ren_out),
        .addrb (ASRAM_raddr)  ,
        .doutb (ASRAM_dout[255:0])  
    );

    SRAM_D4W256 activation_memory_bank1(
        .clka  (clk)          ,             // Maybe need to change
        .ena   (ASRAM_wen1)   ,
        .wea   (1'b1)         ,
        .addra (ASRAM_waddr1) ,
        .dina  (data_i_act)   ,
        .clkb  (clk)          ,              // Maybe need to change
        .enb   (ASRAM_ren_in) ,
        .regceb(ASRAM_ren_out),
        .addrb (ASRAM_raddr)  ,
        .doutb (ASRAM_dout[511:256])  
    );

    SRAM_D4W256 activation_memory_bank2(
        .clka  (clk)          ,             // Maybe need to change
        .ena   (ASRAM_wen2)   ,
        .wea   (1'b1)         ,
        .addra (ASRAM_waddr2) ,
        .dina  (data_i_act)   ,
        .clkb  (clk)          ,              // Maybe need to change
        .enb   (ASRAM_ren_in) ,
        .regceb(ASRAM_ren_out),
        .addrb (ASRAM_raddr)  ,
        .doutb (ASRAM_dout[767:512])  
    );

    wire signed [31:0] pre_LUT_o [7:0][7:0];

    generate
    genvar j;
    for (j = 0; j < 8; j = j + 1) begin : preprocesser_inst
        Preprocesser u_Preprocesser (
            .clk                 (clk)                              ,
            .rst_n_i             (rst_n_i)                          ,
            .Act0_i              (ASRAM_dout[96*j + 31 : 96*j])     ,
            .Act1_i              (ASRAM_dout[96*j + 63 : 96*j + 32]),
            .Act2_i              (ASRAM_dout[96*j + 95 : 96*j + 64]),
            .dff_en_i            (dff_en_i)                         ,
            // 模块输出连接到线网数组
            .LUT_entries_0_o     (pre_LUT_o[j][0])                  ,
            .LUT_entries_1_o     (pre_LUT_o[j][1])                  ,
            .LUT_entries_2_o     (pre_LUT_o[j][2])                  ,
            .LUT_entries_3_o     (pre_LUT_o[j][3])                  ,
            .LUT_entries_4_o     (pre_LUT_o[j][4])                  ,
            .LUT_entries_5_o     (pre_LUT_o[j][5])                  ,
            .LUT_entries_6_o     (pre_LUT_o[j][6])                  ,
            .LUT_entries_7_o     (pre_LUT_o[j][7])                  
        );
    end
    endgenerate
    // 例化8×32个LUT MUX模块
    wire [15:0]        LUT_MUX_result [7:0][31:0];
    wire [1023:0]      WM                        ;
    wire [1023:0]      WMSRAM_dout               ;
    assign WM        = WMSRAM_dout               ;

    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin : LUT_MUX_row
            for (j = 0; j < 32; j = j + 1) begin : LUT_MUX_col
                LUT_MUX u_LUT_MUX (
                    .lut_0_0_i (pre_LUT_o[i][0])                    ,
                    .lut_0_1_i (pre_LUT_o[i][1])                    ,
                    .lut_0_2_i (pre_LUT_o[i][2])                    ,
                    .lut_0_3_i (pre_LUT_o[i][3])                    ,
                    .lut_0_4_i (pre_LUT_o[i][4])                    ,
                    .lut_0_5_i (pre_LUT_o[i][5])                    ,
                    .lut_0_6_i (pre_LUT_o[i][6])                    ,
                    .lut_0_7_i (pre_LUT_o[i][7])                    ,
                    .weight_i  (WM[4*i + 32*j + 3:4*i + 32*j])      ,                            
                    .lut_o     (LUT_MUX_result[i][j])
                );
            end
        end
    endgenerate




    // 例化8×32个Sign_Gen模块

    wire [15:0]        result_magnitude_d [7:0][31:0];
    wire [15:0]        result_magnitude   [7:0][31:0];
    wire               result_sign_d      [7:0][31:0];
    wire               result_sign        [7:0][31:0];
    wire [255:0]       WS                         ;        // 256位外部sign信号,连接到存储器
    wire [255:0]       WSSRAM_dout                ;
    assign WS        = WSSRAM_dout                ;
    
    generate
    // i：模块行索引（0~7），j：模块列索引（0~31）
    for (i = 0; i < 8; i = i + 1) begin : sign_gen_row
        for (j = 0; j < 32; j = j + 1) begin : sign_gen_col
            Sign_Gen u_Sign_Gen (
                .partial_result  (LUT_MUX_result[i][j])        ,     // 第i,j个输入来自pre_LUT_o[i][j]
                .sign            (WS[8*j+i])                   ,     // 第i,j个模块的sign信号来自WS[32*i + j]
                .result_magnitude(result_magnitude_d[i][j])    ,     // 输出到第i,j个结果
                .result_sign     (result_sign_d[i][j])
            );
            dff  #(16) u_sign_gen_dff  (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i_q_o), .d_i(result_magnitude_d[i][j]), .q_o(result_magnitude[i][j]));
            dff  #(1)  u_sign_gen_dff2 (.clk(clk), .rst_n_i(rst_n_i), .en_i(dff_en_i_q_o), .d_i(result_sign_d[i][j]),
                .q_o(result_sign[i][j]));
        end
    end
    endgenerate

    // 例化WMSRAM模块 由4个D32W256的SRAM组成
    // All these control signals are empty, need to be filled in later
    SRAM_D32W256 WM_SRAM_bank0(
        .clka  (clk)                   ,             // Maybe need to change
        .ena   (WMSRAM_wen0)           ,
        .wea   (1'b1)                  ,
        .addra (WMSRAM_waddr0)         ,
        .dina  (data_i_wm)             ,
        .clkb  (clk)                   ,              // Maybe need to change
        .enb   (WMSRAM_ren_in)         ,
        .regceb(WMSRAM_ren_out)        ,
        .addrb (WMSRAM_raddr)          ,
        .doutb (WMSRAM_dout[255:0])  
    );

    SRAM_D32W256 WM_SRAM_bank1(
        .clka  (clk)                   ,             // Maybe need to change
        .ena   (WMSRAM_wen1)           ,
        .wea   (1'b1)                  ,
        .addra (WMSRAM_waddr1)         ,
        .dina  (data_i_wm)             ,
        .clkb  (clk)                   ,              // Maybe need to change
        .enb   (WMSRAM_ren_in)         ,
        .regceb(WMSRAM_ren_out)        ,
        .addrb (WMSRAM_raddr)          ,
        .doutb (WMSRAM_dout[511:256])  
    );

    SRAM_D32W256 WM_SRAM_bank2(
        .clka  (clk)                   ,             // Maybe need to change
        .ena   (WMSRAM_wen2)           ,
        .wea   (1'b1)                  ,
        .addra (WMSRAM_waddr2)         ,
        .dina  (data_i_wm)             ,
        .clkb  (clk)                   ,              // Maybe need to change
        .enb   (WMSRAM_ren_in)         ,
        .regceb(WMSRAM_ren_out)        ,
        .addrb (WMSRAM_raddr)          ,
        .doutb (WMSRAM_dout[767:512])  
    );

    SRAM_D32W256 WM_SRAM_bank3(
        .clka  (clk)                   ,             // Maybe need to change
        .ena   (WMSRAM_wen3)           ,
        .wea   (1'b1)                  ,
        .addra (WMSRAM_waddr3)         ,
        .dina  (data_i_wm)             ,
        .clkb  (clk)                   ,              // Maybe need to change
        .enb   (WMSRAM_ren_in)         ,
        .regceb(WMSRAM_ren_out)        ,
        .addrb (WMSRAM_raddr)          ,
        .doutb (WMSRAM_dout[1023:768])  
    );


    // 例化WSSRAM模块 由1个D32W256的SRAM组成
    // All these control signals are empty, need to be filled in later
    SRAM_D32W256 WS_SRAM(
        .clka  (clk)                   ,             // Maybe need to change
        .ena   (WSSRAM_wen)            ,
        .wea   (1'b1)                  ,
        .addra (WSSRAM_waddr)          ,
        .dina  (data_i_ws)             ,
        .clkb  (clk)                   ,              // Maybe need to change
        .enb   (WSSRAM_ren_in)         ,
        .regceb(WSSRAM_ren_out)        ,
        .addrb (WSSRAM_raddr)          ,
        .doutb (WSSRAM_dout)
    );




    // 例化Adder_Tree模块 需要把相同的j的8个结果按照树形结构累加起来
    wire [15:0] tree_result [31:0];




    // 生成32个Adder_Tree_8_to_1模块
    generate
        for (j = 0; j < 32; j = j + 1) begin : Adder_Tree_Array
            Adder_Tree_8_to_1 u_Adder_Tree_8_to_1 (
                // 将8个16位数据拼接为128位向量（顺序与模块内部拆分对应）
                .in_vec   ( {result_magnitude[7][j], result_magnitude[6][j], result_magnitude[5][j], result_magnitude[4][j],
                           result_magnitude[3][j], result_magnitude[2][j], result_magnitude[1][j], result_magnitude[0][j]} ),
                .sign_vec ( {result_sign[7][j], result_sign[6][j], result_sign[5][j], result_sign[4][j],
                           result_sign[3][j], result_sign[2][j], result_sign[1][j], result_sign[0][j]} ),
                .out      ( tree_result[j] )  // 输出当前j的累加结果
            );
        end
    endgenerate


    // accumulator 
    wire [31:0] acc_result    [31:0];
    wire [31:0] acc_result_int[31:0];
    generate
    genvar acc_item;
    for (acc_item = 0; acc_item < 32; acc_item = acc_item + 1) begin : acc_array
        Accumulator u_Accumulator (
            .clk          (clk),
            .rst_n_i      (rst_n_i),
            .acc_dff_en_i (acc_dff_en_i),
            .oprand_sel   (oprand_sel),  // 共享选择信号
            .tree_data    (tree_result[acc_item]),  // 对应索引的tree_result输入
            .acc_out      (acc_result[acc_item])    // 对应索引的累加结果
        );
    end
    endgenerate

    dff #(32) u_output_dff0(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[0]), .q_o(result_0_o));
    dff #(32) u_output_dff1(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[1]), .q_o(result_1_o));
    dff #(32) u_output_dff2(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[2]), .q_o(result_2_o));
    dff #(32) u_output_dff3(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[3]), .q_o(result_3_o));
    dff #(32) u_output_dff4(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[4]), .q_o(result_4_o));
    dff #(32) u_output_dff5(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[5]), .q_o(result_5_o));
    dff #(32) u_output_dff6(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[6]), .q_o(result_6_o));
    dff #(32) u_output_dff7(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[7]), .q_o(result_7_o));
    dff #(32) u_output_dff8(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[8]), .q_o(result_8_o));
    dff #(32) u_output_dff9(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[9]), .q_o(result_9_o));
    dff #(32) u_output_dff10(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[10]), .q_o(result_10_o));
    dff #(32) u_output_dff11(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[11]), .q_o(result_11_o));
    dff #(32) u_output_dff12(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[12]), .q_o(result_12_o));
    dff #(32) u_output_dff13(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[13]), .q_o(result_13_o));
    dff #(32) u_output_dff14(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[14]), .q_o(result_14_o));
    dff #(32) u_output_dff15(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[15]), .q_o(result_15_o));
    dff #(32) u_output_dff16(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[16]), .q_o(result_16_o));
    dff #(32) u_output_dff17(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[17]), .q_o(result_17_o));
    dff #(32) u_output_dff18(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[18]), .q_o(result_18_o));
    dff #(32) u_output_dff19(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[19]), .q_o(result_19_o));
    dff #(32) u_output_dff20(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[20]), .q_o(result_20_o));
    dff #(32) u_output_dff21(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[21]), .q_o(result_21_o));
    dff #(32) u_output_dff22(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[22]), .q_o(result_22_o));
    dff #(32) u_output_dff23(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[23]), .q_o(result_23_o));
    dff #(32) u_output_dff24(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[24]), .q_o(result_24_o));
    dff #(32) u_output_dff25(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[25]), .q_o(result_25_o));
    dff #(32) u_output_dff26(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[26]), .q_o(result_26_o));
    dff #(32) u_output_dff27(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[27]), .q_o(result_27_o));
    dff #(32) u_output_dff28(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[28]), .q_o(result_28_o));
    dff #(32) u_output_dff29(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[29]), .q_o(result_29_o));
    dff #(32) u_output_dff30(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[30]), .q_o(result_30_o));
    dff #(32) u_output_dff31(.clk(clk), .rst_n_i(rst_n_i), .en_i(out_dff_en_i), .d_i(acc_result[31]), .q_o(result_31_o));

        
    

    


endmodule
