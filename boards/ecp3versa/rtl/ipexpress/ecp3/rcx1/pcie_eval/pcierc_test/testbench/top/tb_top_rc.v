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
// Project          : pci_exp
// File             : tb_top.v
// Title            :
// Dependencies     : pci_exp.v
// Description      : Top level for testbench of pci_exp X4 IP with Serdes PCS PIPE
//                   
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        :  
// Mod. Date        : Aug 11, 2006
// Changes Made     : Initial Creation
// =============================================================================

`timescale 100 ps/100 ps
module tb_top;

// DUT User defines
`include "pci_exp_params.v"
`include "pci_exp_dparams.v"
`include "pci_exp_ddefines.v"


// =============================================================================
// Regs for BFM & Test case 
// =============================================================================
//---- Regs
reg                      clk_100;
reg                      error;
reg                      rst_n;
reg                      no_pcie_train;   // This signal disables the training process
reg                      txtlpu_req ;     // Request from TL for sending TLPs.
reg  [63:0]              txtlpu_data ;    // Input data from TL.
reg                      txtlpu_st ;      // start of TLP.
reg                      txtlpu_end ;     // End of TLP. 
reg                      txtlpu_nlfy ;    // Nullify TLP.
reg                      ecrc_gen_enb ; 
reg                      ecrc_chk_enb ; 
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
wire                     sys_clk_125_temp;
wire                     txdp_pm_sent;


wire [63:0]              INIT_PH_FC;      //Initial P HdrFC value
wire [63:0]              INIT_NPH_FC;     // For NPH
wire [63:0]              INIT_CPLH_FC;    // For CPLH
wire [95:0]              INIT_PD_FC;      // Initial P DataFC value
wire [95:0]              INIT_NPD_FC;     // For NPD
wire [95:0]              INIT_CPLD_FC;    // For CPLD
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
wire [7:0]               cplh_buf_status; // For CPLH
wire [7:0]               cpld_buf_status; // For CPLD
wire [7:0]               ph_processed;    // TL has processed one TLP Header - PH Type
wire [7:0]               pd_processed;    // TL has processed one TLP Data - PD TYPE
wire [7:0]               nph_processed;   // For NPH
wire [7:0]               npd_processed;   // For NPD
wire [7:0]               cplh_processed;  // For CPLH
wire [7:0]               cpld_processed;  // For CPLD


//---------Outputs From Core------------
wire  [7:0]              tx_rdy;  
wire  [511:0]            rx_data; 
wire  [7:0]              rx_st;  
wire  [7:0]              rx_end;
wire  [7:0]              rx_ecrc_err;
wire  [7:0]              rx_us_req;
wire  [7:0]              rx_malf_tlp;
wire  [7:0]              rx_pois_tlp;
wire  [3:0]              phy_ltssm_state; 
  
wire  [7:0]              tx_req;  
wire  [2:0]              rx_status;  
wire  [1:0]              power_down;  
wire                     tx_detect_rx;
wire                     tx_elec_idle;
wire                     tx_compliance;
wire                     rx_polarity;
wire  [15:0]             rx_valid;
wire  [15:0]             rx_elec_idle;
wire  [15:0]             phy_status;

wire                     rx_valid0;    //For Debug
wire                     rx_elec_idle0;
wire                     phy_status0;
wire                     phy_realign_req;

//---- Integer
integer                  i;

//---------- TB_MUX signals
reg  [3:0]               tc_block_skip;
reg  [3:0]               tc_block_ts1;
reg  [3:0]               tc_mask_pad1;
reg  [11:0]              tc_allow_num1[0:3];
reg  [3:0]               tc_inv_polar;
reg  [3:0]               tc_change_laneid;
reg  [3:0]               tc_change_linkid;
reg  [3:0]               tc_change_nfts;
reg  [31:0]              tc_linkid;
reg  [31:0]              tc_laneid;
reg  [31:0]              tc_nfts;

wire [3:0]               tbmux_allow_done1;
reg  [3:0]               tc_block_ts2;
reg  [3:0]               tc_mask_pad2;
reg  [11:0]              tc_allow_num2[0:3];
wire [3:0]               tbmux_allow_done2;

