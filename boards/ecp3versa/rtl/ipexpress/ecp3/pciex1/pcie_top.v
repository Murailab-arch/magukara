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
// Project          : pci_express_top
// File             : pci_express_top.v
// Title            :
// Dependencies     : 
// Description      : Top level for core. 
// =============================================================================
module pcie_top (
   // Clock and Reset
   input wire                     refclkp,        // 100MHz from board
   input wire                     refclkn,        // 100MHz from board
   input wire                     rst_n,

// ASIC side pins for PCSA.  These pins must exist for the PCS core.
   input  wire                    hdinp0,         
   input  wire                    hdinn0,         
   output wire                    hdoutp0,        
   output wire                    hdoutn0,        

   input wire                     flip_lanes ,         

   input wire                     inta_n,           
   input wire  [7:0]              msi,              
   input wire [15:0]              vendor_id ,       
   input wire [15:0]              device_id ,       
   input wire [7:0]               rev_id ,          
   input wire [23:0]              class_code ,      
   input wire [15:0]              subsys_ven_id ,   
   input wire [15:0]              subsys_id ,       
   input wire                     load_id ,         

   input wire                     force_lsm_active, //  Force LSM Status Active
   input wire                     force_rec_ei,     //  Force Received Electrical Idle
   input wire                     force_phy_status, //  Force PHY Connection Status
   input wire                     force_disable_scr,//  Force Disable Scrambler to PCS
                                  
   input wire                     hl_snd_beacon,    // HL req. to Send Beacon
   input wire                     hl_disable_scr,   // HL req. to Disable Scrambling bit in TS1/TS2 
   input wire                     hl_gto_dis,       // HL req a jump to Disable
   input wire                     hl_gto_det,       // HL req a jump to detect
   input wire                     hl_gto_hrst,      // HL req a jump to Hot reset
   input wire                     hl_gto_l0stx,     // HL req a jump to TX L0s
   input wire                     hl_gto_l1,        // HL req a jump to L1
   input wire                     hl_gto_l2,        // HL req a jump to L2 
   input wire                     hl_gto_l0stxfts,  // HL req a jump to L0s TX FTS 
   input wire                     hl_gto_lbk,       // HL req a jump to Loopback
   input wire                     hl_gto_rcvry,     // HL req a jump to recovery 
   input wire                     hl_gto_cfg,       // HL req a jump to CFG 
   input wire                     no_pcie_train,    // Disable the training process

   // Power Management Interface
   input wire  [1:0]              tx_dllp_val,      // Req for Sending PM/Vendor type DLLP
   input wire  [2:0]              tx_pmtype,        // Power Management Type
   input wire  [23:0]             tx_vsd_data,      // Vendor Type DLLP contents

// For VC Inputs 
   input wire                     tx_req_vc0,          // VC0 Request from User  
   input wire [15:0]              tx_data_vc0,         // VC0 Input data from user logic 
   input wire                     tx_st_vc0,           // VC0 start of pkt from user logic.  
   input wire                     tx_end_vc0,          // VC0 End of pkt from user logic. 
   input wire                     tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.  
   input wire                     ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
   input wire                     pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
   input wire                     nph_buf_status_vc0,  // VC0 For NPH
   input wire                     npd_buf_status_vc0,  // VC0 For NPD
   input wire                     ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
   input wire                     pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
   input wire                     nph_processed_vc0,   // VC0 For NPH
   input wire                     npd_processed_vc0,   // VC0 For NPD
   input wire [7:0]               pd_num_vc0,          // VC0 For PD -- No. of Data processed
   input wire [7:0]               npd_num_vc0,         // VC0 For PD

   // From User logic
   input wire                     cmpln_tout ,     // Completion time out.
   input wire                     cmpltr_abort_np ,   // Completor abort.
   input wire                     cmpltr_abort_p ,   // Completor abort.
   input wire                     unexp_cmpln ,    // Unexpexted completion.
   input wire                     ur_np_ext ,      // UR for NP type.
   input wire                     ur_p_ext ,       // UR for P type.
   input wire                     np_req_pend ,    // Non posted request is pending.
   input wire                     pme_status ,     // PME status to reg 044h.
                                  
   // User Loop back data         
   input wire  [15:0]             tx_lbk_data,     // TX User Master Loopback data
   input wire  [1:0]              tx_lbk_kcntl,    // TX User Master Loopback control
                                  
                                  
   output wire                    tx_lbk_rdy,      // TX loop back is ready to accept data
   output wire [15:0]             rx_lbk_data,     // RX User Master Loopback data
   output wire [1:0]              rx_lbk_kcntl,    // RX User Master Loopback control

   // Power Management/ Vendor specific DLLP
   output wire                    tx_dllp_sent,    // Requested PM DLLP is sent
   output wire [2:0]              rxdp_pmd_type,   // PM DLLP type bits.
   output wire [23:0]             rxdp_vsd_data ,  // Vendor specific DLLP data.
   output wire [1:0]              rxdp_dllp_val,   // PM/Vendor specific DLLP valid.

   output wire                    phy_pol_compliance,  // Polling compliance 
   output wire [3:0]              phy_ltssm_state,     // Indicates the states of the ltssm 
   output wire [2:0]              phy_ltssm_substate,  // sub-states of the ltssm_state

//---------Outputs------------
   output wire                    tx_rdy_vc0,      // VC0 TX ready indicating signal
   output wire [8:0]              tx_ca_ph_vc0,    // VC0 Available credit for Posted Type Headers
   output wire [12:0]             tx_ca_pd_vc0,    // VC0 For Posted - Data
   output wire [8:0]              tx_ca_nph_vc0,   // VC0 For Non-posted - Header
   output wire [12:0]             tx_ca_npd_vc0,   // VC0 For Non-posted - Data
   output wire [8:0]              tx_ca_cplh_vc0,  // VC0 For Completion - Header
   output wire [12:0]             tx_ca_cpld_vc0,  // VC0 For Completion - Data
   output wire                    tx_ca_p_recheck_vc0, //
   output wire                    tx_ca_cpl_recheck_vc0, //
   output wire [15:0]             rx_data_vc0,     // VC0 Receive data
   output wire                    rx_st_vc0,       // VC0 Receive data start
   output wire                    rx_end_vc0,      // VC0 Receive data end
   output wire                    rx_us_req_vc0 ,  // VC0 unsupported req received  
   output wire                    rx_malf_tlp_vc0 ,// VC0 malformed TLP in received data 

   output wire [6:0]              rx_bar_hit ,     // Bar hit
   output wire [2:0]              mm_enable ,     // Multiple message enable bits of Register
   output wire                    msi_enable ,    // MSI enable bit of Register
                                  
   // From Config Registers       
   output wire [7:0]              bus_num ,        // Bus number
   output wire [4:0]              dev_num ,        // Device number
   output wire [2:0]              func_num ,       // Function number
   output wire [1:0]              pm_power_state , // Power state bits of Register at 044h
   output wire                    pme_en ,         // PME_En at 044h
   output wire [5:0]              cmd_reg_out ,    // Bits 10,8,6,2,1,0 From register 004h
   output wire [14:0]             dev_cntl_out ,   // Divice control register at 060h 
   output wire [7:0]              lnk_cntl_out ,   // Link control register at 068h 

   // Datal Link Control SM Status
   output wire                    dl_inactive,     // Data Link Control SM is in INACTIVE state
   output wire                    dl_init,         // INIT state
   output wire                    dl_active,       // ACTIVE state
   output wire                    dl_up,           // Data Link Layer is UP 
   output wire                    sys_clk_125      // 125MHz output clock from core 

  );

