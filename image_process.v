module video_timing_data
#(
	parameter DATA_WIDTH = 24                       // 定义好数据宽度
)
(
	input                       video_clk,          
	input                       rst,
	output reg                  read_req,               
	input                       read_req_ack,       
	output                      read_en,            
	input[DATA_WIDTH - 1:0]     read_data,         
	output                      hs,                
	output                      vs,                
	output                      de,                 // 输出使能

    output  [11:0]              center_h,          //增加的中心坐标输出
    output  [11:0]              center_v,

	input sw_extract,
	input sw_clear,
	output[DATA_WIDTH - 1:0]    vout_data           
);

wire [11:0] h_cnt;                 
wire [11:0] v_cnt;
wire                   video_hs;
wire                   video_vs;
wire                   video_de;

reg                    video_hs_d0;
reg                    video_vs_d0;
reg                    video_de_d0;
reg                    video_hs_d1;
reg                    video_vs_d1;
reg                    video_de_d1;

reg[DATA_WIDTH - 1:0]  vout_data_r;

wire[DATA_WIDTH - 1:0]  RGB24_dis;
wire[DATA_WIDTH - 1:0]  HSV24;

wire dilate_0_pix_o;
wire erode_0_pix_o;
wire Binary_PreProcess;

assign read_en = video_de;
assign hs = video_hs_d1;
assign vs = video_vs_d1;
assign de = video_de_d1;
assign vout_data = vout_data_r;
always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		video_hs_d0 <= 1'b0;
		video_vs_d0 <= 1'b0;
		video_de_d0 <= 1'b0;
	end
	else
	begin
		
		video_hs_d0 <= video_hs;
		video_vs_d0 <= video_vs;
		video_de_d0 <= video_de;
		video_hs_d1 <= video_hs_d0;
		video_vs_d1 <= video_vs_d0;
		video_de_d1 <= video_de_d0;		
	end
end

always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		vout_data_r <= {DATA_WIDTH{1'b0}};
	else if(video_de_d0)
		vout_data_r <= RGB24_dis;
	else
		vout_data_r <= {DATA_WIDTH{1'b0}};
end

always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		read_req <= 1'b0;
	else if(video_vs_d0 & ~video_vs) 
		read_req <= 1'b1;
	else if(read_req_ack)
		read_req <= 1'b0;
end

rgb2hsv rgb2hsv_m0
       (.HSV24(HSV24),
        .RGB24(read_data),
        .pclk(video_clk));

color_detect color_detect_m0
       (.Binary_PostProcess(dilate_0_pix_o),
        .Binary_PreProcess(Binary_PreProcess),
        .HSV24(HSV24),
        .PClk(video_clk),
        .RGB24(read_data),
        .RGB24_dis(RGB24_dis),
        .VtcHCnt(h_cnt),
        .VtcVCnt(v_cnt),
        .btn_ColorExtract(sw_extract),
        .center_h(center_h),
        .center_v(center_v),
        .sw_ColorClear(sw_clear));

dilate_obj dilate_m0
       (.PCLK(video_clk),
        .VtcHCnt(h_cnt),
        .VtcVCnt(v_cnt),
        .pix_i(erode_0_pix_o),
        .pix_o(dilate_0_pix_o));

erode_obj erode_m0
       (.PCLK(video_clk),
        .VtcHCnt(h_cnt),
        .VtcVCnt(v_cnt),
        .pix_i(Binary_PreProcess),
        .pix_o(erode_0_pix_o));


vga_gen vga_gen_m0(
	.clk(video_clk),
	.rst(rst),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.v_cnt(v_cnt),
	.h_cnt(h_cnt),
	.rgb_r(),
	.rgb_g(),
	.rgb_b()
);
endmodule 