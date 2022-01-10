`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/25 00:22:18
// Design Name: 
// Module Name: VGA_Printer
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


module VGA_Printer(
        CLK_100MHz,
        pix_addr, error_note,
        state, cur_map, read_only, cur_select, temp_map,
        pix_R, pix_G, pix_B
    );
    input CLK_100MHz;
    input [18:0] pix_addr;
    input [3:0] state;
    input [323:0] cur_map;
    input [7:0] cur_select;
    input [80:0] read_only;

    output [3:0] pix_R;
    output [3:0] pix_G;
    output [3:0] pix_B;

    // error correction assistance
    input error_note;
    input [323:0] temp_map;

    // counter
    reg [23:0] color_switch = 24'd0;
    always @(posedge CLK_100MHz) begin
        color_switch <= color_switch + 1;
    end

    // parameters
    parameter state_init = 4'd0;
    parameter state_gaming = 4'd1;
    parameter state_end = 4'd2;
    parameter rows = 19'd480;
    parameter cols = 19'd640;

    wire [11:0] pix_row, pix_col;
    assign pix_row = pix_addr / cols;
    assign pix_col = pix_addr % cols;
    wire in_grid = (pix_row >= 12'd14 && pix_row < 12'd22)
        || (pix_row >= 12'd66 && pix_row < 12'd70)
        || (pix_row >= 12'd114 && pix_row < 12'd118)
        || (pix_row >= 12'd162 && pix_row < 12'd170)
        || (pix_row >= 12'd214 && pix_row < 12'd218)
        || (pix_row >= 12'd262 && pix_row < 12'd266)
        || (pix_row >= 12'd310 && pix_row < 12'd318)
        || (pix_row >= 12'd362 && pix_row < 12'd366)
        || (pix_row >= 12'd410 && pix_row < 12'd414)
        || (pix_row >= 12'd458 && pix_row < 12'd466)
        || (pix_col >= 12'd94 && pix_col < 12'd102)
        || (pix_col >= 12'd146 && pix_col < 12'd150)
        || (pix_col >= 12'd194 && pix_col < 12'd198)
        || (pix_col >= 12'd242 && pix_col < 12'd250)
        || (pix_col >= 12'd294 && pix_col < 12'd298)
        || (pix_col >= 12'd342 && pix_col < 12'd346)
        || (pix_col >= 12'd390 && pix_col < 12'd398)
        || (pix_col >= 12'd442 && pix_col < 12'd446)
        || (pix_col >= 12'd490 && pix_col < 12'd494)
        || (pix_col >= 12'd538 && pix_col < 12'd546);
    wire in_square = (pix_row >= 12'd14 && pix_row < 12'd466) && (pix_col >= 12'd94 && pix_col <= 12'd546);
    wire [3:0] row_index, col_index;
    wire [11:0] row_offset, col_offset;
    wire [11:0] index_tot = row_index * 9 + col_index;
    wire [11:0] offset_tot = (row_offset / 4) * 11 + (col_offset / 4); 
    wire [3:0] index_number = cur_map[index_tot * 4 +: 4];
    wire in_select = (index_tot == cur_select);
    wire in_error = (temp_map[index_tot * 4 +: 4] != cur_map[index_tot * 4 +: 4]);

    wire [120:0] lattice;
    NumberLattice latt_conv_inst(
        .number(index_number),
        .lattice(lattice)
    );
    // row_index
    /*
    always @(posedge CLK_100MHz) begin
        if (in_grid) begin
            // do nothing
        end
        else begin
                 if (pix_row >=  12'd22 && pix_row <  12'd66) begin row_index <= 4'd0; row_offset <= pix_row - 12'd22; end
            else if (pix_row >=  12'd70 && pix_row < 12'd114) begin row_index <= 4'd1; row_offset <= pix_row - 12'd70; end
            else if (pix_row >= 12'd118 && pix_row < 12'd162) begin row_index <= 4'd2; row_offset <= pix_row - 12'd118; end
            else if (pix_row >= 12'd170 && pix_row < 12'd214) begin row_index <= 4'd3; row_offset <= pix_row - 12'd170; end
            else if (pix_row >= 12'd218 && pix_row < 12'd262) begin row_index <= 4'd4; row_offset <= pix_row - 12'd218; end
            else if (pix_row >= 12'd266 && pix_row < 12'd310) begin row_index <= 4'd5; row_offset <= pix_row - 12'd266; end
            else if (pix_row >= 12'd318 && pix_row < 12'd362) begin row_index <= 4'd6; row_offset <= pix_row - 12'd318; end
            else if (pix_row >= 12'd366 && pix_row < 12'd410) begin row_index <= 4'd7; row_offset <= pix_row - 12'd366; end
            else if (pix_row >= 12'd414 && pix_row < 12'd458) begin row_index <= 4'd8; row_offset <= pix_row - 12'd414; end
            else row_index <= 4'd0;
        end
    end
    */
    assign row_index = 
            (pix_row >=  12'd22 && pix_row <  12'd66) ? 4'd0 :
            (pix_row >=  12'd70 && pix_row < 12'd114) ? 4'd1 :
            (pix_row >= 12'd118 && pix_row < 12'd162) ? 4'd2 :
            (pix_row >= 12'd170 && pix_row < 12'd214) ? 4'd3 :
            (pix_row >= 12'd218 && pix_row < 12'd262) ? 4'd4 :
            (pix_row >= 12'd266 && pix_row < 12'd310) ? 4'd5 :
            (pix_row >= 12'd318 && pix_row < 12'd362) ? 4'd6 :
            (pix_row >= 12'd366 && pix_row < 12'd410) ? 4'd7 :
            (pix_row >= 12'd414 && pix_row < 12'd458) ? 4'd8 : 4'd9;
    assign row_offset = 
            (pix_row >=  12'd22 && pix_row <  12'd66) ? pix_row - 12'd22 :
            (pix_row >=  12'd70 && pix_row < 12'd114) ? pix_row - 12'd70 :
            (pix_row >= 12'd118 && pix_row < 12'd162) ? pix_row - 12'd118 :
            (pix_row >= 12'd170 && pix_row < 12'd214) ? pix_row - 12'd170 :
            (pix_row >= 12'd218 && pix_row < 12'd262) ? pix_row - 12'd218 :
            (pix_row >= 12'd266 && pix_row < 12'd310) ? pix_row - 12'd266 :
            (pix_row >= 12'd318 && pix_row < 12'd362) ? pix_row - 12'd318 :
            (pix_row >= 12'd366 && pix_row < 12'd410) ? pix_row - 12'd366 :
            (pix_row >= 12'd414 && pix_row < 12'd458) ? pix_row - 12'd414 : 12'd0;
    // pix_col
    assign col_index = 
            (pix_col >= 12'd102 && pix_col < 12'd146) ? 4'd0 :
            (pix_col >= 12'd150 && pix_col < 12'd194) ? 4'd1 :
            (pix_col >= 12'd198 && pix_col < 12'd242) ? 4'd2 :
            (pix_col >= 12'd250 && pix_col < 12'd294) ? 4'd3 :
            (pix_col >= 12'd298 && pix_col < 12'd342) ? 4'd4 :
            (pix_col >= 12'd346 && pix_col < 12'd390) ? 4'd5 :
            (pix_col >= 12'd398 && pix_col < 12'd442) ? 4'd6 :
            (pix_col >= 12'd446 && pix_col < 12'd490) ? 4'd7 :
            (pix_col >= 12'd494 && pix_col < 12'd538) ? 4'd8 : 4'd9;
    assign col_offset = 
            (pix_col >= 12'd102 && pix_col < 12'd146) ? pix_col - 12'd102 :
            (pix_col >= 12'd150 && pix_col < 12'd194) ? pix_col - 12'd150 :
            (pix_col >= 12'd198 && pix_col < 12'd242) ? pix_col - 12'd198 :
            (pix_col >= 12'd250 && pix_col < 12'd294) ? pix_col - 12'd250 :
            (pix_col >= 12'd298 && pix_col < 12'd342) ? pix_col - 12'd298 :
            (pix_col >= 12'd346 && pix_col < 12'd390) ? pix_col - 12'd346 :
            (pix_col >= 12'd398 && pix_col < 12'd442) ? pix_col - 12'd398 :
            (pix_col >= 12'd446 && pix_col < 12'd490) ? pix_col - 12'd446 :
            (pix_col >= 12'd494 && pix_col < 12'd538) ? pix_col - 12'd494 : 12'd0;
    // color assignment
    wire [11:0] pix_init = 12'h770;
    wire [11:0] pix_run_grid = 12'hfff;
    wire [11:0] pix_run_latt = 12'heee;
    wire [11:0] pix_run_readonly_bg = 12'h286;
    wire [11:0] pix_run_writeable_bg = 12'h7c5;
    wire [11:0] pix_run_selected_bg = 12'h16f;
    wire [11:0] pix_run_errorcor_bg = 12'hf55;
    wire [11:0] pix_run_bg = 12'h032;
    wire [11:0] pix_end = 12'h0ff;
    wire [11:0] pix_ill = 12'hf0f;

    wire [11:0] pix_run_readonly = lattice[offset_tot] ? pix_run_latt : pix_run_readonly_bg;
    wire [11:0] pix_run_writeable = lattice[offset_tot] ? pix_run_latt : pix_run_writeable_bg;
    wire [11:0] pix_run_selected = lattice[offset_tot] ? pix_run_latt : pix_run_selected_bg;
    wire [11:0] pix_run_errorcor = lattice[offset_tot] ? pix_run_latt : pix_run_errorcor_bg;
    wire [11:0] pix_run_insq = in_grid ? pix_run_grid : (in_select ? pix_run_selected : ((error_note & in_error) ? pix_run_errorcor : (read_only[index_tot] ? pix_run_readonly : pix_run_writeable)));
    wire [11:0] pix_run = in_square ? pix_run_insq : pix_run_bg;

    wire [11:0] pix_rgb = 
        (state == state_init) ? pix_init :
        (state == state_gaming) ? pix_run :
        (state == state_end) ? pix_end : pix_ill;

    assign pix_R = pix_rgb[11:8];
    assign pix_G = pix_rgb[7:4];
    assign pix_B = pix_rgb[3:0];
    /*
    always @(posedge CLK_100MHz) begin
        if (state == state_init) begin
            pix_R <= 4'd7;
            pix_G <= 4'd7;
            pix_B <= 4'd0;
        end
        else if (state == state_gaming) begin
            // in square 452*452
            if (in_square) begin
                if (in_grid) begin
                    pix_R <= 4'd15;
                    pix_G <= 4'd15;
                    pix_B <= 4'd15;
                end
                else if (read_only[index_tot]) begin
                    // read-only cells has a deeper color
                    if (lattice[offset_tot]) begin
                        pix_R <= 4'd15;
                        pix_G <= 4'd15;
                        pix_B <= 4'd15;
                    end
                    else begin
                        pix_R <= 4'd2;
                        pix_G <= 4'd8;
                        pix_B <= 4'd6;
                    end
                end
                else begin // modifiable cells has a lighter color
                    if (lattice[offset_tot]) begin
                        pix_R <= 4'd15;
                        pix_G <= 4'd15;
                        pix_B <= 4'd15;
                    end
                    else begin
                        pix_R <= 4'd7;
                        pix_G <= 4'd12;
                        pix_B <= 4'd5;
                    end
                end
            end
            // out of square: dark green
            else begin
                pix_R <= 4'd0;
                pix_G <= 4'd3;
                pix_B <= 4'd2;
            end
        end
        else if (state == state_end) begin
            pix_R <= 4'd0;
            pix_G <= 4'd15;
            pix_B <= 4'd15;
        end
        else begin
            pix_R <= 4'd15;
            pix_G <= 4'd0;
            pix_B <= 4'd15;
        end
    end
    */
endmodule
