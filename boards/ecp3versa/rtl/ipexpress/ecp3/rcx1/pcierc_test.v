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
// Project          : USERNAME
// File             : USERNAME.v
// Title            :
// Dependencies     : 
// Description      : Top level for core. 
// =============================================================================
module pcierc_test (
   input wire             sys_clk_250,     // 250 Mhz Clock     
   input wire             sys_clk_125,     // 125 Mhz Clock     
   input wire             rst_n,           // asynchronous system reset.

   input wire [3:0]       phy_force_cntl,   // debug force bus
                                            // [0] - Force LSM Status Active
                                            // [1] - Force Received Electrical Idle
                                            // [2] - Force PHY Connection Status
                                            // [3] - Force Disable Scrambler to PCS

   input wire [12:0]      phy_ltssm_cntl,   // LTSSM control bus
                                            // [0] - Disable the training process
                                            // [1] - Force to retraing Link
                                            // [2] - HL req. to Disable Scrambling bit in TS1/TS2 
                                            // [3] - HL req a jump to Disable
                                            // [4] - HL req a jump to detect
                                            // [5] - HL req a jump to Hot reset
                                            // [6] - HL req a jump to TX L0s
                                            // [7] - HL req a jump to L1
                                            // [8] - HL req a jump to L2 
                                            // [9] - HL req a jump to L0s TX FTS 
                                            // [10] - HL req a jump to Loopback
                                            // [11] - HL req a jump to recovery 
                                            // [12] - HL req a jump to CFG 


   // Power Management Interface
   input wire  [1:0]         tx_dllp_val,         // Req for Sending PM/Vendor type DLLP
   input wire  [2:0]         tx_pmtype,           // Power Management Type
   input wire  [23:0]        tx_vsd_data,         // Vendor Type DLLP contents

   // For VC Inputs 
   input wire                tx_req_vc0,          // VC0 Request from User  
   input wire [15:0]         tx_data_vc0,         // VC0 Input data from user logic 
   input wire                tx_st_vc0,           // VC0 start of pkt from user logic.  
   input wire                tx_end_vc0,          // VC0 End of pkt from user logic. 
   input wire                tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.  
   input wire                ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
   input wire                pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
   input wire                nph_buf_status_vc0,  // VC0 For NPH
   input wire                npd_buf_status_vc0,  // VC0 For NPD
   input wire                cplh_buf_status_vc0, // VC0 For CPLH
   input wire                cpld_buf_status_vc0, // VC0 For CPLD
   input wire                ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
   input wire                pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
   input wire                nph_processed_vc0,   // VC0 For NPH
   input wire                npd_processed_vc0,   // VC0 For NPD
   input wire                cplh_processed_vc0,  // VC0 For CPLH
   input wire                cpld_processed_vc0,  // VC0 For CPLD
   input wire [7:0]          pd_num_vc0,          // VC0 For PD -- No. of Data processed
   input wire [7:0]          npd_num_vc0,         // VC0 For PD
   input wire [7:0]          cpld_num_vc0,        // VC0 For CPLD

   input wire  [7:0]         rxp_data,        // LN0:PCI Express data from External Phy
   input wire                rxp_data_k,      // LN0:PCI Express Control from External Phy 
   input wire                rxp_valid,       // LN0:Indicates a symbol lock and valid data on rx_data /rx_data_k 
   input wire                rxp_elec_idle,   // LN0:Inidicates receiver detection of an electrical signal  
   input wire  [2:0]         rxp_status,      // LN0:Indicates receiver Staus/Error codes 

   input wire                phy_status,          // Indicates PHY status info  

   // User Loop back data
   input wire  [15:0]        tx_lbk_data,     // TX User Master Loopback data
   input wire  [1:0]         tx_lbk_kcntl,    // TX User Master Loopback control
   output wire               tx_lbk_rdy,      // TX loop back is ready to accept data
   output wire [15:0]        rx_lbk_data,     // RX User Master Loopback data
   output wire [1:0]         rx_lbk_kcntl,    // RX User Master Loopback control

   // Power Management/ Vendor specific DLLP
   output wire               tx_dllp_sent,    // Requested PM DLLP is sent
   output wire [2:0]         rxdp_pmd_type,   // PM DLLP type bits.
   output wire [23:0]        rxdp_vsd_data ,  // Vendor specific DLLP data.
   output wire [1:0]         rxdp_dllp_val,   // PM/Vendor specific DLLP valid.

   output wire [7:0]         txp_data,        // LN0:PCI Express data to External Phy
   output wire               txp_data_k,      // LN0:PCI Express control to External Phy
   output wire               txp_elec_idle,   // LN0:Tells PHY to output Electrical Idle 
   output wire               txp_compliance,  // LN0:Sets the PHY running disparity to -ve 
   output wire               rxp_polarity,    // LN0:Tells PHY to do polarity inversion on the received data

   output wire               txp_detect_rx_lb,   // Tells PHY to begin receiver detection or begin Loopback 
   output wire               reset_n,            // Async reset to the PHY
   output wire [1:0]         power_down,         // Tell sthe PHY to power Up or Down

   output wire               tx_rdy_vc0,         // VC0 TX ready indicating signal
   output wire [8:0]         tx_ca_ph_vc0,       // VC0 Available credit for Posted Type Headers
   output wire [12:0]        tx_ca_pd_vc0,       // VC0 For Posted - Data
   output wire [8:0]         tx_ca_nph_vc0,      // VC0 For Non-posted - Header
   output wire [12:0]        tx_ca_npd_vc0,      // VC0 For Non-posted - Data
   output wire [8:0]         tx_ca_cplh_vc0,     // VC0 For Completion - Header
   output wire [12:0]        tx_ca_cpld_vc0,     // VC0 For Completion - Data

   output wire [15:0]        rx_data_vc0,        // VC0 Receive data
   output wire               rx_st_vc0,          // VC0 Receive data start
   output wire               rx_end_vc0,         // VC0 Receive data end
   output wire               rx_pois_tlp_vc0 ,   // VC0 poisoned tlp received  
   output wire               rx_malf_tlp_vc0 ,   // VC0 malformed TLP in received data 

   // FROM TRN
   output wire               inta_n ,            // INTA interrupt
   output wire               intb_n ,            // INTB interrupt
   output wire               intc_n ,            // INTC interrupt
   output wire               intd_n ,            // INTD interrupt
   output wire               ftl_err_msg ,       // Fata error message received
   output wire               nftl_err_msg ,      // non-Fatal error message received
   output wire               cor_err_msg ,       // Correctable error message received

   // FROM DLL
   output wire [7:0]         dll_status,     // DLL status bus
                                            // [0] - DL_Up, Data link layer is ready
                                            // [1] - DL_init, DLL is in DL_Init state. 
                                            // [2] - DL_inact, DLL is in DL_Inact state. 
                                            // [3] - Bad_dllp, DLL receivced a bad DLLP.
                                            // [4] - DL error, DLL protocol error
                                            // [5] - Bad TLP,  DLL receivced a bad TLP
                                            // [6] - rply_tout, DLL replay timeout indication
                                            // [7] - rnum_rlor, replay number roll over in DLL

   // FROM PHY
   output wire [2:0]         phy_cfgln_sum,      // Number of Configured lanes
   output wire               phy_pol_compliance, // Polling compliance 
   output wire [3:0]         phy_ltssm_state,    // Indicates the states of the ltssm 
   output wire [2:0]         phy_ltssm_substate  // sub-states of the ltssm_state

  );