reg  [3:0]               tc_force_ts1;
reg  [3:0]               tc_force_ts2;
reg  [3:0]               tc_linkid_en;
reg  [3:0]               tc_laneid_en;
reg  [3:0]               tc_lb;
reg  [3:0]               tc_dis;
reg  [3:0]               tc_hr;

reg  [3:0]               tc_force_EIos;
reg  [3:0]               tc_force_skip;
reg  [3:0]               tc_block_idle;
reg  [4:0]               tc_idle_cnt [0:3];
reg  [3:0]               tc_idle_gap;
reg  [15:0]              tx_lbk_data;    
reg  [1:0]               tx_lbk_kcntl;   
wire                     tx_lbk_rdy;    
wire [15:0]              rx_lbk_data;  
wire [1:0]               rx_lbk_kcntl;


wire  [(`NUM_VC*16)-1:0] tx_data; 
wire  [`NUM_VC-1:0]      tx_st;  
wire  [`NUM_VC-1:0]      tx_end;
wire  [`NUM_VC-1:0]      tx_nlfy; 

wire  [`NUM_VC-1:0]      tb_sys_clk; 

parameter DLY1 = 1 ;
parameter DLY2 = 1 ;


// =============================================================================

// DUT Design params file
`include "pci_exp_ddefines.v"

// Include the test case 
`include "test_rc.v"

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
wire                     hdoutp_0 ;
wire                     hdoutn_0 ;
reg                      hdoutp_0_d ;
reg                      hdoutn_0_d ;
wire                     hdoutp_1 ;
wire                     hdoutn_1 ;
reg                      hdoutp_1_d ;
reg                      hdoutn_1_d ;
wire                     hdoutp_2 ;
wire                     hdoutn_2 ;
reg                      hdoutp_2_d ;
reg                      hdoutn_2_d ;
wire                     hdoutp_3 ;
wire                     hdoutn_3 ;
reg                      hdoutp_3_d ;
reg                      hdoutn_3_d ;
wire                     refclkp;
wire                     refclkn;

pullup (hdoutp_0);
pullup (hdoutn_0);
pullup (hdoutp_1);
pullup (hdoutn_1);
pullup (hdoutp_2);
pullup (hdoutn_2);
pullup (hdoutp_3);
pullup (hdoutn_3);


always @* begin
   //0
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
      #DLY1 hdoutn_0_d <= 1'b1 ;
   else
      #DLY1 hdoutn_0_d <= hdoutn_0_d ;
end

always @* begin
   //1
   if (!rst_n)
      #DLY1 hdoutp_1_d <= hdoutp_1 ;
   else if (hdoutp_1 == 1'b1)
      #DLY1 hdoutp_1_d <= 1'b1 ;
   else if (hdoutp_1 == 1'b0)
      #DLY1 hdoutp_1_d <= 1'b0 ;
   else if (hdoutp_1 === 1'bz)
      #DLY1 hdoutp_1_d <= 1'b1 ;
   else
      #DLY1 hdoutp_1_d <= hdoutp_1_d ;

   if (!rst_n)
      #DLY1 hdoutn_1_d <= hdoutn_1 ;
   else if (hdoutn_1 == 1'b1)
      #DLY1 hdoutn_1_d <= 1'b1 ;
   else if (hdoutn_1 == 1'b0)
      #DLY1 hdoutn_1_d <= 1'b0 ;
   else if (hdoutn_1 === 1'bz)
      #DLY1 hdoutn_1_d <= 1'b1 ;
   else
      #DLY1 hdoutn_1_d <= hdoutn_1_d ;
end

always @* begin
   //2
   if (!rst_n)
      #DLY1 hdoutp_2_d <= hdoutp_2 ;
   else if (hdoutp_2 == 1'b1)
      #DLY1 hdoutp_2_d <= 1'b1 ;
   else if (hdoutp_2 == 1'b0)
      #DLY1 hdoutp_2_d <= 1'b0 ;
   else if (hdoutp_2 === 1'bz)
      #DLY1 hdoutp_2_d <= 1'b1 ;
   else
      #DLY1 hdoutp_2_d <= hdoutp_2_d ;

   if (!rst_n)
      #DLY1 hdoutn_2_d <= hdoutn_2 ;
   else if (hdoutn_2 == 1'b1)
      #DLY1 hdoutn_2_d <= 1'b1 ;
   else if (hdoutn_2 == 1'b0)
      #DLY1 hdoutn_2_d <= 1'b0 ;
   else if (hdoutn_2 === 1'bz)
      #DLY1 hdoutn_2_d <= 1'b1 ;
   else
      #DLY1 hdoutn_2_d <= hdoutn_2_d ;
end

always @* begin
   //3
   if (!rst_n)
      #DLY1 hdoutp_3_d <= hdoutp_3 ;
   else if (hdoutp_3 == 1'b1)
      #DLY1 hdoutp_3_d <= 1'b1 ;
   else if (hdoutp_3 == 1'b0)
      #DLY1 hdoutp_3_d <= 1'b0 ;
   else if (hdoutp_3 === 1'bz)
      #DLY1 hdoutp_3_d <= 1'b1 ;
   else
      #DLY1 hdoutp_3_d <= hdoutp_3_d ;

   if (!rst_n)
      #DLY1 hdoutn_3_d <= hdoutn_3 ;
   else if (hdoutn_3 == 1'b1)
      #DLY1 hdoutn_3_d <= 1'b1 ;
   else if (hdoutn_3 == 1'b0)
      #DLY1 hdoutn_3_d <= 1'b0 ;
   else if (hdoutn_3 === 1'bz)
      #DLY1 hdoutn_3_d <= 1'b1 ;
   else
      #DLY1 hdoutn_3_d <= hdoutn_3_d ;

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

assign tbrx_vc = 3'd0;
assign tbtx_vc = 3'd0;

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
    .tx_ca_p_recheck    ( 1'b0 ),
    .tx_ca_cpl_recheck  ( 1'b0 ),

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
   .cplh_buf_status  (cplh_buf_status[`NUM_VC-1:0]),
   .cpld_buf_status  (cpld_buf_status[`NUM_VC-1:0]),
   .ph_processed     (ph_processed[`NUM_VC-1:0]),
   .pd_processed     (pd_processed[`NUM_VC-1:0]),
   .nph_processed    (nph_processed[`NUM_VC-1:0]),
   .npd_processed    (npd_processed[`NUM_VC-1:0]),
   .cplh_processed   (cplh_processed[`NUM_VC-1:0]),
   .cpld_processed   (cpld_processed[`NUM_VC-1:0]),
   .pd_num           ( ),
   .npd_num          ( ),
   .cpld_num         ( ),
   .INIT_PH_FC       ( ),
   .INIT_NPH_FC      ( ),
   .INIT_CPLH_FC     ( ),
   .INIT_PD_FC       ( ),
   .INIT_NPD_FC      ( ),
   .INIT_CPLD_FC     ( ) 
    );

// =============================================================================
// DUT
// =============================================================================

`USERNAME_EVAL_TOP u1_top(
   //------- Clock and Reset
   .refclkp                    ( clk_100), 
   .refclkn                    ( ~clk_100), 
   .sys_clk_125                ( sys_clk_125_temp ),
   .rst_n                      ( rst_n ),

   .hdinp0                     ( hdoutp_0_d ), 
   .hdinn0                     ( hdoutn_0_d ), 
   .hdoutp0                    ( hdoutp_0 ), 
   .hdoutn0                    ( hdoutn_0 ),

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
   .cplh_buf_status_vc0        (cplh_buf_status[0]),
   .cpld_buf_status_vc0        (cpld_buf_status[0]),
   .ph_processed_vc0           (ph_processed[0]),
   .pd_processed_vc0           (pd_processed[0]),
   .nph_processed_vc0          (nph_processed[0]),
   .npd_processed_vc0          (npd_processed[0]),
   .cplh_processed_vc0         (cplh_processed[0]),
   .cpld_processed_vc0         (cpld_processed[0]),
   `ifdef ECRC
      .ecrc_gen_enb            ( ecrc_gen_enb ) ,
      .ecrc_chk_enb            ( ecrc_chk_enb ) ,
   `endif

   .tx_rdy_vc0                 (tx_rdy[0]),  
   .tx_ca_ph_vc0               (tx_ca_ph[(9*1)-1:0]),
   .tx_ca_pd_vc0               (tx_ca_pd[(13*1)-1:0]),
   .tx_ca_nph_vc0              (tx_ca_nph[(9*1)-1:0]),
   .tx_ca_npd_vc0              (tx_ca_npd[(13*1)-1:0]), 
   .tx_ca_cplh_vc0             (tx_ca_cplh[(9*1)-1:0]),
   .tx_ca_cpld_vc0             (tx_ca_cpld[(13*1)-1:0]),

   // Inputs/Outputs per VC
   .rx_data_vc0                ( rx_data[(16*1)-1:0]),    
   .rx_st_vc0                  ( rx_st[0]),     
   .rx_end_vc0                 ( rx_end[0]),   
   `ifdef ECRC
      .rx_ecrc_err_vc0         ( rx_ecrc_err[0] ), 
   `endif 
   .rx_pois_tlp_vc0            ( rx_pois_tlp[0] ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp[0] ), 

   .inta_n                     (  ),
   .intb_n                     (  ),
   .intc_n                     (  ),
   .intd_n                     (  ),
   .ftl_err_msg                (  ),
   .nftl_err_msg               (  ),
   .cor_err_msg                (  )
   );

// ====================================================================
// Initilize the design
// ====================================================================
initial begin
    error           = 1'b0;
    rst_n           = 1'b0;
    clk_100         = 1'b0;
    rx_tlp_discard  = 0;
    enb_log         = 1'b0 ;
    ecrc_gen_enb    = 1'b0; 
    ecrc_chk_enb    = 1'b0; 
end

// =============================================================================
// Timeout generation to finish hung test cases.
// =============================================================================

parameter TIMEOUT_NUM = 150000;
initial begin
   repeat (TIMEOUT_NUM) @(posedge sys_clk_125);
   $display(" ERROR : First -  Simulation Time Out, Test case Terminated at time : %0t", $time) ;
   repeat (TIMEOUT_NUM) @(posedge sys_clk_125);
   $display(" ERROR : Second - Simulation Time Out, Test case Terminated at time : %0t", $time) ;
   //$finish ;
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
initial begin
   $timeformat (-9 ,1 , "ns", 10);
   `ifdef REGRESS
   `else
      `ifdef NO_DUMP
      `else
         //$recordfile ("pcie_test.trn");
         //$recordvars ();
         //$shm_open ("pcie_test.shm");
         //$shm_probe ("ACMTF");
      `endif
   `endif
end
// =============================================================================
// Clocks generation
// =============================================================================

// 100 Mhz clock input to PLL to generate 125MHz for PCS
 
always   #50        clk_100      <= ~clk_100 ;



`ifdef SDF_SIM
    assign sys_clk_125 = u1_top.sys_clk_125_c; 
    assign tb_sys_clk = u1_top.\u1_pcie_top/pclk;
`else
    assign sys_clk_125 = sys_clk_125_temp; 
    assign tb_sys_clk = u1_top.u1_pcie_top.pclk;
`endif

// =============================================================================
// =============================================================================
initial begin
   `ifdef SDF_SIM
       //$sdf_annotate("../../../../par/ecp2m/config1/synplicity/top/verilog/pci_exp_x4_top.sdf", u1_top,, "pci_exp_x4_top_sdf.log");
   `endif
end

// =============================================================================
// Reset Task 
// =============================================================================
task  RST_DUT;
begin
   repeat(2) @(negedge  clk_100);
   #40000;
   rst_n = 1'b1;

   repeat (50) @ (posedge clk_100) ;
   force u1_top.u1_pcie_top.core_rst_n = 1'b1; // de-assert delayed reset to core

   repeat(10) @(negedge  clk_100);
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
   //tbtx_vc = vcid;
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
   //tbtx_vc = vcid;
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
   //tbtx_vc = vcid;
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
   //tbtx_vc = vcid;
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
   //tbtx_vc = vcid;
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
   //tbtx_vc = vcid;
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
// =============================================================================
//$Log: PCI_EXP_x4_11/technology/ver1.0/testbench/beh/tb_top_ecp2m_rc.v  $
