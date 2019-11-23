module sevo_track(
    input [11:0]cen_x,
	 input clk_pwm,
    input rst,
	input sw_en,
    input  clk_servo,
     output wire PWM 
    );
//localparam define 
localparam  angle_0    = 24_000; 
localparam  angle_5    = 778;                 
localparam  angle_90   = 75_000;            
localparam  angle_180  = 126_000;    


reg [31:0] anglex;
reg [31:0]cnt;
reg clk_50hz;




//²úÉú0.01sÊ±ÖÓ
always@(posedge clk_servo , negedge rst)
if(!rst)begin
    cnt<=0;
    clk_50hz<=0;
end
else begin
	if(cnt<32'd25_000 -1)begin
		cnt<=cnt+1;
	end
	else begin
		clk_50hz<=~clk_50hz;
		cnt<=0;
	end
	
end
//-------------------------------------------------------------


//
always@(posedge clk_50hz , negedge rst)begin
    if(!rst)begin
        anglex<=angle_90;    
    end
    else if(!sw_en)
	     anglex<=anglex;
    else if(anglex<angle_0)
          anglex<=32'd25_000;
    else if(anglex>angle_180)
          anglex<=32'd125_000;
    else if(cen_x<=270)begin 
        anglex<=anglex+angle_5;
       end
    else if(cen_x>=370)begin
        anglex<=anglex-angle_5;
    end
   else 
        anglex<=anglex;
end
//
sevo_ctrl strl_x(
.clk_pwm(clk_pwm),
.rst(rst),
.angle(anglex),
.PWM(PWM) 
);
endmodule

