`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/07 11:07:44
// Design Name: 
// Module Name: tb_Controller
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

module MiniController(
    clk, btn_c, rst_n,
    glob_state, init_tag, sig_newgame
);
    input clk, btn_c, rst_n;
    output reg [3:0] glob_state = 0;
    output init_tag, sig_newgame;

    wire win_tag = 0;

    parameter state_init = 4'd0;
    parameter state_gaming = 4'd1;
    parameter state_end = 4'd2;

    assign init_tag = (glob_state == state_gaming);
    assign sig_newgame = (glob_state == state_gaming);

    always @(posedge clk) begin
        case (glob_state)
        state_init: begin
            if (btn_c) begin
                glob_state <= state_gaming;
            end
            else begin
                // do nothing
            end
        end
        state_gaming: begin
            if (!rst_n) begin
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
            if (btn_c) begin
                glob_state <= state_init;
            end
        end
        endcase
    end
endmodule

module tb_Controller(
    );
    reg clk = 0;
    reg btn_c = 0;
    reg rst_n = 1;
    wire [3:0] state;
    wire init, ng;

    MiniController ct_inst(
        .clk(clk), .btn_c(btn_c), .rst_n(rst_n),
        .glob_state(state), .init_tag(init), .sig_newgame(ng)
    );

    always #4 clk = ~clk;

    initial begin
        #15 btn_c = 1;
        #15 btn_c = 0;

        #20 rst_n = 0;
        #21 rst_n = 1;
    end
endmodule
