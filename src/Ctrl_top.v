`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/12 16:21:25
// Design Name: 
// Module Name: Ctrl_top
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


module Ctrl_top(
    // 输入接口
    input  wire          clk           ,  // 时钟信号
    input  wire          rst_n_i       ,  // 异步复位信号（低有效）
    input  wire          valid_in_i_act,  // 输入有效信号
    input  wire          valid_in_i_wm ,  // 输入有效信号
    input  wire          valid_in_i_ws ,  // 输入有效信号
    input  wire          ready_out_i   ,  // 外部就绪信号
    
    // 输出接口
    output reg           valid_out_o   ,  // 输出有效信号
    output wire          ready_in_o_act,  // 内部就绪信号
    output wire          ready_in_o_wm ,  // 内部就绪信号
    output wire          ready_in_o_ws ,  // 内部就绪信号
    output wire          dff_en_i      ,  // D触发器使能信号
    output wire          dff_en_i_q_o  ,  // D触发器使能信号的延迟版本
    output wire          acc_dff_en_i  ,  // 输出D触发器使能信号,这个信号实际是累加器内部的寄存器的使能信号
    output wire          out_dff_en_i  ,  // 输出D触发器使能信号
    output wire          ASRAM_wen0    ,  // ASRAM写使能0
    output wire          ASRAM_wen1    ,  // ASRAM写使能1
    output wire          ASRAM_wen2    ,  // ASRAM写使能2
    output reg  [1:0]    ASRAM_waddr0  ,  // ASRAM写地址0
    output reg  [1:0]    ASRAM_waddr1  ,  // ASRAM写地址1
    output reg  [1:0]    ASRAM_waddr2  ,  // ASRAM写地址2
    output wire          ASRAM_ren_in  ,  // ASRAM输入读使能
    output wire          ASRAM_ren_out ,  // ASRAM输出读使能
    output wire [1:0]    ASRAM_raddr   ,  // ASRAM读地址
    output wire          WMSRAM_wen0   ,  // WMSRAM写使能0
    output wire          WMSRAM_wen1   ,  // WMSRAM写使能1
    output wire          WMSRAM_wen2   ,  // WMSRAM写使能2
    output wire          WMSRAM_wen3   ,  // WMSRAM写使能3
    output wire [4:0]    WMSRAM_waddr0 ,  // WMSRAM写地址0
    output wire [4:0]    WMSRAM_waddr1 ,  // WMSRAM写地址1
    output wire [4:0]    WMSRAM_waddr2 ,  // WMSRAM写地址2
    output wire [4:0]    WMSRAM_waddr3 ,  // WMSRAM写地址3
    output wire          WMSRAM_ren_in ,  // WMSRAM输入读使能
    output wire          WMSRAM_ren_out,  // WMSRAM输出读使能
    output wire [4:0]    WMSRAM_raddr  ,  // WMSRAM读地址
    output wire          WSSRAM_wen    ,  // WSSRAM写使能
    output wire          WSSRAM_ren_in ,  // WSSRAM输入读使能
    output wire          WSSRAM_ren_out,  // WSSRAM输出读使能
    output wire [4:0]    WSSRAM_raddr  ,  // WSSRAM读地址
    output wire [4:0]    WSSRAM_waddr  ,  // WSSRAM写地址
    output wire          oprand_sel       // 操作数选择信号（待补充逻辑）
    );
    // 这是一个基于状态机的控制子系统
    // 用于产生SRAM的读写控制信号
    // 流水线中寄存器的使能信号
    // 累加器中MUX的选择信号

    /****************************
    State List
    IDLE      :  3'b000 
    LOAD_ACT  :  3'b001 
    LOAD_WM   :  3'b010
    LOAD_WS   :  3'b011
    SYS_INIT0 :  3'b100
    SYS_INIT1 :  3'b101
    CLAC      :  3'b110
    WAIT      :  3'b111 Maybe another output register is needed
    *****************************/
    localparam IDLE      = 3'b000;
    localparam LOAD_ACT  = 3'b001;
    localparam LOAD_WM   = 3'b010;
    localparam LOAD_WS   = 3'b011;
    localparam SYS_INIT0 = 3'b100;
    localparam SYS_INIT1 = 3'b101;
    localparam CALC      = 3'b110;
    localparam WAIT      = 3'b111;

    reg [2:0] state;
    reg [2:0] next_state;
    reg [3:0] ACT_LOAD_cnt;
    reg [6:0] WM_LOAD_cnt;
    reg [4:0] WS_LOAD_cnt;
    reg [5:0] Act_Input_cnt;
    reg [5:0] Weight_Input_cnt;
    reg [5:0] Input_cnt;
    reg [5:0] Output_cnt;

    always @(posedge clk or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
           IDLE: begin
                if(ASRAM_wen0) 
                    next_state = LOAD_ACT;
                else
                    next_state = IDLE;
           end 
           LOAD_ACT: begin
                if (ACT_LOAD_cnt == 4'd11 && ASRAM_wen2)
                    next_state = LOAD_WM;
                else
                    next_state = LOAD_ACT;
           end
           LOAD_WM: begin
                if (WM_LOAD_cnt == 7'd127 && WMSRAM_wen3)
                    next_state = LOAD_WS;
                else
                    next_state = LOAD_WM;    
           end
           LOAD_WS: begin
                if (WS_LOAD_cnt == 5'd31 && WSSRAM_wen)
                    next_state = SYS_INIT0;
                else
                    next_state = LOAD_WS;
           end
           SYS_INIT0: begin
                next_state = SYS_INIT1;
           end
           SYS_INIT1: begin
                next_state = CALC;
           end
           CALC: begin
                if (Output_cnt == 6'd32)
                    next_state = WAIT;
                else
                    next_state = CALC;
           end
           WAIT: begin
                if (ready_out_i && valid_out_o)
                    next_state = IDLE;
                else
                    next_state = WAIT;
           end
        endcase
    end

    // IDLE/LOAD_ACT
    always @(posedge clk or negedge rst_n_i) begin
        if (!rst_n_i) begin
            ACT_LOAD_cnt <= 0;
        end
        else if (ACT_LOAD_cnt == 4'd11 && ASRAM_wen2) begin
            ACT_LOAD_cnt <= 0;
        end
        else if (ASRAM_wen0 || ASRAM_wen1 || ASRAM_wen2) begin
            ACT_LOAD_cnt <= ACT_LOAD_cnt + 1;
        end
        else begin
            ACT_LOAD_cnt <= ACT_LOAD_cnt;
        end
    end

    wire   w_act_pos_0, w_act_pos_1, w_act_pos_2;
    assign w_act_pos_0 = ((state == LOAD_ACT) && ((ACT_LOAD_cnt == 4'd3) || (ACT_LOAD_cnt == 4'd6) || (ACT_LOAD_cnt == 4'd9))) || ((state == IDLE) && ACT_LOAD_cnt == 4'd0);
    assign w_act_pos_1 = ((state == LOAD_ACT) && ((ACT_LOAD_cnt == 4'd1) || (ACT_LOAD_cnt == 4'd4) || (ACT_LOAD_cnt == 4'd7) || (ACT_LOAD_cnt == 4'd10)));
    assign w_act_pos_2 = ((state == LOAD_ACT) && ((ACT_LOAD_cnt == 4'd2) || (ACT_LOAD_cnt == 4'd5) || (ACT_LOAD_cnt == 4'd8) || (ACT_LOAD_cnt == 4'd11)));
    assign ASRAM_wen0 = w_act_pos_0 && valid_in_i_act && ready_in_o_act;
    assign ASRAM_wen1 = w_act_pos_1 && valid_in_i_act && ready_in_o_act;
    assign ASRAM_wen2 = w_act_pos_2 && valid_in_i_act && ready_in_o_act;
    
    always @(*) begin
        if (ASRAM_wen0)
            case(ACT_LOAD_cnt)
                4'd0 : ASRAM_waddr0 = 2'b00;
                4'd3 : ASRAM_waddr0 = 2'b01;
                4'd6 : ASRAM_waddr0 = 2'b10;
                4'd9 : ASRAM_waddr0 = 2'b11;
                default : ASRAM_waddr0 = 2'b00;
            endcase
        else
            ASRAM_waddr0 = 2'b00;
    end

    always @(*) begin
        if (ASRAM_wen1)
            case(ACT_LOAD_cnt)
                4'd1 : ASRAM_waddr1 = 2'b00;
                4'd4 : ASRAM_waddr1 = 2'b01;
                4'd7 : ASRAM_waddr1 = 2'b10;
                4'd10: ASRAM_waddr1 = 2'b11;
                default : ASRAM_waddr1 = 2'b00;
            endcase
        else
            ASRAM_waddr1 = 2'b00;
    end

    always @(*) begin
        if (ASRAM_wen2)
            case(ACT_LOAD_cnt)
                4'd2 : ASRAM_waddr2 = 2'b00;
                4'd5 : ASRAM_waddr2 = 2'b01;
                4'd8 : ASRAM_waddr2 = 2'b10;
                4'd11: ASRAM_waddr2 = 2'b11;
                default : ASRAM_waddr2 = 2'b00;
            endcase
        else
            ASRAM_waddr2 = 2'b00;
    end
    
    // LOAD_WM
    always @(posedge clk or negedge rst_n_i) begin
        if (!rst_n_i) begin
            WM_LOAD_cnt <= 0;
        end
        else if (WM_LOAD_cnt == 7'd127 && WMSRAM_wen3) begin
            WM_LOAD_cnt <= 0;
        end
        else if (WMSRAM_wen0 || WMSRAM_wen1 || WMSRAM_wen2 || WMSRAM_wen3) begin
            WM_LOAD_cnt <= WM_LOAD_cnt + 1;
        end
        else begin
            WM_LOAD_cnt <= WM_LOAD_cnt;
        end
    end

    wire   w_wm_pos_0, w_wm_pos_1, w_wm_pos_2, w_wm_pos_3;
    assign w_wm_pos_0 = (state == LOAD_WM) && (WM_LOAD_cnt[1:0] == 2'b00);
    assign w_wm_pos_1 = (state == LOAD_WM) && (WM_LOAD_cnt[1:0] == 2'b01);
    assign w_wm_pos_2 = (state == LOAD_WM) && (WM_LOAD_cnt[1:0] == 2'b10);
    assign w_wm_pos_3 = (state == LOAD_WM) && (WM_LOAD_cnt[1:0] == 2'b11);
    assign WMSRAM_wen0 = w_wm_pos_0 && valid_in_i_wm && ready_in_o_wm;
    assign WMSRAM_wen1 = w_wm_pos_1 && valid_in_i_wm && ready_in_o_wm;
    assign WMSRAM_wen2 = w_wm_pos_2 && valid_in_i_wm && ready_in_o_wm;
    assign WMSRAM_wen3 = w_wm_pos_3 && valid_in_i_wm && ready_in_o_wm;
    assign WMSRAM_waddr0 = WM_LOAD_cnt[6:2] & ({5{WMSRAM_wen0}});
    assign WMSRAM_waddr1 = WM_LOAD_cnt[6:2] & ({5{WMSRAM_wen1}});
    assign WMSRAM_waddr2 = WM_LOAD_cnt[6:2] & ({5{WMSRAM_wen2}});
    assign WMSRAM_waddr3 = WM_LOAD_cnt[6:2] & ({5{WMSRAM_wen3}});

    // LOAD_WS
    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            WS_LOAD_cnt <= 0;
        end
        else if (WSSRAM_wen && WS_LOAD_cnt == 5'd31) begin
            WS_LOAD_cnt <= 0;
        end
        else if (WSSRAM_wen) begin
            WS_LOAD_cnt <= WS_LOAD_cnt + 1;
        end
        else begin
            WS_LOAD_cnt <= WS_LOAD_cnt;
        end
    end

    assign WSSRAM_wen = (state == LOAD_WS) && valid_in_i_ws && ready_in_o_ws;
    assign WSSRAM_waddr = WS_LOAD_cnt & ({5{WSSRAM_wen}});

    // ready_in_o
    assign ready_in_o_act = (state == IDLE || state == LOAD_ACT);
    assign ready_in_o_wm  = (state == LOAD_WM);
    assign ready_in_o_ws  = (state == LOAD_WS);

    // SYS_INIT0 & SYS_INIT1 & CALC
    assign ASRAM_ren_in  = (state == SYS_INIT0 || state == SYS_INIT1 || state == CALC) && (Act_Input_cnt    != 6'd32) && (~valid_out_o);
    assign ASRAM_ren_out = (                      state == SYS_INIT1 || state == CALC) && (Weight_Input_cnt != 6'd32) && (~valid_out_o);
    assign WMSRAM_ren_in = (                      state == SYS_INIT1 || state == CALC) && (Weight_Input_cnt != 6'd32) && (~valid_out_o);
    assign WSSRAM_ren_in = (                      state == SYS_INIT1 || state == CALC) && (Weight_Input_cnt != 6'd32) && (~valid_out_o);
    // Contact directly with the calc module
    assign WSSRAM_ren_out= (state == CALC && Input_cnt != 6'd32) && (~valid_out_o);
    assign dff_en_i      = (state == CALC && Input_cnt != 6'd32) && (~valid_out_o); 
    assign WMSRAM_ren_out= (state == CALC && Input_cnt != 6'd32) && (~valid_out_o);

    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            Act_Input_cnt <= 0;
        end
        else if (WS_LOAD_cnt == 5'd31 && WSSRAM_wen)
            Act_Input_cnt <= 0;
        else if (ASRAM_ren_in && Act_Input_cnt == 6'd32) begin
            Act_Input_cnt <= Act_Input_cnt;
        end
        else if (ASRAM_ren_in) begin
            Act_Input_cnt <= Act_Input_cnt + 1;
        end
        else begin
            Act_Input_cnt <= Act_Input_cnt;
        end
    end

    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            Weight_Input_cnt <= 0;
        end
        else if (WS_LOAD_cnt == 5'd31 && WSSRAM_wen)
            Weight_Input_cnt <= 0;
        else if (WMSRAM_ren_in && Weight_Input_cnt == 6'd32) begin
            Weight_Input_cnt <= Weight_Input_cnt;
        end
        else if (WMSRAM_ren_in) begin
            Weight_Input_cnt <= Weight_Input_cnt + 1;
        end
        else begin
            Weight_Input_cnt <= Weight_Input_cnt;
        end
    end

    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            Input_cnt <= 6'd0;
        end
        else if (state == SYS_INIT1) begin
            Input_cnt <= 6'd0;
        end
        else if (dff_en_i && Input_cnt == 6'd32) begin
            Input_cnt <= Input_cnt;
        end
        else if (dff_en_i) begin
            Input_cnt <= Input_cnt + 1;
        end
        else begin
            Input_cnt <= Input_cnt;
        end
    end

    assign ASRAM_raddr  = Act_Input_cnt[1:0];
    assign WMSRAM_raddr = Weight_Input_cnt[4:0];
    assign WSSRAM_raddr = Weight_Input_cnt[4:0];

    wire result_valid;
    wire dff_en_i_q;
    dff #(1) u_dff_en_0 (.clk(clk), .rst_n_i(rst_n_i), .en_i(~valid_out_o), .d_i(dff_en_i), .q_o(dff_en_i_q));
    dff #(1) u_dff_en_1 (.clk(clk), .rst_n_i(rst_n_i), .en_i(~valid_out_o), .d_i(dff_en_i_q), .q_o(result_valid));
    assign dff_en_i_q_o = dff_en_i_q & ~valid_out_o;
    

    assign acc_dff_en_i = result_valid && ~valid_out_o;

    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            Output_cnt <= 6'd0;
        end
        else if (Output_cnt == 6'd32 && ~valid_out_o) begin
            Output_cnt <= 6'd0;
        end
        else if (acc_dff_en_i) begin
            Output_cnt <= Output_cnt + 1;
        end
        else begin
            Output_cnt <= Output_cnt;
        end
    end

    assign oprand_sel = ~(Output_cnt[1:0] == 2'b00);
    assign out_dff_en_i = ((~oprand_sel && Output_cnt != 6'd0) || (Output_cnt == 6'd32)) && ~valid_out_o;
    // 最后一级可能会存在valid/ready握手以避免结果被覆盖
    always @(posedge clk or negedge rst_n_i) begin
        if (~rst_n_i) begin
            valid_out_o <= 0;
        end
        else if (out_dff_en_i) begin
            valid_out_o <= 1;
        end
        else if (ready_out_i) begin
            valid_out_o <= 0;
        end
        else begin
            valid_out_o <= valid_out_o;
        end
    end

endmodule
