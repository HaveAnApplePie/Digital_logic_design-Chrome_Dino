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
	inout[3:0] BTN_Y,
	output SEGLED_CLK,
	output SEGLED_CLR,
	output SEGLED_DO,
	output SEGLED_PEN
    );
	 
	wire[31:0] clk_div;
	clkdiv clk0(.clk(clk), .rst(1'b0), .clkdiv(clk_div));	//时钟分频器
	
	wire[15:0] SW_OK;
	AntiJitter #(4) a0[15:0](.clk(clk_div[15]), .I(SW), .O(SW_OK));	//SW防抖
	
	wire[4:0] keyCode;
	wire keyReady;
	Keypad k0(.clk(clk_div[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));	//BTN矩阵模式防抖
	
	reg[11:0] vga_data;
	wire[9:0] col_addr;
	wire[8:0] row_addr;
	vgac vga(.vga_clk(clk_div[1]), .clrn(SW_OK[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(R), .g(G), .b(B), .hs(HS), .vs(VS));	//VGA驱动

	
	reg[18:0] Dino0;	//恐龙图像ip核地址
	//wire[11:0] spob;	//恐龙图像ip核输出，4*3 rgb
	reg[9:0] Dino0_X, Dino1_X;	//恐龙位置X坐标（左上角）
	initial Dino0_X <= 10'd30;
	initial Dino1_X <= 10'd30;
	reg[8:0] Dino0_Y, Dino1_Y;	//恐龙位置Y坐标（左上角）
	initial Dino0_Y <= 9'd146;
	initial Dino1_Y <= 9'd386;
	//Dinosaur64 Dino(.addra(Dino0), .douta(spob), .clka(clk_div[1]));	//恐龙模型ip核
	wire[11:0] spobDinoL;	//左腿抬起图像
	DinoL DinoL(.addra(Dino0), .douta(spobDinoL), .clka(clk_div[1]));
	wire[11:0] spobDinoR;	//右腿抬起图像
	DinoR DinoR(.addra(Dino0), .douta(spobDinoR), .clka(clk_div[1]));
	
			
	wire [31:0] segData;
	wire [3:0] sout;
	ScoreCounter Score0(.clk_div(clk_div), .data(segData));
	Seg7Device segDevice(.clkIO(clk_div[3]), .clkScan(clk_div[15:14]), .clkBlink(clk_div[25]),
									.data(segData), .point(8'h0), .LES(8'h0),
									.sout(sout));
	assign SEGLED_CLK = sout[3];
	assign SEGLED_DO = sout[2];
	assign SEGLED_PEN = sout[1];
	assign SEGLED_CLR = sout[0];
	
	reg wasReady;
	reg isJump, isJump0;	//是否改变恐龙的位置
	reg[7:0] jumpTime, jumpTime0;	//跳跃时间计数器
	initial isJump <= 1'b0;
	initial isJump0 <= 1'b0;
	initial jumpTime <= 8'd128;
	initial jumpTime0 <= 8'd128;
	reg DinoLeg, DinoLeg0;
	initial DinoLeg <= 1'b0;
	initial DinoLeg0 <= 1'b1;
	always@(posedge clk)begin
	
	
		wasReady <= keyReady;
		if(!wasReady && keyReady)begin
			case(keyCode)
				5'h10: if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end	//开始跳跃，将计数器置零
				5'h12: if(jumpTime0 >= 8'd64)begin isJump0 <= 1'b1; jumpTime0 <= 8'd0; end
				//5'hc: Dino0_X <= Dino0_X - 10'd20;
				//5'he: Dino0_X <= Dino0_X + 10'd20;
				//5'h9: Dino0_Y <= Dino0_Y - 9'd20;
				//5'h11: Dino0_Y <= Dino0_Y + 9'd20;
				default:;
			endcase
		end
		
		if(clk_div[23] && DinoLeg)begin
			DinoLeg <= 1'b0;
			DinoLeg0 <= 1'b1;
		end
		else if(!clk_div[23] && !DinoLeg)begin
			DinoLeg <= 1'b1;
			DinoLeg0 <= 1'b0;
		end
		
		if(col_addr >= Dino0_X && col_addr <= Dino0_X + 63 && row_addr >= Dino0_Y && row_addr <= Dino0_Y + 63)begin //当扫描到恐龙应该出现的位置时
			Dino0 <= (col_addr-Dino0_X)*64 + (row_addr-Dino0_Y);	//将需要读取的内存地址送入ip核
			if(DinoLeg)
				vga_data <= spobDinoL[11:0];	//输出传入VGA
			else
				vga_data <= spobDinoR[11:0];
		end
		else if(col_addr >= Dino1_X && col_addr <= Dino1_X + 63 && row_addr >= Dino1_Y && row_addr <= Dino1_Y + 63)begin
			Dino0 <= (col_addr-Dino1_X)*64 + (row_addr-Dino1_Y);	//将需要读取的内存地址送入ip核
			if(DinoLeg0)
				vga_data <= spobDinoL[11:0];	//输出传入VGA
			else
				vga_data <= spobDinoR[11:0];
		end
		else if(row_addr == 9'd240)begin
			vga_data <= 12'h000;
		end
		else begin
			vga_data <= 12'hfff;	//否则渲染白色
		end
		
		//注：上升/下降均采用分三段速度进行，模拟重力
		//跳跃上升阶段开始
		if(clk_div[19] && isJump && jumpTime < 8'd10)begin
			Dino0_Y <= Dino0_Y - 10'd6;
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
		//跳跃上升阶段结束
		else if(!clk_div[19] && !isJump && jumpTime < 8'd64) begin
			isJump <= 1;
		end
		//跳跃下降阶段开始
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
			Dino0_Y <= Dino0_Y + 10'd6;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		//跳跃下降阶段结束
		
		
		//注：上升/下降均采用分三段速度进行，模拟重力
		//跳跃上升阶段开始
		if(clk_div[19] && isJump0 && jumpTime0 < 8'd10)begin
			Dino1_Y <= Dino1_Y - 10'd6;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd10 && jumpTime0 < 8'd20)begin
			Dino1_Y <= Dino1_Y - 10'd4;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd20 && jumpTime0 < 8'd32)begin
			Dino1_Y <= Dino1_Y - 10'd2;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		//跳跃上升阶段结束
		else if(!clk_div[19] && !isJump0 && jumpTime0 < 8'd64) begin
			isJump0 <= 1;
		end
		//跳跃下降阶段开始
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd32 && jumpTime0 < 8'd44)begin
			Dino1_Y <= Dino1_Y + 10'd2;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <= 0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd44 && jumpTime0 < 8'd54)begin
			Dino1_Y <= Dino1_Y + 10'd4;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <= 0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd54 && jumpTime0 < 8'd64)begin
			Dino1_Y <= Dino1_Y + 10'd6;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		//跳跃下降阶段结束
		
	end
	
	
	
endmodule
