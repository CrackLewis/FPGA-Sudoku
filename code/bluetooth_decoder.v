`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/02 12:39:06
// Design Name: 
// Module Name: bluetooth_decoder
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


module bluetooth_decoder(
        input CLK_100MHz,
        input [7:0] sig_bt,

        output [3:0] sig_num
    );
    // TODO: bluetooth_decoder
    assign sig_num = sig_bt[3:0];
endmodule
