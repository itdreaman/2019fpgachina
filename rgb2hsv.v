`timescale 1ns / 1ps
module rgb2hsv_top(
input pclk,
input [23:0]RGB24,
output[23:0]HSV24
    );

reg [7:0]max,min;
reg [14:0] h_dividend;
reg [7:0]  h_divisor;
wire [14:0] h_quotient;
reg [8:0]  h_add;
reg [16:0]  s_dividend;
reg [7:0]  s_divisor;
wire [16:0]  s_quotient;
reg [7:0]  v;
reg sign_flag;

wire [7:0] Red,Green,Blue;
reg [7:0]R_reg,G_reg,B_reg;
reg [7:0] Hue,Saturation,Value;

wire [31:0]yshang_h,yshang_s;
wire [31:0] a,b,c,d;

assign Red = RGB24[23:16];
assign Green = RGB24[15:8];
assign Blue = RGB24[7:0];



assign HSV24[23:16] = Hue;
assign HSV24[15:8] = Saturation;
assign HSV24[7:0] = Value;


always@(posedge pclk)begin //打一拍进行后续处理
R_reg <= Red;
G_reg <= Green; 
B_reg <= Blue;
end


//先寻找RGB中的最大和最小值
compare compare_m0(
.data_a(Red)    ,
.data_b(Green)    ,
.data_c(Blue)    ,
.data_max(max)  ,
.data_min(min)  ,
.data_med()
             );


always@(posedge pclk)begin
if(max == min)begin
    sign_flag <= 0;
    h_dividend <= 0;
    h_divisor <= 1;//
    h_add <= 0;
    s_dividend <= 0;
    s_divisor <= 1;
    v <= max;
end
else if(max == R_reg && G_reg >= B_reg)begin
    sign_flag <= 0;
    h_dividend <= 60 * (G_reg - B_reg);
	h_divisor <= max - min;
	h_add <= 0;
	s_dividend <= 255 * (max - min);
	s_divisor <= max; 
	v <= max;
end
else if(max == R_reg && G_reg < B_reg )begin
    sign_flag <= 1;
    h_dividend <= 60 * (B_reg - G_reg);
	h_divisor <= max - min;
	h_add <= 360;
	s_dividend <= 255 * (max - min);
	s_divisor <= max;
	v <= max;
end 
else if(max == G_reg)begin
    if(B_reg >= R_reg)begin
	    sign_flag <= 0;
	    h_dividend <= 60 * (B_reg - R_reg);
	end
	else begin 
	    sign_flag <= 1;
        h_dividend <= 60 * (R_reg - B_reg);
	end
	
	h_divisor <= max - min;
	h_add <= 120;
	s_dividend <= 255 * (max - min) ;
	s_divisor <= max;
	v <= max;
end
else if(max == B_reg)begin
    if(R_reg >= G_reg)begin
	    sign_flag <= 0;
	    h_dividend <= 60 * (R_reg - G_reg);
	end
	else begin 
        sign_flag <= 1;
        h_dividend <= 60 * (G_reg - R_reg);
	end
	
	h_divisor <= max - min;
	h_add <= 240;
	s_dividend <= 255 * (max - min);
	s_divisor <= max;
	v <= max;
    end
end

assign a = {17'b0,h_dividend};
assign b = {24'b0,h_divisor};
//例化低延时除法器
div div_m0(
.a(a),
.b(b),
.yshang(yshang_h),
.yyushu());

assign h_quotient = yshang_h[14:0];
	
assign c = {17'b0,s_dividend};
assign d = {24'b0,s_divisor};
//例化低延时除法器
div div_m1(
.a(c),
.b(d),
.yshang(yshang_s),
.yyushu());

assign s_quotient = yshang_s[16:0];

always@(posedge pclk)begin
    if(sign_flag == 0)
        Hue <= (h_quotient + h_add)/2;
    else
        Hue <= (h_add - h_quotient)/2;
        Saturation <= s_quotient;
        Value <= v;
end

endmodule
