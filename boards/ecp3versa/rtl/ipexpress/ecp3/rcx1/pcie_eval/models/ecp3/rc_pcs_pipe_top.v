
//`define EXERCISER_DEBUG 
`define NULL 0
`timescale 1ns / 1 ps

module rc_pcs_pipe_top (
   input wire       refclkp,
   input wire       refclkn,
   input wire       RESET_n, 
   input wire       ffc_quad_rst,  
   input wire [1:0] PowerDown,
   input wire       TxDetectRx_Loopback,

   output wire   PCLK,
   `ifdef DataWidth_8
      output wire   PCLK_by_2,
   `endif
   output reg    PhyStatus,
   output wire   ffs_plol,

   `ifdef Channel_0
      input wire             hdinp0, 
      input wire             hdinn0, 
      output wire            hdoutp0,
      output wire            hdoutn0,
   `endif
   `ifdef Channel_1
      input wire             hdinp1, 
      input wire             hdinn1, 
      output wire            hdoutp1,
      output wire            hdoutn1,
   `endif 
   `ifdef Channel_2
      input wire             hdinp2, 
      input wire             hdinn2, 
      output wire            hdoutp2,
      output wire            hdoutn2,
   `endif 
   `ifdef Channel_3
      input wire             hdinp3, 
      input wire             hdinn3, 
      output wire            hdoutp3,
      output wire            hdoutn3,
   `endif 

   input wire [`DataWidth-1:0]  TxData_0,
   input wire [`BusWidth-1:0]   TxDataK_0,  
   input wire                   TxCompliance_0,
   input wire                   TxElecIdle_0,
   input wire                   RxPolarity_0,
   input wire                   scisel_0,
   input wire                   scien_0,   
   
   output wire [`DataWidth-1:0] RxData_0,
   output wire [`BusWidth-1:0]  RxDataK_0, 
   output wire                  RxValid_0,
   output wire                  RxElecIdle_0,
   output wire [2:0]            RxStatus_0,  
   output wire                  ffs_rlol_ch0,

   `ifdef X4
      input wire [`DataWidth-1:0]   TxData_1,
      input wire [`BusWidth-1:0]    TxDataK_1,
      input wire                    TxCompliance_1,
      input wire                    TxElecIdle_1,
      input wire                    RxPolarity_1,
      input wire                    scisel_1,
      input wire                    scien_1,
      output wire [`DataWidth-1:0]  RxData_1,
      output wire [`BusWidth-1:0]   RxDataK_1, 
      output wire                   RxValid_1,
      output wire                   RxElecIdle_1,
      output wire [2:0]             RxStatus_1,  
    //  output                      ffs_rlol_ch1,

      input wire  [`DataWidth-1:0]  TxData_2,
      input wire  [`BusWidth-1:0]   TxDataK_2,
      input wire                    TxCompliance_2,
      input wire                    TxElecIdle_2,
      input wire                    RxPolarity_2,
      input wire                    scisel_2,
      input wire                    scien_2,
      output wire [`DataWidth-1:0]  RxData_2,
      output wire [`BusWidth-1:0]   RxDataK_2, 
      output wire                   RxValid_2,
      output wire                   RxElecIdle_2,
      output wire [2:0]             RxStatus_2,  
   //   output                      ffs_rlol_ch2,

      input wire  [`DataWidth-1:0]  TxData_3,
      input wire  [`BusWidth-1:0]   TxDataK_3,
      input wire                    TxCompliance_3,
      input wire                    TxElecIdle_3,
      input wire                    RxPolarity_3,
      input wire                    scisel_3,
      input wire                    scien_3,
      output wire [`DataWidth-1:0]  RxData_3,
      output wire [`BusWidth-1:0]   RxDataK_3, 
      output wire                   RxValid_3,
      output wire                   RxElecIdle_3,
      output wire [2:0]             RxStatus_3,  
   //   output                      ffs_rlol_ch3,
   `endif // X4

   input [7:0]              sciwritedata,
   input [5:0]              sciaddress,
   input                    sciselaux,
   input                    scienaux,
   input                    scird,
   input                    sciwstn,
   output[7:0]              scireaddata,

   input wire               phy_l0,
   input wire [3:0]         phy_cfgln,
   input wire               ctc_disable,
   input wire               flip_lanes
   );

// =============================================================================
// Parameters
// =============================================================================
`ifdef DataWidth_8
   localparam  ONE_US         = 8'b11111111;   // 1 Micro sec = 256 clks
   localparam  ONE_US_4BYTE   = 8'b00000101;   // 1 us + 6 clks
`endif
`ifdef DataWidth_16
   localparam  ONE_US         = 7'b1111111;   // 1 Micro sec = 128 clks
   localparam  ONE_US_4BYTE   = 7'b0000010;   // 1 us + 3 clks
`endif

localparam  PCIE_DET_IDLE   = 2'b00;
localparam  PCIE_DET_EN     = 2'b01;
localparam  PCIE_CT         = 2'b10;
localparam  PCIE_DONE       = 2'b11;

// =============================================================================
// Wires & Regs
// =============================================================================
wire          clk_250;
wire          clk_125;

wire [19:0]   cout;
wire          ffs_rlol_ch1;
wire          ffs_rlol_ch2;
wire          ffs_rlol_ch3;

wire          fpsc_vlo;
wire  [11:0]  cin;
wire          ffc_trst;
wire          ffc_macro_rst;
wire          ffc_lane_tx_rst;   
wire          ffc_lane_rx_rst;  
wire          ffc_signal_detect;
wire          ffc_enb_cgalign;

//wire          sync_rst;
reg           sync_rst;
wire          ff_tx_f_clk;
wire          ff_tx_h_clk;  
`ifdef ECP3
   wire          ff_tx_f_clk_0;
   wire          ff_tx_f_clk_1;
   wire          ff_tx_f_clk_2;
   wire          ff_tx_f_clk_3;

   wire          ff_tx_h_clk_0;  
   wire          ff_tx_h_clk_1;  
   wire          ff_tx_h_clk_2;  
   wire          ff_tx_h_clk_3;  
`endif

`ifdef X1
`ifdef Channel_0
   wire                      ffs_pcie_done_0;
   wire                      ffs_pcie_con_0;
   wire                      RxValid_0_in;
   wire                      RxElecIdle_0_in; 
   wire  [7:0]               RxData_0_in;
   wire                      RxDataK_0_in; 
   wire  [2:0]               RxStatus_0_in;  
   wire  [7:0]               TxData_0_out;
   wire                      TxDataK_0_out;
   
   wire                       flip_RxValid_0;
   wire    [`DataWidth-1:0]   flip_RxData_0;
   wire    [`BusWidth-1:0]    flip_RxDataK_0; 
   wire                       flip_RxElecIdle_0;
   wire    [2:0]              flip_RxStatus_0;  
   wire    [`DataWidth-1:0]   flip_TxData_0;
   wire    [`BusWidth-1:0]    flip_TxDataK_0;
   //wire                       flip_TxElecIdle_0;
   wire                       flip_TxElecIdle_0;
   wire                       flip_TxCompliance_0;
   wire                       flip_scisel_0;
   wire                       flip_scien_0;   
   wire                       flip_RxPolarity_0;
   wire    [3:0]              flip_phy_cfgln;
   
   assign RxValid_0           = flip_RxValid_0;
   assign RxData_0            = flip_RxData_0;
   assign RxDataK_0           = flip_RxDataK_0;
   assign RxElecIdle_0        = flip_RxElecIdle_0; 
   assign RxStatus_0          = flip_RxStatus_0; 
   assign flip_TxData_0       = TxData_0;
   assign flip_TxDataK_0      = TxDataK_0;
   assign flip_TxElecIdle_0   = TxElecIdle_0;
   assign flip_TxCompliance_0 = TxCompliance_0;
   assign flip_RxPolarity_0   = RxPolarity_0;
   assign flip_scisel_0       = scisel_0;
   assign flip_scien_0        = scien_0;
   assign flip_phy_cfgln      = phy_cfgln;
`endif
`ifdef Channel_1
   wire                       ffs_pcie_done_1;
   wire                       ffs_pcie_con_1;
   wire                       RxValid_1_in;
   wire                       RxElecIdle_1_in;
   wire    [7:0]              RxData_1_in;
   wire                       RxDataK_1_in; 
   wire    [2:0]              RxStatus_1_in;  
   wire    [7:0]              TxData_1_out;
   wire                       TxDataK_1_out;
   
   wire                       flip_RxValid_1;
   wire    [`DataWidth-1:0]   flip_RxData_1;
   wire    [`BusWidth-1:0]    flip_RxDataK_1; 
   wire                       flip_RxElecIdle_1;
   wire    [2:0]              flip_RxStatus_1;  
   wire    [`DataWidth-1:0]   flip_TxData_1;
   wire    [`BusWidth-1:0]    flip_TxDataK_1;
   wire                       flip_TxElecIdle_1;
   wire                       flip_TxCompliance_1;
   wire                       flip_scisel_1;
   wire                       flip_scien_1;   
   wire                       flip_RxPolarity_1;
   wire    [3:0]              flip_phy_cfgln;
   
   assign RxValid_0           = flip_RxValid_1;
   assign RxData_0            = flip_RxData_1;
   assign RxDataK_0           = flip_RxDataK_1;
   assign RxElecIdle_0        = flip_RxElecIdle_1; 
   assign RxStatus_0          = flip_RxStatus_1; 
   assign flip_TxData_1       = TxData_0;
   assign flip_TxDataK_1      = TxDataK_0;
   assign flip_TxElecIdle_1   = TxElecIdle_0;
   assign flip_TxCompliance_1 = TxCompliance_0;
   assign flip_RxPolarity_1   = RxPolarity_0;
   assign flip_scisel_1       = scisel_0;
   assign flip_scien_1        = scien_0;
   assign flip_phy_cfgln      = phy_cfgln;
   assign ffs_pcie_con_0      = ffs_pcie_con_1;
