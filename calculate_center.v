`timescale 1ns / 1ps
module center(
input                pclk,  			
input                din,  			
input [11:0]         Hcnt,  	
input [11:0]         Vcnt,		
output reg[11:0]    center_h, 
output reg [11:0]   center_v, 	
input [20:0]         Binary_Sum,
input [3:0] weight
);
	
reg [24:0]        num; 	
reg [24:0]        num_cnt; 
reg [15:0]        h_cnt;	
reg [14:0]        v_cnt;	
reg [14:0]        center_line_num; 
reg [14:0]        H_num_cnt;
reg [14:0]        center_line_num_cnt; 

reg en;
always@(*) begin//设定有效区域
	if(Hcnt>0 && Hcnt<640 && Vcnt>0 && Vcnt<479) 
		en<= 1;
	else
		en<= 0;
end


always@(posedge pclk) begin
	if(Hcnt==1 && Vcnt==0) 
		begin
			num_cnt<= 0;
		end
	else
		if(din==1 && en==1) num_cnt<= num_cnt+weight;
		else	   			num_cnt<= num_cnt;
end

always@(posedge pclk) begin//在center_v行，对特征像素计数，当达到center_line_num/2时,得到中心坐标的x值
	if(Hcnt==1 && Vcnt==0) 
		begin
			 H_num_cnt<= 0;
			 h_cnt<= 0;
		end
	else
		if(Vcnt==center_v &&din==1 && en==1)begin H_num_cnt<= H_num_cnt+weight;
		   if(Hcnt>0 && Hcnt<639 && Vcnt>0 && Vcnt<479) begin
            if(H_num_cnt<center_line_num/2)
             h_cnt<= Hcnt;
            else			 
             h_cnt<= h_cnt;
             end
		end
		else	   			
		     H_num_cnt<= H_num_cnt;
end
always@(posedge pclk) begin//当num_cnt的计数值为num的一半时，得到中心坐标的y值
if(Hcnt>0 && Hcnt<639 && Vcnt>0 && Vcnt<479) begin
	if(num_cnt<num/2) v_cnt<= Vcnt;
	else			  v_cnt<= v_cnt;
	end
end


always@(posedge pclk) begin
	if(Hcnt==1 && Vcnt==0) 
		begin
			center_line_num_cnt<= 0;
		end
	else
		if(Vcnt==center_v && en==1 &&din==1) 
			center_line_num_cnt<= center_line_num_cnt + weight;
		else 
			center_line_num_cnt<= center_line_num_cnt;
end
always@(posedge pclk) begin
	if(Hcnt==639 && Vcnt==479)begin
	    num<= num_cnt;
	    center_line_num<= center_line_num_cnt;
	    if(Binary_Sum> 30)begin
            center_v<= (v_cnt==478 )? 0 : v_cnt;
            center_h<=h_cnt;
	    end
	    else begin
            center_v<= 240;
            center_h<=320;
	    end
	end
end

endmodule