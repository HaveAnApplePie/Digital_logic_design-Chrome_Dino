`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:33 12/30/2019 
// Design Name: 
// Module Name:    Cactus_s 
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
module Cactus_b(					 //大仙人掌 big cactus
	 input wire clk_ip,			 //给IP核用的时钟信号，频率更高，clk_div[1]
	 input wire clk,				 //物体向前移动一列的时钟信号
	 input wire start,			 //开始信号,为一个短脉冲  接到短脉冲之后开始输出图像
	 input wire rdn,            // read pixel RAM (active_low)11
	 input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	 input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	 output reg [11:0] dout,	 //数据输出bbbb_gggg_rrrr 
	 output reg finish			 //完成信号
    );
	 parameter	
		HEIGHT  	   = 68,			 //图像高度
		LENGTH      = 34,			 //图像长度
		COLNUM      = 640,	    //总列数
		ROW_HIGHEST = 300;	    //该模块所在的最高的行数，以0开始

	//这里可以用IP核代替
	 wire [11:0]data;  							//每个为12位数据
	 wire [15:0]col,row;
	 wire [15:0]addr;								//对应于       ||||||||||■ ■||||||||||      的位置
														//            ||		 ||■■■||		  ||
														//				  |||||||||| ■ ||||||||||
	 initial begin
		count <= LENGTH+COLNUM;					//保证一开始finish一直为1，从而输出一直为白色
	 end

	
	Cactus_b_ip CACTUS(clk_ip,{addr+1'b1},data);	//取出来的值会延时一个时钟周期clk_ip，要不要把address+1？？？
	
	
	reg [11: 0]count;				 //起始列的位置
	always @(posedge clk or posedge start) begin
		if(start)					 //start由0变为1时,开始输出图像
			count <= 0;
		else if(count <= 12'hfff)
			count <= count + 1'b1;
			
		
	end
	
/*	assign col   = HEIGHT - 1 - (row_addr-(ROW_HIGHEST-HEIGHT+1));	//对应文件里的列
	assign row   = (count+col_addr-COLNUM);								//对应文件里的行
	assign addr	 =	row*LENGTH+col;					
*/
	assign addr	 =	(row_addr-(ROW_HIGHEST-HEIGHT+1))*LENGTH+			//对应文件里的行
			          count+col_addr-COLNUM ;						      //对应文件里的列
						 
	always@(*)begin
		
		if(count>=LENGTH+COLNUM)	 //如果已经移出，则输出finish信号
			finish <= 1;
		else
			finish <= 0;
	end
	
	
	always @(*) begin
		if(!rdn)begin  //读入操作
			if(!finish)begin	//未完成输出
				if ( ((count+col_addr) >= COLNUM)&& 				//左边界 闭
					((count+col_addr) < (COLNUM+LENGTH))&&	   	//右边界 开
					(row_addr <= ROW_HIGHEST) &&						//下边界 闭
					(row_addr > (ROW_HIGHEST-HEIGHT)))	begin		//上边界 开			
					dout <= data;		    							   //特定颜色
					//dout <= 12'h555;
				end
				else begin
					dout <=  12'hfff;    //白色
				end
			end
		end
		else begin	//完成输出
				dout <=  12'hfff;    //白色
		end
	end



endmodule
