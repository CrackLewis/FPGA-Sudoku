`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/15 22:04:16
// Design Name: 
// Module Name: random_gen
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


module random_gen(
        CLK_100MHz,
        rand_out
    );
    input CLK_100MHz;
    output [31:0] rand_out;
    reg [31:0] rand_buf = 32'b1;

    parameter FACTOR = 32'd48271;

    always @(posedge CLK_100MHz) begin
        rand_buf <= rand_buf * FACTOR;
    end

    assign rand_out = rand_buf;
endmodule
