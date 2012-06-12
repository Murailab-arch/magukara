
`define NULL 0
`timescale 1ns / 1 ps

module pcs_top (
   // Common for all 4 Channels
   // Resets
   input wire         ffc_lane_tx_rst,
   input wire         ffc_lane_rx_rst,
   input wire         ffc_trst,
   input wire         ffc_quad_rst,
   input wire         ffc_macro_rst,

   // Clocks
   input  wire        refclkp,
   input  wire        refclkn,
   input  wire        PCLK,
   `ifdef ECP3
      `ifdef Channel_0
         output wire     ff_tx_f_clk_0,
         output wire     ff_tx_h_clk_0,
      `endif
      `ifdef Channel_1
         output wire     ff_tx_f_clk_1,
         output wire     ff_tx_h_clk_1,
      `endif
      `ifdef Channel_2
         output wire     ff_tx_f_clk_2,
         output wire     ff_tx_h_clk_2,
      `endif
      `ifdef Channel_3
         output wire     ff_tx_f_clk_3,
         output wire     ff_tx_h_clk_3,
      `endif
   `else
   output wire        ff_tx_f_clk,
   output wire        ff_tx_h_clk,
   `endif

   input  wire        ffc_signal_detect,
   input  wire        ffc_enb_cgalign,
   output wire        ffs_plol,

   // SCI Interface
   input  wire        sciwstn,
   input  wire [7:0]  sciwritedata,
   input  wire [5:0]  sciaddress,
   input  wire        scienaux,
   input  wire        sciselaux,
   input  wire        scird,
   output wire [7:0]  scireaddata,

   `ifdef Channel_0
      input wire         hdinp0, 
      input wire         hdinn0, 
      input wire [7:0]   TxData_ch0,
      input wire         TxDataK_ch0,
      input wire         TxCompliance_ch0,
      input wire         TxElecIdle_ch0,
      input wire         ffc_txpwdnb_0,
      input wire         ffc_rxpwdnb_0,
      input wire         ffc_rrst_ch0,
      input wire         ffc_pcie_ct_ch0,
      input wire         ffc_pcie_det_en_ch0,
      input wire         ffc_fb_loopback_ch0,
      input wire         RxPolarity_ch0,

      input wire         scisel_ch0,
      input wire         scien_ch0,

      output wire        ff_rx_fclk_ch0,
      output wire        hdoutp0,
      output wire        hdoutn0,
      output wire [7:0]  RxData_ch0,
      output wire        RxDataK_ch0, 
      output wire [2:0]  RxStatus_ch0,  
      output wire        RxValid_ch0,
      output wire        RxElecIdle_ch0,
      output wire        ffs_rlol_ch0,
      output wire        ffs_pcie_done_0,
      output wire        ffs_pcie_con_0,
   `endif

   `ifdef Channel_1
      input wire         hdinp1, 
      input wire         hdinn1, 
      input wire [7:0]   TxData_ch1,
      input wire         TxDataK_ch1,
      input wire         TxCompliance_ch1,
      input wire         TxElecIdle_ch1,
      input wire         ffc_txpwdnb_1,
      input wire         ffc_rxpwdnb_1,
      input wire         ffc_rrst_ch1,
      input wire         ffc_pcie_ct_ch1,
      input wire         ffc_pcie_det_en_ch1,
      input wire         ffc_fb_loopback_ch1,
      input wire         RxPolarity_ch1,

      input wire         scisel_ch1,
      input wire         scien_ch1,

      output wire        ff_rx_fclk_ch1,
      output wire        hdoutp1,
      output wire        hdoutn1,
      output wire [7:0]  RxData_ch1,
      output wire        RxDataK_ch1, 
      output wire [2:0]  RxStatus_ch1,  
      output wire        RxValid_ch1,
      output wire        RxElecIdle_ch1,
      output wire        ffs_rlol_ch1,
      output wire        ffs_pcie_done_1,
      output wire        ffs_pcie_con_1,
   `endif

   `ifdef Channel_2
      input wire         hdinp2, 
      input wire         hdinn2, 
      input wire [7:0]   TxData_ch2,
      input wire         TxDataK_ch2,
      input wire         TxCompliance_ch2,
      input wire         TxElecIdle_ch2,
      input wire         ffc_txpwdnb_2,
      input wire         ffc_rxpwdnb_2,
      input wire         ffc_rrst_ch2,
      input wire         ffc_pcie_ct_ch2,
      input wire         ffc_pcie_det_en_ch2,
      input wire         ffc_fb_loopback_ch2,
      input wire         RxPolarity_ch2,

      input wire         scisel_ch2,
      input wire         scien_ch2,

      output wire        ff_rx_fclk_ch2,
      output wire        hdoutp2,
      output wire        hdoutn2,
      output wire [7:0]  RxData_ch2,
      output wire        RxDataK_ch2, 
      output wire [2:0]  RxStatus_ch2,  
      output wire        RxValid_ch2,
      output wire        RxElecIdle_ch2,
      output wire        ffs_rlol_ch2,
      output wire        ffs_pcie_done_2,
      output wire        ffs_pcie_con_2,
   `endif

   `ifdef Channel_3
      input wire         hdinp3, 
      input wire         hdinn3, 
      input wire [7:0]   TxData_ch3,
      input wire         TxDataK_ch3,
      input wire         TxCompliance_ch3,
      input wire         TxElecIdle_ch3,
      input wire         ffc_txpwdnb_3,
      input wire         ffc_rxpwdnb_3,
      input wire         ffc_rrst_ch3,
      input wire         ffc_pcie_ct_ch3,
      input wire         ffc_pcie_det_en_ch3,
      input wire         ffc_fb_loopback_ch3,
      input wire         RxPolarity_ch3,

      input wire         scisel_ch3,
      input wire         scien_ch3,

      output wire        ff_rx_fclk_ch3,
      output wire        hdoutp3,
      output wire        hdoutn3,
      output wire [7:0]  RxData_ch3,
      output wire        RxDataK_ch3, 
      output wire [2:0]  RxStatus_ch3,  
      output wire        RxValid_ch3,
      output wire        RxElecIdle_ch3,
      output wire        ffs_rlol_ch3,
      output wire        ffs_pcie_done_3,
      output wire        ffs_pcie_con_3,
   `endif

   input  wire [11:0] cin,
   output wire [19:0] cout

) ;

// =============================================================================
//synopsys translate_off
`ifdef ECP3
   `ifdef X1
      parameter USER_CONFIG_FILE = "pcs_pipe_8b_x1.txt";
   `else 
      parameter USER_CONFIG_FILE = "pcs_pipe_8b_x4.txt";
   `endif
   parameter QUAD_MODE     = "SINGLE";
   parameter PLL_SRC       = "REFCLK_EXT";
   parameter CH0_CDR_SRC   = "REFCLK_EXT";
   parameter CH1_CDR_SRC   = "REFCLK_EXT";
   parameter CH2_CDR_SRC   = "REFCLK_EXT";
   parameter CH3_CDR_SRC   = "REFCLK_EXT";

   defparam pcs_inst_0.CONFIG_FILE   = USER_CONFIG_FILE;
   defparam pcs_inst_0.QUAD_MODE     = QUAD_MODE;
   defparam pcs_inst_0.PLL_SRC       = PLL_SRC;
   defparam pcs_inst_0.CH0_CDR_SRC   = CH0_CDR_SRC;
   defparam pcs_inst_0.CH1_CDR_SRC   = CH1_CDR_SRC;
   defparam pcs_inst_0.CH2_CDR_SRC   = CH2_CDR_SRC;
   defparam pcs_inst_0.CH3_CDR_SRC   = CH3_CDR_SRC;
`else 
   `ifdef X1
      parameter USER_CONFIG_FILE = "pcs_pipe_8b_x1.txt";
      defparam pcs_inst_0.CONFIG_FILE = USER_CONFIG_FILE;
   `else 
      parameter USER_CONFIG_FILE = "pcs_pipe_8b_x4.txt";
      defparam pcs_inst_0.CONFIG_FILE = USER_CONFIG_FILE;
   `endif
`endif


integer file, r;

initial begin
   file = $fopen(USER_CONFIG_FILE, "r");
   if (file == `NULL) begin
      $display ("ERROR : Auto configuration file for PCSC module not found.");
      $display ("      : PCSC internal configuration registers will not be ");
      $display ("      : initialized correctly during simulation!");
   end
end
//synopsys translate_on

// =============================================================================
// Wires 
// =============================================================================
wire       pcs_refclkp, pcs_refclkn, pcs_PCLK ;
wire       pcs_ffc_lane_tx_rst, pcs_ffc_lane_rx_rst ;
wire       pcs_ffc_macro_rst, pcs_ffc_quad_rst, pcs_ffc_trst ;
`ifdef ECP3
   wire    pcs_ff_tx_f_clk_0, pcs_ff_tx_h_clk_0;
   wire    pcs_ff_tx_f_clk_1, pcs_ff_tx_h_clk_1;
   wire    pcs_ff_tx_f_clk_2, pcs_ff_tx_h_clk_2;
   wire    pcs_ff_tx_f_clk_3, pcs_ff_tx_h_clk_3;
`else
wire       pcs_ff_tx_f_clk, pcs_ff_tx_h_clk;
`endif
wire       pcs_ffc_signal_detect, pcs_ffc_enb_cgalign, pcs_ffs_plol ;

// SCI
wire [7:0] pcs_sciwritedata, pcs_scireaddata ;
wire [5:0] pcs_sciaddress ;
wire       pcs_scienaux, pcs_sciselaux, pcs_scird, pcs_sciwstn ;

//CH0/CH1/CH2/CH3
wire       pcs_hdinp0, pcs_hdinp1, pcs_hdinp2, pcs_hdinp3 ;
wire       pcs_hdinn0, pcs_hdinn1, pcs_hdinn2, pcs_hdinn3 ;
wire       pcs_hdoutp0, pcs_hdoutp1, pcs_hdoutp2, pcs_hdoutp3 ;
wire       pcs_hdoutn0, pcs_hdoutn1, pcs_hdoutn2, pcs_hdoutn3 ;
wire       pcs_scisel_ch0, pcs_scisel_ch1, pcs_scisel_ch2, pcs_scisel_ch3 ;
wire       pcs_scien_ch0, pcs_scien_ch1, pcs_scien_ch2, pcs_scien_ch3 ;
wire       pcs_ff_rx_fclk_ch0, pcs_ff_rx_fclk_ch1, pcs_ff_rx_fclk_ch2, pcs_ff_rx_fclk_ch3 ;
wire [7:0] pcs_TxData_ch0, pcs_TxData_ch1,pcs_TxData_ch2,pcs_TxData_ch3 ;
wire       pcs_TxDataK_ch0, pcs_TxDataK_ch1, pcs_TxDataK_ch2, pcs_TxDataK_ch3 ;
wire       pcs_TxCompliance_ch0, pcs_TxCompliance_ch1, pcs_TxCompliance_ch2, pcs_TxCompliance_ch3 ;
wire       pcs_TxElecIdle_ch0, pcs_TxElecIdle_ch1, pcs_TxElecIdle_ch2, pcs_TxElecIdle_ch3 ;
wire [7:0] pcs_RxData_ch0, pcs_RxData_ch1, pcs_RxData_ch2, pcs_RxData_ch3 ;
wire       pcs_RxDataK_ch0, pcs_RxDataK_ch1, pcs_RxDataK_ch2, pcs_RxDataK_ch3 ;
wire [2:0] pcs_RxStatus_ch0, pcs_RxStatus_ch1, pcs_RxStatus_ch2, pcs_RxStatus_ch3 ;
wire       pcs_ffc_rrst_ch0, pcs_ffc_rrst_ch1, pcs_ffc_rrst_ch2, pcs_ffc_rrst_ch3 ;
wire       pcs_ffc_fb_loopback_ch0, pcs_ffc_fb_loopback_ch1, pcs_ffc_fb_loopback_ch2, pcs_ffc_fb_loopback_ch3;
wire       pcs_RxPolarity_ch0, pcs_RxPolarity_ch1, pcs_RxPolarity_ch2, pcs_RxPolarity_ch3 ;
wire       pcs_ffc_pcie_ct_ch0, pcs_ffc_pcie_ct_ch1, pcs_ffc_pcie_ct_ch2, pcs_ffc_pcie_ct_ch3 ;
wire       pcs_ffc_pcie_det_en_ch0, pcs_ffc_pcie_det_en_ch1, pcs_ffc_pcie_det_en_ch2, pcs_ffc_pcie_det_en_ch3 ;
wire       pcs_ffs_pcie_done_0, pcs_ffs_pcie_done_1, pcs_ffs_pcie_done_2, pcs_ffs_pcie_done_3 ;
wire       pcs_ffs_pcie_con_0, pcs_ffs_pcie_con_1, pcs_ffs_pcie_con_2, pcs_ffs_pcie_con_3 ;
wire       pcs_ffc_txpwdnb_0, pcs_ffc_txpwdnb_1, pcs_ffc_txpwdnb_2, pcs_ffc_txpwdnb_3 ;
wire       pcs_ffc_rxpwdnb_0, pcs_ffc_rxpwdnb_1, pcs_ffc_rxpwdnb_2, pcs_ffc_rxpwdnb_3 ;
wire       pcs_RxElecIdle_ch0, pcs_RxElecIdle_ch1, pcs_RxElecIdle_ch2, pcs_RxElecIdle_ch3 ;
wire       pcs_RxValid_ch0, pcs_RxValid_ch1, pcs_RxValid_ch2, pcs_RxValid_ch3 ;
wire       pcs_ffs_rlol_ch0 ,pcs_ffs_rlol_ch1, pcs_ffs_rlol_ch2, pcs_ffs_rlol_ch3 ;

wire [11:0] pcs_cin ;
wire [19:0] pcs_cout ;

// =============================================================================
// PCS Connections
// =============================================================================
// Inputs
assign pcs_refclkp           = refclkp ;
assign pcs_refclkn           = refclkn ;
assign pcs_PCLK              = PCLK ;
assign pcs_ffc_lane_tx_rst   = ffc_lane_tx_rst; 
assign pcs_ffc_lane_rx_rst   = ffc_lane_rx_rst;
assign pcs_ffc_macro_rst     = ffc_macro_rst; 
assign pcs_ffc_quad_rst      = ffc_quad_rst;
assign pcs_ffc_trst          = ffc_trst;
assign pcs_ffc_signal_detect = ffc_signal_detect;
assign pcs_ffc_enb_cgalign   = ffc_enb_cgalign;

assign pcs_sciwritedata      = sciwritedata;
assign pcs_sciaddress        = sciaddress;
assign pcs_scienaux          = scienaux;
assign pcs_sciselaux         = sciselaux;
assign pcs_scird             = scird;
assign pcs_sciwstn           = sciwstn;

assign pcs_cin               = cin;

// Outputs
`ifdef ECP3
   `ifdef Channel_0
      assign ff_tx_f_clk_0   = pcs_ff_tx_f_clk_0;
      assign ff_tx_h_clk_0   = pcs_ff_tx_h_clk_0;
   `endif
   `ifdef Channel_1
      assign ff_tx_f_clk_1   = pcs_ff_tx_f_clk_1;
      assign ff_tx_h_clk_1   = pcs_ff_tx_h_clk_1;
   `endif
   `ifdef Channel_2
      assign ff_tx_f_clk_2   = pcs_ff_tx_f_clk_2;
      assign ff_tx_h_clk_2   = pcs_ff_tx_h_clk_2;
   `endif
   `ifdef Channel_3
      assign ff_tx_f_clk_3   = pcs_ff_tx_f_clk_3;
      assign ff_tx_h_clk_3   = pcs_ff_tx_h_clk_3;
   `endif
`else
assign ff_tx_f_clk           = pcs_ff_tx_f_clk;
assign ff_tx_h_clk           = pcs_ff_tx_h_clk;
`endif
assign ffs_plol              = pcs_ffs_plol;
assign scireaddata           = pcs_scireaddata;

assign cout                  = pcs_cout;

// ========================================================
`ifdef Channel_0
   // Inputs
   assign pcs_hdinp0              = hdinp0 ;
   assign pcs_hdinn0              = hdinn0 ;
   assign pcs_TxData_ch0          = TxData_ch0 ;
   assign pcs_TxDataK_ch0         = TxDataK_ch0 ;
   assign pcs_TxCompliance_ch0    = TxCompliance_ch0 ;
   assign pcs_TxElecIdle_ch0      = TxElecIdle_ch0 ;
   assign pcs_ffc_txpwdnb_0       = ffc_txpwdnb_0 ;
   assign pcs_ffc_rxpwdnb_0       = ffc_rxpwdnb_0 ;
   assign pcs_ffc_rrst_ch0        = ffc_rrst_ch0 ;
   assign pcs_ffc_pcie_ct_ch0     = ffc_pcie_ct_ch0 ;
   assign pcs_ffc_pcie_det_en_ch0 = ffc_pcie_det_en_ch0 ;
   assign pcs_ffc_fb_loopback_ch0 = ffc_fb_loopback_ch0 ;
   assign pcs_RxPolarity_ch0      = RxPolarity_ch0 ;

   assign pcs_scisel_ch0          = scisel_ch0 ;
   assign pcs_scien_ch0           = scien_ch0 ;

   // Outputs
   assign hdoutp0                 = pcs_hdoutp0 ;
   assign hdoutn0                 = pcs_hdoutn0 ;
   assign RxData_ch0              = pcs_RxData_ch0 ;
   assign RxDataK_ch0             = pcs_RxDataK_ch0 ; 
   assign RxStatus_ch0            = pcs_RxStatus_ch0 ;  
   assign RxValid_ch0             = pcs_RxValid_ch0 ;
   assign RxElecIdle_ch0          = pcs_RxElecIdle_ch0 ;
   assign ffs_rlol_ch0            = pcs_ffs_rlol_ch0 ;
   assign ffs_pcie_done_0         = pcs_ffs_pcie_done_0 ;
   assign ff_rx_fclk_ch0          = pcs_ff_rx_fclk_ch0 ;
   assign ffs_pcie_con_0          = pcs_ffs_pcie_con_0 ;
`else
   // Inputs
   assign pcs_hdinp0              = 'd0 ;
   assign pcs_hdinn0              = 'd0 ;
   assign pcs_TxData_ch0          = 'd0 ;
   assign pcs_TxDataK_ch0         = 'd0 ;
   assign pcs_TxCompliance_ch0    = 'd0 ;
   assign pcs_TxElecIdle_ch0      = 'd0 ;
   assign pcs_ffc_txpwdnb_0       = 'd0 ;
   assign pcs_ffc_rxpwdnb_0       = 'd0 ;
   assign pcs_ffc_rrst_ch0        = 'd0 ;
   assign pcs_ffc_pcie_ct_ch0     = 'd0 ;
   assign pcs_ffc_pcie_det_en_ch0 = 'd0 ;
   assign pcs_ffc_fb_loopback_ch0 = 'd0 ;
   assign pcs_RxPolarity_ch0      = 'd0 ;

   assign pcs_scisel_ch0          = 'd0 ;
   assign pcs_scien_ch0           = 'd0 ;
`endif

// ========================================================
`ifdef Channel_1
   // Inputs
   assign pcs_hdinp1              = hdinp1 ;
   assign pcs_hdinn1              = hdinn1 ;
   assign pcs_TxData_ch1          = TxData_ch1 ;
   assign pcs_TxDataK_ch1         = TxDataK_ch1 ;
   assign pcs_TxCompliance_ch1    = TxCompliance_ch1 ;
   assign pcs_TxElecIdle_ch1      = TxElecIdle_ch1 ;
   assign pcs_ffc_txpwdnb_1       = ffc_txpwdnb_1 ;
   assign pcs_ffc_rxpwdnb_1       = ffc_rxpwdnb_1 ;
   assign pcs_ffc_rrst_ch1        = ffc_rrst_ch1 ;
   assign pcs_ffc_pcie_ct_ch1     = ffc_pcie_ct_ch1 ;
   assign pcs_ffc_pcie_det_en_ch1 = ffc_pcie_det_en_ch1 ;
   assign pcs_ffc_fb_loopback_ch1 = ffc_fb_loopback_ch1 ;
   assign pcs_RxPolarity_ch1      = RxPolarity_ch1 ;

   assign pcs_scisel_ch1          = scisel_ch1 ;
   assign pcs_scien_ch1           = scien_ch1 ;

   // Outputs
   assign hdoutp1                 = pcs_hdoutp1 ;
   assign hdoutn1                 = pcs_hdoutn1 ;
   assign RxData_ch1              = pcs_RxData_ch1 ;
   assign RxDataK_ch1             = pcs_RxDataK_ch1 ; 
   assign RxStatus_ch1            = pcs_RxStatus_ch1 ;  
   assign RxValid_ch1             = pcs_RxValid_ch1 ;
   assign RxElecIdle_ch1          = pcs_RxElecIdle_ch1 ;
   assign ffs_rlol_ch1            = pcs_ffs_rlol_ch1 ;
   assign ffs_pcie_done_1         = pcs_ffs_pcie_done_1 ;
   assign ff_rx_fclk_ch1          = pcs_ff_rx_fclk_ch1 ;
   assign ffs_pcie_con_1          = pcs_ffs_pcie_con_1 ;
`else
   // Inputs
   assign pcs_hdinp1              = 'd0 ;
   assign pcs_hdinn1              = 'd0 ;
   assign pcs_TxData_ch1          = 'd0 ;
   assign pcs_TxDataK_ch1         = 'd0 ;
   assign pcs_TxCompliance_ch1    = 'd0 ;
   assign pcs_TxElecIdle_ch1      = 'd0 ;
   assign pcs_ffc_txpwdnb_1       = 'd0 ;
   assign pcs_ffc_rxpwdnb_1       = 'd0 ;
   assign pcs_ffc_rrst_ch1        = 'd0 ;
   assign pcs_ffc_pcie_ct_ch1     = 'd0 ;
   assign pcs_ffc_pcie_det_en_ch1 = 'd0 ;
   assign pcs_ffc_fb_loopback_ch1 = 'd0 ;
   assign pcs_RxPolarity_ch1      = 'd0 ;

   assign pcs_scisel_ch1          = 'd0 ;
   assign pcs_scien_ch1           = 'd0 ;
`endif

// ========================================================
`ifdef Channel_2
   // Inputs
   assign pcs_hdinp2              = hdinp2 ;
   assign pcs_hdinn2              = hdinn2 ;
   assign pcs_TxData_ch2          = TxData_ch2 ;
   assign pcs_TxDataK_ch2         = TxDataK_ch2 ;
   assign pcs_TxCompliance_ch2    = TxCompliance_ch2 ;
   assign pcs_TxElecIdle_ch2      = TxElecIdle_ch2 ;
   assign pcs_ffc_txpwdnb_2       = ffc_txpwdnb_2 ;
   assign pcs_ffc_rxpwdnb_2       = ffc_rxpwdnb_2 ;
   assign pcs_ffc_rrst_ch2        = ffc_rrst_ch2 ;
   assign pcs_ffc_pcie_ct_ch2     = ffc_pcie_ct_ch2 ;
   assign pcs_ffc_pcie_det_en_ch2 = ffc_pcie_det_en_ch2 ;
   assign pcs_ffc_fb_loopback_ch2 = ffc_fb_loopback_ch2 ;
   assign pcs_RxPolarity_ch2      = RxPolarity_ch2 ;

   assign pcs_scisel_ch2          = scisel_ch2 ;
   assign pcs_scien_ch2           = scien_ch2 ;

   // Outputs
   assign hdoutp2                 = pcs_hdoutp2 ;
   assign hdoutn2                 = pcs_hdoutn2 ;
   assign RxData_ch2              = pcs_RxData_ch2 ;
   assign RxDataK_ch2             = pcs_RxDataK_ch2 ; 
   assign RxStatus_ch2            = pcs_RxStatus_ch2 ;  
   assign RxValid_ch2             = pcs_RxValid_ch2 ;
   assign RxElecIdle_ch2          = pcs_RxElecIdle_ch2 ;
   assign ffs_rlol_ch2            = pcs_ffs_rlol_ch2 ;
   assign ffs_pcie_done_2         = pcs_ffs_pcie_done_2 ;
   assign ff_rx_fclk_ch2          = pcs_ff_rx_fclk_ch2 ;
   assign ffs_pcie_con_2          = pcs_ffs_pcie_con_2 ;
`else
   // Inputs
   assign pcs_hdinp2              = 'd0 ;
   assign pcs_hdinn2              = 'd0 ;
   assign pcs_TxData_ch2          = 'd0 ;
   assign pcs_TxDataK_ch2         = 'd0 ;
   assign pcs_TxCompliance_ch2    = 'd0 ;
   assign pcs_TxElecIdle_ch2      = 'd0 ;
   assign pcs_ffc_txpwdnb_2       = 'd0 ;
   assign pcs_ffc_rxpwdnb_2       = 'd0 ;
   assign pcs_ffc_rrst_ch2        = 'd0 ;
   assign pcs_ffc_pcie_ct_ch2     = 'd0 ;
   assign pcs_ffc_pcie_det_en_ch2 = 'd0 ;
   assign pcs_ffc_fb_loopback_ch2 = 'd0 ;
   assign pcs_RxPolarity_ch2      = 'd0 ;

   assign pcs_scisel_ch2          = 'd0 ;
   assign pcs_scien_ch2           = 'd0 ;
`endif

// ========================================================
`ifdef Channel_3
   // Inputs
   assign pcs_hdinp3              = hdinp3 ;
   assign pcs_hdinn3              = hdinn3 ;
   assign pcs_TxData_ch3          = TxData_ch3 ;
   assign pcs_TxDataK_ch3         = TxDataK_ch3 ;
   assign pcs_TxCompliance_ch3    = TxCompliance_ch3 ;
   assign pcs_TxElecIdle_ch3      = TxElecIdle_ch3 ;
   assign pcs_ffc_txpwdnb_3       = ffc_txpwdnb_3 ;
   assign pcs_ffc_rxpwdnb_3       = ffc_rxpwdnb_3 ;
   assign pcs_ffc_rrst_ch3        = ffc_rrst_ch3 ;
   assign pcs_ffc_pcie_ct_ch3     = ffc_pcie_ct_ch3 ;
   assign pcs_ffc_pcie_det_en_ch3 = ffc_pcie_det_en_ch3 ;
   assign pcs_ffc_fb_loopback_ch3 = ffc_fb_loopback_ch3 ;
   assign pcs_RxPolarity_ch3      = RxPolarity_ch3 ;

   assign pcs_scisel_ch3          = scisel_ch3 ;
   assign pcs_scien_ch3           = scien_ch3 ;

   // Outputs
   assign hdoutp3                 = pcs_hdoutp3 ;
   assign hdoutn3                 = pcs_hdoutn3 ;
   assign RxData_ch3              = pcs_RxData_ch3 ;
   assign RxDataK_ch3             = pcs_RxDataK_ch3 ; 
   assign RxStatus_ch3            = pcs_RxStatus_ch3 ;  
   assign RxValid_ch3             = pcs_RxValid_ch3 ;
   assign RxElecIdle_ch3          = pcs_RxElecIdle_ch3 ;
   assign ffs_rlol_ch3            = pcs_ffs_rlol_ch3 ;
   assign ffs_pcie_done_3         = pcs_ffs_pcie_done_3 ;
   assign ff_rx_fclk_ch3          = pcs_ff_rx_fclk_ch3 ;
   assign ffs_pcie_con_3          = pcs_ffs_pcie_con_3 ;
`else
   // Inputs
   assign pcs_hdinp3              = 'd0 ;
   assign pcs_hdinn3              = 'd0 ;
   assign pcs_TxData_ch3          = 'd0 ;
   assign pcs_TxDataK_ch3         = 'd0 ;
   assign pcs_TxCompliance_ch3    = 'd0 ;
   assign pcs_TxElecIdle_ch3      = 'd0 ;
   assign pcs_ffc_txpwdnb_3       = 'd0 ;
   assign pcs_ffc_rxpwdnb_3       = 'd0 ;
   assign pcs_ffc_rrst_ch3        = 'd0 ;
   assign pcs_ffc_pcie_ct_ch3     = 'd0 ;
   assign pcs_ffc_pcie_det_en_ch3 = 'd0 ;
   assign pcs_ffc_fb_loopback_ch3 = 'd0 ;
   assign pcs_RxPolarity_ch3      = 'd0 ;

   assign pcs_scisel_ch3          = 'd0 ;
   assign pcs_scien_ch3           = 'd0 ;
`endif
// =============================================================================
// PCS instantiation
// =============================================================================
`ifdef ECP3
   `define PCS_CD PCSD
`else
   `define PCS_CD PCSC
`endif
`PCS_CD pcs_inst_0 (
 .REFCLKP               ( pcs_refclkp ),
 .REFCLKN               ( pcs_refclkn ), 
 .FFC_CK_CORE_TX        ( 1'b0 ),

//CH0
 .HDINP0                ( pcs_hdinp0 ),
 .HDINN0                ( pcs_hdinn0 ),
 .HDOUTP0               ( pcs_hdoutp0 ),
 .HDOUTN0               ( pcs_hdoutn0 ),
 `ifdef ECP3
    .PCIE_TXDETRX_PR2TLB_0 ( 1'b0 ),
    .PCIE_TXCOMPLIANCE_0   ( 1'b0 ),
    .PCIE_RXPOLARITY_0     ( 1'b0 ),
    .PCIE_POWERDOWN_0_0    ( 1'b0 ),
    .PCIE_POWERDOWN_0_1    ( 1'b0 ),
    .PCIE_RXVALID_0        ( ),
    .PCIE_PHYSTATUS_0      ( ),
    .FF_TX_F_CLK_0         ( pcs_ff_tx_f_clk_0 ),
    .FF_TX_H_CLK_0         ( pcs_ff_tx_h_clk_0 ),
    .FFC_CK_CORE_RX_0      ( 1'b0 ),
    .FFS_RLOS_HI_0         ( ),
    .FFS_SKP_ADDED_0       ( ),
    .FFS_SKP_DELETED_0     ( ),
    .LDR_CORE2TX_0         ( 1'b0 ),
    .FFC_LDR_CORE2TX_EN_0  ( 1'b0 ),
    .LDR_RX2CORE_0         ( ),
    .FFS_CDR_TRAIN_DONE_0  ( ),
    .FFC_DIV11_MODE_TX_0   ( 1'b0 ),
    .FFC_RATE_MODE_TX_0    ( 1'b0 ),
    .FFC_DIV11_MODE_RX_0   ( 1'b0 ),
    .FFC_RATE_MODE_RX_0    ( 1'b0 ),
 `else
    .FF_RX_Q_CLK_0         ( ),
    .OOB_OUT_0             ( ),
 `endif
 .SCISELCH0             ( pcs_scisel_ch0 ),
 .SCIENCH0              ( pcs_scien_ch0 ),
 .FF_TXI_CLK_0          ( pcs_PCLK ),
 `ifdef X4
    .FF_RXI_CLK_0       ( pcs_ff_rx_fclk_ch0 ),
    .FF_EBRD_CLK_0      ( 1'b0 ), 
 `else
    .FF_RXI_CLK_0       ( pcs_PCLK ),
    .FF_EBRD_CLK_0      ( pcs_PCLK ),
 `endif
 .FF_RX_F_CLK_0         ( pcs_ff_rx_fclk_ch0 ),
 .FF_RX_H_CLK_0         ( ),
 .FF_TX_D_0_0           ( pcs_TxData_ch0[0] ),
 .FF_TX_D_0_1           ( pcs_TxData_ch0[1] ),
 .FF_TX_D_0_2           ( pcs_TxData_ch0[2] ),
 .FF_TX_D_0_3           ( pcs_TxData_ch0[3] ),
 .FF_TX_D_0_4           ( pcs_TxData_ch0[4] ),
 .FF_TX_D_0_5           ( pcs_TxData_ch0[5] ),
 .FF_TX_D_0_6           ( pcs_TxData_ch0[6] ),
 .FF_TX_D_0_7           ( pcs_TxData_ch0[7] ),
 .FF_TX_D_0_8           ( pcs_TxDataK_ch0 ),
 .FF_TX_D_0_9           ( pcs_TxCompliance_ch0 ),
 .FF_TX_D_0_10          ( 1'b0 ),
 .FF_TX_D_0_11          ( pcs_TxElecIdle_ch0 ),
 .FF_TX_D_0_12          ( 1'b0 ),
 .FF_TX_D_0_13          ( 1'b0 ),
 .FF_TX_D_0_14          ( 1'b0 ),
 .FF_TX_D_0_15          ( 1'b0 ),
 .FF_TX_D_0_16          ( 1'b0 ),
 .FF_TX_D_0_17          ( 1'b0 ),
 .FF_TX_D_0_18          ( 1'b0 ),
 .FF_TX_D_0_19          ( 1'b0 ),
 .FF_TX_D_0_20          ( 1'b0 ),
 .FF_TX_D_0_21          ( 1'b0 ),
 .FF_TX_D_0_22          ( 1'b0 ),
 .FF_TX_D_0_23          ( 1'b0 ),
 .FF_RX_D_0_0           ( pcs_RxData_ch0[0] ),
 .FF_RX_D_0_1           ( pcs_RxData_ch0[1] ),
 .FF_RX_D_0_2           ( pcs_RxData_ch0[2] ),
 .FF_RX_D_0_3           ( pcs_RxData_ch0[3] ),
 .FF_RX_D_0_4           ( pcs_RxData_ch0[4] ),
 .FF_RX_D_0_5           ( pcs_RxData_ch0[5] ),
 .FF_RX_D_0_6           ( pcs_RxData_ch0[6] ),
 .FF_RX_D_0_7           ( pcs_RxData_ch0[7] ),
 .FF_RX_D_0_8           ( pcs_RxDataK_ch0 ),
 .FF_RX_D_0_9           ( pcs_RxStatus_ch0[0] ),
 .FF_RX_D_0_10          ( pcs_RxStatus_ch0[1] ),
 .FF_RX_D_0_11          ( pcs_RxStatus_ch0[2] ),
 .FF_RX_D_0_12          ( ), 
 .FF_RX_D_0_13          ( ), 
 .FF_RX_D_0_14          ( ), 
 .FF_RX_D_0_15          ( ), 
 .FF_RX_D_0_16          ( ), 
 .FF_RX_D_0_17          ( ), 
 .FF_RX_D_0_18          ( ), 
 .FF_RX_D_0_19          ( ), 
 .FF_RX_D_0_20          ( ),
 .FF_RX_D_0_21          ( ),
 .FF_RX_D_0_22          ( ),
 .FF_RX_D_0_23          ( ),
 .FFC_RRST_0            ( pcs_ffc_rrst_ch0 ),
 .FFC_SIGNAL_DETECT_0   ( pcs_ffc_signal_detect ),
 .FFC_ENABLE_CGALIGN_0  ( pcs_ffc_enb_cgalign ),
 .FFC_SB_PFIFO_LP_0     ( 1'b0 ),
 .FFC_PFIFO_CLR_0       ( 1'b0 ),
 .FFC_FB_LOOPBACK_0     ( pcs_ffc_fb_loopback_ch0),
 .FFC_SB_INV_RX_0       ( pcs_RxPolarity_ch0 ),
 .FFC_PCIE_CT_0	        ( pcs_ffc_pcie_ct_ch0 ),
 .FFC_PCI_DET_EN_0      ( pcs_ffc_pcie_det_en_ch0 ),
 .FFS_PCIE_DONE_0       ( pcs_ffs_pcie_done_0 ),
 .FFS_PCIE_CON_0        ( pcs_ffs_pcie_con_0 ),
 .FFC_EI_EN_0           ( 1'b0 ),
 .FFC_LANE_TX_RST_0     ( pcs_ffc_lane_tx_rst ),
 .FFC_LANE_RX_RST_0     ( pcs_ffc_lane_rx_rst ),
 .FFC_TXPWDNB_0         ( pcs_ffc_txpwdnb_0 ),
 .FFC_RXPWDNB_0         ( pcs_ffc_rxpwdnb_0 ),
 .FFS_RLOS_LO_0         ( pcs_RxElecIdle_ch0 ),
 .FFS_LS_SYNC_STATUS_0  ( pcs_RxValid_ch0 ),
 .FFS_CC_UNDERRUN_0     ( ),
 .FFS_CC_OVERRUN_0      ( ),
 .FFS_RXFBFIFO_ERROR_0  ( ),
 .FFS_TXFBFIFO_ERROR_0  ( ),
 .FFS_RLOL_0            ( pcs_ffs_rlol_ch0 ),

//CH1
 .HDINP1                ( pcs_hdinp1 ),
 .HDINN1                ( pcs_hdinn1 ),
 .HDOUTP1               ( pcs_hdoutp1 ),
 .HDOUTN1               ( pcs_hdoutn1 ),
 `ifdef ECP3
    .PCIE_TXDETRX_PR2TLB_1 ( 1'b0 ),
    .PCIE_TXCOMPLIANCE_1   ( 1'b0 ),
    .PCIE_RXPOLARITY_1     ( 1'b0 ),
    .PCIE_POWERDOWN_1_0    ( 1'b0 ),
    .PCIE_POWERDOWN_1_1    ( 1'b0 ),
    .PCIE_RXVALID_1        ( ),
    .PCIE_PHYSTATUS_1      ( ),
    .FF_TX_F_CLK_1         ( pcs_ff_tx_f_clk_1 ),
    .FF_TX_H_CLK_1         ( pcs_ff_tx_h_clk_1 ),
    .FFC_CK_CORE_RX_1      ( 1'b0 ),
    .FFS_RLOS_HI_1         ( ),
    .FFS_SKP_ADDED_1       ( ),
    .FFS_SKP_DELETED_1     ( ),
    .LDR_CORE2TX_1         ( 1'b0 ),
    .FFC_LDR_CORE2TX_EN_1  ( 1'b0 ),
    .LDR_RX2CORE_1         ( ),
    .FFS_CDR_TRAIN_DONE_1  ( ),
    .FFC_DIV11_MODE_TX_1   ( 1'b0 ),
    .FFC_RATE_MODE_TX_1    ( 1'b0 ),
    .FFC_DIV11_MODE_RX_1   ( 1'b0 ),
    .FFC_RATE_MODE_RX_1    ( 1'b0 ),
 `else
    .FF_RX_Q_CLK_1         ( ),
    .OOB_OUT_1             ( ),
 `endif
 .SCISELCH1             ( pcs_scisel_ch1 ),
 .SCIENCH1              ( pcs_scien_ch1 ),
 .FF_TXI_CLK_1          ( pcs_PCLK ),
 `ifdef X4
    .FF_RXI_CLK_1       ( pcs_ff_rx_fclk_ch1 ),
    .FF_EBRD_CLK_1      ( 1'b0 ), 
 `else
    .FF_RXI_CLK_1       ( pcs_PCLK ),
    .FF_EBRD_CLK_1      ( pcs_PCLK ),
 `endif
 .FF_RX_F_CLK_1         ( pcs_ff_rx_fclk_ch1 ),
 .FF_RX_H_CLK_1         ( ),
 .FF_TX_D_1_0           ( pcs_TxData_ch1[0] ),
 .FF_TX_D_1_1           ( pcs_TxData_ch1[1] ),
 .FF_TX_D_1_2           ( pcs_TxData_ch1[2] ),
 .FF_TX_D_1_3           ( pcs_TxData_ch1[3] ),
 .FF_TX_D_1_4           ( pcs_TxData_ch1[4] ),
 .FF_TX_D_1_5           ( pcs_TxData_ch1[5] ),
 .FF_TX_D_1_6           ( pcs_TxData_ch1[6] ),
 .FF_TX_D_1_7           ( pcs_TxData_ch1[7] ),
 .FF_TX_D_1_8           ( pcs_TxDataK_ch1 ),
 .FF_TX_D_1_9           ( pcs_TxCompliance_ch1 ),
 .FF_TX_D_1_10          ( 1'b0 ),
 .FF_TX_D_1_11          ( pcs_TxElecIdle_ch1 ),
 .FF_TX_D_1_12          ( 1'b0 ),
 .FF_TX_D_1_13          ( 1'b0 ),
 .FF_TX_D_1_14          ( 1'b0 ),
 .FF_TX_D_1_15          ( 1'b0 ),
 .FF_TX_D_1_16          ( 1'b0 ),
 .FF_TX_D_1_17          ( 1'b0 ),
 .FF_TX_D_1_18          ( 1'b0 ),
 .FF_TX_D_1_19          ( 1'b0 ),
 .FF_TX_D_1_20          ( 1'b0 ),
 .FF_TX_D_1_21          ( 1'b0 ),
 .FF_TX_D_1_22          ( 1'b0 ),
 .FF_TX_D_1_23          ( 1'b0 ),
 .FF_RX_D_1_0           ( pcs_RxData_ch1[0] ),
 .FF_RX_D_1_1           ( pcs_RxData_ch1[1] ),
 .FF_RX_D_1_2           ( pcs_RxData_ch1[2] ),
 .FF_RX_D_1_3           ( pcs_RxData_ch1[3] ),
 .FF_RX_D_1_4           ( pcs_RxData_ch1[4] ),
 .FF_RX_D_1_5           ( pcs_RxData_ch1[5] ),
 .FF_RX_D_1_6           ( pcs_RxData_ch1[6] ),
 .FF_RX_D_1_7           ( pcs_RxData_ch1[7] ),
 .FF_RX_D_1_8           ( pcs_RxDataK_ch1 ),
 .FF_RX_D_1_9           ( pcs_RxStatus_ch1[0] ),
 .FF_RX_D_1_10          ( pcs_RxStatus_ch1[1] ),
 .FF_RX_D_1_11          ( pcs_RxStatus_ch1[2] ),
 .FF_RX_D_1_12          ( ),
 .FF_RX_D_1_13          ( ), 
 .FF_RX_D_1_14          ( ), 
 .FF_RX_D_1_15          ( ), 
 .FF_RX_D_1_16          ( ), 
 .FF_RX_D_1_17          ( ), 
 .FF_RX_D_1_18          ( ), 
 .FF_RX_D_1_19          ( ), 
 .FF_RX_D_1_20          ( ),
 .FF_RX_D_1_21          ( ),
 .FF_RX_D_1_22          ( ),
 .FF_RX_D_1_23          ( ),
 .FFC_RRST_1            ( pcs_ffc_rrst_ch1 ),
 .FFC_SIGNAL_DETECT_1   ( pcs_ffc_signal_detect ),
 .FFC_ENABLE_CGALIGN_1  ( pcs_ffc_enb_cgalign ),
 .FFC_SB_PFIFO_LP_1     ( 1'b0 ),
 .FFC_PFIFO_CLR_1       ( 1'b0 ),
 .FFC_FB_LOOPBACK_1     ( pcs_ffc_fb_loopback_ch1 ),
 .FFC_SB_INV_RX_1       ( pcs_RxPolarity_ch1 ),
 .FFC_PCIE_CT_1         ( pcs_ffc_pcie_ct_ch1 ),
 .FFC_PCI_DET_EN_1      ( pcs_ffc_pcie_det_en_ch1 ),
 .FFS_PCIE_DONE_1       ( pcs_ffs_pcie_done_1 ),
 .FFS_PCIE_CON_1        ( pcs_ffs_pcie_con_1 ),
 .FFC_EI_EN_1           ( 1'b0 ),
 .FFC_LANE_TX_RST_1     ( pcs_ffc_lane_tx_rst ),
 .FFC_LANE_RX_RST_1     ( pcs_ffc_lane_rx_rst ),
 .FFC_TXPWDNB_1         ( pcs_ffc_txpwdnb_1 ),
 .FFC_RXPWDNB_1         ( pcs_ffc_rxpwdnb_1 ),
 .FFS_RLOS_LO_1         ( pcs_RxElecIdle_ch1 ),
 .FFS_LS_SYNC_STATUS_1  ( pcs_RxValid_ch1 ),
 .FFS_CC_UNDERRUN_1     ( ),
 .FFS_CC_OVERRUN_1      ( ),
 .FFS_RXFBFIFO_ERROR_1  ( ),
 .FFS_TXFBFIFO_ERROR_1  ( ),
 .FFS_RLOL_1            ( pcs_ffs_rlol_ch1 ),

//CH2
 .HDINP2                ( pcs_hdinp2 ),
 .HDINN2                ( pcs_hdinn2 ),
 .HDOUTP2               ( pcs_hdoutp2 ),
 .HDOUTN2               ( pcs_hdoutn2 ),
 `ifdef ECP3
    .PCIE_TXDETRX_PR2TLB_2 ( 1'b0 ),
    .PCIE_TXCOMPLIANCE_2   ( 1'b0 ),
    .PCIE_RXPOLARITY_2     ( 1'b0 ),
    .PCIE_POWERDOWN_2_0    ( 1'b0 ),
    .PCIE_POWERDOWN_2_1    ( 1'b0 ),
    .PCIE_RXVALID_2        ( ),
    .PCIE_PHYSTATUS_2      ( ),
    .FF_TX_F_CLK_2         ( pcs_ff_tx_f_clk_2 ),
    .FF_TX_H_CLK_2         ( pcs_ff_tx_h_clk_2 ),
    .FFC_CK_CORE_RX_2      ( 1'b0 ),
    .FFS_RLOS_HI_2         ( ),
    .FFS_SKP_ADDED_2       ( ),
    .FFS_SKP_DELETED_2     ( ),
    .LDR_CORE2TX_2         ( 1'b0 ),
    .FFC_LDR_CORE2TX_EN_2  ( 1'b0 ),
    .LDR_RX2CORE_2         ( ),
    .FFS_CDR_TRAIN_DONE_2  ( ),
    .FFC_DIV11_MODE_TX_2   ( 1'b0 ),
    .FFC_RATE_MODE_TX_2    ( 1'b0 ),
    .FFC_DIV11_MODE_RX_2   ( 1'b0 ),
    .FFC_RATE_MODE_RX_2    ( 1'b0 ),
 `else
    .FF_RX_Q_CLK_2         ( ),
    .OOB_OUT_2             ( ),
 `endif
 .SCISELCH2             ( pcs_scisel_ch2 ),
 .SCIENCH2              ( pcs_scien_ch2 ),
 .FF_TXI_CLK_2          ( pcs_PCLK ),
 `ifdef X4
    .FF_RXI_CLK_2       ( pcs_ff_rx_fclk_ch2 ),
    .FF_EBRD_CLK_2      ( 1'b0 ), 
 `else
    .FF_RXI_CLK_2       ( pcs_PCLK ),
    .FF_EBRD_CLK_2      ( pcs_PCLK ),
 `endif
 .FF_RX_F_CLK_2         ( pcs_ff_rx_fclk_ch2 ),
 .FF_RX_H_CLK_2         ( ),
 .FF_TX_D_2_0           ( pcs_TxData_ch2[0] ),
 .FF_TX_D_2_1           ( pcs_TxData_ch2[1] ),
 .FF_TX_D_2_2           ( pcs_TxData_ch2[2] ),
 .FF_TX_D_2_3           ( pcs_TxData_ch2[3] ),
 .FF_TX_D_2_4           ( pcs_TxData_ch2[4] ),
 .FF_TX_D_2_5           ( pcs_TxData_ch2[5] ),
 .FF_TX_D_2_6           ( pcs_TxData_ch2[6] ),
 .FF_TX_D_2_7           ( pcs_TxData_ch2[7] ),
 .FF_TX_D_2_8           ( pcs_TxDataK_ch2 ),
 .FF_TX_D_2_9           ( pcs_TxCompliance_ch2 ),
 .FF_TX_D_2_10          ( 1'b0 ),
 .FF_TX_D_2_11          ( pcs_TxElecIdle_ch2 ),
 .FF_TX_D_2_12          ( 1'b0 ),
 .FF_TX_D_2_13          ( 1'b0 ),
 .FF_TX_D_2_14          ( 1'b0 ),
 .FF_TX_D_2_15          ( 1'b0 ),
 .FF_TX_D_2_16          ( 1'b0 ),
 .FF_TX_D_2_17          ( 1'b0 ),
 .FF_TX_D_2_18          ( 1'b0 ),
 .FF_TX_D_2_19          ( 1'b0 ),
 .FF_TX_D_2_20          ( 1'b0 ),
 .FF_TX_D_2_21          ( 1'b0 ),
 .FF_TX_D_2_22          ( 1'b0 ),
 .FF_TX_D_2_23          ( 1'b0 ),
 .FF_RX_D_2_0           ( pcs_RxData_ch2[0] ),
 .FF_RX_D_2_1           ( pcs_RxData_ch2[1] ),
 .FF_RX_D_2_2           ( pcs_RxData_ch2[2] ),
 .FF_RX_D_2_3           ( pcs_RxData_ch2[3] ),
 .FF_RX_D_2_4           ( pcs_RxData_ch2[4] ),
 .FF_RX_D_2_5           ( pcs_RxData_ch2[5] ),
 .FF_RX_D_2_6           ( pcs_RxData_ch2[6] ),
 .FF_RX_D_2_7           ( pcs_RxData_ch2[7] ),
 .FF_RX_D_2_8           ( pcs_RxDataK_ch2 ),
 .FF_RX_D_2_9           ( pcs_RxStatus_ch2[0] ),
 .FF_RX_D_2_10          ( pcs_RxStatus_ch2[1] ),
 .FF_RX_D_2_11          ( pcs_RxStatus_ch2[2] ),
 .FF_RX_D_2_12          ( ),
 .FF_RX_D_2_13          ( ),
 .FF_RX_D_2_14          ( ), 
 .FF_RX_D_2_15          ( ), 
 .FF_RX_D_2_16          ( ), 
 .FF_RX_D_2_17          ( ), 
 .FF_RX_D_2_18          ( ), 
 .FF_RX_D_2_19          ( ), 
 .FF_RX_D_2_20          ( ),
 .FF_RX_D_2_21          ( ),
 .FF_RX_D_2_22          ( ),
 .FF_RX_D_2_23          ( ),
 .FFC_RRST_2            ( pcs_ffc_rrst_ch2 ),
 .FFC_SIGNAL_DETECT_2   ( pcs_ffc_signal_detect ),
 .FFC_ENABLE_CGALIGN_2  ( pcs_ffc_enb_cgalign ),
 .FFC_SB_PFIFO_LP_2     ( 1'b0 ),
 .FFC_PFIFO_CLR_2       ( 1'b0 ),
 .FFC_FB_LOOPBACK_2     ( pcs_ffc_fb_loopback_ch2 ),
 .FFC_SB_INV_RX_2       ( pcs_RxPolarity_ch2 ),
 .FFC_PCIE_CT_2         ( pcs_ffc_pcie_ct_ch2 ),
 .FFC_PCI_DET_EN_2      ( pcs_ffc_pcie_det_en_ch2 ),
 .FFS_PCIE_DONE_2       ( pcs_ffs_pcie_done_2 ),
 .FFS_PCIE_CON_2        ( pcs_ffs_pcie_con_2 ),
 .FFC_EI_EN_2           ( 1'b0 ),
 .FFC_LANE_TX_RST_2     ( pcs_ffc_lane_tx_rst ),
 .FFC_LANE_RX_RST_2     ( pcs_ffc_lane_rx_rst ),
 .FFC_TXPWDNB_2         ( pcs_ffc_txpwdnb_2 ),
 .FFC_RXPWDNB_2         ( pcs_ffc_rxpwdnb_2 ),
 .FFS_RLOS_LO_2         ( pcs_RxElecIdle_ch2 ),
 .FFS_LS_SYNC_STATUS_2  ( pcs_RxValid_ch2 ),
 .FFS_CC_UNDERRUN_2     ( ),
 .FFS_CC_OVERRUN_2      ( ),
 .FFS_RXFBFIFO_ERROR_2  ( ),
 .FFS_TXFBFIFO_ERROR_2  ( ),
 .FFS_RLOL_2            ( pcs_ffs_rlol_ch2 ),

//CH3
 .HDINP3                ( pcs_hdinp3 ),
 .HDINN3                ( pcs_hdinn3 ),
 .HDOUTP3               ( pcs_hdoutp3 ),
 .HDOUTN3               ( pcs_hdoutn3 ),
 `ifdef ECP3
    .PCIE_TXDETRX_PR2TLB_3 ( 1'b0 ),
    .PCIE_TXCOMPLIANCE_3   ( 1'b0 ),
    .PCIE_RXPOLARITY_3     ( 1'b0 ),
    .PCIE_POWERDOWN_3_0    ( 1'b0 ),
    .PCIE_POWERDOWN_3_1    ( 1'b0 ),
    .PCIE_RXVALID_3        ( ),
    .PCIE_PHYSTATUS_3      ( ),
    .FF_TX_F_CLK_3         ( pcs_ff_tx_f_clk_3 ),
    .FF_TX_H_CLK_3         ( pcs_ff_tx_h_clk_3 ),
    .FFC_CK_CORE_RX_3      ( 1'b0 ),
    .FFS_RLOS_HI_3         ( ),
    .FFS_SKP_ADDED_3       ( ),
    .FFS_SKP_DELETED_3     ( ),
    .LDR_CORE2TX_3         ( 1'b0 ),
    .FFC_LDR_CORE2TX_EN_3  ( 1'b0 ),
    .LDR_RX2CORE_3         ( ),
    .FFS_CDR_TRAIN_DONE_3  ( ),
    .FFC_DIV11_MODE_TX_3   ( 1'b0 ),
    .FFC_RATE_MODE_TX_3    ( 1'b0 ),
    .FFC_DIV11_MODE_RX_3   ( 1'b0 ),
    .FFC_RATE_MODE_RX_3    ( 1'b0 ),
 `else
    .FF_RX_Q_CLK_3         ( ),
    .OOB_OUT_3             ( ),
 `endif
 .SCISELCH3             ( pcs_scisel_ch3 ),
 .SCIENCH3              ( pcs_scien_ch3 ),
 .FF_TXI_CLK_3          ( pcs_PCLK ),
 `ifdef X4
    .FF_RXI_CLK_3       ( pcs_ff_rx_fclk_ch3 ),
    .FF_EBRD_CLK_3      ( 1'b0 ), 
 `else
    .FF_RXI_CLK_3       ( pcs_PCLK ),
    .FF_EBRD_CLK_3      ( pcs_PCLK ),
 `endif
 .FF_RX_F_CLK_3         ( pcs_ff_rx_fclk_ch3 ),
 .FF_RX_H_CLK_3         ( ),
 .FF_TX_D_3_0           ( pcs_TxData_ch3[0] ),
 .FF_TX_D_3_1           ( pcs_TxData_ch3[1] ),
 .FF_TX_D_3_2           ( pcs_TxData_ch3[2] ),
 .FF_TX_D_3_3           ( pcs_TxData_ch3[3] ),
 .FF_TX_D_3_4           ( pcs_TxData_ch3[4] ),
 .FF_TX_D_3_5           ( pcs_TxData_ch3[5] ),
 .FF_TX_D_3_6           ( pcs_TxData_ch3[6] ),
 .FF_TX_D_3_7           ( pcs_TxData_ch3[7] ),
 .FF_TX_D_3_8           ( pcs_TxDataK_ch3 ),
 .FF_TX_D_3_9           ( pcs_TxCompliance_ch3 ),
 .FF_TX_D_3_10          ( 1'b0 ),
 .FF_TX_D_3_11          ( pcs_TxElecIdle_ch3 ),
 .FF_TX_D_3_12          ( 1'b0 ),
 .FF_TX_D_3_13          ( 1'b0 ),
 .FF_TX_D_3_14          ( 1'b0 ),
 .FF_TX_D_3_15          ( 1'b0 ),
 .FF_TX_D_3_16          ( 1'b0 ),
 .FF_TX_D_3_17          ( 1'b0 ),
 .FF_TX_D_3_18          ( 1'b0 ),
 .FF_TX_D_3_19          ( 1'b0 ),
 .FF_TX_D_3_20          ( 1'b0 ),
 .FF_TX_D_3_21          ( 1'b0 ),
 .FF_TX_D_3_22          ( 1'b0 ),
 .FF_TX_D_3_23          ( 1'b0 ), 
 .FF_RX_D_3_0           ( pcs_RxData_ch3[0] ),
 .FF_RX_D_3_1           ( pcs_RxData_ch3[1] ),
 .FF_RX_D_3_2           ( pcs_RxData_ch3[2] ),
 .FF_RX_D_3_3           ( pcs_RxData_ch3[3] ),
 .FF_RX_D_3_4           ( pcs_RxData_ch3[4] ),
 .FF_RX_D_3_5           ( pcs_RxData_ch3[5] ),
 .FF_RX_D_3_6           ( pcs_RxData_ch3[6] ),
 .FF_RX_D_3_7           ( pcs_RxData_ch3[7] ),
 .FF_RX_D_3_8           ( pcs_RxDataK_ch3 ),
 .FF_RX_D_3_9           ( pcs_RxStatus_ch3[0] ),
 .FF_RX_D_3_10          ( pcs_RxStatus_ch3[1] ),
 .FF_RX_D_3_11          ( pcs_RxStatus_ch3[2] ),
 .FF_RX_D_3_12          ( ), 
 .FF_RX_D_3_13          ( ), 
 .FF_RX_D_3_14          ( ), 
 .FF_RX_D_3_15          ( ), 
 .FF_RX_D_3_16          ( ), 
 .FF_RX_D_3_17          ( ), 
 .FF_RX_D_3_18          ( ), 
 .FF_RX_D_3_19          ( ), 
 .FF_RX_D_3_20          ( ),
 .FF_RX_D_3_21          ( ),
 .FF_RX_D_3_22          ( ),
 .FF_RX_D_3_23          ( ),
 .FFC_RRST_3            ( pcs_ffc_rrst_ch3 ),
 .FFC_SIGNAL_DETECT_3   ( pcs_ffc_signal_detect ),
 .FFC_ENABLE_CGALIGN_3  ( pcs_ffc_enb_cgalign ),
 .FFC_SB_PFIFO_LP_3     ( 1'b0 ),
 .FFC_PFIFO_CLR_3       ( 1'b0 ),
 .FFC_FB_LOOPBACK_3     ( pcs_ffc_fb_loopback_ch3 ),
 .FFC_SB_INV_RX_3       ( pcs_RxPolarity_ch3 ),
 .FFC_PCIE_CT_3         ( pcs_ffc_pcie_ct_ch3 ),
 .FFC_PCI_DET_EN_3      ( pcs_ffc_pcie_det_en_ch3 ),
 .FFS_PCIE_DONE_3       ( pcs_ffs_pcie_done_3 ),
 .FFS_PCIE_CON_3        ( pcs_ffs_pcie_con_3 ),
 .FFC_EI_EN_3           ( 1'b0 ),
 .FFC_LANE_TX_RST_3     ( pcs_ffc_lane_tx_rst ),
 .FFC_LANE_RX_RST_3     ( pcs_ffc_lane_rx_rst ),
 .FFC_TXPWDNB_3         ( pcs_ffc_txpwdnb_3 ),
 .FFC_RXPWDNB_3         ( pcs_ffc_rxpwdnb_3 ),
 .FFS_RLOS_LO_3         ( pcs_RxElecIdle_ch3 ),
 .FFS_LS_SYNC_STATUS_3  ( pcs_RxValid_ch3 ),
 .FFS_CC_UNDERRUN_3     ( ),
 .FFS_CC_OVERRUN_3      ( ),
 .FFS_RXFBFIFO_ERROR_3  ( ),
 .FFS_TXFBFIFO_ERROR_3  ( ),
 .FFS_RLOL_3            ( pcs_ffs_rlol_ch3 ),

// SCI PINS
 .SCIWDATA0             ( pcs_sciwritedata[0] ),
 .SCIWDATA1             ( pcs_sciwritedata[1] ),
 .SCIWDATA2             ( pcs_sciwritedata[2] ),
 .SCIWDATA3             ( pcs_sciwritedata[3] ),
 .SCIWDATA4             ( pcs_sciwritedata[4] ),
 .SCIWDATA5             ( pcs_sciwritedata[5] ),
 .SCIWDATA6             ( pcs_sciwritedata[6] ),
 .SCIWDATA7             ( pcs_sciwritedata[7] ),
 .SCIADDR0              ( pcs_sciaddress[0] ),
 .SCIADDR1              ( pcs_sciaddress[1] ),
 .SCIADDR2              ( pcs_sciaddress[2] ),
 .SCIADDR3              ( pcs_sciaddress[3] ),
 .SCIADDR4              ( pcs_sciaddress[4] ),
 .SCIADDR5              ( pcs_sciaddress[5] ),
 .SCIRDATA0             ( pcs_scireaddata[0] ),
 .SCIRDATA1             ( pcs_scireaddata[1] ),
 .SCIRDATA2             ( pcs_scireaddata[2] ),
 .SCIRDATA3             ( pcs_scireaddata[3] ),
 .SCIRDATA4             ( pcs_scireaddata[4] ),
 .SCIRDATA5             ( pcs_scireaddata[5] ),
 .SCIRDATA6             ( pcs_scireaddata[6] ),
 .SCIRDATA7             ( pcs_scireaddata[7] ),
 .SCIENAUX              ( pcs_scienaux ),
 .SCISELAUX             ( pcs_sciselaux ),
 .SCIRD                 ( pcs_scird ),
 .SCIWSTN               ( pcs_sciwstn ),
 .CYAWSTN               ( 1'b0 ),
 .SCIINT                ( ),
 `ifdef ECP3
    .FFC_SYNC_TOGGLE    ( 1'b0 ),
    .REFCLK_FROM_NQ     ( 1'b0 ),
    .REFCLK_TO_NQ       ( ),
 `else
    .FFC_CK_CORE_RX     ( 1'b0 ),
    .FF_TX_F_CLK        ( pcs_ff_tx_f_clk ),
    .FF_TX_H_CLK        ( pcs_ff_tx_h_clk ),
    .FF_TX_Q_CLK        ( ),
 `endif
 .FFC_MACRO_RST         ( pcs_ffc_macro_rst ),
 .FFC_QUAD_RST          ( pcs_ffc_quad_rst ),
 .FFC_TRST              ( pcs_ffc_trst ),
 .REFCK2CORE            ( ),
 .CIN0                  ( pcs_cin[0] ),
 .CIN1                  ( pcs_cin[1] ),
 .CIN2                  ( pcs_cin[2] ),
 .CIN3                  ( pcs_cin[3] ),
 .CIN4                  ( pcs_cin[4] ),
 .CIN5                  ( pcs_cin[5] ),
 .CIN6                  ( pcs_cin[6] ),
 .CIN7                  ( pcs_cin[7] ),
 .CIN8                  ( pcs_cin[8] ),
 .CIN9                  ( pcs_cin[9] ),
 .CIN10                 ( pcs_cin[10] ),
 .CIN11                 ( pcs_cin[11] ),
 .COUT0                 ( pcs_cout[0] ),
 .COUT1                 ( pcs_cout[1] ),
 .COUT2                 ( pcs_cout[2] ),
 .COUT3                 ( pcs_cout[3] ),
 .COUT4                 ( pcs_cout[4] ),
 .COUT5                 ( pcs_cout[5] ),
 .COUT6                 ( pcs_cout[6] ),
 .COUT7                 ( pcs_cout[7] ),
 .COUT8                 ( pcs_cout[8] ),
 .COUT9                 ( pcs_cout[9] ),
 .COUT10                ( pcs_cout[10] ),
 .COUT11                ( pcs_cout[11] ),
 .COUT12                ( pcs_cout[12] ),
 .COUT13                ( pcs_cout[13] ),
 .COUT14                ( pcs_cout[14] ),
 .COUT15                ( pcs_cout[15] ),
 .COUT16                ( pcs_cout[16] ),
 .COUT17                ( pcs_cout[17] ),
 .COUT18                ( pcs_cout[18] ),
 .COUT19                ( pcs_cout[19] ),
 .FFS_PLOL              ( pcs_ffs_plol )
 `ifdef ECP3
    `ifdef X1
       )  /* synthesis IS_ASB="ep5c00/data/ep5c00.acd" CONFIG_FILE="pcs_pipe_8b_x1.txt" */;
    `else
       )  /* synthesis IS_ASB="ep5c00/data/ep5c00.acd" CONFIG_FILE="pcs_pipe_8b_x4.txt" */;
    `endif
 `else
    `ifdef X1
       )  /* synthesis IS_ASB="ep5m00/data/ep5m00.acd" CONFIG_FILE="pcs_pipe_8b_x1.txt" */;
    `else
       )  /* synthesis IS_ASB="ep5m00/data/ep5m00.acd" CONFIG_FILE="pcs_pipe_8b_x4.txt" */;
    `endif
 `endif

// =============================================================================
endmodule


