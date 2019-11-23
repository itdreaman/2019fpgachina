
 module top(
input                       sys_clk,
input                       rst_n,
output                      cmos_scl,         
inout                       cmos_sda,         
input                       cmos_vsync,       
input                       cmos_href,        
input                       cmos_pclk,         
output                      cmos_xclk,         
input  [7:0]                  cmos_db,

output                cam_rst_n   , 
output                cam_sgm_ctrl, 
      
input               sw_extract,
input               sw_clear,   

input       sw_en,
output      pwm_x,   
output      pwm_y,  
                                                                                                        
input                                pad_loop_in            ,
input                                pad_loop_in_h          ,
output                               pad_rstn_ch0           ,
output                               pad_ddr_clk_w          ,
output                               pad_ddr_clkn_w         ,
output                               pad_csn_ch0            ,
output [15:0]                        pad_addr_ch0           ,
inout  [16-1:0]                      pad_dq_ch0             ,
inout  [16/8-1:0]                    pad_dqs_ch0            ,
inout  [16/8-1:0]                    pad_dqsn_ch0           ,
output [16/8-1:0]                    pad_dm_rdqs_ch0        ,
output                               pad_cke_ch0            ,
output                               pad_odt_ch0            ,
output                               pad_rasn_ch0           ,
output                               pad_casn_ch0           ,
output                               pad_wen_ch0            ,
output [2:0]                         pad_ba_ch0             ,
output                               pad_loop_out           ,
output                               pad_loop_out_h         ,

output                              tmds_clk_p,
output                              tmds_clk_n,
output  [2:0]                       tmds_data_p,       
output  [2:0]                       tmds_data_n                       
);
assign     cam_rst_n = 1'b1;
assign     cam_sgm_ctrl = 1'b0;
parameter  SLAVE_ADDR =  7'h21        ;  
parameter  BIT_CTRL   =  1'b0         ;  
parameter  CLK_FREQ   = 26'd50_000_000;  
parameter  I2C_FREQ   = 18'd250_000   ;  


parameter MEM_DATA_BITS          = 64;             //external memory user interface data width
parameter ADDR_BITS              = 25;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data0;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            video_clk;         //video pixel clock
wire                            video_clk5x;
wire                            hs;
wire                            vs;
wire                            de;
wire[23:0]                      vout_data;
wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

wire                            ui_clk;
wire                            ui_clk_sync_rst;
wire                            init_calib_complete;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
wire                            clk_200MHz;

wire                  i2c_exec        ;  
wire   [15:0]         i2c_data        ;       
wire                  cam_init_done   ;  
wire                  i2c_done        ;  
wire                  i2c_dri_clk     ;  

wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire [7:0]                       hdmi_r;
wire [7:0]                       hdmi_g;
wire [7:0]                       hdmi_b;


assign  hdmi_hs    = hs;
assign  hdmi_vs    = vs;
assign  hdmi_de    = de;
assign hdmi_r      = dip_data[23:16];
assign hdmi_g      = dip_data[15:8];
assign hdmi_b      = dip_data[7:0];

assign write_en = cmos_16bit_wr;
assign write_data = cmos_16bit_data;

//timing
wire [23:0] HSV_detect;
wire[23:0]  HSV24;

wire[3:0] weight; 
wire[20:0] Binary_Sum;
wire [23:0] RGB_render;
wire dilate_0;
wire erode_0;
wire Binary_Pre;
wire clk_servo;

wire [11:0] h_cnt;                
wire [11:0] v_cnt;
wire [11:0] h_cnt0;
wire [11:0] v_cnt0;

