`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/13 22:49:42
// Design Name: 
// Module Name: VGA_Driver
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

// VGA输出控制器
// 每隔一个时钟上升沿，更新一次坐标和输出状态
module VGA_Control(
        CLK_25MH, RST_n, Vcoord, Hcoord, Sig_disp, Vsync_s, Hsync_s
    );
    input CLK_25MH; // VGA时钟
    input RST_n;
    output reg [11:0] Vcoord; // 输出：垂直坐标
    output reg [11:0] Hcoord; // 输出：水平坐标
    output Sig_disp; // 当前是否可以输出
    output Vsync_s; // 列同步
    output Hsync_s; // 行同步
    
    // 行参数
    parameter H_sync = 11'd96;
    parameter H_before = 11'd144;
    parameter H_beside_after = 11'd784;
    parameter H_all = 11'd800;

    // 列参数
    parameter V_sync = 11'd2;
    parameter V_before = 11'd35;
    parameter V_beside_after = 11'd515;
    parameter V_all = 11'd525;

    assign Sig_disp = ((Hcoord >= H_before) && (Hcoord < H_beside_after) && (Vcoord >= V_before) && (Vcoord < V_beside_after));
    assign Hsync_s = (Hcoord < H_sync) ? 0 : 1;
    assign Vsync_s = (Vcoord < V_sync) ? 0 : 1;

    initial begin
        Vcoord <= 0;
        Hcoord <= 0;
    end

    always @(posedge CLK_25MH) begin
        if (!RST_n) begin
            Hcoord <= 0;
            Vcoord <= 0;
        end
        else begin
            if (Hcoord == H_all - 1) begin
                Hcoord <= 0;
                if (Vcoord == V_all - 1) begin
                    Vcoord <= 0;
                end
                else begin
                    Vcoord <= Vcoord + 1;
                end
            end
            else begin
                Hcoord <= Hcoord + 1;
            end
        end
    end
endmodule

// VGA驱动
// 
module VGA_Driver(
        CLK_25MH, RST_n, pix_data, pix_addr, Vsync_s, Hsync_s, R_s, G_s, B_s
    );
    input CLK_25MH;  // VGA时钟频率为25MH
    input RST_n; // 复位信号，需要拉高
    input [11:0] pix_data;
    output reg [18:0] pix_addr;
    output Vsync_s;
    output Hsync_s;
    output reg [3:0] R_s;
    output reg [3:0] G_s;
    output reg [3:0] B_s;

    // 参数
    parameter H_before = 11'd144;
    parameter V_before = 11'd35;
    parameter H_size_pic = 11'd640;
    parameter V_size_pic = 11'd480;

    wire [11:0] Hcoord;
    wire [11:0] Vcoord;
    wire Sig_disp;

    // 控制器例化
    VGA_Control controller(
        .CLK_25MH(CLK_25MH),
        .RST_n(RST_n),
        .Vcoord(Vcoord),
        .Hcoord(Hcoord),
        .Sig_disp(Sig_disp),
        .Vsync_s(Vsync_s),
        .Hsync_s(Hsync_s)
    );

    initial begin
        pix_addr <= 19'b0;
    end

    always @(*) begin
        R_s <= 0;
        G_s <= 0;
        B_s <= 0;
        if (Sig_disp) begin
            if (Hcoord - H_before <= H_size_pic && Vcoord - V_before <= V_size_pic) begin
                pix_addr <= (Vcoord - V_before) * H_size_pic + (Hcoord - H_before);
                R_s <= pix_data[11:8];
                G_s <= pix_data[7:4];
                B_s <= pix_data[3:0];
            end
            else begin
                R_s <= 0;
                G_s <= 0;
                B_s <= 0;
            end
        end
        else ;
    end
endmodule
