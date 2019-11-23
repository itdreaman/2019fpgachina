`timescale 1ns / 1ps

module mark_obj(
input [23:0] HSV24,
input [23:0] HSV_Detect,
output reg Binary_out
);

reg [7:0] H_diff;
reg [7:0] S_diff;
reg [7:0] V_diff;
reg [8:0] diff_sum;

always@(*) begin
	if(HSV24[23:16] > HSV_Detect[23:16])//对画面中的的HSV和采集学习的HSV做差
		H_diff <= HSV24[23:16] - HSV_Detect[23:16];
	else
		H_diff <= HSV_Detect[23:16] - HSV24[23:16];
	if(HSV24[15:8] > HSV_Detect[15:8])
		S_diff <= HSV24[15:8] - HSV_Detect[15:8];
	else
		S_diff <= HSV_Detect[15:8] - HSV24[15:8];
	if(HSV24[7:0] > HSV_Detect[7:0])
		V_diff <= HSV24[7:0] - HSV_Detect[7:0];
	else
		V_diff <= HSV_Detect[7:0] - HSV24[7:0];
        diff_sum <= H_diff/2 + S_diff/4 + V_diff/4;
   if(diff_sum > 20|| H_diff/2 > 6 ||  S_diff/4 > 12 || V_diff/4 >12)//设定阈值
        Binary_out <= 0;
   else
        Binary_out <= 1;
end

endmodule