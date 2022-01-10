`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/28 12:07:26
// Design Name: 
// Module Name: Game
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

module Game(
        CLK_100MHz,
        UP, DOWN, LEFT, RIGHT, CENTER,
        RST_n, 
        win_tag, lose_tag,
        init_tag, seed, temp_map, temp_mask,
        num_read, num_code,
        cur_map, cur_select, read_only, inited,
        read_sig, read_done, clear_sig, clear_done, // test signal
        op_counter
    );
    input CLK_100MHz;
    input UP, DOWN, LEFT, RIGHT, CENTER;
    input RST_n;
    input win_tag, lose_tag;
    input init_tag;
    input [31:0] seed;
    input [323:0] temp_map;
    input [80:0] temp_mask;

    input num_read;
    input [3:0] num_code;
    
    output reg [323:0] cur_map = 324'd0;
    output reg [7:0] cur_select = 8'd0;
    output [80:0] read_only; // abandoned
    output reg inited = 0;

    output reg read_sig = 0;
    output reg clear_sig = 0;
    output reg read_done = 0;
    output reg clear_done = 0;

    output reg [15:0] op_counter = 16'd0;

    wire [323:0] masked_map;
    //= {temp_mask[80] ? temp_map[323:320] : 4'b0,temp_mask[79] ? temp_map[319:316] : 4'b0,temp_mask[78] ? temp_map[315:312] : 4'b0,temp_mask[77] ? temp_map[311:308] : 4'b0,temp_mask[76] ? temp_map[307:304] : 4'b0,temp_mask[75] ? temp_map[303:300] : 4'b0,temp_mask[74] ? temp_map[299:296] : 4'b0,temp_mask[73] ? temp_map[295:292] : 4'b0,temp_mask[72] ? temp_map[291:288] : 4'b0,temp_mask[71] ? temp_map[287:284] : 4'b0,temp_mask[70] ? temp_map[283:280] : 4'b0,temp_mask[69] ? temp_map[279:276] : 4'b0,temp_mask[68] ? temp_map[275:272] : 4'b0,temp_mask[67] ? temp_map[271:268] : 4'b0,temp_mask[66] ? temp_map[267:264] : 4'b0,temp_mask[65] ? temp_map[263:260] : 4'b0,temp_mask[64] ? temp_map[259:256] : 4'b0,temp_mask[63] ? temp_map[255:252] : 4'b0,temp_mask[62] ? temp_map[251:248] : 4'b0,temp_mask[61] ? temp_map[247:244] : 4'b0,temp_mask[60] ? temp_map[243:240] : 4'b0,temp_mask[59] ? temp_map[239:236] : 4'b0,temp_mask[58] ? temp_map[235:232] : 4'b0,temp_mask[57] ? temp_map[231:228] : 4'b0,temp_mask[56] ? temp_map[227:224] : 4'b0,temp_mask[55] ? temp_map[223:220] : 4'b0,temp_mask[54] ? temp_map[219:216] : 4'b0,temp_mask[53] ? temp_map[215:212] : 4'b0,temp_mask[52] ? temp_map[211:208] : 4'b0,temp_mask[51] ? temp_map[207:204] : 4'b0,temp_mask[50] ? temp_map[203:200] : 4'b0,temp_mask[49] ? temp_map[199:196] : 4'b0,temp_mask[48] ? temp_map[195:192] : 4'b0,temp_mask[47] ? temp_map[191:188] : 4'b0,temp_mask[46] ? temp_map[187:184] : 4'b0,temp_mask[45] ? temp_map[183:180] : 4'b0,temp_mask[44] ? temp_map[179:176] : 4'b0,temp_mask[43] ? temp_map[175:172] : 4'b0,temp_mask[42] ? temp_map[171:168] : 4'b0,temp_mask[41] ? temp_map[167:164] : 4'b0,temp_mask[40] ? temp_map[163:160] : 4'b0,temp_mask[39] ? temp_map[159:156] : 4'b0,temp_mask[38] ? temp_map[155:152] : 4'b0,temp_mask[37] ? temp_map[151:148] : 4'b0,temp_mask[36] ? temp_map[147:144] : 4'b0,temp_mask[35] ? temp_map[143:140] : 4'b0,temp_mask[34] ? temp_map[139:136] : 4'b0,temp_mask[33] ? temp_map[135:132] : 4'b0,temp_mask[32] ? temp_map[131:128] : 4'b0,temp_mask[31] ? temp_map[127:124] : 4'b0,temp_mask[30] ? temp_map[123:120] : 4'b0,temp_mask[29] ? temp_map[119:116] : 4'b0,temp_mask[28] ? temp_map[115:112] : 4'b0,temp_mask[27] ? temp_map[111:108] : 4'b0,temp_mask[26] ? temp_map[107:104] : 4'b0,temp_mask[25] ? temp_map[103:100] : 4'b0,temp_mask[24] ? temp_map[99:96] : 4'b0,temp_mask[23] ? temp_map[95:92] : 4'b0,temp_mask[22] ? temp_map[91:88] : 4'b0,temp_mask[21] ? temp_map[87:84] : 4'b0,temp_mask[20] ? temp_map[83:80] : 4'b0,temp_mask[19] ? temp_map[79:76] : 4'b0,temp_mask[18] ? temp_map[75:72] : 4'b0,temp_mask[17] ? temp_map[71:68] : 4'b0,temp_mask[16] ? temp_map[67:64] : 4'b0,temp_mask[15] ? temp_map[63:60] : 4'b0,temp_mask[14] ? temp_map[59:56] : 4'b0,temp_mask[13] ? temp_map[55:52] : 4'b0,temp_mask[12] ? temp_map[51:48] : 4'b0,temp_mask[11] ? temp_map[47:44] : 4'b0,temp_mask[10] ? temp_map[43:40] : 4'b0,temp_mask[9] ? temp_map[39:36] : 4'b0,temp_mask[8] ? temp_map[35:32] : 4'b0,temp_mask[7] ? temp_map[31:28] : 4'b0,temp_mask[6] ? temp_map[27:24] : 4'b0,temp_mask[5] ? temp_map[23:20] : 4'b0,temp_mask[4] ? temp_map[19:16] : 4'b0,temp_mask[3] ? temp_map[15:12] : 4'b0,temp_mask[2] ? temp_map[11:8] : 4'b0,temp_mask[1] ? temp_map[7:4] : 4'b0,temp_mask[0] ? temp_map[3:0] : 4'b0 };
    assign masked_map[323:320] = temp_mask[80] ? temp_map[323:320] : 4'b0;
    assign masked_map[319:316] = temp_mask[79] ? temp_map[319:316] : 4'b0;
    assign masked_map[315:312] = temp_mask[78] ? temp_map[315:312] : 4'b0;
    assign masked_map[311:308] = temp_mask[77] ? temp_map[311:308] : 4'b0;
    assign masked_map[307:304] = temp_mask[76] ? temp_map[307:304] : 4'b0;
    assign masked_map[303:300] = temp_mask[75] ? temp_map[303:300] : 4'b0;
    assign masked_map[299:296] = temp_mask[74] ? temp_map[299:296] : 4'b0;
    assign masked_map[295:292] = temp_mask[73] ? temp_map[295:292] : 4'b0;
    assign masked_map[291:288] = temp_mask[72] ? temp_map[291:288] : 4'b0;
    assign masked_map[287:284] = temp_mask[71] ? temp_map[287:284] : 4'b0;
    assign masked_map[283:280] = temp_mask[70] ? temp_map[283:280] : 4'b0;
    assign masked_map[279:276] = temp_mask[69] ? temp_map[279:276] : 4'b0;
    assign masked_map[275:272] = temp_mask[68] ? temp_map[275:272] : 4'b0;
    assign masked_map[271:268] = temp_mask[67] ? temp_map[271:268] : 4'b0;
    assign masked_map[267:264] = temp_mask[66] ? temp_map[267:264] : 4'b0;
    assign masked_map[263:260] = temp_mask[65] ? temp_map[263:260] : 4'b0;
    assign masked_map[259:256] = temp_mask[64] ? temp_map[259:256] : 4'b0;
    assign masked_map[255:252] = temp_mask[63] ? temp_map[255:252] : 4'b0;
    assign masked_map[251:248] = temp_mask[62] ? temp_map[251:248] : 4'b0;
    assign masked_map[247:244] = temp_mask[61] ? temp_map[247:244] : 4'b0;
    assign masked_map[243:240] = temp_mask[60] ? temp_map[243:240] : 4'b0;
    assign masked_map[239:236] = temp_mask[59] ? temp_map[239:236] : 4'b0;
    assign masked_map[235:232] = temp_mask[58] ? temp_map[235:232] : 4'b0;
    assign masked_map[231:228] = temp_mask[57] ? temp_map[231:228] : 4'b0;
    assign masked_map[227:224] = temp_mask[56] ? temp_map[227:224] : 4'b0;
    assign masked_map[223:220] = temp_mask[55] ? temp_map[223:220] : 4'b0;
    assign masked_map[219:216] = temp_mask[54] ? temp_map[219:216] : 4'b0;
    assign masked_map[215:212] = temp_mask[53] ? temp_map[215:212] : 4'b0;
    assign masked_map[211:208] = temp_mask[52] ? temp_map[211:208] : 4'b0;
    assign masked_map[207:204] = temp_mask[51] ? temp_map[207:204] : 4'b0;
    assign masked_map[203:200] = temp_mask[50] ? temp_map[203:200] : 4'b0;
    assign masked_map[199:196] = temp_mask[49] ? temp_map[199:196] : 4'b0;
    assign masked_map[195:192] = temp_mask[48] ? temp_map[195:192] : 4'b0;
    assign masked_map[191:188] = temp_mask[47] ? temp_map[191:188] : 4'b0;
    assign masked_map[187:184] = temp_mask[46] ? temp_map[187:184] : 4'b0;
    assign masked_map[183:180] = temp_mask[45] ? temp_map[183:180] : 4'b0;
    assign masked_map[179:176] = temp_mask[44] ? temp_map[179:176] : 4'b0;
    assign masked_map[175:172] = temp_mask[43] ? temp_map[175:172] : 4'b0;
    assign masked_map[171:168] = temp_mask[42] ? temp_map[171:168] : 4'b0;
    assign masked_map[167:164] = temp_mask[41] ? temp_map[167:164] : 4'b0;
    assign masked_map[163:160] = temp_mask[40] ? temp_map[163:160] : 4'b0;
    assign masked_map[159:156] = temp_mask[39] ? temp_map[159:156] : 4'b0;
    assign masked_map[155:152] = temp_mask[38] ? temp_map[155:152] : 4'b0;
    assign masked_map[151:148] = temp_mask[37] ? temp_map[151:148] : 4'b0;
    assign masked_map[147:144] = temp_mask[36] ? temp_map[147:144] : 4'b0;
    assign masked_map[143:140] = temp_mask[35] ? temp_map[143:140] : 4'b0;
    assign masked_map[139:136] = temp_mask[34] ? temp_map[139:136] : 4'b0;
    assign masked_map[135:132] = temp_mask[33] ? temp_map[135:132] : 4'b0;
    assign masked_map[131:128] = temp_mask[32] ? temp_map[131:128] : 4'b0;
    assign masked_map[127:124] = temp_mask[31] ? temp_map[127:124] : 4'b0;
    assign masked_map[123:120] = temp_mask[30] ? temp_map[123:120] : 4'b0;
    assign masked_map[119:116] = temp_mask[29] ? temp_map[119:116] : 4'b0;
    assign masked_map[115:112] = temp_mask[28] ? temp_map[115:112] : 4'b0;
    assign masked_map[111:108] = temp_mask[27] ? temp_map[111:108] : 4'b0;
    assign masked_map[107:104] = temp_mask[26] ? temp_map[107:104] : 4'b0;
    assign masked_map[103:100] = temp_mask[25] ? temp_map[103:100] : 4'b0;
    assign masked_map[99:96] = temp_mask[24] ? temp_map[99:96] : 4'b0;
    assign masked_map[95:92] = temp_mask[23] ? temp_map[95:92] : 4'b0;
    assign masked_map[91:88] = temp_mask[22] ? temp_map[91:88] : 4'b0;
    assign masked_map[87:84] = temp_mask[21] ? temp_map[87:84] : 4'b0;
    assign masked_map[83:80] = temp_mask[20] ? temp_map[83:80] : 4'b0;
    assign masked_map[79:76] = temp_mask[19] ? temp_map[79:76] : 4'b0;
    assign masked_map[75:72] = temp_mask[18] ? temp_map[75:72] : 4'b0;
    assign masked_map[71:68] = temp_mask[17] ? temp_map[71:68] : 4'b0;
    assign masked_map[67:64] = temp_mask[16] ? temp_map[67:64] : 4'b0;
    assign masked_map[63:60] = temp_mask[15] ? temp_map[63:60] : 4'b0;
    assign masked_map[59:56] = temp_mask[14] ? temp_map[59:56] : 4'b0;
    assign masked_map[55:52] = temp_mask[13] ? temp_map[55:52] : 4'b0;
    assign masked_map[51:48] = temp_mask[12] ? temp_map[51:48] : 4'b0;
    assign masked_map[47:44] = temp_mask[11] ? temp_map[47:44] : 4'b0;
    assign masked_map[43:40] = temp_mask[10] ? temp_map[43:40] : 4'b0;
    assign masked_map[39:36] = temp_mask[9] ? temp_map[39:36] : 4'b0;
    assign masked_map[35:32] = temp_mask[8] ? temp_map[35:32] : 4'b0;
    assign masked_map[31:28] = temp_mask[7] ? temp_map[31:28] : 4'b0;
    assign masked_map[27:24] = temp_mask[6] ? temp_map[27:24] : 4'b0;
    assign masked_map[23:20] = temp_mask[5] ? temp_map[23:20] : 4'b0;
    assign masked_map[19:16] = temp_mask[4] ? temp_map[19:16] : 4'b0;
    assign masked_map[15:12] = temp_mask[3] ? temp_map[15:12] : 4'b0;
    assign masked_map[11:8] = temp_mask[2] ? temp_map[11:8] : 4'b0;
    assign masked_map[7:4] = temp_mask[1] ? temp_map[7:4] : 4'b0;
    assign masked_map[3:0] = temp_mask[0] ? temp_map[3:0] : 4'b0;

    // map initer
    /*
    always @(posedge init_tag) begin
        // initialize with an empty grid
        cur_map <= 324'b0;
        temp_mask <= 81'b0;
        // TODO: fix the filler
        for (cur_select = 8'd0; cur_select < 8'd81; cur_select = cur_select + 1) begin
            if (temp_mask[cur_select]) begin
                cur_map[cur_select * 4 +: 4] <= temp_map[cur_select * 4 +: 4];
                temp_mask[cur_select] <= 1;
            end
            else begin
                // do nothing
            end
        end
        // set the cursor
        cur_select = 8'd40;
    end
    */

    // cur_map writer
    always @(posedge CLK_100MHz) begin
        if (!RST_n) begin
            cur_map <= 324'd0;
            inited <= 0;
            read_done <= 0;
            clear_done <= 0;
            op_counter <= 16'd0;
        end
        else if (init_tag & !inited) begin
            inited = 1;
            //temp_mask = temp_mask;
            #10 cur_map[323:243] <= masked_map[323:243];
            cur_map[242:162] <= masked_map[242:162];
            cur_map[161:81] <= masked_map[161:81];
            cur_map[80:0] <= masked_map[80:0];
            op_counter <= 16'd0;
        end
        else if (read_sig) begin
            cur_map[cur_select * 4 +: 4] = num_code;
            read_done = 1;
            if (op_counter >= 16'd9999)
                op_counter = 16'd0;
            else
                op_counter = op_counter + 1;
        end
        else if (clear_sig) begin
            cur_map[cur_select * 4 +: 4] = 4'd0;
            clear_done = 1;
        end
        else if (!init_tag) begin
            inited = 0;
        end
        else begin
            read_done = 0;
            clear_done = 0;
        end
    end

    // clock reference
    always @(posedge CLK_100MHz) begin
        if (clear_done | !RST_n) begin
            clear_sig = 0;
        end
        else begin
            // do nothing
        end

        if (!win_tag & !lose_tag) begin
            if (CENTER) begin
                if (!inited | temp_mask[cur_select]) begin
                    // do nothing
                end
                else
                    clear_sig = 1;
            end
            else if (UP) begin
                if (cur_select >= 0 && cur_select < 9) begin
                    cur_select <= cur_select + 72;
                end
                else begin
                    cur_select <= cur_select - 9;
                end
            end
            else if (DOWN) begin
                if (cur_select >= 72 && cur_select < 81) begin
                    cur_select <= cur_select - 72;
                end
                else begin
                    cur_select <= cur_select + 9;
                end
            end
            else if (LEFT) begin
                if (cur_select % 9 == 0) begin
                    cur_select <= cur_select + 8;
                end
                else begin
                    cur_select <= cur_select - 1;
                end
            end
            else if (RIGHT) begin
                if (cur_select % 9 == 8) begin
                    cur_select <= cur_select - 8;
                end
                else begin
                    cur_select <= cur_select + 1;
                end
            end
            else begin
                // do nothing
            end
        end
    end

    // number input
    always @(posedge num_read or posedge read_done) begin
        if (read_done | !RST_n) begin
            read_sig = 0;
        end
        else if (num_read & !temp_mask[cur_select]) begin
            read_sig = 1;
        end
        else begin
            // do nothing
        end
    end
endmodule
