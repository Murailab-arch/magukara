module pcierc_test_eval_top (
   // Clock and Reset
   input  wire              refclkp,        // 100MHz from board
   input  wire              refclkn,        // 100MHz from board
   output wire              sys_clk_125,    // 125MHz output clock from core 
   input  wire              rst_n,

   // ASIC side pins for PCSA.  These pins must exist for the PCS core.
   input  wire              hdinp0,         // exemplar attribute hdinp0 NOPAD true
   input  wire              hdinn0,         // exemplar attribute hdinp0 NOPAD true
   output wire              hdoutp0,        // exemplar attribute hdoutp0 NOPAD true
   output wire              hdoutn0,        // exemplar attribute hdoutp0 NOPAD true

   // From TX user Interface  
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


   // To TX User Interface
   output wire               tx_rdy_vc0,         // VC0 TX ready indicating signal
   output wire [8:0]         tx_ca_ph_vc0,       // VC0 Available credit for Posted Type Headers
   output wire [12:0]        tx_ca_pd_vc0,       // VC0 For Posted - Data
   output wire [8:0]         tx_ca_nph_vc0,      // VC0 For Non-posted - Header
   output wire [12:0]        tx_ca_npd_vc0,      // VC0 For Non-posted - Data
   output wire [8:0]         tx_ca_cplh_vc0,     // VC0 For Completion - Header
   output wire [12:0]        tx_ca_cpld_vc0,     // VC0 For Completion - Data

   // To RX User Interface
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
   output wire               cor_err_msg         // Correctable error message received

   )/* synthesis black_box_pad_pin = "HDINP0, HDINN0, HDOUTP0, HDOUTN0, REFCLKP, REFCLKN" */;

// =============================================================================
// Define Wires & Regs
// =============================================================================

// =============================================================================
//
//// =============================================================================
pcierc_test_top u1_pcie_top(
   // Clock and Reset
   .refclkp                    ( refclkp ) ,
   .refclkn                    ( refclkn ) ,
   .sys_clk_125                ( sys_clk_125 ) ,
   .rst_n                      ( rst_n ),

   .hdinp0                     ( hdinp0 ), 
   .hdinn0                     ( hdinn0 ), 
   .hdoutp0                    ( hdoutp0 ), 
   .hdoutn0                    ( hdoutn0 ), 

   .phy_force_cntl             ( 4'b0000 ),
   .phy_ltssm_cntl             ( 13'h0000 ),

   // Power Management Interface
   .tx_dllp_val                ( 2'd0 ),
   .tx_pmtype                  ( 3'd0 ),
   .tx_vsd_data                ( 24'd0 ),

   // From TX user Interface  
   .tx_req_vc0                 ( tx_req_vc0 ),    
   .tx_data_vc0                ( tx_data_vc0 ),    
   .tx_st_vc0                  ( tx_st_vc0 ), 
   .tx_end_vc0                 ( tx_end_vc0 ), 
   .tx_nlfy_vc0                ( tx_nlfy_vc0 ), 
   .ph_buf_status_vc0          ( ph_buf_status_vc0 ),
   .pd_buf_status_vc0          ( pd_buf_status_vc0 ),
   .nph_buf_status_vc0         ( nph_buf_status_vc0 ),
   .npd_buf_status_vc0         ( npd_buf_status_vc0 ),
   .cplh_buf_status_vc0        ( cplh_buf_status_vc0 ),
   .cpld_buf_status_vc0        ( cpld_buf_status_vc0 ),
   .ph_processed_vc0           ( ph_processed_vc0 ),
   .pd_processed_vc0           ( pd_processed_vc0 ),
   .nph_processed_vc0          ( nph_processed_vc0 ),
   .npd_processed_vc0          ( npd_processed_vc0 ),
   .cplh_processed_vc0         ( cplh_processed_vc0 ),
   .cpld_processed_vc0         ( cpld_processed_vc0 ),
   .pd_num_vc0                 ( 8'd1 ),
   .npd_num_vc0                ( 8'd1 ),
   .cpld_num_vc0               ( 8'd1 ),

   // User Loop back data
   .tx_lbk_data                ( 16'd0 ),
   .tx_lbk_kcntl               ( 2'd0 ),
   .tx_lbk_rdy                 (  ),
   .rx_lbk_data                (  ),
   .rx_lbk_kcntl               (  ),

   // Power Management
   .tx_dllp_sent               (  ),
   .rxdp_pmd_type              (  ),
   .rxdp_vsd_data              (  ),
   .rxdp_dllp_val              (  ),

   //-------- Outputs
   // To TX User Interface
   .tx_rdy_vc0                 ( tx_rdy_vc0),  
   .tx_ca_ph_vc0               ( tx_ca_ph_vc0),
   .tx_ca_pd_vc0               ( tx_ca_pd_vc0),
   .tx_ca_nph_vc0              ( tx_ca_nph_vc0),
   .tx_ca_npd_vc0              ( tx_ca_npd_vc0), 
   .tx_ca_cplh_vc0             ( tx_ca_cplh_vc0),
   .tx_ca_cpld_vc0             ( tx_ca_cpld_vc0),

   // To RX User Interface
   .rx_data_vc0                ( rx_data_vc0),    
   .rx_st_vc0                  ( rx_st_vc0),     
   .rx_end_vc0                 ( rx_end_vc0),   
   .rx_pois_tlp_vc0            ( rx_pois_tlp_vc0 ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp_vc0 ), 


   // From DLL
   .dll_status                 (  ),

   // From PHY
   .phy_cfgln_sum              (  ),   
   .phy_pol_compliance         (  ),   
   .phy_ltssm_state            (  ),     
   .phy_ltssm_substate         (  ),     

   // From TRN
   .inta_n                     ( inta_n ) , 
   .intb_n                     ( intb_n ) , 
   .intc_n                     ( intc_n ) , 
   .intd_n                     ( intd_n ) , 
   .ftl_err_msg                ( ftl_err_msg ) ,
   .nftl_err_msg               ( nftl_err_msg ) ,
   .cor_err_msg                ( cor_err_msg ) 
   )  ;

endmodule

