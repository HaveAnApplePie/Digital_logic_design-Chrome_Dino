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
	output[3:0] R, G, B
    );
	 
	wire[31:0] clk_div;
	clkdiv clk0(.clk(clk), .rst(1'b0), .clkdiv(clk_div));
	
	reg[11:0] vga_data;
	wire[9:0] col_addr;
	wire[8:0] row_addr;
	
	reg[18:0] Dino0;
	wire[11:0] spob;
	
	always@(posedge clk)begin
		if(col_addr >= 128 && col_addr<= 255 && row_addr >= 128 && row_addr <= 255)begin
			Dino0 <= (col_addr-128)*128 + (row_addr-128);
			vga_data <= spob[11:0];
		end
		else
			vga_data <= 12'hfff;
	end
	
	vgac vga(.vga_clk(clk_div[1]), .clrn(SW[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(R), .g(G), .b(B), .hs(HS), .vs(VS));
		
	Dinosaur Dino(.addra(Dino0), .douta(spob), .clka(clk_div[1]));

endmodule