wire [23:0]dip_data;
wire hs0;
wire vs0;
wire de0;
wire hs1;
wire vs1;
wire de1;
wire [23:0]read_data;
wire [23:0]filter_data;
assign read_data={read_data0[15:11],3'd0,read_data0[10:5],2'd0,read_data0[4:0],3'd0};

wire  [11:0] center_h;
wire  [11:0] center_v;
sevo_track ux(
.cen_x(center_h),
.clk_pwm(sys_clk),
.rst(rst_n),
.sw_en(sw_en),
.clk_servo(clk_servo),
.PWM(pwm_x) 
    );
sevo_v uy(
.cen_y(center_v),
.clk_pwm(sys_clk),
.rst(rst_n),
.sw_en(sw_en),
.clk_servo(clk_servo),
.PWM(pwm_y) 
    );
//display
video_display  u_display(
	  .video_clk   (video_clk),        
	  .rst         (~rst_n),
	  .data_in     (RGB_render),
      .video_hs    (hs1),
      .video_vs    (vs1),
      .video_de    (de1),        
	  .hs          (hs),               
	  .vs          (vs),               
	  .de          (de),               
      .vout_data   (dip_data)          
);
//filter
filter_med med_u(
	       .clk         (video_clk),
	       .rst         (~rst_n),	
	       .data_in     (vout_data),
	       .rgb_hs      (hs0),
	       .rgb_vs      (vs0),
	       .rgb_de      (de0),
           .v_cnt       (v_cnt0),
           .h_cnt       (h_cnt0),
           .v_cnt_out   (v_cnt),
           .h_cnt_out   (h_cnt),
	       .data_out    (filter_data),
	       .hs_out      (hs1),
	       .vs_out      (vs1),
	       .de_out      (de1)
);
//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs0                       ),
	.vs                         (vs0                       ),
	.de                         (de0                       ),
    .v_cnt(v_cnt0),
    .h_cnt(h_cnt0),
	.vout_data                  (vout_data                )
);

colorDetect colorDetect_0
       (
        .PClk                  (video_clk),
        .VtcHCnt               (h_cnt),
        .VtcVCnt               (v_cnt),
        .btn_ColorExtract      (~sw_extract),
        .HSV24                 (HSV24),
        .Binary_PostProcess    (dilate_0),
        .Binary_Sum            (Binary_Sum),
        .HSV_detect            (HSV_detect),
        .sw_ColorClear         (~sw_clear));
BW RGB2BW(
	.HSV24        (HSV24),
    .HSV_Detect   (HSV_detect),
    .Binary_out   (Binary_Pre)
);
weight_cal u_weight(
   .PCLK             (video_clk),
   .VtcHCnt          (h_cnt),
   .VtcVCnt          (v_cnt),
   .center_h         (center_h),
   .center_v         (center_v),
   .weight            (weight)
);
center cenCalculate(
    .pclk             (video_clk),  			
    .din              (dilate_0),  		
    .Hcnt             (h_cnt),       	
    .Vcnt             (v_cnt), 		  
    .center_h         (center_h),    
    .center_v         (center_v), 	
    .Binary_Sum       (Binary_Sum),
    .weight           (weight)
);
render RGBrender(
	.PClk            (video_clk),
	.RGB24           (filter_data),
	.Binary_in       (dilate_0),
	.VtcHCnt         (h_cnt),      	
	.VtcVCnt         (v_cnt), 	    
	.center_h        (center_h),    
	.center_v        (center_v),    
	.RGB_render      (RGB_render)
);	
erode erode_u(
        .PCLK        (video_clk),
        .VtcHCnt     (h_cnt),
        .VtcVCnt     (v_cnt),
        .pix_i       (Binary_Pre),
        .pix_o       (erode_0));
dilate dilate_u(
        .PCLK        (video_clk),
        .VtcHCnt     (h_cnt),
        .VtcVCnt     (v_cnt),
        .pix_i       (erode_0),
        .pix_o       (dilate_0));
rgb2hsv_top rgb2hsv_top_0(
        .HSV24       (HSV24),
        .RGB24       (filter_data),
        .pclk        (video_clk));