// =============================================================================
// Define Wires & Regs
// =============================================================================
reg   [19:0]             rstn_cnt;
reg                      core_rst_n; 
wire                     irst_n ;

wire  [1:0]              power_down;  
wire                     tx_detect_rx_lb;
wire                     phy_status;

wire  [7:0]              txp_data;
wire                     txp_data_k;
wire                     txp_elec_idle;
wire                     txp_compliance;

wire  [7:0]              rxp_data;
wire                     rxp_data_k;
wire                     rxp_valid;
wire                     rxp_polarity;
wire                     rxp_elec_idle;
wire  [2:0]              rxp_status;

wire                     pclk;           //250MHz clk from PCS PIPE for 8 bit data
wire                     phy_l0;  

assign phy_l0         = (phy_ltssm_state == 'd3) ;

// =============================================================================
// Reset management
// =============================================================================
always @(posedge sys_clk_125 or negedge rst_n) begin
   if (!rst_n) begin
       rstn_cnt   <= 20'd0 ;
       core_rst_n <= 1'b0 ;
   end
   else begin
      if (rstn_cnt[19])            // 4ms in real hardware
         core_rst_n <= 1'b1 ;
      // synthesis translate_off
         else if (rstn_cnt[7])     // 128 clocks 
            core_rst_n <= 1'b1 ;
      // synthesis translate_on
      else 
         rstn_cnt <= rstn_cnt + 1'b1 ;
   end
end

GSR GSR_INST (.GSR(rst_n));
PUR PUR_INST (.PUR(1'b1));

// Connect rst_n pin to GSR, pipe wrapper, core and user logic
// assign irst_n = rst_n ;            
// Connect rst_n pin to pipe wrapper, 4ms delayed rst_n to core and user logic
assign irst_n = core_rst_n ; 

// =============================================================================
// SERDES/PCS instantiation in PIPE mode
// =============================================================================
pcs_pipe_top u1_pcs_pipe (
        .refclkp                ( refclkp ), 
        .refclkn                ( refclkn ), 
        .ffc_quad_rst           ( ~rst_n ), 
        .RESET_n                ( rst_n ),

        .hdinp0                 ( hdinp0 ), 
        .hdinn0                 ( hdinn0 ), 
        .hdoutp0                ( hdoutp0 ), 
        .hdoutn0                ( hdoutn0 ), 

        .TxData_0               ( txp_data ), 
        .TxDataK_0              ( txp_data_k ), 
        .TxCompliance_0         ( txp_compliance ), 
        .TxElecIdle_0           ( txp_elec_idle ), 
        
        .RxData_0               ( rxp_data ), 
        .RxDataK_0              ( rxp_data_k ), 
        .RxValid_0              ( rxp_valid ), 
        .RxPolarity_0           ( rxp_polarity ), 
        .RxElecIdle_0           ( rxp_elec_idle ), 
        .RxStatus_0             ( rxp_status ), 
       
        .scisel_0               ( 1'b0 ),
        .scien_0                ( 1'b0 ),   
        .sciwritedata           ( 8'h0 ),
        .sciaddress             ( 6'h0 ),
        .scireaddata            (  ),
        .scienaux               ( 1'b0 ),
        .sciselaux              ( 1'b0 ),
        .scird                  ( 1'b0 ),
        .sciwstn                ( 1'b0 ),
        .ffs_plol               ( ), 
        .ffs_rlol_ch0           ( ), 
        .flip_lanes             ( flip_lanes ), 

        .PCLK                   ( pclk ),
        .PCLK_by_2              ( sys_clk_125 ),
        .TxDetectRx_Loopback    ( tx_detect_rx_lb ), 
        .PhyStatus              ( phy_status ), 
        .PowerDown              ( power_down ), 
        .phy_l0                 ( phy_l0 ), 
        .phy_cfgln              ( 4'b0000 ),      //Not required (unused in X1 mode)
        .ctc_disable            ( 1'b0 )
        );

// =============================================================================
// PCI Express Core
// =============================================================================
pcie u1_dut(
   // Clock and Reset
   .sys_clk_250                ( pclk ) ,
   .sys_clk_125                ( sys_clk_125 ) ,
   .rst_n                      ( irst_n ),

   .inta_n                     ( inta_n ),
   .msi                        ( msi ),
   .vendor_id                  ( vendor_id     ),    
   .device_id                  ( device_id     ),    
   .rev_id                     ( rev_id        ),    
   .class_code                 ( class_code    ),    
   .subsys_ven_id              ( subsys_ven_id ),    
   .subsys_id                  ( subsys_id     ),    
   .load_id                    ( load_id       ),    

   // Inputs
   .force_lsm_active           ( force_lsm_active  ), 
   .force_rec_ei               ( force_rec_ei      ),     
   .force_phy_status           ( force_phy_status  ), 
   .force_disable_scr          ( force_disable_scr ),
                                                  
   .hl_snd_beacon              ( hl_snd_beacon     ),
   .hl_disable_scr             ( hl_disable_scr    ),
   .hl_gto_dis                 ( hl_gto_dis        ),
   .hl_gto_det                 ( hl_gto_det        ),
   .hl_gto_hrst                ( hl_gto_hrst       ),
   .hl_gto_l0stx               ( hl_gto_l0stx      ),
   .hl_gto_l1                  ( hl_gto_l1         ),
   .hl_gto_l2                  ( hl_gto_l2         ),
   .hl_gto_l0stxfts            ( hl_gto_l0stxfts   ),
   .hl_gto_lbk                 ( hl_gto_lbk        ),
   .hl_gto_rcvry               ( hl_gto_rcvry      ),
   .hl_gto_cfg                 ( hl_gto_cfg        ),
   .no_pcie_train              ( no_pcie_train     ),    

   // Power Management Interface
   .tx_dllp_val                (tx_dllp_val  ),
   .tx_pmtype                  (tx_pmtype    ),
   .tx_vsd_data                (tx_vsd_data  ),

   .tx_req_vc0                 ( tx_req_vc0 ),    
   .tx_data_vc0                ( tx_data_vc0 ),    
   .tx_st_vc0                  ( tx_st_vc0 ), 
   .tx_end_vc0                 ( tx_end_vc0 ), 
   .tx_nlfy_vc0                ( tx_nlfy_vc0 ), 
   .ph_buf_status_vc0          ( ph_buf_status_vc0 ),
   .pd_buf_status_vc0          ( pd_buf_status_vc0 ),
   .nph_buf_status_vc0         ( nph_buf_status_vc0 ),
   .npd_buf_status_vc0         ( npd_buf_status_vc0 ),
   .ph_processed_vc0           ( ph_processed_vc0 ),
   .pd_processed_vc0           ( pd_processed_vc0 ),
   .nph_processed_vc0          ( nph_processed_vc0 ),
   .npd_processed_vc0          ( npd_processed_vc0 ),
   .pd_num_vc0                 ( pd_num_vc0  ),
   .npd_num_vc0                ( npd_num_vc0 ),
   
   
   
   
   
   
   

    // From  External PHY (PIPE I/F)
   .rxp_data                   ( rxp_data ),            
   .rxp_data_k                 ( rxp_data_k ),          
   .rxp_valid                  ( rxp_valid ),         
   .rxp_elec_idle              ( rxp_elec_idle ),    
   .rxp_status                 ( rxp_status ),      
   .phy_status                 ( phy_status),    

   
   // From User logic
   .cmpln_tout                 ( cmpln_tout    ),       
   .cmpltr_abort_np            ( cmpltr_abort_np ),       
   .cmpltr_abort_p             ( cmpltr_abort_p ),       
   .unexp_cmpln                ( unexp_cmpln   ),       
   .ur_np_ext                  ( ur_np_ext     ) ,  
   .ur_p_ext                   ( ur_p_ext      ) ,  
   .np_req_pend                ( np_req_pend   ),     
   .pme_status                 ( pme_status    ),     
                                              
   .tx_lbk_data                ( tx_lbk_data   ),
   .tx_lbk_kcntl               ( tx_lbk_kcntl  ),
                                              
   .tx_lbk_rdy                 ( tx_lbk_rdy    ),
   .rx_lbk_data                ( rx_lbk_data   ),
   .rx_lbk_kcntl               ( rx_lbk_kcntl  ),

   // Power Management         
   .tx_dllp_sent               ( tx_dllp_sent  ),
   .rxdp_pmd_type              ( rxdp_pmd_type ),
   .rxdp_vsd_data              ( rxdp_vsd_data ),
   .rxdp_dllp_val              ( rxdp_dllp_val ),

   //-------- Outputs
   // To External PHY (PIPE I/F)
   .txp_data                   ( txp_data ),
   .txp_data_k                 ( txp_data_k ),
   .txp_elec_idle              ( txp_elec_idle ), 
   .txp_compliance             ( txp_compliance ),  
   .rxp_polarity               ( rxp_polarity ),   

   .txp_detect_rx_lb           ( tx_detect_rx_lb ),    
   .reset_n                    ( ),            
   .power_down                 ( power_down ),        

   // From TX User Interface
   .phy_ltssm_state            ( phy_ltssm_state   ),     
   .phy_ltssm_substate         ( phy_ltssm_substate),     
   .phy_pol_compliance         ( phy_pol_compliance),   

   .tx_rdy_vc0                 ( tx_rdy_vc0),  
   .tx_ca_ph_vc0               ( tx_ca_ph_vc0),
   .tx_ca_pd_vc0               ( tx_ca_pd_vc0),
   .tx_ca_nph_vc0              ( tx_ca_nph_vc0),
   .tx_ca_npd_vc0              ( tx_ca_npd_vc0), 
   .tx_ca_cplh_vc0             ( tx_ca_cplh_vc0),
   .tx_ca_cpld_vc0             ( tx_ca_cpld_vc0),
   .tx_ca_p_recheck_vc0        ( tx_ca_p_recheck_vc0 ),
   .tx_ca_cpl_recheck_vc0      ( tx_ca_cpl_recheck_vc0 ),
   .rx_data_vc0                ( rx_data_vc0),    
   .rx_st_vc0                  ( rx_st_vc0),     
   .rx_end_vc0                 ( rx_end_vc0),   
   .rx_us_req_vc0              ( rx_us_req_vc0 ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp_vc0 ), 
   
   
   
   
   
   
   
   
   .rx_bar_hit                 ( rx_bar_hit ), 
   .mm_enable                  ( mm_enable  ) , 
   .msi_enable                 ( msi_enable ) , 

   // From Config Registers
   .bus_num                    ( bus_num        ) ,
   .dev_num                    ( dev_num        ) ,
   .func_num                   ( func_num       ) ,
   .pm_power_state             ( pm_power_state ) , 
   .pme_en                     ( pme_en         ) , 
   .cmd_reg_out                ( cmd_reg_out    ),
   .dev_cntl_out               ( dev_cntl_out   ),  
   .lnk_cntl_out               ( lnk_cntl_out   ),  

   // To ASPM implementation outside the IP
   .tx_rbuf_empty              (  ), 
   .tx_dllp_pend               (  ),   
   .rx_tlp_rcvd                (  ),

   // Datal Link Control SM Status
   .dl_inactive                ( dl_inactive ),
   .dl_init                    ( dl_init     ),
   .dl_active                  ( dl_active   ),
   .dl_up                      ( dl_up )
   );

endmodule
