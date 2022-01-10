`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/15 22:01:04
// Design Name: 
// Module Name: TopModule
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

module BigClockDiv(
    CLK_100MHz, RST_n,
    CLK_slice, CLK_sec
);
    input CLK_100MHz;
    input RST_n;
    output CLK_slice;
    output CLK_sec;

    parameter cir_sec = 32'd100_000_000;
    parameter cir_sli = 32'd250_000;

    reg [31:0] sec_cnt = 0;
    reg [31:0] sli_cnt = 0;
    reg sig_sli = 0;
    reg sig_sec = 0;

    always @(posedge CLK_100MHz or negedge RST_n) begin
        if (!RST_n) begin
            sec_cnt <= 32'd0;
            sli_cnt <= 32'd0;
        end
        else begin
            // check cir_sec
            if (sec_cnt >= cir_sec / 2 - 1) begin
                sec_cnt <= 0;
                sig_sec <= ~sig_sec;
            end
            else begin
                sec_cnt <= sec_cnt + 1;
            end
            // check cir_sli
            if (sli_cnt >= cir_sli / 2 - 1) begin
                sli_cnt <= 0;
                sig_sli <= ~sig_sli;
            end
            else begin
                sli_cnt <= sli_cnt + 1;
            end
        end
    end

    assign CLK_slice = sig_sli;
    assign CLK_sec = sig_sec;
endmodule

module RegularClockDiv(
    CLK_100MHz, RST_n,
    CLK_VGA
);
    input CLK_100MHz;
    input RST_n;
    output reg CLK_VGA = 0;

    reg [1:0] CLK_buf = 2'b0;

    always @(posedge CLK_100MHz) begin
        if (!RST_n) begin
            CLK_buf <= 2'd0;
            CLK_VGA <= 0;
        end
        else if (CLK_buf == 2'd1) begin
            CLK_buf <= 2'd0;
            CLK_VGA = ~CLK_VGA;
        end
        else begin
            CLK_buf <= CLK_buf + 1;
        end
    end
endmodule

// edge debouncer
/*
module EdgeDebouncer(
    CLK_100MHz, CLK_slice, BTN,
    BTN_o
);
    input CLK_100MHz, CLK_slice, BTN;
    output BTN_o;
    reg [2:0] btn_history = 3'b0;

    always @(posedge CLK_100MHz) begin
        if (CLK_slice) begin
            btn_history <= { BTN, btn_history[2:1] };
        end
    end

    assign BTN_o = CLK_slice & (btn_history[1] & ~btn_history[0]);
endmodule
*/
module EdgeDebouncer(
    CLK_100MHz, CLK_slice, BTN,
    BTN_o
);
    input CLK_100MHz, CLK_slice, BTN;
    output BTN_o;
    reg [2:0] btn_history = 3'b0;

    always @(posedge CLK_100MHz) begin
        btn_history <= { BTN, btn_history[2:1] };
    end

    assign BTN_o = (btn_history[1] & ~btn_history[0]);
endmodule

module TopModule(
        CLK_100MHz, // 100MHz clock signal
        BTN_L, BTN_R, BTN_U, BTN_D, BTN_C, // buttons
        RST_n, error_note, // global reset & error switch
        R_s, G_s, B_s, Hsync, Vsync, // VGA signals
        get_bluetooth,
        test_map, test_mask, test_cur, inited, // test signals
        led, anode // led signals
    );
    input CLK_100MHz;
    input BTN_L, BTN_R, BTN_U, BTN_D, BTN_C;
    input RST_n;
    input get_bluetooth;
    input error_note;
    output [3:0] R_s, G_s, B_s;
    output Hsync, Vsync;
    // the following ports are for testing usage,
    // and will be removed from the release version.
    output [3:0] test_map;
    output [3:0] test_mask;
    output [3:0] test_cur;
    output inited;

    output [7:0] led;
    output [7:0] anode;

    assign led = 8'd0;
    assign anode = 8'd0;

    // parameters
    parameter state_init = 4'd0;
    parameter state_gaming = 4'd1;
    parameter state_end = 4'd2;

    // state machine
    reg [3:0] glob_state = state_init;
    wire init_tag = (glob_state == state_gaming);

    // clock divider
    wire CLK_sec, CLK_slice;
    wire CLK_VGA;
    RegularClockDiv clk_div1(
        .CLK_100MHz(CLK_100MHz), .RST_n(RST_n),
        .CLK_VGA(CLK_VGA)
    );
    BigClockDiv clk_div2(
        .CLK_100MHz(CLK_100MHz), .RST_n(RST_n),
        .CLK_sec(CLK_sec), .CLK_slice(CLK_slice)
    );

    // edge debouncer
    wire UP, DOWN, LEFT, RIGHT, CENTER;
    EdgeDebouncer up_deb(CLK_100MHz, CLK_slice, BTN_U, UP);
    EdgeDebouncer dn_deb(CLK_100MHz, CLK_slice, BTN_D, DOWN);
    EdgeDebouncer lt_deb(CLK_100MHz, CLK_slice, BTN_L, LEFT);
    EdgeDebouncer rt_deb(CLK_100MHz, CLK_slice, BTN_R, RIGHT);
    EdgeDebouncer ct_deb(CLK_100MHz, CLK_slice, BTN_C, CENTER);

    // bluetooth
    wire [7:0] sig_bt;
    wire [3:0] sig_num;
    wire sig_bt_en;
    bluetooth bt_inst(
        .clk(CLK_100MHz), .rst(~RST_n),
        .get(get_bluetooth),
        .out(sig_bt),
        .out_en(sig_bt_en)
    );
    bluetooth_decoder bt_dec_inst(
        .CLK_100MHz(CLK_100MHz),
        .sig_bt(sig_bt),
        .sig_num(sig_num)
    );

    // random generator
    wire [31:0] rand_val;
    random_gen rand_inst(CLK_100MHz, rand_val);

    // template implementation
    wire sig_newgame = (glob_state == state_gaming);
    //reg [31:0] seed = 32'h0;
    wire [323:0] template_map;
    wire [80:0] template_mask;
    GameTemplate temp_inst(
        .sig_new(sig_newgame),
        .seed(rand_val),
        .template_map(template_map)
    );
    MaskTemplate mask_inst(
        .sig_new(sig_newgame),
        .seed(rand_val),
        .template_mask(template_mask)
    );

    // game logic model
    wire [323:0] cur_map;
    wire [80:0] read_only;
    wire [7:0] cur_select;
    wire read_sig, read_done, clear_sig, clear_done;
    wire [15:0] op_counter;
    Game game_inst(
        .CLK_100MHz(CLK_100MHz),
        .UP(UP), .DOWN(DOWN), .LEFT(LEFT), .RIGHT(RIGHT), .CENTER(CENTER),
        .RST_n(RST_n), .win_tag(win_tag), .lose_tag(lose_tag),
        .init_tag(init_tag), .seed(rand_val), .temp_map(template_map), .temp_mask(template_mask),
        .num_read(sig_bt_en), .num_code(sig_num),
        .cur_map(cur_map), .cur_select(cur_select), .read_only(read_only), .inited(inited),
        .read_sig(read_sig), .read_done(read_done), .clear_sig(clear_sig), .clear_done(clear_done),
        .op_counter(op_counter)
    );
    assign win_tag = (cur_map == template_map);
    assign lose_tag = 0; // just assume game never lose now...

    // test assign
    // WILL BE REMOVED!!!
    // left 4
    assign test_map = { read_sig, read_done, clear_sig, clear_done };
    // mid-left 4
    assign test_mask = { template_mask[3], template_mask[2], template_mask[1], template_mask[0] };
    // mid-right 4
    assign test_cur = { cur_map[3], cur_map[2], cur_map[1], cur_map[0] };

    // VGA assistance
    wire [18:0] pix_addr;
    wire [3:0] R_in, G_in, B_in;
    VGA_Printer vga_print_inst(
        .CLK_100MHz(CLK_100MHz),
        .pix_addr(pix_addr), .error_note(error_note),
        .state(glob_state), .cur_map(cur_map), .read_only(template_mask), .cur_select(cur_select), .temp_map(template_map),
        .pix_R(R_in), .pix_G(G_in), .pix_B(B_in)
    );
    VGA_Driver vga_driver_inst(
        .CLK_25MH(CLK_VGA),
        .RST_n(RST_n), .pix_data({R_in, G_in, B_in}),
        .pix_addr(pix_addr), .Vsync_s(Vsync), .Hsync_s(Hsync),
        .R_s(R_s), .G_s(G_s), .B_s(B_s)
    );

    // digital display
    /* LedTop led_inst(
        .CLK_100MHz(CLK_100MHz), .RST_n(RST_n), .glob_state(glob_state), .init_tag(init_tag),
        .op_counter(op_counter),
        .led(led), .h_anode(anode[7:4]), .l_anode(anode[3:0])
    ); */ // ABANDONED

    // controller function (OUTDATED)
    always @(posedge CLK_100MHz) begin
        case (glob_state)
        state_init: begin
            if (CENTER) begin
                glob_state <= state_gaming;
            end
            else begin
                // do nothing
            end
        end
        state_gaming: begin
            if (!RST_n) begin
                glob_state <= state_init;
            end
            else if (win_tag) begin
                glob_state <= state_end;
            end
            else begin
                // do nothing
            end
        end
        state_end: begin
            if (CENTER) begin
                glob_state <= state_init;
            end
        end
        endcase
    end
endmodule
