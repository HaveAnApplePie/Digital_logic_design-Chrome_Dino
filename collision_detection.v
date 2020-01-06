`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:50:02 01/06/2020 
// Design Name: 
// Module Name:    collision_detection 
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
module collision_detection(
	input wire rst,
	input wire [11:0]dino,		//恐龙
	input wire [11:0]obstacle, //障碍物
	input wire rdn,            // read pixel RAM (active_low)11
	input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	output reg crash				//是否碰撞
    );

	 parameter	
		LEFT      = 30,	    //恐龙左侧
		RIGHT 	 = 93;	    //恐龙右侧
	
	initial begin
		crash <= 0;
	end
	
	always@(*)begin
		if(rst)begin			//复位
			crash <= 0;
		end
		else if(!rdn)begin
			if(col_addr<=RIGHT && col_addr>=LEFT)begin
				if(dino == 12'hfff || obstacle == 12'hfff)	//恐龙和障碍物至少有一个为空白表示为碰撞
					crash <= 0;
				else
					crash <= 1;											//碰撞
			end
		end
	end

endmodule
