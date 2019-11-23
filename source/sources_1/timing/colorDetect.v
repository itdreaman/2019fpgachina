`timescale 1ns / 1ps

module colorDetect(
input PClk,
input btn_ColorExtract,
input sw_ColorClear,
input [11:0] VtcHCnt,
input [11:0] VtcVCnt,
input [23:0] HSV24,
input Binary_PostProcess,
	 
output reg [20:0] Binary_Sum,
output reg [23:0] HSV_detect
);
wire [7:0] HUE;
wire [7:0] SATURATION;
wire [7:0] VALUE;

reg [23:0] HSV_out_temp;
assign HUE = HSV24[23:16];
assign SATURATION = HSV24[15:8];
assign VALUE = HSV24[7:0];

reg [31:0] H_Sum;
reg [31:0] S_Sum;
reg [31:0] V_Sum;

reg [20:0] Binary_Sum;
always@(posedge PClk) begin
if( VtcVCnt == 1 && VtcHCnt==1) begin 
Binary_Sum<=0;
end
        if(Binary_PostProcess==1)begin
        Binary_Sum<=Binary_Sum+1;
        end
end
always@(posedge PClk) begin	
	// signal output
	if(btn_ColorExtract==1) begin
		HSV_detect <= HSV_out_temp;
		end
	if(sw_ColorClear == 1)begin
	   HSV_detect <= 24'b11111111_11111111_11111111;
		end
	
	if( VtcHCnt >=296 && VtcHCnt <344 && VtcVCnt >=216 && VtcVCnt <264 ) begin  // acumulate
		H_Sum <= H_Sum + HUE;
		S_Sum <= S_Sum + SATURATION;
		V_Sum <= V_Sum + VALUE;
		end
	else if( VtcVCnt == 1 ) begin // initial
		H_Sum <= 0;
		S_Sum <= 0;
		V_Sum <= 0;
		end
	else if( VtcVCnt == 479 ) begin // result
			HSV_out_temp[23:16] 	<= H_Sum / 2304;
			HSV_out_temp[15:8] 	<= S_Sum / 2304;
			HSV_out_temp[7:0] 	<= V_Sum / 2304;
		end
end

endmodule



	 
