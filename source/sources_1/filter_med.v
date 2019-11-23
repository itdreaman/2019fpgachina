module filter_med(
	input                         clk,
	input                         rst,	
	input[23:0]                   data_in,
	input                         rgb_hs,
	input                         rgb_vs,
	input                         rgb_de,
    input  [11:0]                 v_cnt,
    input  [11:0]                 h_cnt,
    output reg [11:0]             v_cnt_out,
    output reg [11:0]             h_cnt_out,
	output [23:0]                 data_out,
	output reg                    hs_out,
	output reg                    vs_out,
	output reg                    de_out
);
wire   [7:0]r,g,b;

assign  r=data_in[23:16];
assign  g=data_in[15:8];
assign  b=data_in[7:0];

reg    [11:0]             v_cnt_delay_1;
reg    [11:0]             h_cnt_delay_1;
reg    [11:0]             v_cnt_delay_2;
reg    [11:0]             h_cnt_delay_2;
reg    [11:0]             v_cnt_delay_3;
reg    [11:0]             h_cnt_delay_3;

reg                            i_h_sync_delay_1;
reg                            i_v_sync_delay_1;
reg                            i_data_en_delay_1;
reg                            i_h_sync_delay_2;
reg                            i_v_sync_delay_2;
reg                            i_data_en_delay_2;
reg                            i_h_sync_delay_3;
reg                            i_v_sync_delay_3;
reg                            i_data_en_delay_3;


always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		i_h_sync_delay_1 <= 1'b0;
		i_v_sync_delay_1 <= 1'b0;
		i_data_en_delay_1 <= 1'b0;
        v_cnt_delay_1 <= 12'b0;
        h_cnt_delay_1 <= 12'b0;
		i_h_sync_delay_2 <= 1'b0;
		i_v_sync_delay_2 <= 1'b0;
		i_data_en_delay_2 <= 1'b0;
        v_cnt_delay_2 <= 12'b0;
        h_cnt_delay_2 <= 12'b0;
		i_h_sync_delay_3 <= 1'b0;
		i_v_sync_delay_3 <= 1'b0;
		i_data_en_delay_3 <= 1'b0;
        v_cnt_delay_3 <= 12'b0;
        h_cnt_delay_3 <= 12'b0;
		hs_out <= 1'b0;
		vs_out <= 1'b0;
		de_out <= 1'b0;
        v_cnt_out <= 12'b0;
        h_cnt_out <= 12'b0;
	end
	else
	begin
		i_h_sync_delay_1 <= rgb_hs;
		i_v_sync_delay_1 <= rgb_vs;
		i_data_en_delay_1 <= rgb_de;
        v_cnt_delay_1 <= v_cnt;
        h_cnt_delay_1 <= h_cnt;
		i_h_sync_delay_2 <= i_h_sync_delay_1;
		i_v_sync_delay_2 <= i_v_sync_delay_1;
		i_data_en_delay_2 <= i_data_en_delay_1;
        v_cnt_delay_2 <= v_cnt_delay_1;
        h_cnt_delay_2 <= h_cnt_delay_1;
		i_h_sync_delay_3 <= i_h_sync_delay_2;
		i_v_sync_delay_3 <= i_v_sync_delay_2;
		i_data_en_delay_3 <= i_data_en_delay_2;
        v_cnt_delay_3 <= v_cnt_delay_2;
        h_cnt_delay_3 <= h_cnt_delay_2;
		hs_out <= i_h_sync_delay_3;
		vs_out <= i_v_sync_delay_3;
		de_out <= i_data_en_delay_3;
        v_cnt_out <= v_cnt_delay_3;
        h_cnt_out <= h_cnt_delay_3;
	end
	
end

filter filter_m0(
	.rst                        (rst                  ),
	.pclk                       (clk                  ),
	.de                         (de_out               ),
	.data_in                    (r                    ),
	.data_out                   (data_out[23:16]      )
);
filter filter_m1(
	.rst                        (rst                  ),
	.pclk                       (clk                  ),
	.de                         (de_out               ),
	.data_in                    (g                    ),
	.data_out                   (data_out[15:8]       )
);
filter filter_m2(
	.rst                        (rst                  ),
	.pclk                       (clk                  ),
	.de                         (de_out               ),
	.data_in                    (b                    ),
	.data_out                   (data_out[7:0]        )
);


endmodule