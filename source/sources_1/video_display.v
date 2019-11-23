module video_display(
	input                       video_clk,        
	input                       rst,
	input[23:0]        data_in,        
	output                      hs,               
	output                      vs,               
	output                      de,               
input                   video_hs,
input                   video_vs,
input                   video_de,
	output[23:0]       vout_data           // video data
);

//delay video_hs video_vs  video_de 2 clock cycles
reg                    video_hs_d0;
reg                    video_vs_d0;
reg                    video_de_d0;
reg                    video_hs_d1;
reg                    video_vs_d1;
reg                    video_de_d1;

reg[23:0]  vout_data_r;


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
		//delay video_hs video_vs  video_de 2 clock cycles
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
		vout_data_r <= {23{1'b0}};
	else if(video_de_d0)
		vout_data_r <= data_in;
	else
		vout_data_r <= {23{1'b0}};
end


endmodule