video_pll video_pll_m0
(
  .clkin1                    (sys_clk                  ),
  .clkout0                   (video_clk                ),
  .clkout1                   (video_clk5x              ),
  .clkout2                   (cmos_xclk                ),
  .clkout3                   (clk_servo                ),
  .pll_rst                   (1'b0                     ),
  .pll_lock                  (                         )
);

dvi_encoder dvi_encoder_m0
(
	.pixelclk      (video_clk          ),// system clock
	.pixelclk5x    (video_clk5x        ),// system clock x5
	.rstin         (~rst_n             ),// reset
	.blue_din      (hdmi_b             ),// Blue data in
	.green_din     (hdmi_g             ),// Green data in
	.red_din       (hdmi_r             ),// Red data in
	.hsync         (hdmi_hs            ),// hsync data
	.vsync         (hdmi_vs            ),// vsync data
	.de            (hdmi_de            ),// data enable
	.tmds_clk_p    (tmds_clk_p         ),
	.tmds_clk_n    (tmds_clk_n         ),
	.tmds_data_p   (tmds_data_p        ),//rgb
	.tmds_data_n   (tmds_data_n        ) //rgb
);
i2c_ov7725_rgb565_cfg u_i2c_cfg(
    .clk                (i2c_dri_clk),
    .rst_n              (rst_n),
            
    .i2c_done           (i2c_done),
    .i2c_exec           (i2c_exec),
    .i2c_data           (i2c_data),
    .init_done          (cam_init_done)
    );    


i2c_dri 
   #(
    .SLAVE_ADDR         (SLAVE_ADDR),
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  )                
    )       
   u_i2c_dri(       
    .clk                (sys_clk    ),   
    .rst_n              (rst_n     ),   
        
    .i2c_exec           (i2c_exec  ),   
    .bit_ctrl           (BIT_CTRL  ),   
    .i2c_rh_wl          (1'b0),                    
    .i2c_addr           (i2c_data[15:8]),   
    .i2c_data_w         (i2c_data[7:0]),   
    .i2c_data_r         (),   
    .i2c_done           (i2c_done  ),   
    .scl                (cmos_scl   ),   
    .sda                (cmos_sda   ),   

    .dri_clk            (i2c_dri_clk)               
);

//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
	.de_o                       (cmos_16bit_wr            )
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_vsync               ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);


