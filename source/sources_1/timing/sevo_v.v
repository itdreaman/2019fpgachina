module sevo_v(
    input [11:0]cen_y,
	 input clk_pwm,
    input rst,
	input sw_en,
    input  clk_servo,
     output wire PWM 
    );
//localparam define 
localparam  angle_0    = 24_000; 
localparam  angle_5    = 778;         
localparam  angle_10   = 30_555;    
localparam  angle_20   = 36_111;
localparam  angle_45   = 50_000;     
localparam  angle_90   = 75_000;          
localparam  angle_135  = 100_000;  
localparam  angle_180  = 126_000;    


reg [31:0] angley;
reg [31:0]cnt;
reg clk_hz;




always@(posedge clk_servo , negedge rst)
if(!rst)begin
    cnt<=0;
    clk_hz<=0;
end
else begin
	if(cnt<32'd25_000 -1)begin
		cnt<=cnt+1;
	end
	else begin
		clk_hz<=~clk_hz;
		cnt<=0;
	end
	
end

always@(posedge clk_hz , negedge rst)begin
    if(!rst)begin
        angley<=angle_90;    
    end
    else if(!sw_en)
	     angley<=angley;
    else if(angley<angle_0)
          angley<=32'd25_000;
    else if(angley>angle_180)
          angley<=32'd125_000;
    else if(cen_y<=190)begin 
        angley<=angley+angle_5;
       end
    else if(cen_y>=290)begin
        angley<=angley-angle_5;
    end
   else 
        angley<=angley;
end
//
sevo_ctrl strl_y(
.clk_pwm(clk_pwm),
.rst(rst),
.angle(angley),
.PWM(PWM) 
);
endmodule

