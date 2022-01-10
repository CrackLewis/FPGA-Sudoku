`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 13:01:18
// Design Name: 
// Module Name: tb_top
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


module tb_top(
    );
    reg CLK = 0;
    reg BTN_U = 0, BTN_D = 0, BTN_L = 0, BTN_R = 0, BTN_C = 0;
    reg RST_n = 1;
    wire [3:0] R_s, G_s, B_s;
    wire Hsync, Vsync;
    wire [3:0] test_map, test_mask, test_cur;

    TopModule top_inst(
        .CLK_100MHz(CLK),
        .BTN_U(BTN_U), .BTN_D(BTN_D), .BTN_L(BTN_L), .BTN_R(BTN_R), .BTN_C(BTN_C),
        .RST_n(RST_n), .get_bluetooth(0),
        .R_s(R_s), .G_s(G_s), .B_s(B_s),
        .Hsync(Hsync), .Vsync(Vsync),
        .test_map(test_map), .test_mask(test_mask), .test_cur(test_cur)
    );

    always #5 CLK = ~CLK;

    initial begin
        // start a game
        #74 BTN_C = 1; #17 BTN_C = 0;
        // try to move
        #3 BTN_L = 1; #72 BTN_L = 0;
        #23 BTN_L = 1; #85 BTN_L = 0;
        #46 BTN_L = 1; #61 BTN_L = 0;
        #31 BTN_U = 1; #49 BTN_U = 0;
        #75 BTN_U = 1; #80 BTN_U = 0;
        #50 BTN_R = 1; #53 BTN_R = 0;
    end
endmodule