pci_exp_x1_core_wrap_rc u1_dut (
   .sys_clk_250(sys_clk_250),
   .sys_clk_125(sys_clk_125),
   .rst_n(rst_n),

   .phy_force_cntl(phy_force_cntl),
   .phy_ltssm_cntl(phy_ltssm_cntl),
   // Power Management Interface
   .tx_dllp_val(tx_dllp_val),
   .tx_pmtype(tx_pmtype),
   .tx_vsd_data(tx_vsd_data),

   // For VC Inputs 
   .tx_req_vc0(tx_req_vc0),
   .tx_data_vc0(tx_data_vc0),
   .tx_st_vc0(tx_st_vc0),
   .tx_end_vc0(tx_end_vc0),
   .tx_nlfy_vc0(tx_nlfy_vc0),
   .ph_buf_status_vc0(ph_buf_status_vc0),
   .pd_buf_status_vc0(pd_buf_status_vc0),
   .nph_buf_status_vc0(nph_buf_status_vc0),
   .npd_buf_status_vc0(npd_buf_status_vc0),
   .cplh_buf_status_vc0(cplh_buf_status_vc0),
   .cpld_buf_status_vc0(cpld_buf_status_vc0),
   .ph_processed_vc0(ph_processed_vc0),
   .pd_processed_vc0(pd_processed_vc0),
   .nph_processed_vc0(nph_processed_vc0),
   .npd_processed_vc0(npd_processed_vc0),
   .cplh_processed_vc0(cplh_processed_vc0),
   .cpld_processed_vc0(cpld_processed_vc0),
   .pd_num_vc0(pd_num_vc0),
   .npd_num_vc0(npd_num_vc0),
   .cpld_num_vc0(cpld_num_vc0),

   .rxp_data(rxp_data),
   .rxp_data_k(rxp_data_k),
   .rxp_valid(rxp_valid),
   .rxp_elec_idle(rxp_elec_idle),
   .rxp_status(rxp_status),

   .phy_status(phy_status),

   // User Loop back data
   .tx_lbk_data(tx_lbk_data),
   .tx_lbk_kcntl(tx_lbk_kcntl),
   .tx_lbk_rdy(tx_lbk_rdy),
   .rx_lbk_data(rx_lbk_data),
   .rx_lbk_kcntl(rx_lbk_kcntl),

   // Power Management/ Vendor specific DLLP
   .tx_dllp_sent(tx_dllp_sent),
   .rxdp_pmd_type(rxdp_pmd_type),
   .rxdp_vsd_data (rxdp_vsd_data),
   .rxdp_dllp_val(rxdp_dllp_val),

   .txp_data(txp_data),
   .txp_data_k(txp_data_k),
   .txp_elec_idle(txp_elec_idle),
   .txp_compliance(txp_compliance),
   .rxp_polarity(rxp_polarity),

   .txp_detect_rx_lb(txp_detect_rx_lb),
   .reset_n(reset_n),
   .power_down(power_down),

   .tx_rdy_vc0(tx_rdy_vc0),
   .tx_ca_ph_vc0(tx_ca_ph_vc0),
   .tx_ca_pd_vc0(tx_ca_pd_vc0),
   .tx_ca_nph_vc0(tx_ca_nph_vc0),
   .tx_ca_npd_vc0(tx_ca_npd_vc0),
   .tx_ca_cplh_vc0(tx_ca_cplh_vc0),
   .tx_ca_cpld_vc0(tx_ca_cpld_vc0),

   .rx_data_vc0(rx_data_vc0),
   .rx_st_vc0(rx_st_vc0),
   .rx_end_vc0(rx_end_vc0),
   .rx_pois_tlp_vc0 (rx_pois_tlp_vc0),
   .rx_malf_tlp_vc0 (rx_malf_tlp_vc0),
   // FROM TRN
   .inta_n (inta_n),
   .intb_n (intb_n),
   .intc_n (intc_n),
   .intd_n (intd_n),
   .ftl_err_msg (ftl_err_msg),
   .nftl_err_msg (nftl_err_msg),
   .cor_err_msg (cor_err_msg),
   // FROM DLL
   .dll_status(dll_status),
   // FROM PHY
   .phy_cfgln_sum(phy_cfgln_sum),
   .phy_pol_compliance(phy_pol_compliance),
   .phy_ltssm_state(phy_ltssm_state),
   .phy_ltssm_substate(phy_ltssm_substate)
  );
endmodule
