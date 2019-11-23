`timescale 1ns / 1ps

module weight_cal(
    input PCLK,
input [11:0] VtcHCnt,
input [11:0] VtcVCnt,
input [11:0]    center_h, 
input [11:0]   center_v, 	
 output reg[3:0]  weight
);
wire [11:0]diff_h;
wire [11:0]diff_v;
assign diff_h = (VtcHCnt > center_h)? (VtcHCnt - center_h):(center_h - VtcHCnt);
assign diff_v = (VtcVCnt > center_v)? (VtcVCnt - center_v):(center_v - VtcVCnt);


always@(posedge PCLK)begin
if(diff_h <20 && diff_v<15)
weight <= 4'b1111;
if(diff_h >20 && diff_v>15 && diff_h <40 && diff_v<30)
weight <= 4'b1101;
  if(diff_h >40 && diff_v>30&&diff_h <60 && diff_v<45)
 weight <= 4'b1001;
   if(diff_h >60 && diff_v>45&&diff_h <80 && diff_v<60)
weight <= 4'b0101;
  if(diff_h >80 && diff_v>60&&diff_h <100 && diff_v<75)
weight <= 4'b0011;
  if(diff_h >100 && diff_v>75&&diff_h <120 && diff_v<90)
weight <= 4'b0010;
  if(diff_h >120 && diff_v>90&&diff_h <140 && diff_v<105)
weight <= 4'b0010;

 if(diff_h >140 && diff_v>105)
 weight <= 4'b0001;  
end

endmodule
