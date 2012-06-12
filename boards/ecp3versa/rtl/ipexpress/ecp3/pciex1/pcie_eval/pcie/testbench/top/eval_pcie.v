// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised
// by a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement
// from Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation    TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                        408-826-6000 (other locations)
// Hillsboro, OR 97124                  web  : http://www.latticesemi.com/
// U.S.A                                email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_exp_x1
// File             : tb_top.v
// Title            :
// Dependencies     : pci_exp_params.v pci_exp_ddefines.v testcase.v
// Description      : Top level for testbench of pci_exp IP with Serdes PCS PIPE
//                   
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Mod. Date        : Oct 02, 2007
// Changes Made     : Initial Creation
// =============================================================================

`timescale 100 ps/100 ps
module tb_top;

// DUT User defines
`include "pci_exp_params.v"


// =============================================================================
// Regs for BFM & Test case 
// =============================================================================
//---- Regs
reg                      clk_100;
reg                      error;
reg                      rst_n;
reg                      no_pcie_train;   // This signal disables the training process

reg                      ecrc_gen_enb ; 
reg                      ecrc_chk_enb ; 

reg  [1:0]               tx_dllp_val;   
reg  [2:0]               tx_pmtype;       // Power Management Type
reg  [23:0]              tx_vsd_data;   
reg                      rx_tlp_discard;

wire [23:0]              tbtx_vc;
wire [23:0]              tbrx_vc;
reg                      disable_mlfmd_check; 
reg                      DISABLE_SKIP_CHECK;
wire [1:0]               power_down_init;
wire [14:0]              init_15_00;
wire [14:0]              init_15_11;
wire [15:0]              init_16_11;
reg                      enb_log;
 

//---- Wires

wire  [2:0]              rxdp_pmd_type;
wire  [23:0]             rxdp_vsd_data;
wire                     rxdp_vsd_val;
wire  [1:0]              rxdp_dllp_val;
wire                     dl_up;
wire                     sys_clk_125;
wire                     sys_clk_125_tmp;
wire                     tx_dllp_sent;


wire [63:0]              INIT_PH_FC;      //Initial P HdrFC value
wire [63:0]              INIT_NPH_FC;     // For NPH
wire [95:0]              INIT_PD_FC;      // Initial P DataFC value
wire [95:0]              INIT_NPD_FC;     // For NPD
wire [71:0]              tx_ca_ph;
wire [103:0]             tx_ca_pd;
wire [71:0]              tx_ca_nph;
wire [103:0]             tx_ca_npd;
wire [71:0]              tx_ca_cplh;
wire [103:0]             tx_ca_cpld;

reg  [7:0]               tbrx_cmd_prsnt;
wire [7:0]               tbrx_cmd_prsnt_int;
wire [7:0]               ph_buf_status;   // Indicate the Full/alm.Full status of the PH buffers
wire [7:0]               pd_buf_status;   // Indicate PD Buffer has got space less than Max Pkt size
wire [7:0]               nph_buf_status;  // For NPH
wire [7:0]               npd_buf_status;  // For NPD
wire [7:0]               ph_processed;    // TL has processed one TLP Header - PH Type
wire [7:0]               pd_processed;    // TL has processed one TLP Data - PD TYPE
wire [7:0]               nph_processed;   // For NPH
wire [7:0]               npd_processed;   // For NPD
wire [8*8-1:0]           pd_num;
wire [8*8-1:0]           npd_num;

//---------Outputs From Core------------
wire  [7:0]              tx_rdy;  
wire  [127:0]            rx_data; 
wire  [7:0]              rx_st;  
wire  [7:0]              rx_end;
wire  [7:0]              rx_ecrc_err;
wire  [7:0]              rx_us_req;
wire  [7:0]              rx_malf_tlp;
wire  [3:0]              phy_ltssm_state; 
  
wire  [7:0]              tx_req;  
wire  [2:0]              rx_status;  
wire  [1:0]              power_down;  
wire                     tx_detect_rx;
wire                     tx_elec_idle;
wire                     tx_compliance;
wire                     rx_polarity;
//wire                     reset_n;
wire  [15:0]             rx_valid;
wire  [15:0]             rx_elec_idle;
wire  [15:0]             phy_status;

wire                     rx_valid0;    //For Debug
wire                     rx_elec_idle0;
wire                     phy_status0;
wire                     phy_realign_req;

//---- Integer
integer                  i;

