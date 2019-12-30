`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:46 12/30/2019 
// Design Name: 
// Module Name:    ScoreCounter 
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
module ScoreCounter(
	input[31:0] clk_div,
	output reg[31:0] data
    );
	 
	initial data <= 32'h0000_0000;
	
	always@(posedge clk_div[24])begin
		if(data[3:0] == 4'h9)begin
			data[3:0] <= 4'h0;
			data[7:4] <= data[7:4] + 1'd1;
		end
		else
			data[3:0] <= data[3:0] + 1'd1;
		if(data[7:4] == 4'h9 && data[3:0] == 4'h9)begin
			data[7:4] <= 4'h0;
			data[11:8] <= data[11:8] + 1'd1;
		end
		if(data[11:8] == 4'h9 && data[7:4] == 4'h9 && data[3:0] == 4'h9)begin
			data[11:8] <= 4'h0;
			data[15:12] <= data[15:12] + 1'd1;
		end
		
		if(data[19:16] == 4'h9)begin
			data[19:16] <= 4'h0;
			data[23:20] <= data[23:20] + 1'd1;
		end
		else
			data[19:16] <= data[19:16] + 1'd1;
		if(data[23:20] == 4'h9 && data[19:16] == 4'h9)begin
			data[23:20] <= 4'h0;
			data[27:24] <= data[27:24] + 1'd1;
		end
		if(data[27:24] == 4'h9 && data[23:20] == 4'h9 && data[19:16] == 4'h9)begin
			data[27:24] <= 4'h0;
			data[31:28] <= data[31:28] + 1'd1;
		end
	end
	

endmodule
