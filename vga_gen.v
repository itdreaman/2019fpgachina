`timescale 1ns / 1ps
module color_bar(
	input                 clk,           //pixel clock
	input                 rst,           //reset signal high active
	output                hs,            //horizontal synchronization
	output                vs,            //vertical synchronization
	output                de,            //video valid
output reg [11:0] v_cnt,
output reg [11:0] h_cnt
);

//640x480 25.175Mhz

parameter H_ACTIVE = 16'd640; 
parameter H_FP = 16'd16;      
parameter H_SYNC = 16'd96;    
parameter H_BP = 16'd48;      
parameter V_ACTIVE = 16'd480; 
parameter V_FP  = 16'd10;    
parameter V_SYNC  = 16'd2;    
parameter V_BP  = 16'd33;    
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;



parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
//define the RGB values for 8 colors

reg hs_reg;                      //horizontal sync register
reg vs_reg;                      //vertical sync register
reg hs_reg_d0;                   //delay 1 clock of 'hs_reg'
reg vs_reg_d0;                   //delay 1 clock of 'vs_reg'
reg[11:0] h_cnt0;                 //horizontal counter
reg[11:0] v_cnt0;                 //vertical counter
reg[11:0] active_x;              //video x position 
reg[11:0] active_y;              //video y position 
reg[7:0] rgb_r_reg;              //video red data register
reg[7:0] rgb_g_reg;              //video green data register
reg[7:0] rgb_b_reg;              //video blue data register
reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
wire video_active;               //video active(horizontal active and vertical active)
reg video_active_d0;             //delay 1 clock of video_active
assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign video_active = h_active & v_active;
assign de = video_active_d0;
assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_cnt0 <= 12'd0;
	else if(h_cnt0 == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt0 <= 12'd0;
	else
		h_cnt0 <= h_cnt0 + 12'd1;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_cnt <= 12'd0;
	else if((h_cnt0 >= H_FP + H_SYNC + H_BP - 1)&&(h_cnt0 <= H_TOTAL - 1))//horizontal video active
		h_cnt <= h_cnt0 - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		h_cnt <= 0;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_cnt0 <= 12'd0;
	else if(h_cnt0 == H_FP  - 1)//horizontal sync time
		if(v_cnt0 == V_TOTAL - 1)//vertical counter maximum value
			v_cnt0 <= 12'd0;
		else
			v_cnt0 <= v_cnt0 + 12'd1;
	else
		v_cnt0 <= v_cnt0;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_cnt <= 12'd0;
	else if((v_cnt0 >= V_FP + V_SYNC + V_BP - 1)&&(v_cnt0 <= V_TOTAL - 1))//horizontal video active
		v_cnt <= v_cnt0 - (V_FP[11:0] + V_SYNC[11:0] + V_BP[11:0] - 12'd1);
	else
		v_cnt <= 0;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		hs_reg <= 1'b0;
	else if(h_cnt0 == H_FP - 1)//horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt0 == H_FP + H_SYNC - 1)//horizontal sync end
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_active <= 1'b0;
	else if(h_cnt0 == H_FP + H_SYNC + H_BP - 1)//horizontal active begin
		h_active <= 1'b1;
	else if(h_cnt0 == H_TOTAL - 1)//horizontal active end
		h_active <= 1'b0;
	else
		h_active <= h_active;
end
 

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		vs_reg <= 1'd0;
	else if((v_cnt0 == V_FP - 1) && (h_cnt0 == H_FP - 1))//vertical sync begin
		vs_reg <= HS_POL;
	else if((v_cnt0 == V_FP + V_SYNC - 1) && (h_cnt0 == H_FP - 1))//vertical sync end
		vs_reg <= ~vs_reg;  
	else
		vs_reg <= vs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_active <= 1'd0;
	else if((v_cnt0 == V_FP + V_SYNC + V_BP - 1) && (h_cnt0 == H_FP - 1))//vertical active begin
		v_active <= 1'b1;
	else if((v_cnt0 == V_TOTAL - 1) && (h_cnt0 == H_FP - 1)) //vertical active end
		v_active <= 1'b0;   
	else
		v_active <= v_active;
end

endmodule 