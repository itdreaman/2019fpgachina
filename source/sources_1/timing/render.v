`timescale 1ns / 1ps

module render(
    input               PClk,
    input [23:0]        RGB24,
    input               Binary_in,
    input [11:0]        VtcHCnt,
    input [11:0]        VtcVCnt,
    input [11:0]        center_h,  	
    input [11:0]        center_v,		
    output reg [23:0]   RGB_render
    );
	 
reg [23:0]      RGB_render_temp;

always@(posedge PClk) begin
    if(Binary_in==1) begin
        RGB_render_temp[23:16]  <= 0;
        RGB_render_temp[15:8]	<= 255;
        RGB_render_temp[7:0] 	<= 0;
    end
    else begin
        RGB_render_temp[23:16]  <= RGB24[23:16];
        RGB_render_temp[15:8]	<= RGB24[15:8];
        RGB_render_temp[7:0] 	<= RGB24[7:0];
    end
    
    if ((320-24==VtcHCnt||320+24==VtcHCnt) && VtcVCnt>=240-24&&VtcVCnt<=240+24 
    ||(240-24==VtcVCnt||240+24==VtcVCnt) && VtcHCnt>=320-24&&VtcHCnt<=320+24  )begin
        RGB_render <= 24'b11111111_00000000_11111111;
    end
    else  if(center_h==VtcHCnt | center_v==VtcVCnt)
        RGB_render <= 24'b11111111_00000000_00000000;
    else
        RGB_render <= RGB_render_temp;

end


endmodule