`endif // Channel_1
`ifdef Channel_2
   wire                       ffs_pcie_done_2;
   wire                       ffs_pcie_con_2;
   wire                       RxValid_2_in;
   wire                       RxElecIdle_2_in;
   wire    [7:0]              RxData_2_in;
   wire                       RxDataK_2_in; 
   wire    [2:0]              RxStatus_2_in;  
   wire    [7:0]              TxData_2_out;
   wire                       TxDataK_2_out;

   wire                       flip_RxValid_2;
   wire    [`DataWidth-1:0]   flip_RxData_2;
   wire    [`BusWidth-1:0]    flip_RxDataK_2; 
   wire                       flip_RxElecIdle_2;
   wire    [2:0]              flip_RxStatus_2;  
   wire    [`DataWidth-1:0]   flip_TxData_2;
   wire    [`BusWidth-1:0]    flip_TxDataK_2;
   wire                       flip_TxElecIdle_2;
   wire                       flip_TxCompliance_2;
   wire                       flip_scisel_2;
   wire                       flip_scien_2;   
   wire                       flip_RxPolarity_2;
   wire    [3:0]              flip_phy_cfgln;
   
   assign RxValid_0           = flip_RxValid_2;
   assign RxData_0            = flip_RxData_2;
   assign RxDataK_0           = flip_RxDataK_2;
   assign RxElecIdle_0        = flip_RxElecIdle_2; 
   assign RxStatus_0          = flip_RxStatus_2; 
   assign flip_TxData_2       = TxData_0;
   assign flip_TxDataK_2      = TxDataK_0;
   assign flip_TxElecIdle_2   = TxElecIdle_0;
   assign flip_TxCompliance_2 = TxCompliance_0;
   assign flip_RxPolarity_2   = RxPolarity_0;
   assign flip_scisel_2       = scisel_0;
   assign flip_scien_2        = scien_0;
   assign flip_phy_cfgln      = phy_cfgln;
   assign ffs_pcie_con_0      = ffs_pcie_con_2;
`endif // Channel_2
`ifdef Channel_3
   wire                       ffs_pcie_done_3;
   wire                       ffs_pcie_con_3;
   wire                       RxValid_3_in;
   wire                       RxElecIdle_3_in;
   wire    [7:0]              RxData_3_in;
   wire                       RxDataK_3_in; 
   wire    [2:0]              RxStatus_3_in;  
   wire    [7:0]              TxData_3_out;
   wire                       TxDataK_3_out;

   wire                       flip_RxValid_3;
   wire    [`DataWidth-1:0]   flip_RxData_3;
   wire    [`BusWidth-1:0]    flip_RxDataK_3; 
   wire                       flip_RxElecIdle_3;
   wire    [2:0]              flip_RxStatus_3;  
   wire    [`DataWidth-1:0]   flip_TxData_3;
   wire    [`BusWidth-1:0]    flip_TxDataK_3;
   wire                       flip_TxElecIdle_3;
   wire                       flip_TxCompliance_3;
   wire                       flip_scisel_3;
   wire                       flip_scien_3;   
   wire                       flip_RxPolarity_3;
   wire    [3:0]              flip_phy_cfgln;
   
   assign RxValid_0           = flip_RxValid_3;
   assign RxData_0            = flip_RxData_3;
   assign RxDataK_0           = flip_RxDataK_3;
   assign RxElecIdle_0        = flip_RxElecIdle_3; 
   assign RxStatus_0          = flip_RxStatus_3; 
   assign flip_TxData_3       = TxData_0;
   assign flip_TxDataK_3      = TxDataK_0;
   assign flip_TxElecIdle_3   = TxElecIdle_0;
   assign flip_TxCompliance_3 = TxCompliance_0;
   assign flip_RxPolarity_3   = RxPolarity_0;
   assign flip_scisel_3       = scisel_0;
   assign flip_scien_3        = scien_0;
   assign flip_phy_cfgln      = phy_cfgln;
   assign ffs_pcie_con_0      = ffs_pcie_con_3;
`endif // Channel_3
`endif