wire  [(`NUM_VC*16)-1:0] tx_data; 
wire  [`NUM_VC-1:0]      tx_st;  
wire  [`NUM_VC-1:0]      tx_end;
wire  [`NUM_VC-1:0]      tx_nlfy; 

wire  [`NUM_VC-1:0]      tb_sys_clk; 

`ifdef WISHBONE
reg                      RST_I ;
reg                      CLK_I ;
reg [12:0]               ADR_I ;
reg [31:0]               DAT_I ;
reg [3:0]                SEL_I ;
reg                      WE_I ;
reg                      STB_I ;
reg                      CYC_I ;

wire [31:0]              CHAIN_RDAT_in = 32'd0 ;
wire                     CHAIN_ACK_in  = 1'd0;
wire [31:0]              DAT_O ;     
wire                     ACK_O ;
wire                     IRQ_O ;
`endif

parameter DLY1 = 1 ;
parameter DLY2 = 1 ;

// =============================================================================

// Include Testbench params files 

// DUT Design params file
`include "pci_exp_ddefines.v"

// Include the test case 
`include "testcase.v"


// =============================================================================
//-------- For Flow Control Tasks
parameter P    = 2'b00;
parameter NP   = 2'b01;
parameter CPLX = 2'b10;  //CPL is already used in some other paramter

parameter PH   = 3'b000;
parameter PD   = 3'b001;
parameter NPH  = 3'b010;
parameter NPD  = 3'b011;
parameter CPLH = 3'b100;
parameter CPLD = 3'b101;

//---- Wires
wire                    hdoutp_0 ;
wire                    hdoutn_0 ;
reg                     hdoutp_0_d ;
reg                     hdoutn_0_d ;
wire                    refclkp;
wire                    refclkn;

pullup (hdoutp_0);
pullup (hdoutn_0);

always @* begin
   if (!rst_n)
      #DLY1 hdoutp_0_d <= hdoutp_0 ;
   else if (hdoutp_0 == 1'b1)
      #DLY1 hdoutp_0_d <= 1'b1 ;
   else if (hdoutp_0 == 1'b0)
      #DLY1 hdoutp_0_d <= 1'b0 ;
   else if (hdoutp_0 === 1'bz)
      #DLY1 hdoutp_0_d <= 1'b1 ;
   else
      #DLY1 hdoutp_0_d <= hdoutp_0_d ;

   if (!rst_n)
      #DLY1 hdoutn_0_d <= hdoutn_0 ;
   else if (hdoutn_0 == 1'b1)
      #DLY1 hdoutn_0_d <= 1'b1 ;
   else if (hdoutn_0 == 1'b0)
      #DLY1 hdoutn_0_d <= 1'b0 ;
   else if (hdoutn_0 === 1'bz)
      #DLY1 hdoutp_0_d <= 1'b1 ;
   else
      #DLY1 hdoutn_0_d <= hdoutn_0_d ;

end

// =============================================================================
// PIPE_SIGNALS For Debug -- For X1 
// =============================================================================
assign rx_valid0      = rx_valid[0];  
assign rx_elec_idle0  = rx_elec_idle[0];
assign phy_status0    = phy_status[0];

// =============================================================================
// Generate  tbrx_cmd_prsnt
// =============================================================================
always@(sys_clk_125) begin
    tbrx_cmd_prsnt[7] <= (tbrx_cmd_prsnt_int[7] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[6] <= (tbrx_cmd_prsnt_int[6] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[5] <= (tbrx_cmd_prsnt_int[5] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[4] <= (tbrx_cmd_prsnt_int[4] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[3] <= (tbrx_cmd_prsnt_int[3] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[2] <= (tbrx_cmd_prsnt_int[2] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[1] <= (tbrx_cmd_prsnt_int[1] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[0] <= (tbrx_cmd_prsnt_int[0] === 1'b1) ? 1'b1 : 1'b0;
end

`ifdef VC8
   assign tbrx_vc = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
`endif
`ifdef VC7
   assign tbrx_vc = {3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
`endif
`ifdef VC6
   assign tbrx_vc = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
`endif
`ifdef VC5
   assign tbrx_vc = {3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
`endif
`ifdef VC4
   assign tbrx_vc = {3'd3, 3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd3, 3'd2, 3'd1, 3'd0};
`endif
`ifdef VC3
   assign tbrx_vc = {3'd2, 3'd1, 3'd0};
   assign tbtx_vc = {3'd2, 3'd1, 3'd0};
`endif
`ifdef VC2
   assign tbrx_vc = {3'd1, 3'd0};
   assign tbtx_vc = {3'd1, 3'd0};
`endif
`ifdef VC1
   assign tbrx_vc = 3'd0;
   assign tbtx_vc = 3'd0;
`endif

assign  power_down_init = 2'b10;
assign  init_15_00 = 15'b0000_0000_0000_000;
assign  init_15_11 = 15'b1111_1111_1111_111;
assign  init_16_11 = 16'b1111_1111_1111_1111;

// =============================================================================
// TBTX (User Logic on TX side) Instantiations
// =============================================================================
tbtx u_tbtx [`NUM_VC-1:0]  (
    //----- Inputs
    .sys_clk         (sys_clk_125),
    .rst_n           (rst_n),
    .tx_tc           (tbtx_vc[(`NUM_VC*3)-1:0]),

    .tx_ca_ph        (tx_ca_ph[(9*`NUM_VC)-1:0]),
    .tx_ca_pd        (tx_ca_pd[(13*`NUM_VC)-1:0]),
    .tx_ca_nph       (tx_ca_nph[(9*`NUM_VC)-1:0]),
    .tx_ca_npd       (tx_ca_npd[(13*`NUM_VC)-1:0]), 
    .tx_ca_cplh      (tx_ca_cplh[(9*`NUM_VC)-1:0]),
    .tx_ca_cpld      (tx_ca_cpld[(13*`NUM_VC)-1:0]),
    .tx_ca_p_recheck    (tx_ca_p_recheck_vc0),
    .tx_ca_cpl_recheck  (tx_ca_cpl_recheck_vc0),

    .tx_rdy          (tx_rdy[`NUM_VC-1:0]),

    //------- Outputs
    .tx_req          (tx_req[`NUM_VC-1:0]),
    .tx_data         (tx_data),
    .tx_st           (tx_st),
    .tx_end          (tx_end),
    .tx_nlfy         (tx_nlfy)
    );

// =============================================================================
// TBRX (User Logic on RX side) Instantiations
// =============================================================================
tbrx u_tbrx [`NUM_VC-1:0]  (
   //----- Inputs
   .sys_clk         (sys_clk_125),
   .rst_n           (rst_n),
   .rx_tc           (tbrx_vc[(`NUM_VC*3)-1:0]),

   .rx_data         ( rx_data[(`NUM_VC*16)-1:0]),    
   .rx_st           ( rx_st[`NUM_VC -1:0]),     
   .rx_end          ( rx_end[`NUM_VC -1:0]),   
   `ifdef ECRC
      .rx_ecrc_err  ( rx_ecrc_err[`NUM_VC -1:0] ), 
   `endif
   .rx_us_req       ( rx_us_req[`NUM_VC -1:0] ), 
   .rx_malf_tlp     ( rx_malf_tlp[`NUM_VC -1:0] ), 

    //------- Outputs
   .tbrx_cmd_prsnt   (tbrx_cmd_prsnt_int[`NUM_VC-1:0]),
   .ph_buf_status    (ph_buf_status[`NUM_VC-1:0]),
   .pd_buf_status    (pd_buf_status[`NUM_VC-1:0]),
   .nph_buf_status   (nph_buf_status[`NUM_VC-1:0]),
   .npd_buf_status   (npd_buf_status[`NUM_VC-1:0]),
   .cplh_buf_status  ( ),
   .cpld_buf_status  ( ),
   .ph_processed     (ph_processed[`NUM_VC-1:0]),
   .pd_processed     (pd_processed[`NUM_VC-1:0]),
   .nph_processed    (nph_processed[`NUM_VC-1:0]),
   .npd_processed    (npd_processed[`NUM_VC-1:0]),
   .cplh_processed   ( ),
   .cpld_processed   ( ),
   .pd_num           (pd_num[(8*`NUM_VC) -1:0]),
   .npd_num          (npd_num[(8*`NUM_VC) -1:0]),
   .cpld_num         ( ),
   .INIT_PH_FC       (INIT_PH_FC[(8*`NUM_VC)-1:0]),
   .INIT_NPH_FC      (INIT_NPH_FC[(8*`NUM_VC)-1:0]),
   .INIT_CPLH_FC     ( ),
   .INIT_PD_FC       (INIT_PD_FC[(12*`NUM_VC)-1:0]),
   .INIT_NPD_FC      (INIT_NPD_FC[(12*`NUM_VC)-1:0]),
   .INIT_CPLD_FC     ( ) 
    );


// =============================================================================
// DUT
// =============================================================================

`USERNAME_EVAL_TOP u1_top(
   //------- Clock and Reset
   .refclkp                    ( clk_100), 
   .refclkn                    ( ~clk_100), 
   .rst_n                      ( rst_n ),
   `ifdef Channel_0
   .hdinp0                     ( hdoutp_0_d ), 
   .hdinn0                     ( hdoutn_0_d ), 
   .hdoutp0                    ( hdoutp_0 ), 
   .hdoutn0                    ( hdoutn_0 ),
   `endif
   `ifdef Channel_1
   .hdinp1                     ( hdoutp_0_d ), 
   .hdinn1                     ( hdoutn_0_d ), 
   .hdoutp1                    ( hdoutp_0 ), 
   .hdoutn1                    ( hdoutn_0 ),
   `endif
   `ifdef Channel_2
   .hdinp2                     ( hdoutp_0_d ), 
   .hdinn2                     ( hdoutn_0_d ), 
   .hdoutp2                    ( hdoutp_0 ), 
   .hdoutn2                    ( hdoutn_0 ),
   `endif
   `ifdef Channel_3
   .hdinp3                     ( hdoutp_0_d ), 
   .hdinn3                     ( hdoutn_0_d ), 
   .hdoutp3                    ( hdoutp_0 ), 
   .hdoutn3                    ( hdoutn_0 ),
   `endif
   
   `ifdef WISHBONE
      // Wishbone input Signals
      .RST_I                   ( RST_I ),
      .CLK_I                   ( CLK_I ),

      .ADR_I                   ( ADR_I ),
      .DAT_I                   ( DAT_I ),
      .SEL_I                   ( SEL_I ),
      .WE_I                    ( WE_I ),
      .STB_I                   ( STB_I ),
      .CYC_I                   ( CYC_I ),
      .CHAIN_RDAT_in           ( CHAIN_RDAT_in ),
      .CHAIN_ACK_in            ( CHAIN_ACK_in ),
   `else
      .no_pcie_train           ( no_pcie_train ),    
   `endif  

   `ifdef EN_VC0
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc0                 (tx_req[0]),    
   .tx_data_vc0                (tx_data[16*1-1:0]),    
   .tx_st_vc0                  (tx_st[0]), 
   .tx_end_vc0                 (tx_end[0]), 
   .tx_nlfy_vc0                (tx_nlfy[0]), 
   .ph_buf_status_vc0          (ph_buf_status[0]),
   .pd_buf_status_vc0          (pd_buf_status[0]),
   .nph_buf_status_vc0         (nph_buf_status[0]),
   .npd_buf_status_vc0         (npd_buf_status[0]),
   .ph_processed_vc0           (ph_processed[0]),
   .pd_processed_vc0           (pd_processed[0]),
   .nph_processed_vc0          (nph_processed[0]),
   .npd_processed_vc0          (npd_processed[0]),
   `endif

   `ifdef EN_VC1
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc1                 (tx_req[1]),    
   .tx_data_vc1                (tx_data[16*2-1:16]),    
   .tx_st_vc1                  (tx_st[1]), 
   .tx_end_vc1                 (tx_end[1]), 
   .tx_nlfy_vc1                (tx_nlfy[1]), 
   .ph_buf_status_vc1          (ph_buf_status[1]),
   .pd_buf_status_vc1          (pd_buf_status[1]),
   .nph_buf_status_vc1         (nph_buf_status[1]),
   .npd_buf_status_vc1         (npd_buf_status[1]),
   .ph_processed_vc1           (ph_processed[1]),
   .pd_processed_vc1           (pd_processed[1]),
   .nph_processed_vc1          (nph_processed[1]),
   .npd_processed_vc1          (npd_processed[1]),
   `endif
    
    `ifdef EN_VC2
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc2                 (tx_req[2]),    
   .tx_data_vc2                (tx_data[16*3-1:16*2]),    
   .tx_st_vc2                  (tx_st[2]), 
   .tx_end_vc2                 (tx_end[2]), 
   .tx_nlfy_vc2                (tx_nlfy[2]), 
   .ph_buf_status_vc2          (ph_buf_status[2]),
   .pd_buf_status_vc2          (pd_buf_status[2]),
   .nph_buf_status_vc2         (nph_buf_status[2]),
   .npd_buf_status_vc2         (npd_buf_status[2]),
   .ph_processed_vc2           (ph_processed[2]),
   .pd_processed_vc2           (pd_processed[2]),
   .nph_processed_vc2          (nph_processed[2]),
   .npd_processed_vc2          (npd_processed[2]),
   `endif

    `ifdef EN_VC3
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc3                 (tx_req[3]),    
   .tx_data_vc3                (tx_data[16*4-1:16*3]),    
   .tx_st_vc3                  (tx_st[3]), 
   .tx_end_vc3                 (tx_end[3]), 
   .tx_nlfy_vc3                (tx_nlfy[3]), 
   .ph_buf_status_vc3          (ph_buf_status[3]),
   .pd_buf_status_vc3          (pd_buf_status[3]),
   .nph_buf_status_vc3         (nph_buf_status[3]),
   .npd_buf_status_vc3         (npd_buf_status[3]),
   .ph_processed_vc3           (ph_processed[3]),
   .pd_processed_vc3           (pd_processed[3]),
   .nph_processed_vc3          (nph_processed[3]),
   .npd_processed_vc3          (npd_processed[3]),
   `endif
    
    `ifdef EN_VC4
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc4                 (tx_req[4]),    
   .tx_data_vc4                (tx_data[16*5-1:16*4]),    
   .tx_st_vc4                  (tx_st[4]), 
   .tx_end_vc4                 (tx_end[4]), 
   .tx_nlfy_vc4                (tx_nlfy[4]), 
   .ph_buf_status_vc4          (ph_buf_status[4]),
   .pd_buf_status_vc4          (pd_buf_status[4]),
   .nph_buf_status_vc4         (nph_buf_status[4]),
   .npd_buf_status_vc4         (npd_buf_status[4]),
   .ph_processed_vc4           (ph_processed[4]),
   .pd_processed_vc4           (pd_processed[4]),
   .nph_processed_vc4          (nph_processed[4]),
   .npd_processed_vc4          (npd_processed[4]),

   `endif

    `ifdef EN_VC5
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc5                 (tx_req[5]),    
   .tx_data_vc5                (tx_data[16*6-1:16*5]),    
   .tx_st_vc5                  (tx_st[5]), 
   .tx_end_vc5                 (tx_end[5]), 
   .tx_nlfy_vc5                (tx_nlfy[5]), 
   .ph_buf_status_vc5          (ph_buf_status[5]),
   .pd_buf_status_vc5          (pd_buf_status[5]),
   .nph_buf_status_vc5         (nph_buf_status[5]),
   .npd_buf_status_vc5         (npd_buf_status[5]),
   .ph_processed_vc5           (ph_processed[5]),
   .pd_processed_vc5           (pd_processed[5]),
   .nph_processed_vc5          (nph_processed[5]),
   .npd_processed_vc5          (npd_processed[5]),
   `endif

    `ifdef EN_VC6
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc6                 (tx_req[6]),    
   .tx_data_vc6                (tx_data[16*7-1:16*6]),    
   .tx_st_vc6                  (tx_st[6]), 
   .tx_end_vc6                 (tx_end[6]), 
   .tx_nlfy_vc6                (tx_nlfy[6]), 
   .ph_buf_status_vc6          (ph_buf_status[6]),
   .pd_buf_status_vc6          (pd_buf_status[6]),
   .nph_buf_status_vc6         (nph_buf_status[6]),
   .npd_buf_status_vc6         (npd_buf_status[6]),
   .ph_processed_vc6           (ph_processed[6]),
   .pd_processed_vc6           (pd_processed[6]),
   .nph_processed_vc6          (nph_processed[6]),
   .npd_processed_vc6          (npd_processed[6]),
   `endif

   `ifdef EN_VC7
   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc7                 (tx_req[7]),    
   .tx_data_vc7                (tx_data[16*8-1:16*7]),    
   .tx_st_vc7                  (tx_st[7]), 
   .tx_end_vc7                 (tx_end[7]), 
   .tx_nlfy_vc7                (tx_nlfy[7]), 
   .ph_buf_status_vc7          (ph_buf_status[7]),
   .pd_buf_status_vc7          (pd_buf_status[7]),
   .nph_buf_status_vc7         (nph_buf_status[7]),
   .npd_buf_status_vc7         (npd_buf_status[7]),
   .ph_processed_vc7           (ph_processed[7]),
   .pd_processed_vc7           (pd_processed[7]),
   .nph_processed_vc7          (nph_processed[7]),
   .npd_processed_vc7          (npd_processed[7]),
   `endif
   `ifdef ECRC
      `ifdef AER
         .ecrc_gen_enb         (  ) , 
         .ecrc_chk_enb         (  ) , 
      `else
         .ecrc_gen_enb         ( ecrc_gen_enb ) , 
         .ecrc_chk_enb         ( ecrc_chk_enb ) , 
      `endif
   `endif

   `ifdef WISHBONE
      // Wishbone output Signals
      .DAT_O                   ( DAT_O),
      .ACK_O                   ( ACK_O),
      .IRQ_O                   ( IRQ_O),
   `endif

   `ifdef EN_VC0
   // To  TX User 
   `ifdef EN_VC1
      .tcvc_map_vc0            (  ),
   `endif
   .tx_rdy_vc0                 (tx_rdy[0]),  
   .tx_ca_ph_vc0               (tx_ca_ph[(9*1)-1:0]),
   .tx_ca_pd_vc0               (tx_ca_pd[(13*1)-1:0]),
   .tx_ca_nph_vc0              (tx_ca_nph[(9*1)-1:0]),
   .tx_ca_npd_vc0              (tx_ca_npd[(13*1)-1:0]), 
   .tx_ca_cplh_vc0             (tx_ca_cplh[(9*1)-1:0]),
   .tx_ca_cpld_vc0             (tx_ca_cpld[(13*1)-1:0]),
   .tx_ca_p_recheck_vc0        ( tx_ca_p_recheck_vc0 ),
   .tx_ca_cpl_recheck_vc0      ( tx_ca_cpl_recheck_vc0 ),

   // Inputs/Outputs per VC
   .rx_data_vc0                ( rx_data[(16*1)-1:0]),    
   .rx_st_vc0                  ( rx_st[0]),     
   .rx_end_vc0                 ( rx_end[0]),   
   `ifdef ECRC
      .rx_ecrc_err_vc0         ( rx_ecrc_err[0] ), 
   `endif
   .rx_us_req_vc0              ( rx_us_req[0] ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp[0] ), 
   `endif

   `ifdef EN_VC1
   // To  TX User 
   .tcvc_map_vc1               (  ),
   .tx_rdy_vc1                 (tx_rdy[1]),  
   .tx_ca_ph_vc1               (tx_ca_ph[(9*2)-1:9]),
   .tx_ca_pd_vc1               (tx_ca_pd[(13*2)-1:13]),
   .tx_ca_nph_vc1              (tx_ca_nph[(9*2)-1:9]),
   .tx_ca_npd_vc1              (tx_ca_npd[(13*2)-1:13]), 
   .tx_ca_cplh_vc1             (tx_ca_cplh[(9*2)-1:9]),
   .tx_ca_cpld_vc1             (tx_ca_cpld[(13*2)-1:13]),

   // Inputs/Outputs per VC
   .rx_data_vc1                ( rx_data[(16*2)-1:16]),    
   .rx_st_vc1                  ( rx_st[1]),     
   .rx_end_vc1                 ( rx_end[1]),   
   `ifdef ECRC
      .rx_ecrc_err_vc1         ( rx_ecrc_err[1] ), 
   `endif
   .rx_us_req_vc1              ( rx_us_req[1] ), 
   .rx_malf_tlp_vc1            ( rx_malf_tlp[1] ), 
   `endif

    `ifdef EN_VC2
   // To  TX User 
   .tcvc_map_vc2               (  ),
   .tx_rdy_vc2                 (tx_rdy[2]),  
   .tx_ca_ph_vc2               (tx_ca_ph[(9*3)-1:9*2]),
   .tx_ca_pd_vc2               (tx_ca_pd[(13*3)-1:13*2]),
   .tx_ca_nph_vc2              (tx_ca_nph[(9*3)-1:9*2]),
   .tx_ca_npd_vc2              (tx_ca_npd[(13*3)-1:13*2]), 
   .tx_ca_cplh_vc2             (tx_ca_cplh[(9*3)-1:9*2]),
   .tx_ca_cpld_vc2             (tx_ca_cpld[(13*3)-1:13*2]),

   // Inputs/Outputs per VC
   .rx_data_vc2                ( rx_data[(16*3)-1:16*2]),    
   .rx_st_vc2                  ( rx_st[2]),     
   .rx_end_vc2                 ( rx_end[2]),   
   `ifdef ECRC
      .rx_ecrc_err_vc2         ( rx_ecrc_err[2] ), 
   `endif
   .rx_us_req_vc2              ( rx_us_req[2] ), 
   .rx_malf_tlp_vc2            ( rx_malf_tlp[2] ), 
   `endif

    `ifdef EN_VC3
   // To  TX User 
   .tcvc_map_vc3               (  ),
   .tx_rdy_vc3                 (tx_rdy[3]),  
   .tx_ca_ph_vc3               (tx_ca_ph[(9*4)-1:9*3]),
   .tx_ca_pd_vc3               (tx_ca_pd[(13*4)-1:13*3]),
   .tx_ca_nph_vc3              (tx_ca_nph[(9*4)-1:9*3]),
   .tx_ca_npd_vc3              (tx_ca_npd[(13*4)-1:13*3]), 
   .tx_ca_cplh_vc3             (tx_ca_cplh[(9*4)-1:9*3]),
   .tx_ca_cpld_vc3             (tx_ca_cpld[(13*4)-1:13*3]),

   // Inputs/Outputs per VC
   .rx_data_vc3                ( rx_data[(16*4)-1:16*3]),    
   .rx_st_vc3                  ( rx_st[3]),     
   .rx_end_vc3                 ( rx_end[3]),   
   `ifdef ECRC
      .rx_ecrc_err_vc3         ( rx_ecrc_err[3] ), 
   `endif
   .rx_us_req_vc3              ( rx_us_req[3] ), 
   .rx_malf_tlp_vc3            ( rx_malf_tlp[3] ), 
   `endif

    `ifdef EN_VC4
   // To  TX User 
   .tcvc_map_vc4               (  ),
   .tx_rdy_vc4                 (tx_rdy[4]),  
   .tx_ca_ph_vc4               (tx_ca_ph[(9*5)-1:9*4]),
   .tx_ca_pd_vc4               (tx_ca_pd[(13*5)-1:13*4]),
   .tx_ca_nph_vc4              (tx_ca_nph[(9*5)-1:9*4]),
   .tx_ca_npd_vc4              (tx_ca_npd[(13*5)-1:13*4]), 
   .tx_ca_cplh_vc4             (tx_ca_cplh[(9*5)-1:9*4]),
   .tx_ca_cpld_vc4             (tx_ca_cpld[(13*5)-1:13*4]),

   // Inputs/Outputs per VC
   .rx_data_vc4                ( rx_data[(16*5)-1:16*4]),    
   .rx_st_vc4                  ( rx_st[4]),     
   .rx_end_vc4                 ( rx_end[4]),   
   `ifdef ECRC
      .rx_ecrc_err_vc4         ( rx_ecrc_err[4] ), 
   `endif
   .rx_us_req_vc4              ( rx_us_req[4] ), 
   .rx_malf_tlp_vc4            ( rx_malf_tlp[4] ), 
   `endif

    `ifdef EN_VC5
   // To  TX User 
   .tcvc_map_vc5               (  ),
   .tx_rdy_vc5                 (tx_rdy[5]),  
   .tx_ca_ph_vc5               (tx_ca_ph[(9*6)-1:9*5]),
   .tx_ca_pd_vc5               (tx_ca_pd[(13*6)-1:13*5]),
   .tx_ca_nph_vc5              (tx_ca_nph[(9*6)-1:9*5]),
   .tx_ca_npd_vc5              (tx_ca_npd[(13*6)-1:13*5]), 
   .tx_ca_cplh_vc5             (tx_ca_cplh[(9*6)-1:9*5]),
   .tx_ca_cpld_vc5             (tx_ca_cpld[(13*6)-1:13*5]),

   // Inputs/Outputs per VC
   .rx_data_vc5                ( rx_data[(16*6)-1:16*5]),    
   .rx_st_vc5                  ( rx_st[5]),     
   .rx_end_vc5                 ( rx_end[5]),   
   `ifdef ECRC
      .rx_ecrc_err_vc5         ( rx_ecrc_err[5] ), 
   `endif
   .rx_us_req_vc5              ( rx_us_req[5] ), 
   .rx_malf_tlp_vc5            ( rx_malf_tlp[5] ), 
   `endif

   `ifdef EN_VC6
   // To  TX User 
   .tcvc_map_vc6               (  ),
   .tx_rdy_vc6                 (tx_rdy[6]),  
   .tx_ca_ph_vc6               (tx_ca_ph[(9*7)-1:9*6]),
   .tx_ca_pd_vc6               (tx_ca_pd[(13*7)-1:13*6]),
   .tx_ca_nph_vc6              (tx_ca_nph[(9*7)-1:9*6]),
   .tx_ca_npd_vc6              (tx_ca_npd[(13*7)-1:13*6]), 
   .tx_ca_cplh_vc6             (tx_ca_cplh[(9*7)-1:9*6]),
   .tx_ca_cpld_vc6             (tx_ca_cpld[(13*7)-1:13*6]),

   // Inputs/Outputs per VC
   .rx_data_vc6                ( rx_data[(16*7)-1:16*6]),    
   .rx_st_vc6                  ( rx_st[6]),     
   .rx_end_vc6                 ( rx_end[6]),   
   `ifdef ECRC
      .rx_ecrc_err_vc6         ( rx_ecrc_err[6] ), 
   `endif
   .rx_us_req_vc6              ( rx_us_req[6] ), 
   .rx_malf_tlp_vc6            ( rx_malf_tlp[6] ), 
   `endif

    `ifdef EN_VC7
   // To  TX User 
   .tcvc_map_vc7               (  ),
   .tx_rdy_vc7                 (tx_rdy[7]),  
   .tx_ca_ph_vc7               (tx_ca_ph[(9*8)-1:9*7]),
   .tx_ca_pd_vc7               (tx_ca_pd[(13*8)-1:13*7]),
   .tx_ca_nph_vc7              (tx_ca_nph[(9*8)-1:9*7]),
   .tx_ca_npd_vc7              (tx_ca_npd[(13*8)-1:13*7]), 
   .tx_ca_cplh_vc7             (tx_ca_cplh[(9*8)-1:9*7]),
   .tx_ca_cpld_vc7             (tx_ca_cpld[(13*8)-1:13*7]),

   // Inputs/Outputs per VC
   .rx_data_vc7                ( rx_data[(16*8)-1:16*7]),    
   .rx_st_vc7                  ( rx_st[7]),     
   .rx_end_vc7                 ( rx_end[7]),   
   `ifdef ECRC
      .rx_ecrc_err_vc7         ( rx_ecrc_err[7] ), 
   `endif
   .rx_us_req_vc7              ( rx_us_req[7] ), 
   .rx_malf_tlp_vc7            ( rx_malf_tlp[7] ), 
   `endif


   // Datal Link Control SM Status
   .dl_up                      ( dl_up ),
   .sys_clk_125                ( sys_clk_125_temp )
   );


// ====================================================================
// Initilize the design
// ====================================================================
initial begin
    error           = 1'b0;
    rst_n           = 1'b0;
    clk_100         = 1'b0;
    rx_tlp_discard  = 0;
    ecrc_gen_enb    = 1'b0 ;  
    ecrc_chk_enb    = 1'b0 ;  
    enb_log         = 1'b0 ;
    no_pcie_train   = 1'b0;
end

// =============================================================================
// Timeout generation to finish hung test cases.
// =============================================================================

parameter TIMEOUT_NUM = 150000;
initial begin
   repeat (TIMEOUT_NUM) @(posedge sys_clk_125);
   $display(" ERROR : Simulation Time Out, Test case Terminated at time : %0t", $time) ;
   $finish ;
end

// =============================================================================
// Simulation Time Display for long test cases
initial begin
   forever begin
      #100000;  //every 10k (add extra zero - timescale)  ns just display Time value - useful for SDF sim
      $display("                                       Displaying Sim. Time : %0t", $time) ;
   end
end

// =============================================================================
// Clocks generation
// =============================================================================

// 100 Mhz clock input to PLL to generate 125MHz for PCS
 
always   #50        clk_100      <= ~clk_100 ;

`ifdef SDF_SIM
   assign tb_sys_clk = tb_top.u1_top.pclk;
`else
   assign tb_sys_clk = tb_top.u1_top.u1_pcs_pipe.PCLK;
`endif

`ifdef SDF_SIM
    assign sys_clk_125 = u1_top.sys_clk_125; 
`else
    assign sys_clk_125 = sys_clk_125_temp; 
`endif

// =============================================================================
// =============================================================================
//initial begin
//   `ifdef SDF_SIM
//       $sdf_annotate("../../../../par/ecp2m/config1/synplicity/top/verilog/pci_exp_x1_top.sdf", u1_top,, "pci_exp_x1_top_sdf.log");
//   `endif
//end

// =============================================================================
// WISHBONE TASKS
// =============================================================================
`ifdef WISHBONE
initial begin
   RST_I = 'd0 ;
   CLK_I = 'd0 ;
   ADR_I = 'd0 ;
   DAT_I = 'd0 ;
   SEL_I = 'd0 ;
   WE_I  = 'd0 ;
   STB_I = 'd0 ;
   CYC_I = 'd0 ;
end

always #40 CLK_I <= ~CLK_I ;

// =============================================================================
// Wishbone write task
// =============================================================================
task wb_write;  
input [12:0]     addr;
input [31:0]     wr_data;
integer          j;
begin
   repeat (1) @(posedge  CLK_I) ;
   ADR_I <= addr ; 
   DAT_I <= wr_data ; 
   STB_I <= 1'b1 ; 
   CYC_I <= 1'b1 ; 
   WE_I  <= 1'b1 ; 
   for (j=0; j<=20; j=j+1) begin
      if (ACK_O) begin
         $display("---INFO : Wishbone Write to Addr:%h, Data:%h at %0t", addr, wr_data, $time ) ;
         STB_I <= 1'b0 ; 
         CYC_I <= 1'b0 ; 
         WE_I  <= 1'b0 ; 
         j     <= 100;
      end
      else if (j==20) begin
         STB_I <= 1'b0 ; 
         CYC_I <= 1'b0 ; 
         WE_I  <= 1'b0 ; 
         $display("---ERROR : Wishbone slave NOT responding at %0t", $time ) ;
      end
      repeat (1) @(posedge  CLK_I) ;
   end
end
endtask
// =============================================================================
// Wishbone read task
// =============================================================================
task wb_read;  
input  [12:0]    addr;
output [31:0]    rd_data;
integer          i;
begin
   repeat (1) @(posedge  CLK_I) ;
   ADR_I <= addr ; 
   STB_I <= 1'b1 ; 
   CYC_I <= 1'b1 ; 
   WE_I  <= 1'b0 ; 
   for (i=0; i<=20; i=i+1) begin
      if (ACK_O) begin
         rd_data <= DAT_O ;
         $display("---INFO : Wishbone Read to Addr:%h, Data:%h at %0t", addr, DAT_O, $time ) ;
         STB_I   <= 1'b0 ; 
         CYC_I   <= 1'b0 ; 
         WE_I    <= 1'b0 ; 
         i       <= 100;
      end
      else if (i==20) begin
         $display("---ERROR : Wishbone slave NOT responding at %0t", $time ) ;
         STB_I   <= 1'b0 ; 
         CYC_I   <= 1'b0 ; 
         WE_I    <= 1'b0 ; 
      end
      repeat (1) @(posedge  CLK_I) ;
   end
end
endtask
`endif
// =============================================================================
// Reset Task 
// =============================================================================
task  RST_DUT;
begin
   repeat(2) @(negedge  clk_100);
   #40000;
   rst_n         = 1'b1;
   
   repeat (50) @ (posedge clk_100) ;
`ifdef SDF_SIM
   force u1_top.core_rst_n    = 1'b1; // de-assert delayed reset to core
`else
   force u1_top.u1_dut.rst_n  = 1'b1; // de-assert delayed reset to core
`endif

   repeat(10) @(negedge  clk_100);
`ifdef WISHBONE
   wb_write (13'h1010, {2'd0, `ACKNAK_LAT_TIME, 6'd0, `SKP_INS_CNT}) ;
   wb_write (13'h1014, {14'd0,`UPDATE_FREQ_PH, `UPDATE_FREQ_PD});
   wb_write (13'h1018, {14'd0,`UPDATE_FREQ_NPH, `UPDATE_FREQ_NPD});
   wb_write (13'h1020, {20'd0,`UPDATE_TIMER}) ;
`endif
end
endtask

// =============================================================================
// Reset Task 
// =============================================================================
task  DEFAULT_CREDITS;
reg [2:0]  tmp_vcid;
begin
   for(i=0; i<= `NUM_VC-1; i=i+1) begin
      tmp_vcid = i;
      case(tmp_vcid)
        `ifdef EN_VC0
         0 : begin
            u_tbrx[0].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[0].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[0].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC1
         1 : begin
            u_tbrx[1].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[1].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[1].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC2
         2 : begin
            u_tbrx[2].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[2].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[2].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC3
         3 : begin
            u_tbrx[3].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[3].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[3].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC5
         4 : begin
            u_tbrx[4].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[4].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[4].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC5
         5 : begin
            u_tbrx[5].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[5].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[5].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC6
         6 : begin
            u_tbrx[6].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[6].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[6].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
        `ifdef EN_VC7
         7 : begin
            u_tbrx[7].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[7].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[7].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
      endcase
   end
end
endtask

// =============================================================================
// Check on error signal & stop simulation if error = 1
// =============================================================================
always @(posedge sys_clk_125) begin
   if (error) begin
      repeat (200) @(posedge sys_clk_125);
      $finish;
   end
end


// =============================================================================
// TBTX TASKS
// =============================================================================
// HEADER FORMAT FOR MEM READ  
// (Fmt & Type decides what kind of Request) 
//           ================================================
//           R  Fmt  Type  R TC  R R R R  TD EP ATTR R Length
//           Requester ID -- TAG  -- Last DW BE -- First DW BE
//           ----------   Address [63:32] -------------------
//            ---------   Address [31:2] -----------------  R
//           ================================================
// Fixed values : 
//            Fmt[1] = 0
//            First DW BE = 4'b0000
//            Last DW BE  = 4'b0000
//            ATTR is always 2'b00 {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// Arguments : 
//            TC/VC, Address[31:2], Fmt[0]/hdr_Type, Length
// Registers that are used : 
//            TBTX_TD, TBTX_EP, First_DW_BE, TBTX_UPPER32_ADDR
// For hdr_type 4 DW TBTX_UPPER32_ADDR is used (and Fmt[0] = 1)
//
// NOTE : Length is not the LENGTH of this MEM_RD Pkt
// =============================================================================
task tbtx_mem_rd;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //0: 3 DW Header --- 1: 4 DW (with TBTX_UPPER32_ADDR)
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_mem_rd(addr,length,hdr_type);
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_mem_rd(addr,length,hdr_type);
     `endif
   endcase
end
endtask


// =============================================================================
// HEADER FORMAT FOR MEM WRITE  
// (Fmt & Type decides what kind of Request) 
//           ================================================
//           R  Fmt  Type  R TC  R R R R  TD EP ATTR R Length
//           Requester ID -- TAG  -- Last DW BE -- First DW BE
//           ----------   Address [63:32] -------------------
//            ---------   Address [31:2] -----------------  R
//           ================================================
// Arguments : 
//            TC/VC, Address[31:2], Fmt[0]/hdr_Type
// Registers that are used : 
//            TBTX_TD, TBTX_EP, First_DW_BE, Last_DW_BE, TBTX_UPPER32_ADDR
// For hdr_type 4 DW TBTX_UPPER32_ADDR is used (and Fmt[0] = 1)
// =============================================================================
task tbtx_mem_wr;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [9:0]   nul_len;
input          nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_msg;
input  [2:0]   vcid;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_msg;
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_msg;
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_msg;
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_msg;
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_msg;
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_msg;
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_msg;
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_msg;
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_msg_d;
input  [2:0]   vcid;
input [9:0]   length;
input  [9:0]   nul_len;
input          nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_msg_d(length, nul_len, nullify);
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_msg_d(length, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   u_tbtx[0].tbtx_cfg_rd(cfg, addr);
end
endtask
// =============================================================================
task tbtx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   u_tbtx[0].tbtx_cfg_wr(cfg, addr);
end
endtask
// =============================================================================
task tbtx_io_rd;
input  [31:0]  addr;
begin
   u_tbtx[0].tbtx_io_rd(addr);
end
endtask

// =============================================================================
task tbtx_io_wr;
input  [31:0]  addr;
begin
   u_tbtx[0].tbtx_io_wr(addr);
end
endtask

// =============================================================================
task tbtx_cpl;
input  [2:0]   vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_cpl_d;
input  [2:0]   vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [9:0]  nul_len;
input         nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC1
      1 : u_tbtx[1].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC2
      2 : u_tbtx[2].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC3
      3 : u_tbtx[3].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC4
      4 : u_tbtx[4].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC5
      5 : u_tbtx[5].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC6
      6 : u_tbtx[6].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
     `ifdef EN_VC7
      7 : u_tbtx[7].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
// TBRX TASKS
// =============================================================================
//         Error Types
//  NO_TLP_ERR     = 4'b0000;
//  ECRC_ERR       = 4'b0001;
//  UNSUP_ERR      = 4'b0010;
//  MALF_ERR       = 4'b0011;
//  FMT_TYPE_ERR   = 4'b1111;
// =============================================================================
// tbrx_tlp:
// This task is used when User wants create TLP manually 
// For fmt_type error this should be used, no other tasks supports this error.
// =============================================================================
task tbrx_tlp;  //When Giving Malformed TLP (Only fmt & Type error)
input  [2:0]  vcid;
input  [3:0]  Error_Type;
input         hdr_type;  //3 DW or 4 DW 
input [31:0]  h1_msb;
input [31:0]  h1_lsb;
input [31:0]  h2_msb;
input [31:0]  h2_lsb;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif
   endcase

end
endtask

// =============================================================================
task tbrx_mem_rd;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask
// =============================================================================
task tbrx_mem_wr;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_msg;
input  [2:0]   vcid;
input [9:0]    length;
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_msg(length,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_msg(length,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_msg_d;
input  [2:0]   vcid;
input [9:0]    length;
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_msg_d(length, Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_msg_d(length, Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_cfg_rd(cfg, addr,length, Error_Type);
end
endtask
// =============================================================================
task tbrx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_cfg_wr(cfg, addr,length, Error_Type);
end
endtask
// =============================================================================
task tbrx_io_rd;
input  [31:0]  addr;
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_io_rd(addr,length, Error_Type);
end
endtask

// =============================================================================
task tbrx_io_wr;
input  [31:0]  addr;
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_io_wr(addr,length, Error_Type);
end
endtask

// =============================================================================
task tbrx_cpl;
input  [2:0]  vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input  [9:0]   length;
input  [3:0]  Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_cpl_d;
input  [2:0]  vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [3:0]  Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
// TASKS WITH TC INPUT
// =============================================================================
task tbrx_mem_rd_tc;
input  [2:0]   vcid;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask
// =============================================================================
task tbrx_mem_wr_tc;
input  [2:0]   vcid;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
// FLOW CONTROL TASKS
// =============================================================================
// Setting INIT values
// =============================================================================
task FC_INIT;
input  [2:0]  vcid;
input  [1:0]  type;  // p/np/cpl
input  [7:0]  hdr;
input  [11:0] data;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].FC_INIT(type, hdr, data);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].FC_INIT(type, hdr, data);
     `endif
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of buf_status signals
// =============================================================================
task FC_BUF_STATUS;
input  [2:0]  vcid;
input  [2:0]  type;  // ph/pd/nph/npd/cpl/cpld
input         set;   // Set=1: Assert the signal  , Set=0, De-assert the signal
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].FC_BUF_STATUS(type, set);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].FC_BUF_STATUS(type, set);
     `endif
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of Processed signals
// Onle pulse
// =============================================================================
task FC_PROCESSED;
input  [2:0]  vcid;
input  [2:0]  type;  // ph/pd/nph/npd/cpl/cpld
input         set;   // Set=1: Assert the signal  , Set=0, De-assert the signal
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC1
      1 : u_tbrx[1].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC2
      2 : u_tbrx[2].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC3
      3 : u_tbrx[3].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC4
      4 : u_tbrx[4].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC5
      5 : u_tbrx[5].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC6
      6 : u_tbrx[6].FC_PROCESSED(type);
     `endif
     `ifdef EN_VC7
      7 : u_tbrx[7].FC_PROCESSED(type);
     `endif
   endcase
end
endtask

endmodule
