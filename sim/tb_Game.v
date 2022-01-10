`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 09:01:02
// Design Name: 
// Module Name: tb_Game
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


module tb_Game(
    );
    reg CLK = 0;
    reg UP = 0, DOWN = 0, LEFT = 0, RIGHT = 0, CENTER = 0;
    wire RST_n = 1;
    wire win_tag = 0, lose_tag = 0;
    reg init_tag = 0;
    wire [31:0] seed = 32'd0;
    wire [323:0] temp_map = 324'b001010011000000101000110001101010111000101100101001101110010010010001001001101110100010110001001000100100110010000100001011010010011010101111000011010000011010001010111100100010010100101010111001000011000011000110100100000110010100101100001011101000101011101000110100000110101001010010001010100011001011100100100100001100011;
    wire [80:0] temp_mask = 81'b101011100101011100101011100101011100101011100101011100101011100101011100101011100;

    reg num_read = 0;
    reg [3:0] num_code = 4'b0;

    wire [323:0] cur_map;
    wire [7:0] cur_select;
    wire [80:0] read_only;
    wire read_sig, read_done, clear_sig, clear_done;

    Game game_inst(
        .CLK_100MHz(CLK), .UP(UP), .DOWN(DOWN), .LEFT(LEFT), .RIGHT(RIGHT), .CENTER(CENTER),
        .RST_n(RST_n), .win_tag(win_tag), .lose_tag(lose_tag),
        .init_tag(init_tag), .seed(seed), .temp_map(temp_map), .temp_mask(temp_mask),
        .num_read(num_read), .num_code(num_code),
        .cur_map(cur_map), .cur_select(cur_select), .read_only(read_only),
        .read_sig(read_sig), .read_done(read_done), .clear_sig(clear_sig), .clear_done(clear_done)
    );

    always #2 CLK = ~CLK;

    initial begin
        // init test
        #2 init_tag = 1;
        // move test
        #2 UP = 1; #12 UP = 0;
        #2 DOWN = 1; #12 DOWN = 0;
        #2 LEFT = 1; #8 LEFT = 0;
        // data test
        #30 num_code = 4'd4;
        #15 num_read = 1;
    end
endmodule