`ifdef X4
   wire    [3:0]              flip_phy_cfgln;
   wire                       RxValid_0_in;
   wire                       RxElecIdle_0_in;
   wire    [7:0]              RxData_0_in;
   wire                       RxDataK_0_in; 
   wire    [2:0]              RxStatus_0_in;  
   wire    [7:0]              TxData_0_out;
   wire                       TxDataK_0_out;
   
   wire                       flip_RxValid_0;
   wire    [`DataWidth-1:0]   flip_RxData_0;
   wire    [`BusWidth-1:0]    flip_RxDataK_0; 
   wire                       flip_RxElecIdle_0;
   wire    [2:0]              flip_RxStatus_0;  
   wire    [`DataWidth-1:0]   flip_TxData_0;
   wire    [`BusWidth-1:0]    flip_TxDataK_0;
   wire                       flip_TxElecIdle_0;
   wire                       flip_TxCompliance_0;
   wire                       flip_scisel_0;
   wire                       flip_scien_0;   
   wire                       flip_RxPolarity_0;
     
   wire                       RxValid_1_in;
   wire                       RxElecIdle_1_in;
   wire    [7:0]              RxData_1_in;
   wire                       RxDataK_1_in; 
   wire    [2:0]              RxStatus_1_in; 
   wire    [7:0]              TxData_1_out;
   wire                       TxDataK_1_out;   

   wire                       flip_RxValid_1;
   wire    [`DataWidth-1:0]   flip_RxData_1;
   wire    [`BusWidth-1:0]    flip_RxDataK_1; 
   wire                       flip_RxElecIdle_1;
   wire    [2:0]              flip_RxStatus_1;  
   wire    [`DataWidth-1:0]   flip_TxData_1;
   wire    [`BusWidth-1:0]    flip_TxDataK_1;
   wire                       flip_TxElecIdle_1;
   wire                       flip_TxCompliance_1;
   wire                       flip_scisel_1;
   wire                       flip_scien_1;   
   wire                       flip_RxPolarity_1;

   wire                       RxValid_2_in;
   wire                       RxElecIdle_2_in;
   wire    [7:0]              RxData_2_in;
   wire                       RxDataK_2_in; 
   wire    [2:0]              RxStatus_2_in;   
   wire    [7:0]              TxData_2_out;
   wire                       TxDataK_2_out;
   
   wire                       flip_RxValid_2;
   wire    [`DataWidth-1:0]   flip_RxData_2;
   wire    [`BusWidth-1:0]    flip_RxDataK_2; 
   wire                       flip_RxElecIdle_2;
   wire    [2:0]              flip_RxStatus_2;  
   wire    [`DataWidth-1:0]   flip_TxData_2;
   wire    [`BusWidth-1:0]    flip_TxDataK_2;
   wire                       flip_TxElecIdle_2;
   wire                       flip_TxCompliance_2;
   wire                       flip_scisel_2;
   wire                       flip_scien_2;   
   wire                       flip_RxPolarity_2;

    
   wire                       RxValid_3_in;
   wire                       RxElecIdle_3_in;
   wire    [7:0]              RxData_3_in;
   wire                       RxDataK_3_in; 
   wire    [2:0]              RxStatus_3_in;   
   wire    [7:0]              TxData_3_out;
   wire                       TxDataK_3_out;

   wire                       flip_RxValid_3;
   wire    [`DataWidth-1:0]   flip_RxData_3;
   wire    [`BusWidth-1:0]    flip_RxDataK_3; 
   wire                       flip_RxElecIdle_3;
   wire    [2:0]              flip_RxStatus_3;  
   wire    [`DataWidth-1:0]   flip_TxData_3;
   wire    [`BusWidth-1:0]    flip_TxDataK_3;
   wire                       flip_TxElecIdle_3;
   wire                       flip_TxCompliance_3;
   wire                       flip_scisel_3;
   wire                       flip_scien_3;   
   wire                       flip_RxPolarity_3;
   
   wire                       ffs_pcie_done_0;
   wire                       ffs_pcie_done_1;
   wire                       ffs_pcie_done_2;
   wire                       ffs_pcie_done_3;

   wire                       ffs_pcie_con_0;
   wire                       ffs_pcie_con_1;
   wire                       ffs_pcie_con_2;
   wire                       ffs_pcie_con_3;


   // =============================================================================
   //  Flip Logic (for X4 Only)
   // =============================================================================
   assign {RxValid_3, RxValid_2, RxValid_1, RxValid_0} = flip_lanes ? 
                         {flip_RxValid_0, flip_RxValid_1, flip_RxValid_2, flip_RxValid_3}:
                         {flip_RxValid_3, flip_RxValid_2, flip_RxValid_1, flip_RxValid_0};
   assign {RxData_3, RxData_2, RxData_1, RxData_0} = flip_lanes ? 
                         {flip_RxData_0, flip_RxData_1, flip_RxData_2, flip_RxData_3}:
                         {flip_RxData_3, flip_RxData_2, flip_RxData_1, flip_RxData_0};
   assign {RxDataK_3, RxDataK_2, RxDataK_1, RxDataK_0}  = flip_lanes ? 
                         {flip_RxDataK_0, flip_RxDataK_1, flip_RxDataK_2, flip_RxDataK_3}:
                         {flip_RxDataK_3, flip_RxDataK_2, flip_RxDataK_1, flip_RxDataK_0};
   assign {RxElecIdle_3, RxElecIdle_2, RxElecIdle_1, RxElecIdle_0} = flip_lanes ? 
                         {flip_RxElecIdle_0, flip_RxElecIdle_1, flip_RxElecIdle_2, flip_RxElecIdle_3}:
                         {flip_RxElecIdle_3, flip_RxElecIdle_2, flip_RxElecIdle_1, flip_RxElecIdle_0};
   assign {RxStatus_3, RxStatus_2, RxStatus_1, RxStatus_0} = flip_lanes ? 
                         {flip_RxStatus_0, flip_RxStatus_1, flip_RxStatus_2, flip_RxStatus_3}:
                         {flip_RxStatus_3, flip_RxStatus_2, flip_RxStatus_1, flip_RxStatus_0};
   assign {flip_TxData_3, flip_TxData_2, flip_TxData_1, flip_TxData_0} = flip_lanes ? 
                         {TxData_0, TxData_1, TxData_2, TxData_3}:
                         {TxData_3, TxData_2, TxData_1, TxData_0};
   assign {flip_TxDataK_3, flip_TxDataK_2, flip_TxDataK_1, flip_TxDataK_0} = flip_lanes ? 
                         {TxDataK_0, TxDataK_1, TxDataK_2, TxDataK_3}:
                         {TxDataK_3, TxDataK_2, TxDataK_1, TxDataK_0};
   assign {flip_TxElecIdle_3, flip_TxElecIdle_2, flip_TxElecIdle_1, flip_TxElecIdle_0} = flip_lanes ? 
                         {TxElecIdle_0, TxElecIdle_1, TxElecIdle_2, TxElecIdle_3}:
                         {TxElecIdle_3, TxElecIdle_2, TxElecIdle_1, TxElecIdle_0};
   assign {flip_TxCompliance_3, flip_TxCompliance_2, flip_TxCompliance_1, flip_TxCompliance_0} = flip_lanes ?
                         {TxCompliance_0, TxCompliance_1, TxCompliance_2, TxCompliance_3}:
                         {TxCompliance_3, TxCompliance_2, TxCompliance_1, TxCompliance_0};
   assign {flip_RxPolarity_3, flip_RxPolarity_2, flip_RxPolarity_1, flip_RxPolarity_0} = flip_lanes ?
                         {RxPolarity_0, RxPolarity_1, RxPolarity_2, RxPolarity_3}:
                         {RxPolarity_3, RxPolarity_2, RxPolarity_1, RxPolarity_0};
   assign {flip_scisel_3, flip_scisel_2, flip_scisel_1, flip_scisel_0} = flip_lanes ?
                         {scisel_0, scisel_1, scisel_2, scisel_3}:
                         {scisel_3, scisel_2, scisel_1, scisel_0};
   assign {flip_scien_3, flip_scien_2, flip_scien_1, flip_scien_0} = flip_lanes ?
                         {scien_0, scien_1, scien_2, scien_3}:
                         {scien_3, scien_2, scien_1, scien_0};
   assign {flip_phy_cfgln[3], flip_phy_cfgln[2], flip_phy_cfgln[1], flip_phy_cfgln[0]} = flip_lanes ?
                         {phy_cfgln[0], phy_cfgln[1], phy_cfgln[2], phy_cfgln[3]}:
                         {phy_cfgln[3], phy_cfgln[2], phy_cfgln[1], phy_cfgln[0]};
                         
`endif // X4

// =============================================================================
// =============================================================================
//For PowerDown
`ifdef X4
   reg                        ffc_pwdnb_0;
   reg                        ffc_pwdnb_1;
   reg                        ffc_pwdnb_2;
   reg                        ffc_pwdnb_3;

   reg                        ffc_rrst_0;
   reg                        ffc_rrst_1;
   reg                        ffc_rrst_2;
   reg                        ffc_rrst_3;
`endif // X4
`ifdef X1
   wire                       ffc_pwdnb_0;
   wire                       ffc_pwdnb_1;
   wire                       ffc_pwdnb_2;
   wire                       ffc_pwdnb_3;

   wire                       ffc_rrst_0;
   wire                       ffc_rrst_1;
   wire                       ffc_rrst_2;
   wire                       ffc_rrst_3;
`endif // X1

//For DETECT State Machine
reg  [1:0]                    cs_reqdet_sm; 
reg                           detsm_done;
reg  [3:0]                    det_result;   // Only for RTL sim
reg                           pcie_con_0;
reg                           pcie_con_1;
reg                           pcie_con_2;
reg                           pcie_con_3;
reg                           ffc_pcie_ct;
reg                           ffc_pcie_det_en_0;
reg                           ffc_pcie_det_en_1;
reg                           ffc_pcie_det_en_2;
reg                           ffc_pcie_det_en_3;

reg                           cnt_enable;
reg                           cntdone_en;
reg                           cntdone_ct;
`ifdef DataWidth_8
   reg  [7:0]                 detsm_cnt;   // 1 us (256 clks)
`endif
`ifdef DataWidth_16
   reg  [6:0]                 detsm_cnt;   // 1 us (128 clks)
`endif

wire                          done_all_re;
wire                          done_0_re;
wire                          done_1_re;
wire                          done_2_re;
wire                          done_3_re;

reg                           done_0_reg;
reg                           done_0_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_0_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_1_reg;
reg                           done_1_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_1_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_2_reg;
reg                           done_2_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_2_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_3_reg;
reg                           done_3_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_3_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_all;
reg                           done_all_reg /* synthesis syn_srlstyle="registers" */;

reg                           detect_req;
reg                           detect_req_del /* synthesis syn_srlstyle="registers" */;

reg                           enable_det_ch0 ;
reg                           enable_det_ch1 ;
reg                           enable_det_ch2 ;
reg                           enable_det_ch3 ;
wire                          enable_det_int ;
wire                          enable_det_all ;

reg                           PLOL_sync;
reg                           PLOL_pclk /* synthesis syn_srlstyle="registers" */;
reg  [1:0]                    PowerDown_reg /* synthesis syn_srlstyle="registers" */;
reg                           PLOL_hsync;
reg                           PLOL_hclk;

// Signals for Masking RxValid for 4 MS 
reg [16:0]                    count_ms;
reg                           count_ms_enable;
reg [2:0]                     num_ms;
reg                           pcs_wait_done;
reg                           detection_done;
reg                           start_count;
reg                           start_count_del;
reg [3:0]                     RxEI_sync;
reg [3:0]                     RxEI;
reg [3:0]                     RxEI_masked_sync;
reg [3:0]                     RxEI_masked;
wire                          EI_Det_0;
wire                          EI_Det_1;
wire                          EI_Det_2;
wire                          EI_Det_3;
reg [3:0]                     EI_low;
reg [3:0]                     EI_low_pulse;
reg                           reset_counter;
reg                           allEI_high;
reg [3:0]                     RxLOL_sync;
reg [3:0]                     RxLOL;
reg [3:0]                     RxLOL_del;
reg [3:0]                     RxLOL_posedge;

// Signals for Masking EI for 1 us   (false glitch)
reg                           check;
reg                           start_mask;
reg [6:0]                     ei_counter;

// Signals for sync_rst generation
reg [3:0]                     rlol_sync;
reg [3:0]                     rx_elec /* synthesis syn_srlstyle="registers" */;
reg [3:0]                     rlol_fclk /* synthesis syn_srlstyle="registers" */;
reg [3:0]                     rlol_rst_ch;

// For Default Values / RTL Simulation
reg                           Int_RxElecIdle_ch0;
reg                           Int_RxElecIdle_ch1;
reg                           Int_RxElecIdle_ch2;
reg                           Int_RxElecIdle_ch3;
reg                           Int_ffs_rlol_ch0;
reg                           Int_ffs_rlol_ch1;
reg                           Int_ffs_rlol_ch2;
reg                           Int_ffs_rlol_ch3;

wire                          RxElecIdle_ch0_8;  //Required for 4 MS mask from PIPE TOP
wire                          RxElecIdle_ch1_8;
wire                          RxElecIdle_ch2_8;
wire                          RxElecIdle_ch3_8;

wire ff_rx_fclk_0 /* synthesis syn_keep=1 */;
wire ff_rx_fclk_1 /* synthesis syn_keep=1 */;
wire ff_rx_fclk_2 /* synthesis syn_keep=1 */;
wire ff_rx_fclk_3 /* synthesis syn_keep=1 */;

// =============================================================================
VLO fpsc_vlo_inst (.Z(fpsc_vlo));
VHI fpsc_vhi_inst (.Z(fpsc_vhi));

assign cin               = 12'h0;
assign ffc_trst          = fpsc_vlo;
assign ffc_macro_rst     = fpsc_vlo;
assign ffc_lane_tx_rst   = sync_rst;
assign ffc_lane_rx_rst   = sync_rst;
assign ffc_signal_detect = 1'b0;
assign ffc_enb_cgalign   = 1'b1;

//--------- RK MOD ----------
`ifdef ECP3
   `ifdef X4
      assign ff_tx_f_clk = ff_tx_f_clk_0;
      assign ff_tx_h_clk = ff_tx_h_clk_0;
   `else
      `ifdef Channel_0
         assign ff_tx_f_clk = ff_tx_f_clk_0;
         assign ff_tx_h_clk = ff_tx_h_clk_0;
      `endif
      `ifdef Channel_1
         assign ff_tx_f_clk = ff_tx_f_clk_1;
         assign ff_tx_h_clk = ff_tx_h_clk_1;
      `endif
      `ifdef Channel_2
         assign ff_tx_f_clk = ff_tx_f_clk_2;
         assign ff_tx_h_clk = ff_tx_h_clk_2;
      `endif
      `ifdef Channel_3
         assign ff_tx_f_clk = ff_tx_f_clk_3;
         assign ff_tx_h_clk = ff_tx_h_clk_3;
      `endif
   `endif
`endif

assign clk_250           = ff_tx_f_clk;
assign clk_125           = ff_tx_h_clk;

`ifdef DataWidth_8   //8-bit PIPE
   assign PCLK           = ff_tx_f_clk;   // 250 Mhz clock
   assign PCLK_by_2      = ff_tx_h_clk;   // 125 Mhz clock
`else                //16-bit PIPE
   assign PCLK           = ff_tx_h_clk;   // 125 Mhz clock
`endif

// =============================================================================
// Power down unused channels when in downgrade mode and when in L0 
// =============================================================================
assign pwdn   = ~(PowerDown[1] & PowerDown[0]);

`ifdef X1
   `ifdef Channel_0
     assign ffc_pwdnb_0 = pwdn;  //Active LOW
     assign ffc_rrst_0 = 1'b0;   //Active HIGH
   `endif
   `ifdef Channel_1
     assign ffc_pwdnb_1 = pwdn;
     assign ffc_rrst_1 = 1'b0;
   `endif
   `ifdef Channel_2
     assign ffc_pwdnb_2 = pwdn;
     assign ffc_rrst_2 = 1'b0;
   `endif
   `ifdef Channel_3
     assign ffc_pwdnb_3 = pwdn;
     assign ffc_rrst_3 = 1'b0;
   `endif
`endif // X1


`ifdef X4
   always @(posedge PCLK or negedge RESET_n) begin
      if(!RESET_n) begin
         ffc_pwdnb_0  <= 1'b1;
         ffc_pwdnb_1  <= 1'b1;
         ffc_pwdnb_2  <= 1'b1;
         ffc_pwdnb_3  <= 1'b1;
         ffc_rrst_0   <= 1'b0;
         ffc_rrst_1   <= 1'b0;
         ffc_rrst_2   <= 1'b0;
         ffc_rrst_3   <= 1'b0;
      end
      else begin
         ffc_pwdnb_0 <= pwdn;
         ffc_pwdnb_1 <= pwdn;
         ffc_pwdnb_2 <= pwdn;
         ffc_pwdnb_3 <= pwdn;
         if (phy_l0) begin
            ffc_rrst_0 <= ~flip_phy_cfgln[3];
            ffc_rrst_1 <= ~flip_phy_cfgln[2];
            ffc_rrst_2 <= ~flip_phy_cfgln[1];
            ffc_rrst_3 <= ~flip_phy_cfgln[0];
         end
         else begin
            ffc_rrst_0 <= 1'b0; 
            ffc_rrst_1 <= 1'b0; 
            ffc_rrst_2 <= 1'b0; 
            ffc_rrst_3 <= 1'b0; 
         end
      end
   end
`endif // X4

// =============================================================================
// sync_rst generation :
// Generate LANE TX and RX reset to synchonise all the SERDES and CTC channels
// so that the any channel skew causes by delayed start of clocks are is removed
// Generate sync_rst is rst when 
// when any channel LOS OF LOCK is seen, (Useful in X1 downgrade mode)
// when all channel LOS OF LOCK is seen, (Useful in X4 downgrade mode)
// =============================================================================
reg lol_all_d0 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d1 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d2 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d3 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d4 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d5 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d6 /* synthesis syn_srlstyle="registers" */; 
reg lol_all_d7 /* synthesis syn_srlstyle="registers" */; 
always @(posedge clk_250 or negedge RESET_n) begin
   if(!RESET_n) begin
      lol_all_d0 <= 1'b1; 
      lol_all_d1 <= 1'b1; 
      lol_all_d2 <= 1'b1; 
      lol_all_d3 <= 1'b1; 
      lol_all_d4 <= 1'b1; 
      lol_all_d5 <= 1'b1; 
      lol_all_d6 <= 1'b1; 
      lol_all_d7 <= 1'b1; 
      sync_rst   <= 1'b1;
   end
   else begin 
   `ifdef X1
      `ifdef Channel_0  
         lol_all_d0 <= rlol_rst_ch[0];
      `endif 
      `ifdef Channel_1  
         lol_all_d0 <= rlol_rst_ch[1];
      `endif 
      `ifdef Channel_2  
         lol_all_d0 <= rlol_rst_ch[2];
      `endif 
      `ifdef Channel_3   
         lol_all_d0 <= rlol_rst_ch[3];
      `endif 
   `endif // X1

   `ifdef X4
      // When all LOL goes LOW 
      lol_all_d0 <= rlol_rst_ch[3] | rlol_rst_ch[2] | rlol_rst_ch[1] | rlol_rst_ch[0];
   `endif // X4

      lol_all_d1 <= lol_all_d0; 
      lol_all_d2 <= lol_all_d1; 
      lol_all_d3 <= lol_all_d2; 
      lol_all_d4 <= lol_all_d3; 
      lol_all_d5 <= lol_all_d4; 
      lol_all_d6 <= lol_all_d5; 
      lol_all_d7 <= lol_all_d6; 
      sync_rst   <= (~lol_all_d1 & lol_all_d7) ;
   end
end

// =============================================================================
// This Option/define is Meant for Debugging with Lattice  (LSV) Agilent 
// Exerciser ONLY. Others don't use this define.
// =============================================================================
`ifdef EXERCISER_DEBUG 
         // ====================================================================
         //  LSV Agilent Exerciser Tx-L0 has got problem & always is in Elec Idle
         //  Force the RxEI Lane0/3 LOW
         // ====================================================================
	 `ifdef X4
         reg  [3:0]  RxElecIdle_x_in_sync1;
         reg  [3:0]  RxElecIdle_x_in_sync2;
         reg         RxElecIdle_0_in_temp;
         reg         RxElecIdle_3_in_temp;
         // ====================================================================
         //  For X4 : Force the RxEI Lane0/3 LOW when ALL other RxEIs are LOW 
         // ====================================================================
         always @(posedge clk_125 or negedge RESET_n) begin
            if(!RESET_n) begin
              RxElecIdle_x_in_sync1 <= 4'b1111;
              RxElecIdle_x_in_sync2 <= 4'b1111;
              RxElecIdle_0_in_temp  <= 1'b1;
              RxElecIdle_3_in_temp  <= 1'b1;
            end
            else begin
              RxElecIdle_x_in_sync1 <= {RxElecIdle_3_in,RxElecIdle_2_in,RxElecIdle_1_in,RxElecIdle_0_in};
              RxElecIdle_x_in_sync2 <= RxElecIdle_x_in_sync1;
         
              if(RxElecIdle_x_in_sync2 == 4'b0001)
                 RxElecIdle_0_in_temp <= 1'b0;
              else
                 RxElecIdle_0_in_temp <= RxElecIdle_x_in_sync2[0];
         
              if(RxElecIdle_x_in_sync2 == 4'b1000) //Lane reversal for Solution Board
                 RxElecIdle_3_in_temp <= 1'b0;
              else
                 RxElecIdle_3_in_temp <= RxElecIdle_x_in_sync2[3];
         
            end
         end
        `endif
         // ====================================================================
         //  For X1: Force the RxEI Lane0/3 LOW when RxValid is HIGH 
         // ====================================================================
	 `ifdef X1
         reg         RxElecIdle_x_in_sync1;
         reg         RxElecIdle_x_in_sync2;
         reg         RxElecIdle_0_in_temp;
         reg         RxElecIdle_3_in_temp;
         reg         RxValid_x_in_sync1;
         reg         RxValid_x_in_sync2;
         always @(posedge clk_125 or negedge RESET_n) begin
            if(!RESET_n) begin
              RxElecIdle_x_in_sync1 <= 1'b1;
              RxElecIdle_x_in_sync2 <= 1'b1;
              RxElecIdle_0_in_temp  <= 1'b1;
              RxElecIdle_3_in_temp  <= 1'b1;
              RxValid_x_in_sync1    <= 1'b0;
              RxValid_x_in_sync2    <= 1'b0;
            end
            else begin
              `ifdef Channel_0
                 RxElecIdle_x_in_sync1 <= RxElecIdle_0_in;
                 RxElecIdle_x_in_sync2 <= RxElecIdle_x_in_sync1;
                 RxValid_x_in_sync1   <= RxValid_0_in;
                 RxValid_x_in_sync2   <= RxValid_x_in_sync1;

	         //RxEI & RxValid : both are HIGH
                 if(RxElecIdle_x_in_sync2 &&  RxValid_x_in_sync2)
                    RxElecIdle_0_in_temp <= 1'b0;
                 else
                    RxElecIdle_0_in_temp <= RxElecIdle_x_in_sync2;
              `endif
              `ifdef Channel_3
                 RxElecIdle_x_in_sync1 <= RxElecIdle_3_in;
                 RxElecIdle_x_in_sync2 <= RxElecIdle_x_in_sync1;
                 RxValid_x_in_sync1   <= RxValid_3_in;
                 RxValid_x_in_sync2   <= RxValid_x_in_sync1;

	         //RxEI & RxValid : both are HIGH
                 if(RxElecIdle_x_in_sync2 &&  RxValid_x_in_sync2)
                    RxElecIdle_3_in_temp <= 1'b0;
                 else
                    RxElecIdle_3_in_temp <= RxElecIdle_x_in_sync2;
              `endif
            end
         end
        `endif
`endif

// ======================= RK MODIFICATIONS START ==============================
// New signals :
// pcs_wait_done_ch0, 1,2,3  -- for Rx_valid
// rlol_ch0, 1,2,3           -- for sync_rst
// =============================================================================
// 1 MS Timer -- 18-bit : 250,000 clks (250Mhz) 
// count_ms can go upto 262,144 clks (1 ms + 48 us)
// DETECT to POLLING (P1 to P0): the timer starts & after 4 MS,  RxValids
// are passed.
// =============================================================================


///// inputs : pcs_wait_done

///// inputs   : pcs_wait_done, start_mask, Int_RxElecIdle_ch0/1/2/3
///// outputs  : RxElecIdle_ch0_8 (masked EI)

///// inputs : detsm_done

// =============================================================================
// Make Default values in case of X1
// =============================================================================
always@*
begin
   // If defined, take from PCS otherwise assign default values
   pcie_con_0  = 1'b0;
   pcie_con_1  = 1'b0;
   pcie_con_2  = 1'b0;
   pcie_con_3  = 1'b0;

   Int_RxElecIdle_ch0  = 1'b1;
   Int_RxElecIdle_ch1  = 1'b1;
   Int_RxElecIdle_ch2  = 1'b1;
   Int_RxElecIdle_ch3  = 1'b1;

   Int_ffs_rlol_ch0    = 1'b1; 
   Int_ffs_rlol_ch1    = 1'b1; 
   Int_ffs_rlol_ch2    = 1'b1; 
   Int_ffs_rlol_ch3    = 1'b1; 

  `ifdef Channel_0
     pcie_con_0          = ffs_pcie_con_0;
     `ifdef EXERCISER_DEBUG 
         Int_RxElecIdle_ch0  = RxElecIdle_0_in_temp;
     `else
         Int_RxElecIdle_ch0  = RxElecIdle_0_in;
     `endif
     Int_ffs_rlol_ch0    = ffs_rlol_ch0;
  `endif
  `ifdef Channel_1
     pcie_con_1          = ffs_pcie_con_1;
     Int_RxElecIdle_ch1  = RxElecIdle_1_in;
     Int_ffs_rlol_ch1    = ffs_rlol_ch1;
  `endif
  `ifdef Channel_2
     pcie_con_2          = ffs_pcie_con_2;
     Int_RxElecIdle_ch2  = RxElecIdle_2_in;
     Int_ffs_rlol_ch2    = ffs_rlol_ch2;
  `endif
  `ifdef Channel_3
     pcie_con_3          = ffs_pcie_con_3;
     `ifdef EXERCISER_DEBUG 
         Int_RxElecIdle_ch3  = RxElecIdle_3_in_temp;
     `else
         Int_RxElecIdle_ch3  = RxElecIdle_3_in;
     `endif
     Int_ffs_rlol_ch3    = ffs_rlol_ch3;
  `endif
       // synopsys translate_off
           // PCS Sim. Model is not giving Result
           pcie_con_0  = det_result[0];
           pcie_con_1  = det_result[1];
           pcie_con_2  = det_result[2];
           pcie_con_3  = det_result[3];
       // synopsys translate_on
end

// EIDet = 4'b1111 --> when ALL LANES are DETECTED & All lanes are NOT in Elec Idle
// ffs_pcie_con_0/1/2/3 are already stabilized & qualified with "detection_done"
assign EI_Det_0  = ~(RxEI_masked[0]) & pcie_con_0;
assign EI_Det_1  = ~(RxEI_masked[1]) & pcie_con_1;
assign EI_Det_2  = ~(RxEI_masked[2]) & pcie_con_2;
assign EI_Det_3  = ~(RxEI_masked[3]) & pcie_con_3;

//always @(posedge PCLK or negedge RESET_n) begin
always @(posedge clk_125 or negedge RESET_n) begin
   if(!RESET_n) begin
      count_ms        <= 17'b00000000000000000; // 17-bits for 1 MS
      count_ms_enable <= 1'b0;
      num_ms          <= 3'b000;
      pcs_wait_done   <= 1'b0;

      detection_done  <= 1'b0;
      start_count     <= 1'b0;
      start_count_del <= 1'b0;
      RxEI_sync       <= 4'b1111;
      RxEI            <= 4'b1111;
      RxEI_masked_sync <= 4'b1111;
      RxEI_masked     <= 4'b1111;

      EI_low          <= 4'b0000;
      EI_low_pulse    <= 4'b0000;

      reset_counter   <= 1'b0;
      allEI_high      <= 1'b0;
      RxLOL_sync      <= 4'b1111;
      RxLOL           <= 4'b1111;
      RxLOL_del       <= 4'b1111;
      RxLOL_posedge   <= 4'b0000;
   end
   else begin
      //Sync.
      RxLOL_sync <= {Int_ffs_rlol_ch3, Int_ffs_rlol_ch2, Int_ffs_rlol_ch1, Int_ffs_rlol_ch0};
      RxLOL      <= RxLOL_sync;

      //For "1us Masked RxElecIdle -> RxElecIdle_ch0_8"  Take PCS EI
      RxEI_sync  <= {Int_RxElecIdle_ch3, Int_RxElecIdle_ch2, Int_RxElecIdle_ch1, Int_RxElecIdle_ch0}; 
      RxEI       <= RxEI_sync;


      //Use "Masked RxElecIdle -> RxElecIdle_ch0_8"  for 4MS Mask
      RxEI_masked_sync <= {RxElecIdle_ch3_8, RxElecIdle_ch2_8, RxElecIdle_ch1_8, RxElecIdle_ch0_8}; 
      RxEI_masked      <= RxEI_masked_sync;

  // After COUNTER enabled, Reset conditions :
  // 1) Any EI going LOW
  // 2) ALL EI going HIGH 
  //      keep reset ON until at least one EI goes LOW
  // 3) Any RLOL going HIGH (qualified with corresponding EI LOW)

  // 1) Any EI going LOW
      // ffs_pcie_con_0/1/2/3 stable & qualified with "count_ms_enable"
      EI_low[0]     <= count_ms_enable & EI_Det_0;
      EI_low[1]     <= count_ms_enable & EI_Det_1;
      EI_low[2]     <= count_ms_enable & EI_Det_2;
      EI_low[3]     <= count_ms_enable & EI_Det_3;

      // Generate "reset counter pulse" whenever EI goes on ANY channel
      EI_low_pulse[0] <= ~(EI_low[0]) & count_ms_enable & EI_Det_0;
      EI_low_pulse[1] <= ~(EI_low[1]) & count_ms_enable & EI_Det_1;
      EI_low_pulse[2] <= ~(EI_low[2]) & count_ms_enable & EI_Det_2;
      EI_low_pulse[3] <= ~(EI_low[3]) & count_ms_enable & EI_Det_3;

  // 2) ALL EI going HIGH 
  //      keep reset ON until at least one EI goes LOW
  //Timer already started & then ALL EIs are HIGH
      if (count_ms_enable == 1'b1 && EI_low == 4'b0000)
         allEI_high   <= 1'b1;   // Means EI LOW gone 
      else
         allEI_high   <= 1'b0;


  // 3) Any RLOL going HIGH (qualified with corresponding EI LOW)
      RxLOL_del     <= RxLOL;
      RxLOL_posedge[0] <= EI_low[0] & RxLOL[0] & ~(RxLOL_del[0]);
      RxLOL_posedge[1] <= EI_low[1] & RxLOL[1] & ~(RxLOL_del[1]);
      RxLOL_posedge[2] <= EI_low[2] & RxLOL[2] & ~(RxLOL_del[2]);
      RxLOL_posedge[3] <= EI_low[3] & RxLOL[3] & ~(RxLOL_del[3]);

      // Reset Counter = 1 + 2 + 3 
      // ANY EI low pulse -OR- all EI high -OR- ANY RLOL Posedge 
      if ((EI_low_pulse != 4'b0000) || (allEI_high == 1'b1) || (RxLOL_posedge != 4'b0000))
         reset_counter  <= 1'b1;
      else
         reset_counter  <= 1'b0;

      // Any lane DETECTED & NOT in EI
      //if (detsm_done == 1'b1)
         //detection_done  <= 1'b1
      //else if (start_count == 1'b1)
         //detection_done  <= 1'b0;

      if(detection_done == 1'b1) begin
         if (start_count == 1'b1)
            detection_done  <= 1'b0; // change the signal name
      end
      else if (RxEI_masked == 4'b1111 && count_ms_enable == 1'b0)
         detection_done  <= 1'b1;

      //Start Timer after DETECT & AT LEAST ONE Lane is not in EI
      // Reset the count with any EI LOW after that 
      // ie counts from Last EI low
      //Any lane DETECTED & NOT in EI
      start_count     <= detection_done & (EI_Det_0 | EI_Det_1 | EI_Det_2 | EI_Det_3);  
      start_count_del <= start_count;

      // 1 MS Timer
      if (count_ms_enable == 1'b1 && reset_counter == 1'b0)
         count_ms <= count_ms + 1'b1;
      else // EI gone LOW, start again
         count_ms <= 17'b00000000000000000;

      // 1 MS Timer Enable -- From DETECT to POLLING 
      // After detect pulse & then ANY EI gone ZERO
      if ((start_count == 1'b1) && (start_count_del == 1'b0)) //Pulse 
         count_ms_enable <= 1'b1;
      else if (num_ms == 3'b100) //4 MS
         count_ms_enable <= 1'b0;

      // No. of MS
      if (count_ms == 17'b11111111111111111) 
         num_ms  <= num_ms + 1'b1;
      else if (num_ms == 3'b100) //4 MS
         num_ms  <= 3'b000;

      // pcs_wait_done  for bit lock & symbol lock 
      // Waiting for PCS to give stabilized RxValid
      if (num_ms == 3'b100) //4 MS
         pcs_wait_done <= 1'b1;   // Enable passing the RX Valid
      //else if (detsm_done == 1'b1) 
      else if (RxEI_masked == 4'b1111)
      //else if (RxEI_masked == "1111" && count_ms_enable == '0') 
         pcs_wait_done <= 1'b0;   // Disable when in DETECT

             // synopsys translate_off
             // 1 MS Timer  ==> 8 clks Timer
             if (count_ms_enable == 1'b1 && reset_counter == 1'b0) 
                count_ms[2:0] <= count_ms[2:0] + 1'b1;
             else // EI gone LOW, start again
                count_ms <= "00000000000000000";

             // No. of MS
             if (count_ms[2:0] == 3'b111)
                num_ms  <= num_ms + 1'b1;
             else if (num_ms == 3'b100) //4 MS  ==> 4x8=32 clks
                num_ms  <= 3'b000;
             // synopsys translate_on
   end
end

// =============================================================================
// Masking the RxEIDLE Glitch  (otherside Rcvr Detction)
// =============================================================================
always @(posedge clk_125 or negedge RESET_n) begin
   if(!RESET_n) begin
      check       <= 1'b0;
      start_mask  <= 1'b0;
      ei_counter  <= 7'b0000000;
      PLOL_hsync  <= 1'b1;
      PLOL_hclk   <= 1'b1;
   end
   else begin
      // Sync.
      PLOL_hsync <= ffs_plol;
      PLOL_hclk  <= PLOL_hsync;

      if (PLOL_hclk == 1'b0)  begin
            if (RxEI == 4'b1111) 
               check <= 1'b1;
               
            if (ei_counter == 7'b1111111) begin // 128 clks (1us)
               start_mask   <= 1'b0;
               check        <= 1'b0;
            end
            else if (check == 1'b1 && RxEI != 4'b1111) // Any lane goes low
               start_mask  <= 1'b1;

             // synopsys translate_off
	    if (ei_counter[2:0] == 3'b111) begin // 7 clks (1us)
               start_mask   <= 1'b0;
               check        <= 1'b0;
            end
            else if (check == 1'b1 && RxEI != 4'b1111) // Any lane goes low
               start_mask  <= 1'b1;
             // synopsys translate_on
      end
      else begin
         check       <= 1'b0;
         start_mask  <= 1'b0;
      end
 
      if(start_mask == 1'b1) 
         ei_counter  <= ei_counter + 1'b1;
      else
         ei_counter  <= 7'b0000000;
            
   end
end

// =============================================================================
// Sync_rst generation :
//    Qualify the RLOL with RxElecIdle
//    PCS RLOL is toggling even when ElecIdle is asserted 
//    No data during this time
// =============================================================================
always @(posedge clk_250 or negedge RESET_n) begin
   if(!RESET_n) begin
      rlol_sync     <= 4'b1111;
      rx_elec       <= 4'b1111;
      rlol_fclk     <= 4'b1111;
      rlol_rst_ch   <= 4'b1111;  //RLOL qualifed with EI
   end
   else begin
      // Use Masked RxElecIdle
      rx_elec       <= {RxElecIdle_ch3_8, RxElecIdle_ch2_8, RxElecIdle_ch1_8, RxElecIdle_ch0_8}; 

      //Sync
      rlol_sync     <= {Int_ffs_rlol_ch3, Int_ffs_rlol_ch2, Int_ffs_rlol_ch1, Int_ffs_rlol_ch0}; 
      rlol_fclk     <= rlol_sync;

      // Combine LOL and ElecIdle for sync_rst
      rlol_rst_ch[0] <= rlol_fclk[0] | rx_elec[0];
      rlol_rst_ch[1] <= rlol_fclk[1] | rx_elec[1];
      rlol_rst_ch[2] <= rlol_fclk[2] | rx_elec[2];
      rlol_rst_ch[3] <= rlol_fclk[3] | rx_elec[3];
   end
end

// ======================= RK MODIFICATIONS END ===============================




// =============================================================================
// pipe_top instantiation per channel
// =============================================================================
`ifdef Channel_0
   rc_pipe_top pipe_top_0(
     .RESET_n                (RESET_n) ,
     .PCLK                   (PCLK) ,
     .clk_250                (clk_250),

     .ffs_plol               (ffs_plol) ,
     .TxDetectRx_Loopback    (TxDetectRx_Loopback) , 
     .PowerDown              (PowerDown) ,
     .ctc_disable            (ctc_disable), 

     .TxData_in              (flip_TxData_0) ,
     .TxDataK_in             (flip_TxDataK_0) ,
     .TxElecIdle_in          (flip_TxElecIdle_0) ,
     .RxPolarity_in          (flip_RxPolarity_0) , 
     .RxData_in              (RxData_0_in) ,
     .RxDataK_in             (RxDataK_0_in) ,
     .RxStatus_in            (RxStatus_0_in) ,
     .RxValid_in             (RxValid_0_in) ,
     .RxElecIdle_in          (Int_RxElecIdle_ch0) ,

     .ff_rx_fclk_chx         (ff_rx_fclk_0) , 
     .pcie_con_x             (pcie_con_0),

     .pcs_wait_done          (pcs_wait_done),       //RK NEW
     .start_mask             (start_mask),          //RK NEW
     .detsm_done             (detsm_done),          //RK NEW
     .RxElecIdle_chx_8       (RxElecIdle_ch0_8),    //RK NEW

     .TxData_out             (TxData_0_out) ,
     .TxDataK_out            (TxDataK_0_out) ,
     .TxElecIdle_out         (TxElecIdle_0_out) ,   //RK NEW
     .RxPolarity_out         (RxPolarity_0_out) , 
     .RxData_out             (flip_RxData_0) ,
     .RxDataK_out            (flip_RxDataK_0) ,
     .RxStatus_out           (flip_RxStatus_0) ,
     .RxValid_out            (flip_RxValid_0) ,
     .RxElecIdle_out         (flip_RxElecIdle_0) ,

     .ffc_fb_loopback        (ffc_fb_loopback_0) 

     );
`endif 

`ifdef Channel_1
   rc_pipe_top pipe_top_1(
     .RESET_n                (RESET_n) ,
     .PCLK                   (PCLK) ,
     .clk_250                (clk_250),

     .ffs_plol               (ffs_plol) ,
     .TxDetectRx_Loopback    (TxDetectRx_Loopback) , 
     .PowerDown              (PowerDown) ,
     .ctc_disable            (ctc_disable), 

     .TxData_in             (flip_TxData_1) ,
     .TxDataK_in            (flip_TxDataK_1) ,
     .TxElecIdle_in         (flip_TxElecIdle_1) ,
     .RxPolarity_in         (flip_RxPolarity_1) , 
     .RxData_in             (RxData_1_in) ,
     .RxDataK_in            (RxDataK_1_in) ,
     .RxStatus_in           (RxStatus_1_in) ,
     .RxValid_in            (RxValid_1_in) ,
     .RxElecIdle_in         (Int_RxElecIdle_ch1) ,

     .ff_rx_fclk_chx        (ff_rx_fclk_1) , 
     .pcie_con_x             (pcie_con_1),

     .pcs_wait_done          (pcs_wait_done),
     .start_mask             (start_mask),
     .detsm_done             (detsm_done),
     .RxElecIdle_chx_8       (RxElecIdle_ch1_8),

     .TxData_out            (TxData_1_out) ,
     .TxDataK_out           (TxDataK_1_out) ,
     .TxElecIdle_out         (TxElecIdle_1_out) ,
     .RxPolarity_out        (RxPolarity_1_out) , 
     .RxData_out            (flip_RxData_1) ,
     .RxDataK_out           (flip_RxDataK_1) ,
     .RxStatus_out          (flip_RxStatus_1) ,
     .RxValid_out           (flip_RxValid_1) ,
     .RxElecIdle_out        (flip_RxElecIdle_1) ,

     .ffc_fb_loopback       (ffc_fb_loopback_1) 
     );
`endif

`ifdef Channel_2
   rc_pipe_top pipe_top_2(
     .RESET_n                (RESET_n) ,
     .PCLK                   (PCLK) ,
     .clk_250                (clk_250),

     .ffs_plol               (ffs_plol) ,
     .TxDetectRx_Loopback    (TxDetectRx_Loopback) , 
     .PowerDown              (PowerDown) ,
     .ctc_disable            (ctc_disable), 

     .TxData_in              (flip_TxData_2) ,
     .TxDataK_in             (flip_TxDataK_2) ,
     .TxElecIdle_in          (flip_TxElecIdle_2) ,
     .RxPolarity_in          (flip_RxPolarity_2) , 
     .RxData_in              (RxData_2_in) ,
     .RxDataK_in             (RxDataK_2_in) ,
     .RxStatus_in            (RxStatus_2_in) ,
     .RxValid_in             (RxValid_2_in) ,
     .RxElecIdle_in          (Int_RxElecIdle_ch2) ,

     .ff_rx_fclk_chx         (ff_rx_fclk_2) , 
     .pcie_con_x             (pcie_con_2),

     .pcs_wait_done          (pcs_wait_done),
     .start_mask             (start_mask),
     .detsm_done             (detsm_done),
     .RxElecIdle_chx_8       (RxElecIdle_ch2_8),

     .TxData_out             (TxData_2_out) ,
     .TxDataK_out            (TxDataK_2_out) ,
     .TxElecIdle_out         (TxElecIdle_2_out) ,
     .RxPolarity_out         (RxPolarity_2_out) , 
     .RxData_out             (flip_RxData_2) ,
     .RxDataK_out            (flip_RxDataK_2) ,
     .RxStatus_out           (flip_RxStatus_2) ,
     .RxValid_out            (flip_RxValid_2) ,
     .RxElecIdle_out         (flip_RxElecIdle_2) ,

     .ffc_fb_loopback        (ffc_fb_loopback_2) 
     );
`endif

`ifdef Channel_3
   rc_pipe_top pipe_top_3(
     .RESET_n                (RESET_n) ,
     .PCLK                   (PCLK) ,
     .clk_250                (clk_250),

     .ffs_plol               (ffs_plol) ,
     .TxDetectRx_Loopback    (TxDetectRx_Loopback) , 
     .PowerDown              (PowerDown) ,
     .ctc_disable            (ctc_disable), 

     .TxData_in              (flip_TxData_3) ,
     .TxDataK_in             (flip_TxDataK_3) ,
     .TxElecIdle_in          (flip_TxElecIdle_3) ,
     .RxPolarity_in          (flip_RxPolarity_3) , 
     .RxData_in              (RxData_3_in) ,
     .RxDataK_in             (RxDataK_3_in) ,
     .RxStatus_in            (RxStatus_3_in) ,
     .RxValid_in             (RxValid_3_in) ,
     .RxElecIdle_in          (Int_RxElecIdle_ch3) ,

     .ff_rx_fclk_chx         (ff_rx_fclk_3) , 
     .pcie_con_x             (pcie_con_3),

     .pcs_wait_done          (pcs_wait_done),
     .start_mask             (start_mask),
     .detsm_done             (detsm_done),
     .RxElecIdle_chx_8       (RxElecIdle_ch3_8),

     .TxData_out             (TxData_3_out) ,
     .TxDataK_out            (TxDataK_3_out) ,
     .TxElecIdle_out         (TxElecIdle_3_out) ,
     .RxPolarity_out         (RxPolarity_3_out) , 
     .RxData_out             (flip_RxData_3) ,
     .RxDataK_out            (flip_RxDataK_3) ,
     .RxStatus_out           (flip_RxStatus_3) ,
     .RxValid_out            (flip_RxValid_3) ,
     .RxElecIdle_out         (flip_RxElecIdle_3) ,

     .ffc_fb_loopback        (ffc_fb_loopback_3) 
     );
`endif
// =============================================================================
// pcs_top instantiation 
// =============================================================================
rc_pcs_top  pcs_top_0 (
   // Common for all 4 Channels
   // Resets
   .ffc_lane_tx_rst        (ffc_lane_tx_rst) ,
   .ffc_lane_rx_rst        (ffc_lane_rx_rst) ,
   .ffc_trst               (ffc_trst) ,
   .ffc_quad_rst           (ffc_quad_rst) ,
   .ffc_macro_rst          (ffc_macro_rst) ,

   // Clocks
   .refclkp                (refclkp) , 
   .refclkn                (refclkn) , 
   //.PCLK                   (PCLK) ,   --RK
   .PCLK                   (ff_tx_f_clk) , 
   `ifdef ECP3
      `ifdef Channel_0
         .ff_tx_f_clk_0   (ff_tx_f_clk_0) ,
         .ff_tx_h_clk_0   (ff_tx_h_clk_0) ,
      `endif
      `ifdef Channel_1
         .ff_tx_f_clk_1   (ff_tx_f_clk_1) ,
         .ff_tx_h_clk_1   (ff_tx_h_clk_1) ,
      `endif
      `ifdef Channel_2
         .ff_tx_f_clk_2   (ff_tx_f_clk_2) ,
         .ff_tx_h_clk_2   (ff_tx_h_clk_2) ,
      `endif
      `ifdef Channel_3
         .ff_tx_f_clk_3   (ff_tx_f_clk_3) ,
         .ff_tx_h_clk_3   (ff_tx_h_clk_3) ,
      `endif
   `else
   .ff_tx_f_clk            (ff_tx_f_clk) ,
   .ff_tx_h_clk            (ff_tx_h_clk) ,
   `endif
   
   .ffc_signal_detect      (ffc_signal_detect) ,
   .ffc_enb_cgalign        (ffc_enb_cgalign) ,
   .ffs_plol               (ffs_plol) ,

   // SCI Interface
   .sciwstn                (sciwstn) , 
   .sciwritedata           (sciwritedata),
   .sciaddress             (sciaddress) ,
   .scienaux               (scienaux) ,
   .sciselaux              (sciselaux) ,
   .scird                  (scird) ,
   .scireaddata            (scireaddata) ,

   `ifdef Channel_0
     .hdinp0                 (hdinp0) , 
     .hdinn0                 (hdinn0) , 
     .TxData_ch0             (TxData_0_out) ,  
     .TxDataK_ch0            (TxDataK_0_out) , 
     .TxCompliance_ch0       (flip_TxCompliance_0) ,   
     //.TxElecIdle_ch0         (flip_TxElecIdle_0) ,     //RK
     .TxElecIdle_ch0         (TxElecIdle_0_out),
     .ffc_txpwdnb_0          (ffc_pwdnb_0) ,  
     .ffc_rxpwdnb_0          (ffc_pwdnb_0) ,  
     .ffc_rrst_ch0           (ffc_rrst_0) , 
     .ffc_pcie_ct_ch0        (ffc_pcie_ct) ,  
     .ffc_pcie_det_en_ch0    (ffc_pcie_det_en_0) ,
     .ffc_fb_loopback_ch0    (ffc_fb_loopback_0) , 
     .RxPolarity_ch0         (RxPolarity_0_out) , 

     .scisel_ch0             (flip_scisel_0) , 
     .scien_ch0              (flip_scien_0) , 

     .ff_rx_fclk_ch0         (ff_rx_fclk_0) ,
     .hdoutp0                (hdoutp0) ,
     .hdoutn0                (hdoutn0) ,
     .RxData_ch0             (RxData_0_in) ,
     .RxDataK_ch0            (RxDataK_0_in) ,
     .RxStatus_ch0           (RxStatus_0_in) ,
     .RxValid_ch0            (RxValid_0_in) ,
     .RxElecIdle_ch0         (RxElecIdle_0_in) ,
     .ffs_rlol_ch0           (ffs_rlol_ch0) ,
     .ffs_pcie_done_0        (ffs_pcie_done_0) ,
     .ffs_pcie_con_0         (ffs_pcie_con_0) ,
   `endif
   `ifdef Channel_1
     .hdinp1                 (hdinp1) , 
     .hdinn1                 (hdinn1) , 
     .TxData_ch1             (TxData_1_out) ,  
     .TxDataK_ch1            (TxDataK_1_out) , 
     .TxCompliance_ch1       (flip_TxCompliance_1) ,   
     .TxElecIdle_ch1         (TxElecIdle_1_out),
     .ffc_txpwdnb_1          (ffc_pwdnb_1) ,  
     .ffc_rxpwdnb_1          (ffc_pwdnb_1) ,  
     .ffc_rrst_ch1           (ffc_rrst_1) , 
     .ffc_pcie_ct_ch1        (ffc_pcie_ct) ,  
     .ffc_pcie_det_en_ch1    (ffc_pcie_det_en_1) ,
     .ffc_fb_loopback_ch1    (ffc_fb_loopback_1) , 
     .RxPolarity_ch1         (RxPolarity_1_out) , 

     .scisel_ch1             (flip_scisel_1) , 
     .scien_ch1              (flip_scien_1) , 

     .ff_rx_fclk_ch1         (ff_rx_fclk_1) ,
     .hdoutp1                (hdoutp1) ,
     .hdoutn1                (hdoutn1) ,
     .RxData_ch1             (RxData_1_in) ,
     .RxDataK_ch1            (RxDataK_1_in) ,
     .RxStatus_ch1           (RxStatus_1_in) ,
     .RxValid_ch1            (RxValid_1_in) ,
     .RxElecIdle_ch1         (RxElecIdle_1_in) ,
     .ffs_rlol_ch1           (ffs_rlol_ch1) ,
     .ffs_pcie_done_1        (ffs_pcie_done_1) ,
     .ffs_pcie_con_1         (ffs_pcie_con_1) ,
   `endif
   `ifdef Channel_2
     .hdinp2                 (hdinp2) , 
     .hdinn2                 (hdinn2) , 
     .TxData_ch2             (TxData_2_out) ,  
     .TxDataK_ch2            (TxDataK_2_out) , 
     .TxCompliance_ch2       (flip_TxCompliance_2) ,   
     .TxElecIdle_ch2         (TxElecIdle_2_out),
     .ffc_txpwdnb_2          (ffc_pwdnb_2) ,  
     .ffc_rxpwdnb_2          (ffc_pwdnb_2) ,  
     .ffc_rrst_ch2           (ffc_rrst_2) , 
     .ffc_pcie_ct_ch2        (ffc_pcie_ct) ,  
     .ffc_pcie_det_en_ch2    (ffc_pcie_det_en_2) ,
     .ffc_fb_loopback_ch2    (ffc_fb_loopback_2) , 
     .RxPolarity_ch2         (RxPolarity_2_out) , 

     .scisel_ch2             (flip_scisel_2) , 
     .scien_ch2              (flip_scien_2) , 

     .ff_rx_fclk_ch2         (ff_rx_fclk_2) ,
     .hdoutp2                (hdoutp2) ,
     .hdoutn2                (hdoutn2) ,
     .RxData_ch2             (RxData_2_in) ,
     .RxDataK_ch2            (RxDataK_2_in) ,
     .RxStatus_ch2           (RxStatus_2_in) ,
     .RxValid_ch2            (RxValid_2_in) ,
     .RxElecIdle_ch2         (RxElecIdle_2_in) ,
     .ffs_rlol_ch2           (ffs_rlol_ch2) ,
     .ffs_pcie_done_2        (ffs_pcie_done_2) ,
     .ffs_pcie_con_2         (ffs_pcie_con_2) ,
   `endif 
   `ifdef Channel_3
     .hdinp3                 (hdinp3) , 
     .hdinn3                 (hdinn3) , 
     .TxData_ch3             (TxData_3_out) ,  
     .TxDataK_ch3            (TxDataK_3_out) , 
     .TxCompliance_ch3       (flip_TxCompliance_3) ,   
     .TxElecIdle_ch3         (TxElecIdle_3_out),
     .ffc_txpwdnb_3          (ffc_pwdnb_3) ,  
     .ffc_rxpwdnb_3          (ffc_pwdnb_3) ,  
     .ffc_rrst_ch3           (ffc_rrst_3) , 
     .ffc_pcie_ct_ch3        (ffc_pcie_ct) ,  
     .ffc_pcie_det_en_ch3    (ffc_pcie_det_en_3) ,
     .ffc_fb_loopback_ch3    (ffc_fb_loopback_3) , 
     .RxPolarity_ch3         (RxPolarity_3_out) , 

     .scisel_ch3             (flip_scisel_3) , 
     .scien_ch3              (flip_scien_3) , 

     .ff_rx_fclk_ch3         (ff_rx_fclk_3) ,
     .hdoutp3                (hdoutp3) ,
     .hdoutn3                (hdoutn3) ,
     .RxData_ch3             (RxData_3_in) ,
     .RxDataK_ch3            (RxDataK_3_in) ,
     .RxStatus_ch3           (RxStatus_3_in) ,
     .RxValid_ch3            (RxValid_3_in) ,
     .RxElecIdle_ch3         (RxElecIdle_3_in) ,
     .ffs_rlol_ch3           (ffs_rlol_ch3) ,
     .ffs_pcie_done_3        (ffs_pcie_done_3) ,
     .ffs_pcie_con_3         (ffs_pcie_con_3) ,
   `endif 

  .cin                    (cin) ,
  .cout                   (cout) 
);







// =============================================================================
// Enable detect signal for detect statemachine
// =============================================================================



assign enable_det_int = (PowerDown == 2'b10) & TxDetectRx_Loopback ;
`ifdef X4
   assign enable_det_all = (enable_det_int & flip_TxElecIdle_0 & flip_TxElecIdle_1 & 
	                                     flip_TxElecIdle_2 & flip_TxElecIdle_3) ? 1'b1 : 1'b0;
`endif 
// =============================================================================
//Assert enable det as long as TxDetectRx_Loopback is asserted by FPGA side
//when Serdes is in normal mode and TxElecIdle_ch0/1/2/3 is active.
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin //PIPE signals : Use hclk  -- RK
   if(!RESET_n) begin 
      enable_det_ch0 <= 1'b0;
      enable_det_ch1 <= 1'b0;
      enable_det_ch2 <= 1'b0;
      enable_det_ch3 <= 1'b0;
      detect_req     <= 1'b0;
      detect_req_del <= 1'b0;
   end 
   else begin 
   `ifdef X1
      `ifdef Channel_0  
         enable_det_ch0 <= (enable_det_int & flip_TxElecIdle_0) ? 1'b1 : 1'b0;
         detect_req     <= enable_det_ch0;
      `endif 
      `ifdef Channel_1  
         enable_det_ch1 <= (enable_det_int & flip_TxElecIdle_1) ? 1'b1 : 1'b0;
         detect_req     <= enable_det_ch1;
      `endif 
      `ifdef Channel_2  
         enable_det_ch2 <= (enable_det_int & flip_TxElecIdle_2) ? 1'b1 : 1'b0;
         detect_req     <= enable_det_ch2;
      `endif 
      `ifdef Channel_3   
         enable_det_ch3 <= (enable_det_int & flip_TxElecIdle_3) ? 1'b1 : 1'b0;
         detect_req     <= enable_det_ch3;
      `endif 
   `endif // X1

   `ifdef X4
      enable_det_ch0 <= enable_det_all ;
      enable_det_ch1 <= enable_det_all ;
      enable_det_ch2 <= enable_det_all ;
      enable_det_ch3 <= enable_det_all ;

      detect_req     <= enable_det_ch0 & enable_det_ch1 & enable_det_ch2 & enable_det_ch3;
   `endif // X4
    detect_req_del <= detect_req; // For Rising Edge
   end
end

// Use Flopped signals to see raising edge to remove any setup issues for
// data comming from PCS
assign done_0_re  = (done_0_d0 & !done_0_d1);
assign done_1_re  = (done_1_d0 & !done_1_d1);
assign done_2_re  = (done_2_d0 & !done_2_d1);
assign done_3_re  = (done_3_d0 & !done_3_d1);
assign done_all_re = done_all & !done_all_reg;
// =============================================================================
// The Following state machine generates the "ffc_pcie_det_done" and
// "ffc_pcie_ct" as per T-Spec page 81.
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if (!RESET_n) begin
      detsm_done         <= 0;
      ffc_pcie_ct        <= 0;
      ffc_pcie_det_en_0  <= 0;
      ffc_pcie_det_en_1  <= 0;
      ffc_pcie_det_en_2  <= 0;
      ffc_pcie_det_en_3  <= 0;
      cs_reqdet_sm       <= PCIE_DET_IDLE;
      cnt_enable         <= 1'b0;
      done_0_reg         <= 1'b0;
      done_0_d0          <= 1'b0;
      done_0_d1          <= 1'b0;
      done_1_reg         <= 1'b0;
      done_1_d0          <= 1'b0;
      done_1_d1          <= 1'b0;
      done_2_reg         <= 1'b0;
      done_2_d0          <= 1'b0;
      done_2_d1          <= 1'b0;
      done_3_reg         <= 1'b0;
      done_3_d0          <= 1'b0;
      done_3_d1          <= 1'b0;
      done_all           <= 1'b0;
      done_all_reg       <= 1'b0;
      det_result         <= 0;  // Only for RTL sim
   end
   else begin
      // Sync the async signal from PCS (dont use _reg signals)
      `ifdef Channel_0
         done_0_reg   <= ffs_pcie_done_0;
         done_0_d0    <= done_0_reg;
         done_0_d1    <= done_0_d0;
      `endif 
      `ifdef Channel_1
         done_1_reg   <= ffs_pcie_done_1;
         done_1_d0    <= done_1_reg;
         done_1_d1    <= done_1_d0;
      `endif 
      `ifdef Channel_2
         done_2_reg   <= ffs_pcie_done_2;
         done_2_d0    <= done_2_reg;
         done_2_d1    <= done_2_d0;
      `endif 
      `ifdef Channel_3
         done_3_reg   <= ffs_pcie_done_3;
         done_3_d0    <= done_3_reg;
         done_3_d1    <= done_3_d0;
      `endif 

      done_all_reg <= done_all;

      `ifdef X4
         done_all  <=  done_0_d1 & done_1_d1 & done_2_d1 & done_3_d1;  
      `endif 
      `ifdef X1
         `ifdef Channel_0
            done_all  <=  done_0_d1;
         `endif
         `ifdef Channel_1
            done_all  <=  done_1_d1;
         `endif
         `ifdef Channel_2
            done_all  <=  done_2_d1;
         `endif
         `ifdef Channel_3
            done_all  <=  done_3_d1;
         `endif
      `endif

      case(cs_reqdet_sm) //----- Wait for Det Request
      PCIE_DET_IDLE: begin
         ffc_pcie_det_en_0 <= 1'b0;
         ffc_pcie_det_en_1 <= 1'b0;
         ffc_pcie_det_en_2 <= 1'b0;
         ffc_pcie_det_en_3 <= 1'b0;
         ffc_pcie_ct       <= 1'b0;
         cnt_enable        <= 1'b0;
         detsm_done        <= 1'b0;

         // Rising Edge of Det Request
	 if (detect_req == 1'b1 && detect_req_del == 1'b0) begin
            cs_reqdet_sm      <= PCIE_DET_EN;
            ffc_pcie_det_en_0 <= 1'b1;
            ffc_pcie_det_en_1 <= 1'b1;
            ffc_pcie_det_en_2 <= 1'b1;
            ffc_pcie_det_en_3 <= 1'b1;
            cnt_enable        <= 1'b1;
         end 
      end
      // Wait for 120 Ns
      PCIE_DET_EN: begin
	 if (cntdone_en) begin
	    cs_reqdet_sm <= PCIE_CT;
            ffc_pcie_ct  <= 1'b1;
            //cnt_enable   <= 1'b0;   //Reset the counter
         end
      end
      // Wait for 4 Byte Clocks
      PCIE_CT: begin
         //cnt_enable    <= 1'b1;  // Enable for Count 2
	 if (cntdone_ct) begin
	    cs_reqdet_sm <= PCIE_DONE;
            ffc_pcie_ct  <= 1'b0;
         end
                  // synopsys translate_off
                    det_result <= 4'b0000;
                  // synopsys translate_on
      end
      // Wait for done to go high for all channels
      PCIE_DONE: begin
         cnt_enable  <= 1'b0;

         // ALL DONEs are asserted   (Rising Edge)
         if (done_all_re) begin //pulse
            cs_reqdet_sm   <= PCIE_DET_IDLE;
            detsm_done     <= 1'b1;
         end

         // DONE makes det_en ZERO individually (DONE Rising Edge)
         if (done_0_re) begin //pulse
            ffc_pcie_det_en_0   <= 1'b0; 
                  // synopsys translate_off
                  det_result[0] <= 1'b1;
                  // synopsys translate_on
         end
         if (done_1_re) begin //pulse
            ffc_pcie_det_en_1   <= 1'b0; 
                  // synopsys translate_off
                  det_result[1] <= 1'b1;
                  // synopsys translate_on
         end
         if (done_2_re) begin //pulse
            ffc_pcie_det_en_2   <= 1'b0; 
                  // synopsys translate_off
                  det_result[2] <= 1'b1;
                  // synopsys translate_on
         end
         if (done_3_re) begin //pulse
            ffc_pcie_det_en_3   <= 1'b0; 
                  // synopsys translate_off
                  det_result[3] <= 1'b1;
                  // synopsys translate_on
         end
      end
      endcase

   end
end

always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if(!RESET_n) begin
      detsm_cnt  <= 'd0; 
      cntdone_en <= 1'b0;
      cntdone_ct <= 1'b0;
   end 
   else begin
      // Detect State machine Counter
      if (cnt_enable)
          detsm_cnt <= detsm_cnt + 1'b1;
      else
          detsm_cnt <= 0;

      // pcie_det_en time 
      if (detsm_cnt == ONE_US) // 1 us
          cntdone_en <= 1'b1;
      else
          cntdone_en <= 1'b0;
 
      // pcie_ct time 
      if (detsm_cnt == ONE_US_4BYTE) // 2 clks = 16 ns -> 4 byte clks
          cntdone_ct <= 1'b1;
      else
          cntdone_ct <= 1'b0;

      // synopsys translate_off
            // pcie_det_en time -- after 16 clks
            if (detsm_cnt[4:0] == 5'b10000) // 1 us --> 16 clks
                cntdone_en <= 1'b1;
            else
                cntdone_en <= 1'b0;

            // pcie_ct time -- after 19 clks
            if (detsm_cnt[4:0] == 5'b10011) // 2 clks = 16 ns -> 4 byte clks
                cntdone_ct <= 1'b1;
            else
                cntdone_ct <= 1'b0;
      // synopsys translate_on

   end
end

// =============================================================================
// PhyStatus Generation - Det Result and State Changes
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if(!RESET_n) begin
      PhyStatus         <= 1'b1;
      PowerDown_reg     <= 2'b00;
      PLOL_sync         <= 1'b1;
      PLOL_pclk         <= 1'b1;
   end
   else begin
      // Sync.
      PLOL_sync <= ffs_plol;
      PLOL_pclk <= PLOL_sync;

      PowerDown_reg <= PowerDown;

      if (PLOL_pclk == 1'b0) begin // wait for PLL LOCK
          if ((PowerDown_reg == 2'b00 && PowerDown == 2'b11) ||
              (PowerDown_reg == 2'b11 && PowerDown == 2'b10) ||
              (PowerDown_reg == 2'b00 && PowerDown == 2'b01) ||
              (PowerDown_reg == 2'b01 && PowerDown == 2'b00) ||
              (PowerDown_reg == 2'b00 && PowerDown == 2'b10) ||
              (PowerDown_reg == 2'b10 && PowerDown == 2'b00) ||
              (detsm_done == 1'b1)) 
              PhyStatus     <= 1'b1;
          else
              PhyStatus     <= 1'b0;
      end
   end
end




endmodule
