

module video_timing_data
#(
	parameter DATA_WIDTH = 24                       
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
	output                      de,                 
output  [11:0] v_cnt,
output  [11:0] h_cnt,
	output[DATA_WIDTH - 1:0]    vout_data           
);

//delay video_hs video_vs  video_de 2 clock cycles
wire   video_hs;
wire   video_vs;
wire   video_de;
reg                    video_hs_d0;
reg                    video_vs_d0;
reg                    video_de_d0;


assign read_en = video_de;
assign hs = video_hs_d0;
assign vs = video_vs_d0;
assign de = video_de_d0;
assign vout_data = read_data;
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
		//delay video_hs video_vs  video_de 2 clock cycles
		video_hs_d0 <= video_hs;
		video_vs_d0 <= video_vs;
		video_de_d0 <= video_de;	
	end
end

always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		read_req <= 1'b0;
	else if(video_vs_d0 & ~video_vs) //vertical synchronization edge (the rising or falling edges are OK)
		read_req <= 1'b1;
	else if(read_req_ack)
		read_req <= 1'b0;
end
color_bar colar_bar_m0(
      .clk(video_clk), 
      .rst(rst),       
      .hs(video_hs),   
      .vs(video_vs),   
      .de(video_de),   
      .v_cnt(v_cnt),
      .h_cnt(h_cnt)
);
endmodule 