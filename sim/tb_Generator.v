`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/07 10:52:01
// Design Name: 
// Module Name: tb_Generator
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


module tb_Generator(
    );
    reg CLK_100MHz = 0;
    reg sig_newgame = 0;
    wire [31:0] rand_val;
    random_gen rand_inst(CLK_100MHz, rand_val);
    
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

    always #2 CLK_100MHz = ~CLK_100MHz;

    initial begin
        repeat (20) begin
            #100 sig_newgame = 1;
            #100 sig_newgame = 0;
        end
    end
endmodule
