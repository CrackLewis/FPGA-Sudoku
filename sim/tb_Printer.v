`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 11:32:46
// Design Name: 
// Module Name: tb_Printer
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


module tb_Printer(
    );
    reg CLK = 0;
    reg [18:0] pix_addr = 19'd0;
    reg [3:0] state;
    reg [323:0] cur_map;
    reg [7:0] cur_select;
    reg [80:0] read_only;

    wire [3:0] pix_R, pix_G, pix_B;

    VGA_Printer vp_inst(
        .CLK_100MHz(CLK),
        .pix_addr(pix_addr), .state(state), .cur_map(cur_map),
        .cur_select(cur_select), .read_only(read_only),
        .pix_R(pix_R), .pix_G(pix_G), .pix_B(pix_B)
    );

    always #5 CLK = ~CLK;

    initial begin
        cur_map = 324'b010001110110100110000011000100100101000100100101011001000111001110011000001110011000001000010101011101000110100101010011100001110001001001100100011001000001001110010010100001010111011110000010010001010110100100110001001000110111000101100100010110001001010101101001011100101000010000010011100000010100010100111001011001110010;
        state = 4'd1;
        cur_select = 8'd40;
        read_only = 81'd0;
    end

    always @(posedge CLK) begin
        pix_addr <= pix_addr + 1;
    end
endmodule
