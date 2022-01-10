`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/07 21:23:29
// Design Name: 
// Module Name: tb_EdgeDebounce
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


module tb_EdgeDebounce(
    );
    reg CLK = 0;
    reg BTN = 0;

    wire CLK_sec, CLK_slice, SIG;
    BigClockDiv clk_div2(
        .CLK_100MHz(CLK), .RST_n(RST_n),
        .CLK_sec(CLK_sec), .CLK_slice(CLK_slice)
    );
    EdgeDebouncer ed_inst(CLK, CLK_slice, BTN, SIG);

    always #1 CLK = ~CLK;

    initial begin
        #22 BTN = 1;
        #420000 BTN = 0;
    end
endmodule
