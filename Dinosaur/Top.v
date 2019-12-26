`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:55:21 12/25/2019 
// Design Name: 
// Module Name:    Top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top(
	input clk,
	input rst,
	input[15:0] SW,
	output VS,
	output HS,
	output[3:0] R, G, B,
	inout[4:0] BTN_X,
	inout[3:0] BTN_Y
    );
	 
	wire[31:0] clk_div;
	clkdiv clk0(.clk(clk), .rst(1'b0), .clkdiv(clk_div));	//Ê±ÖÓ·ÖÆµÆ÷
	
	wire[15:0] SW_OK;
	AntiJitter #(4) a0[15:0](.clk(clk_div[15]), .I(SW), .O(SW_OK));	//SW·À¶¶
	
	wire[4:0] keyCode;
	wire keyReady;
	Keypad k0(.clk(clk_div[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));	//BTN¾ØÕóÄ£Ê½·À¶¶
	
	reg[11:0] vga_data;
	wire[9:0] col_addr;
	wire[8:0] row_addr;
	vgac vga(.vga_clk(clk_div[1]), .clrn(SW_OK[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(R), .g(G), .b(B), .hs(HS), .vs(VS));	//VGAÇý¶¯

	
	reg[18:0] Dino0;
	wire[11:0] spob;
	reg[9:0] Dino0_X;
	initial Dino0_X <= 10'd320;
	reg[8:0] Dino0_Y;
	initial Dino0_Y <= 9'd240;
	Dinosaur Dino(.addra(Dino0), .douta(spob), .clka(clk_div[1]));	//¿ÖÁúÄ£ÐÍipºË
	
	reg wasReady;
	reg isJump, isDown;
	reg[7:0] jumpTime;
	initial isJump <= 1'b0;
	initial jumpTime <= 8'd64;
	always@(posedge clk)begin
	
	
		wasReady <= keyReady;
		if(!wasReady&&keyReady)begin
			case(keyCode)
				5'h10: if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end
				5'hc: Dino0_X <= Dino0_X - 10'd20;
				5'he: Dino0_X <= Dino0_X + 10'd20;
				5'h9: Dino0_Y <= Dino0_Y - 9'd20;
				5'h11: Dino0_Y <= Dino0_Y + 9'd20;
				default:;
			endcase
		end
		
		
		if(col_addr >= Dino0_X && col_addr <= Dino0_X +127 && row_addr >= Dino0_Y && row_addr <= Dino0_Y + 127)begin
			Dino0 <= (col_addr-Dino0_X)*128 + (row_addr-Dino0_Y);
			vga_data <= spob[11:0];
		end
		else begin
			vga_data <= 12'hfff;
		end
		
		
		if(clk_div[19] && isJump && jumpTime < 8'd10)begin
			Dino0_Y <= Dino0_Y - 10'd8;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd10 && jumpTime < 8'd20)begin
			Dino0_Y <= Dino0_Y - 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd20 && jumpTime < 8'd32)begin
			Dino0_Y <= Dino0_Y - 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		else if(!clk_div[19] && !isJump) begin
			isJump <= 1;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd32 && jumpTime < 8'd44)begin
			Dino0_Y <= Dino0_Y + 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd44 && jumpTime < 8'd54)begin
			Dino0_Y <= Dino0_Y + 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd54 && jumpTime < 8'd64)begin
			Dino0_Y <= Dino0_Y + 10'd8;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		
		
	end
	
	
	
endmodule