//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd196608               ),//frame size 
	.read_en                    (read_en                  ),
	.read_data                  (read_data0                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd196608               ), //frame size  
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
ddr3 u_ipsl_hmemc_top (
    .pll_refclk_in        (sys_clk        ),
    .ddr_rstn_key         (rst_n          ),   
    .pll_aclk_0           (              ),
    .pll_aclk_1           (ui_clk       ),
    .pll_aclk_2           (              ),
    .pll_lock             (      ),
    .ddrphy_rst_done      (),
 
    .ddrc_init_done       ( ),
 
    .ddrc_rst         (0),    
      
    .areset_1         (0),               
    .aclk_1           (ui_clk),                                                        
    .awid_1           (s00_axi_awid),       
    .awaddr_1         (s00_axi_awaddr),     
    .awlen_1          (s00_axi_awlen),      
    .awsize_1         (s00_axi_awsize),     
    .awburst_1        (s00_axi_awburst),    
    .awlock_1         (s00_axi_awlock),                       
    .awvalid_1        (s00_axi_awvalid),    
    .awready_1        (s00_axi_awready),    
  
    .awurgent_1       (1'b0),  //? 
    .awpoison_1       (1'b0),   //?                 
    .wdata_1          (s00_axi_wdata),      
    .wstrb_1          (s00_axi_wstrb),      
    .wlast_1          (s00_axi_wlast),      
    .wvalid_1         (s00_axi_wvalid),     
    .wready_1         (s00_axi_wready),                       
    .bid_1            (s00_axi_bid),        
    .bresp_1          (s00_axi_bresp),      
    .bvalid_1         (s00_axi_bvalid),     
    .bready_1         (s00_axi_bready),                                    
    .arid_1           (s00_axi_arid     ),  
    .araddr_1         (s00_axi_araddr   ),  
    .arlen_1          (s00_axi_arlen    ),  
    .arsize_1         (s00_axi_arsize   ),  
    .arburst_1        (s00_axi_arburst  ),  
    .arlock_1         (s00_axi_arlock   ),                      
    .arvalid_1        (s00_axi_arvalid  ),  
    .arready_1        (s00_axi_arready  ),  
   // .arpoison_1       (s00_axi_arqos ),   //?   
    .arpoison_1       (1'b0 ),   //?                  
    .rid_1            (s00_axi_rid      ),  
    .rdata_1          (s00_axi_rdata    ),  
    .rresp_1          (s00_axi_rresp    ),  
    .rlast_1          (s00_axi_rlast    ),  
    .rvalid_1         (s00_axi_rvalid   ),  
    .rready_1         (s00_axi_rready   ),  
   // .arurgent_1       (axi_arurgent ),    //?    
    .arurgent_1       (1'b0),    //?        
    .csysreq_1        (1'b1),               
    .csysack_1        (),           
    .cactive_1        (), 
          
    .csysreq_ddrc     (1'b1),
    .csysack_ddrc     (),
    .cactive_ddrc     (),
             
    .pad_loop_in           (pad_loop_in),
    .pad_loop_in_h         (pad_loop_in_h),
    .pad_rstn_ch0          (pad_rstn_ch0),
    .pad_ddr_clk_w         (pad_ddr_clk_w),
    .pad_ddr_clkn_w        (pad_ddr_clkn_w),
    .pad_csn_ch0           (pad_csn_ch0),
    .pad_addr_ch0          (pad_addr_ch0),
    .pad_dq_ch0            (pad_dq_ch0),
    .pad_dqs_ch0           (pad_dqs_ch0),
    .pad_dqsn_ch0          (pad_dqsn_ch0),
    .pad_dm_rdqs_ch0       (pad_dm_rdqs_ch0),
    .pad_cke_ch0           (pad_cke_ch0),
    .pad_odt_ch0           (pad_odt_ch0),
    .pad_rasn_ch0          (pad_rasn_ch0),
    .pad_casn_ch0          (pad_casn_ch0),
    .pad_wen_ch0           (pad_wen_ch0),
    .pad_ba_ch0            (pad_ba_ch0),
    .pad_loop_out          (pad_loop_out),
    .pad_loop_out_h        (pad_loop_out_h)                                
);   
aq_axi_master u_aq_axi_master
	(
      .ARESETN                     (rst_n                                     ),
	 // .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ACLK                        (ui_clk                                    ),
	  .M_AXI_AWID                  (s00_axi_awid                              ),
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s00_axi_awready                           ),
	  .M_AXI_WDATA                 (s00_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),
	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_WREADY                (s00_axi_wready                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
	  .M_AXI_BVALID                (s00_axi_bvalid                            ),
	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  .M_AXI_ARID                  (s00_axi_arid                              ),
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s00_axi_arready                           ),
	  .M_AXI_RID                   (s00_axi_rid                               ),
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),
	  .M_AXI_RREADY                (s00_axi_rready                            ),
	  .MASTER_RST                  (1'b0                                     ),
	  .WR_START                    (wr_burst_req                             ),
	  .WR_ADRS                     ({wr_burst_addr,3'd0}                     ),
	  .WR_LEN                      ({wr_burst_len,3'd0}                      ),
	  .WR_READY                    (                                         ),
	  .WR_FIFO_RE                  (wr_burst_data_req                        ),
	  .WR_FIFO_EMPTY               (1'b0                                     ),
	  .WR_FIFO_AEMPTY              (1'b0                                     ),
	  .WR_FIFO_DATA                (wr_burst_data                            ),
	  .WR_DONE                     (wr_burst_finish                          ),
	  .RD_START                    (rd_burst_req                             ),
	  .RD_ADRS                     ({rd_burst_addr,3'd0}                     ),
	  .RD_LEN                      ({rd_burst_len,3'd0}                      ),
	  .RD_READY                    (                                         ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                      ),
	  .RD_FIFO_FULL                (1'b0                                     ),
	  .RD_FIFO_AFULL               (1'b0                                     ),
	  .RD_FIFO_DATA                (rd_burst_data                            ),
	  .RD_DONE                     (rd_burst_finish                          ),
	  .DEBUG                       (                                         )
);
endmodule
