-------------------------------------------------------------------------------
-- Copyright(c) 2007 Lattice Semiconductor Corporation. All rights reserved.   
-- WARNING - Changes to this file should be performed by re-running IPexpress
-- or modifying the .LPC file and regenerating the core.  Other changes may lead
-- to inconsistent simulation and/or implemenation results
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library ecp3;
use ecp3.components.all;
entity pcie_top is port (
-- Clock & reset
refclkp     : in std_logic;        -- 100MHz from board  
refclkn     : in std_logic;        -- 100MHz from board  
rst_n       : in std_logic;        -- asynchronous system reset.   

-- Line side interface
hdinp0            : in std_logic;               -- PCIe lanes                  
hdinn0            : in std_logic;                      
hdoutp0           : out std_logic;    
hdoutn0           : out std_logic;   

flip_lanes        : in std_logic;                         

inta_n            : in std_logic;        -- Legacy INTx support               
msi               : in std_logic_vector(7 downto 0); --  interrupt support
vendor_id         : in std_logic_vector(15 downto 0);       
device_id         : in std_logic_vector(15 downto 0);       
rev_id            : in std_logic_vector( 7 downto 0);          
class_code        : in std_logic_vector(23 downto 0);      
subsys_ven_id     : in std_logic_vector(15 downto 0);   
subsys_id         : in std_logic_vector(15 downto 0);       
load_id           : in std_logic;         
force_lsm_active   : in std_logic;                     -- Force LSM Status Active
force_rec_ei       : in std_logic;                     -- Force Received Electrical Idle
force_phy_status   : in std_logic;                     -- Force PHY Connection Status
force_disable_scr  : in std_logic;                     -- Force Disable Scrambler to PCS
                                          
hl_snd_beacon      : in std_logic;                     -- HL req. to Send Beacon
hl_disable_scr     : in std_logic;                     -- HL req. to Disable Scrambling bit in TS1/TS2 
hl_gto_dis         : in std_logic;                     -- HL req a jump to Disable
hl_gto_det         : in std_logic;                     -- HL req a jump to detect
hl_gto_hrst        : in std_logic;                     -- HL req a jump to Hot reset
hl_gto_l0stx       : in std_logic;                     -- HL req a jump to TX L0s
hl_gto_l1          : in std_logic;                     -- HL req a jump to L1
hl_gto_l2          : in std_logic;                     -- HL req a jump to L2 
hl_gto_l0stxfts    : in std_logic;                     -- HL req a jump to L0s TX FTS 
hl_gto_lbk         : in std_logic;                     -- HL req a jump to Loopback
hl_gto_rcvry       : in std_logic;                     -- HL req a jump to recovery 
hl_gto_cfg         : in std_logic;                     -- HL req a jump to CFG 
no_pcie_train      : in std_logic;                     -- Disable the training process
-- Power Management Interface              
tx_dllp_val        : in std_logic_vector(1 downto 0);  -- Req for Sending PM/Vendor type DLLP
tx_pmtype          : in std_logic_vector(2 downto 0);  -- Power Management Type
tx_vsd_data        : in std_logic_vector(23 downto 0); -- Vendor Type DLLP contents

-- For VC Inputs 
tx_req_vc0           : in std_logic;                     -- VC0 Request from User  
tx_data_vc0          : in std_logic_vector(15 downto 0); -- VC0 Input data from user logic 
tx_st_vc0            : in std_logic;                     -- VC0 start of pkt from user logic.  
tx_end_vc0           : in std_logic;                     -- VC0 End of pkt from user logic. 
tx_nlfy_vc0          : in std_logic;                     -- VC0 End of nullified pkt from user logic.  
ph_buf_status_vc0    : in std_logic;                     -- VC0 Indicate the Full/alm.Full status of the PH buffers
pd_buf_status_vc0    : in std_logic;                     -- VC0 Indicate PD Buffer has got space less than Max Pkt size
nph_buf_status_vc0   : in std_logic;                     -- VC0 For NPH
npd_buf_status_vc0   : in std_logic;                     -- VC0 For NPD
ph_processed_vc0     : in std_logic;                     -- VC0 TL has processed one TLP Header - PH Type
pd_processed_vc0     : in std_logic;                     -- VC0 TL has processed one TLP Data - PD TYPE
nph_processed_vc0    : in std_logic;                     -- VC0 For NPH
npd_processed_vc0    : in std_logic;                     -- VC0 For NPD
pd_num_vc0           : in std_logic_vector(7 downto 0);  -- VC0 For PD -- No. of Data processed
npd_num_vc0          : in std_logic_vector(7 downto 0);  -- VC0 For PD

cmpln_tout           : in std_logic;   -- Completion time out.
cmpltr_abort_np      : in std_logic;   -- Completor abort.
cmpltr_abort_p       : in std_logic;   -- Completor abort.
unexp_cmpln          : in std_logic;   -- Unexpexted completion.
ur_np_ext            : in std_logic;   -- UR for NP type.
ur_p_ext             : in std_logic;   -- UR for P type.
np_req_pend          : in std_logic;   -- Non posted request is pending.
pme_status           : in std_logic;   -- PME status to reg 044h.

-- User Loop back data
tx_lbk_data          : in std_logic_vector(15 downto 0);  -- TX User Master Loopback data
tx_lbk_kcntl         : in std_logic_vector(1 downto 0);   -- TX User Master Loopback control
                     
tx_lbk_rdy           : out std_logic;                     -- TX loop back is ready to accept data
rx_lbk_data          : out std_logic_vector(15 downto 0); -- RX User Master Loopback data
rx_lbk_kcntl         : out std_logic_vector(1 downto 0);  -- RX User Master Loopback control

-- Power Management/ Vendor specific DLLP
tx_dllp_sent        : out std_logic;                     -- Requested PM DLLP is sent
rxdp_pmd_type       : out std_logic_vector(2 downto 0);  -- PM DLLP type bits.
rxdp_vsd_data       : out std_logic_vector(23 downto 0); -- Vendor specific DLLP data.
rxdp_dllp_val       : out std_logic_vector(1 downto 0);  -- PM/Vendor specific DLLP valid.

phy_pol_compliance  : out std_logic;                     -- PHY in Polling.Compliance state
phy_ltssm_state     : out std_logic_vector(3 downto 0);  -- Indicates the states of the ltssm 
phy_ltssm_substate  : out std_logic_vector(2 downto 0);  -- sub-states of the ltssm_state

tx_rdy_vc0             : out std_logic;                     -- VC0 TX ready indicating signal
tx_ca_ph_vc0           : out std_logic_vector(8 downto 0);  -- VC0 Available credit for Posted Type Headers
tx_ca_pd_vc0           : out std_logic_vector(12 downto 0); -- VC0 For Posted - Data
tx_ca_nph_vc0          : out std_logic_vector(8 downto 0);  -- VC0 For Non-posted - Header
tx_ca_npd_vc0          : out std_logic_vector(12 downto 0); -- VC0 For Non-posted - Data
tx_ca_cplh_vc0         : out std_logic_vector(8 downto 0);  -- VC0 For Completion - Header
tx_ca_cpld_vc0         : out std_logic_vector(12 downto 0); -- VC0 For Completion - Data
tx_ca_p_recheck_vc0    : out std_logic;                     -- Indicator to recheck P credit available
tx_ca_cpl_recheck_vc0  : out std_logic;                     -- Indicator to recheck CPL credit available
rx_data_vc0            : out std_logic_vector(15 downto 0); -- VC0 Receive data
rx_st_vc0              : out std_logic;                     -- VC0 Receive data start
rx_end_vc0             : out std_logic;                     -- VC0 Receive data end
rx_us_req_vc0          : out std_logic;                     -- VC0 unsupported req received  
rx_malf_tlp_vc0        : out std_logic;                     -- VC0 malformed TLP in received data
     
rx_bar_hit             : out std_logic_vector(6 downto 0);  -- Bar hit

mm_enable              : out std_logic_vector(2 downto 0);  
msi_enable             : out std_logic; 

-- From Config Registers                          
bus_num                : out std_logic_vector(7 downto 0); -- Bus number
dev_num                : out std_logic_vector(4 downto 0); -- Device number
func_num               : out std_logic_vector(2 downto 0); -- Function number
pm_power_state         : out std_logic_vector(1 downto 0); -- Power state bits of Register at 044h
pme_en                 : out std_logic;                    -- PME_En at 044h
cmd_reg_out            : out std_logic_vector(5 downto 0); -- Bits 10, 8, 6, 2 From register 004h
dev_cntl_out           : out std_logic_vector(14 downto 0);-- Divice control register at 060h 
lnk_cntl_out           : out std_logic_vector(7 downto 0); -- Link control register at 068h 
                                                  
-- Datal Link Control SM Status                   
dl_inactive            : out std_logic;                    -- Data Link Control SM is in INACTIVE state
dl_init                : out std_logic;                    -- INIT state
dl_active              : out std_logic;                    -- ACTIVE state
dl_up                  : out std_logic;                    -- Data Link Layer is UP 
sys_clk_125            : out std_logic                     -- 125 Mhz system clock for User logic
);
end pcie_top;

architecture arch of pcie_top is
component pcie 
  port(
    -- Clock & reset
    sys_clk_250 : in std_logic;        -- 250 Mhz reference Clock           
    sys_clk_125 : in std_logic;        -- 125 Mhz reference Clock           
    rst_n       : in std_logic;        -- asynchronous system reset.        
    inta_n      : in std_logic;        -- Legacy INTx support               
    msi         : in std_logic_vector(7 downto 0); --  interrupt support
    vendor_id     : in std_logic_vector(15 downto 0);       
    device_id     : in std_logic_vector(15 downto 0);       
    rev_id        : in std_logic_vector( 7 downto 0);          
    class_code    : in std_logic_vector(23 downto 0);      
    subsys_ven_id : in std_logic_vector(15 downto 0);   
    subsys_id     : in std_logic_vector(15 downto 0);       
    load_id       : in std_logic;         
    force_lsm_active   : in std_logic;                     -- Force LSM Status Active
    force_rec_ei       : in std_logic;                     -- Force Received Electrical Idle
    force_phy_status   : in std_logic;                     -- Force PHY Connection Status
    force_disable_scr  : in std_logic;                     -- Force Disable Scrambler to PCS
                                              
    hl_snd_beacon      : in std_logic;                     -- HL req. to Send Beacon
    hl_disable_scr     : in std_logic;                     -- HL req. to Disable Scrambling bit in TS1/TS2 
    hl_gto_dis         : in std_logic;                     -- HL req a jump to Disable
    hl_gto_det         : in std_logic;                     -- HL req a jump to detect
    hl_gto_hrst        : in std_logic;                     -- HL req a jump to Hot reset
    hl_gto_l0stx       : in std_logic;                     -- HL req a jump to TX L0s
    hl_gto_l1          : in std_logic;                     -- HL req a jump to L1
    hl_gto_l2          : in std_logic;                     -- HL req a jump to L2 
    hl_gto_l0stxfts    : in std_logic;                     -- HL req a jump to L0s TX FTS 
    hl_gto_lbk         : in std_logic;                     -- HL req a jump to Loopback
    hl_gto_rcvry       : in std_logic;                     -- HL req a jump to recovery 
    hl_gto_cfg         : in std_logic;                     -- HL req a jump to CFG 
    no_pcie_train      : in std_logic;                     -- Disable the training process
                                               
    -- Power Management Interface              
    tx_dllp_val        : in std_logic_vector(1 downto 0);  -- Req for Sending PM/Vendor type DLLP
    tx_pmtype          : in std_logic_vector(2 downto 0);  -- Power Management Type
    tx_vsd_data        : in std_logic_vector(23 downto 0); -- Vendor Type DLLP contents
    
    -- For VC Inputs 
    tx_req_vc0           : in std_logic;                     -- VC0 Request from User  
    tx_data_vc0          : in std_logic_vector(15 downto 0); -- VC0 Input data from user logic 
    tx_st_vc0            : in std_logic;                     -- VC0 start of pkt from user logic.  
    tx_end_vc0           : in std_logic;                     -- VC0 End of pkt from user logic. 
    tx_nlfy_vc0          : in std_logic;                     -- VC0 End of nullified pkt from user logic.  
    ph_buf_status_vc0    : in std_logic;                     -- VC0 Indicate the Full/alm.Full status of the PH buffers
    pd_buf_status_vc0    : in std_logic;                     -- VC0 Indicate PD Buffer has got space less than Max Pkt size
    nph_buf_status_vc0   : in std_logic;                     -- VC0 For NPH
    npd_buf_status_vc0   : in std_logic;                     -- VC0 For NPD
    ph_processed_vc0     : in std_logic;                     -- VC0 TL has processed one TLP Header - PH Type
    pd_processed_vc0     : in std_logic;                     -- VC0 TL has processed one TLP Data - PD TYPE
    nph_processed_vc0    : in std_logic;                     -- VC0 For NPH
    npd_processed_vc0    : in std_logic;                     -- VC0 For NPD
    pd_num_vc0           : in std_logic_vector(7 downto 0);  -- VC0 For PD -- No. of Data processed
    npd_num_vc0          : in std_logic_vector(7 downto 0);  -- VC0 For PD

    rxp_data             : in std_logic_vector(7 downto 0);  -- CH0:PCI Express data from External Phy                              
    rxp_data_k           : in std_logic;                     -- CH0:PCI Express Control from External Phy                         
    rxp_valid            : in std_logic;                     -- CH0:Indicates a symbol lock and valid data on rx_data /rx_data_k   
    rxp_elec_idle        : in std_logic;                     -- CH0:Inidicates receiver detection of an electrical signal        
    rxp_status           : in std_logic_vector(2 downto 0);  -- CH0:Indicates receiver Staus/Error codes                          
    phy_status           : in std_logic;                     --  Indicates PHY status info  
    
    
    -- From User logic
    
    cmpln_tout     : in std_logic;   -- Completion time out.
    cmpltr_abort_np: in std_logic;   -- Completor abort.
    cmpltr_abort_p : in std_logic;   -- Completor abort.
    unexp_cmpln    : in std_logic;   -- Unexpexted completion.
    ur_np_ext      : in std_logic;   -- UR for NP type.
    ur_p_ext       : in std_logic;   -- UR for P type.
    np_req_pend    : in std_logic;   -- Non posted request is pending.
    pme_status     : in std_logic;   -- PME status to reg 044h.
    
    -- User Loop back data
    tx_lbk_data   : in std_logic_vector(15 downto 0);  -- TX User Master Loopback data
    tx_lbk_kcntl  : in std_logic_vector(1 downto 0);   -- TX User Master Loopback control
                
    tx_lbk_rdy    : out std_logic;                     -- TX loop back is ready to accept data
    rx_lbk_data   : out std_logic_vector(15 downto 0); -- RX User Master Loopback data
    rx_lbk_kcntl  : out std_logic_vector(1 downto 0);  -- RX User Master Loopback control
    
    -----------Outputs------------
    -- Power Management/ Vendor specific DLLP
    tx_dllp_sent  : out std_logic;                     -- Requested PM DLLP is sent
    rxdp_pmd_type : out std_logic_vector(2 downto 0);  -- PM DLLP type bits.
    rxdp_vsd_data : out std_logic_vector(23 downto 0); -- Vendor specific DLLP data.
    rxdp_dllp_val : out std_logic_vector(1 downto 0);  -- PM/Vendor specific DLLP valid.
    
    txp_data            : out std_logic_vector(7 downto 0);-- CH0:PCI Express data to External Phy
    txp_data_k          : out std_logic;                   -- CH0:PCI Express control to External Phy
    txp_elec_idle       : out std_logic;                   -- CH0:Tells PHY to output Electrical Idle 
    txp_compliance      : out std_logic;                   -- CH0:Sets the PHY running disparity to -ve 
    rxp_polarity        : out std_logic;                   -- CH0:Tells PHY to do polarity inversion on the received data
                                                
    txp_detect_rx_lb    : out std_logic;                   -- Tells PHY to begin receiver detection or begin Loopback 
    reset_n             : out std_logic;                   -- Async reset to the PHY
    power_down          : out std_logic_vector(1 downto 0);-- Tell sthe PHY to power Up or Down

    phy_pol_compliance  : out std_logic;                     -- PHY in Polling.Compliance state
    phy_ltssm_state     : out std_logic_vector(3 downto 0);  -- Indicates the states of the ltssm 
    phy_ltssm_substate  : out std_logic_vector(2 downto 0);  -- sub-states of the ltssm_state

    tx_rdy_vc0             : out std_logic;                     -- VC0 TX ready indicating signal
    tx_ca_ph_vc0           : out std_logic_vector(8 downto 0);  -- VC0 Available credit for Posted Type Headers
    tx_ca_pd_vc0           : out std_logic_vector(12 downto 0); -- VC0 For Posted - Data
    tx_ca_nph_vc0          : out std_logic_vector(8 downto 0);  -- VC0 For Non-posted - Header
    tx_ca_npd_vc0          : out std_logic_vector(12 downto 0); -- VC0 For Non-posted - Data
    tx_ca_cplh_vc0         : out std_logic_vector(8 downto 0);  -- VC0 For Completion - Header
    tx_ca_cpld_vc0         : out std_logic_vector(12 downto 0); -- VC0 For Completion - Data
    tx_ca_p_recheck_vc0    : out std_logic;                     -- Indicator to recheck P credit available
    tx_ca_cpl_recheck_vc0  : out std_logic;                     -- Indicator to recheck CPL credit available
    rx_data_vc0            : out std_logic_vector(15 downto 0); -- VC0 Receive data
    rx_st_vc0              : out std_logic;                     -- VC0 Receive data start
    rx_end_vc0             : out std_logic;                     -- VC0 Receive data end
    rx_us_req_vc0          : out std_logic;                     -- VC0 unsupported req received  
    rx_malf_tlp_vc0        : out std_logic;                     -- VC0 malformed TLP in received data
     
    rx_bar_hit             : out std_logic_vector(6 downto 0);  -- Bar hit

    mm_enable              : out std_logic_vector(2 downto 0);  
    msi_enable             : out std_logic; 

    -- From Config Registers                          
    bus_num                : out std_logic_vector(7 downto 0); -- Bus number
    dev_num                : out std_logic_vector(4 downto 0); -- Device number
    func_num               : out std_logic_vector(2 downto 0); -- Function number
    pm_power_state         : out std_logic_vector(1 downto 0); -- Power state bits of Register at 044h
    pme_en                 : out std_logic;                    -- PME_En at 044h
    cmd_reg_out            : out std_logic_vector(5 downto 0); -- Bits 10, 8, 6, 2 From register 004h
    dev_cntl_out           : out std_logic_vector(14 downto 0);-- Divice control register at 060h 
    lnk_cntl_out           : out std_logic_vector(7 downto 0); -- Link control register at 068h 
                                                      
    -- To ASPM implementation outside the IP
    tx_rbuf_empty          : out std_logic;
    tx_dllp_pend           : out std_logic;
    rx_tlp_rcvd            : out std_logic;

    -- Datal Link Control SM Status                   
    dl_inactive            : out std_logic;                    -- Data Link Control SM is in INACTIVE state
    dl_init                : out std_logic;                    -- INIT state
    dl_active              : out std_logic;                    -- ACTIVE state
    dl_up                  : out std_logic                     -- Data Link Layer is UP 
    );
   end component;
   
component pcs_pipe_top
  port(
    refclkp             : in std_logic;         
    refclkn             : in std_logic;         
    ffc_quad_rst        : in std_logic;     
    RESET_n             : in std_logic;         

    hdinp0              : in std_logic;         
    hdinn0              : in std_logic;         
    hdoutp0             : out std_logic;           
    hdoutn0             : out std_logic;           
    RxValid_0           : out std_logic;           
    RxElecIdle_0        : out std_logic;           
    TxData_0            : in std_logic_vector(7 downto 0); 
    RxData_0            : out std_logic_vector(7 downto 0); 
    TxElecIdle_0        : in std_logic; 
    TxCompliance_0      : in std_logic; 
    TxDataK_0           : in std_logic_vector(0 downto 0); 
    RxDataK_0           : out std_logic_vector(0 downto 0); 
    RxStatus_0          : out std_logic_vector(2 downto 0); 
    RxPolarity_0        : in std_logic;         
                                                            
    scisel_0            : in std_logic;         
    scien_0             : in std_logic;         
    sciwritedata        : in std_logic_vector(7 downto 0);
    sciaddress          : in std_logic_vector(5 downto 0);
    scireaddata         : out std_logic_vector(7 downto 0);
    sciselaux           : in std_logic;
    scienaux            : in std_logic;
    scird               : in std_logic;
    sciwstn             : in std_logic;
    ffs_plol            : out std_logic;
    ffs_rlol_ch0        : out std_logic;
                                        
    flip_lanes          : in std_logic;                          
    PCLK                : out std_logic;           
    PCLK_by_2           : out std_logic;           
    TxDetectRx_Loopback : in std_logic;         
    PhyStatus           : out std_logic;           
    PowerDown           : in std_logic_vector(1 downto 0);  
                                        
    ctc_disable         : in std_logic;         
    phy_l0              : in std_logic;  
    phy_cfgln           : in std_logic_vector(3 downto 0)
    );
   end component;
component GSR
port( 
      GSR: in std_logic
  );
   end component;
component PUR
port( 
      PUR: in std_logic
  );
   end component;
attribute syn_black_box : boolean;
attribute syn_black_box of pcs_pipe_top : component is true;
attribute syn_black_box of pcie : component is true;
attribute black_box_pad_pin : string;
attribute black_box_pad_pin of pcs_pipe_top : component is "refclkp, refclkn, hdinp0, hdinn0, hdoutp0, hdoutn0";

signal pclk                : std_logic;
signal rxp_data            : std_logic_vector(7 downto 0); 
signal rxp_data_k          : std_logic_vector(0 downto 0);                    
signal rxp_valid           : std_logic;                    
signal rxp_elec_idle       : std_logic;                    
signal rxp_status          : std_logic_vector(2 downto 0); 
                                                    
signal txp_data           : std_logic_vector(7 downto 0); 
signal txp_data_k         : std_logic_vector(0 downto 0);                   
signal txp_elec_idle      : std_logic;                   
signal txp_compliance     : std_logic;                   
signal rxp_polarity       : std_logic;                   
                                                    
signal sys_clk_125_int    : std_logic;                   
signal reset_n            : std_logic;                   
signal tx_detect_rx_lb    : std_logic;                   
signal phy_status         : std_logic;                   
signal power_down         : std_logic_vector(1 downto 0);                   
signal phy_ltssm_state_t  : std_logic_vector(3 downto 0);                   
signal phy_cfgln          : std_logic_vector(3 downto 0);                   
signal phy_l0             : std_logic;                   

signal rstn_cnt           : std_logic_vector(19 downto 0);   
signal core_rst_n         : std_logic; 
signal irst_n             : std_logic;
signal ffc_quad_rst       : std_logic;
 
begin
	
GSR_INST : GSR
  port map (
    GSR => rst_n
  	);

PUR_INST : PUR
  port map (
    PUR => '1'
  	);
  		
sys_clk_125 <= sys_clk_125_int;
phy_l0      <= '1' when (phy_ltssm_state_t = "0011") else '0' ;
phy_ltssm_state <= phy_ltssm_state_t;
-- =============================================================================
-- Reset management
-- =============================================================================
process (sys_clk_125_int, rst_n) 
begin
   if (rst_n = '0') then
       rstn_cnt   <= (others => '0') ;
       core_rst_n <= '0' ;
   elsif rising_edge(sys_clk_125_int) then
      if (rstn_cnt(19) = '1') then           -- 4ms in real hardware
         core_rst_n <= '1' ;
      -- synthesis translate_off
      elsif (rstn_cnt(7) = '1') then    -- 128 clocks 
         core_rst_n <= '1' ;
      -- synthesis translate_on
      else 
         rstn_cnt   <= rstn_cnt + '1' ;
      end if;
   end if;
end process;

irst_n <= core_rst_n;

u1_dut : pcie
  port map (
    sys_clk_250     => pclk, 
    sys_clk_125     => sys_clk_125_int, 
    rst_n           => irst_n,      
                    
    inta_n          => inta_n,     
    msi             => msi,        
    vendor_id       => vendor_id    ,      
    device_id       => device_id    , 
    rev_id          => rev_id       , 
    class_code      => class_code   , 
    subsys_ven_id   => subsys_ven_id, 
    subsys_id       => subsys_id    , 
    load_id         => load_id      ,
    
    force_lsm_active   => force_lsm_active ,
    force_rec_ei       => force_rec_ei     ,
    force_phy_status   => force_phy_status ,
    force_disable_scr  => force_disable_scr,
                                                 
    hl_snd_beacon      => hl_snd_beacon    ,
    hl_disable_scr     => hl_disable_scr   ,
    hl_gto_dis         => hl_gto_dis       ,
    hl_gto_det         => hl_gto_det       ,
    hl_gto_hrst        => hl_gto_hrst      ,
    hl_gto_l0stx       => hl_gto_l0stx     ,
    hl_gto_l1          => hl_gto_l1        ,
    hl_gto_l2          => hl_gto_l2        ,
    hl_gto_l0stxfts    => hl_gto_l0stxfts  ,
    hl_gto_lbk         => hl_gto_lbk       ,
    hl_gto_rcvry       => hl_gto_rcvry     ,
    hl_gto_cfg         => hl_gto_cfg       ,
    no_pcie_train      => no_pcie_train    ,
                                               
    tx_dllp_val        => tx_dllp_val      ,
    tx_pmtype          => tx_pmtype        ,
    tx_vsd_data        => tx_vsd_data      ,
                     
    tx_req_vc0         => tx_req_vc0         , 
    tx_data_vc0        => tx_data_vc0        , 
    tx_st_vc0          => tx_st_vc0          , 
    tx_end_vc0         => tx_end_vc0         , 
    tx_nlfy_vc0        => tx_nlfy_vc0        , 
    ph_buf_status_vc0  => ph_buf_status_vc0  , 
    pd_buf_status_vc0  => pd_buf_status_vc0  , 
    nph_buf_status_vc0 => nph_buf_status_vc0 , 
    npd_buf_status_vc0 => npd_buf_status_vc0 , 
    ph_processed_vc0   => ph_processed_vc0   ,
    pd_processed_vc0   => pd_processed_vc0   , 
    nph_processed_vc0  => nph_processed_vc0  , 
    npd_processed_vc0  => npd_processed_vc0  , 
    pd_num_vc0         => pd_num_vc0         ,
    npd_num_vc0        => npd_num_vc0        ,
    rxp_data           => rxp_data         , 
    rxp_data_k         => rxp_data_k(0)    , 
    rxp_valid          => rxp_valid        , 
    rxp_elec_idle      => rxp_elec_idle    , 
    rxp_status         => rxp_status       , 
                       
    phy_status         => phy_status,
    
    
    cmpln_tout         => cmpln_tout  ,
    cmpltr_abort_np    => cmpltr_abort_np,
    cmpltr_abort_p     => cmpltr_abort_p,
    unexp_cmpln        => unexp_cmpln ,
    ur_np_ext          => ur_np_ext   ,
    ur_p_ext           => ur_p_ext    ,
    np_req_pend        => np_req_pend ,
    pme_status         => pme_status  ,
                     
    tx_lbk_data        => tx_lbk_data ,  
    tx_lbk_kcntl       => tx_lbk_kcntl,  
                                      
    tx_lbk_rdy         => tx_lbk_rdy  ,
    rx_lbk_data        => rx_lbk_data ,
    rx_lbk_kcntl       => rx_lbk_kcntl,
    
    tx_dllp_sent       => tx_dllp_sent ,  
    rxdp_pmd_type      => rxdp_pmd_type,  
    rxdp_vsd_data      => rxdp_vsd_data,  
    rxdp_dllp_val      => rxdp_dllp_val,  

    txp_data            => txp_data,        
    txp_data_k          => txp_data_k(0),      
    txp_elec_idle       => txp_elec_idle,   
    txp_compliance      => txp_compliance,  
    rxp_polarity        => rxp_polarity,    
                                                                                   
    txp_detect_rx_lb    => tx_detect_rx_lb,    
    reset_n             => reset_n,             
    power_down          => power_down,          

    phy_ltssm_state    => phy_ltssm_state_t ,
    phy_ltssm_substate => phy_ltssm_substate,
    phy_pol_compliance => phy_pol_compliance,
       
    tx_rdy_vc0            => tx_rdy_vc0           ,  
    tx_ca_ph_vc0          => tx_ca_ph_vc0         ,  
    tx_ca_pd_vc0          => tx_ca_pd_vc0         ,  
    tx_ca_nph_vc0         => tx_ca_nph_vc0        ,  
    tx_ca_npd_vc0         => tx_ca_npd_vc0        ,  
    tx_ca_cplh_vc0        => tx_ca_cplh_vc0       ,  
    tx_ca_cpld_vc0        => tx_ca_cpld_vc0       ,  
    tx_ca_p_recheck_vc0   => tx_ca_p_recheck_vc0  ,  
    tx_ca_cpl_recheck_vc0 => tx_ca_cpl_recheck_vc0,  
    rx_data_vc0           => rx_data_vc0          ,  
    rx_st_vc0             => rx_st_vc0            ,  
    rx_end_vc0            => rx_end_vc0           ,  
    rx_us_req_vc0         => rx_us_req_vc0        ,  
    rx_malf_tlp_vc0       => rx_malf_tlp_vc0      ,  
    rx_bar_hit            => rx_bar_hit       ,
    mm_enable             => mm_enable        ,  
    msi_enable            => msi_enable       ,
                                           
    bus_num               => bus_num          ,
    dev_num               => dev_num          ,
    func_num              => func_num         ,
    pm_power_state        => pm_power_state   ,
    pme_en                => pme_en           ,
    cmd_reg_out           => cmd_reg_out      ,
    dev_cntl_out          => dev_cntl_out     ,
    lnk_cntl_out          => lnk_cntl_out     ,
                                                  
    -- To ASPM implementation outside the IP
    tx_rbuf_empty         => open         ,
    tx_dllp_pend          => open         ,
    rx_tlp_rcvd           => open         ,

    dl_inactive           => dl_inactive      ,
    dl_init               => dl_init          ,
    dl_active             => dl_active        ,
    dl_up                 => dl_up            
    );


ffc_quad_rst <= not rst_n;

 u1_pcs_pipe : pcs_pipe_top 
  port map(
    refclkp             => refclkp,       
    refclkn             => refclkn,       
    ffc_quad_rst        => ffc_quad_rst,  
    RESET_n             => rst_n,       

    hdinp0              => hdinp0            ,
    hdinn0              => hdinn0            ,
    hdoutp0             => hdoutp0           ,
    hdoutn0             => hdoutn0           ,
    RxValid_0           => rxp_valid         ,
    RxElecIdle_0        => rxp_elec_idle     ,
    TxData_0            => txp_data          ,
    RxData_0            => rxp_data          ,
    TxElecIdle_0        => txp_elec_idle     ,
    TxCompliance_0      => txp_compliance    ,
    TxDataK_0           => txp_data_k        ,
    RxDataK_0           => rxp_data_k        ,
    RxStatus_0          => rxp_status        ,
    RxPolarity_0        => rxp_polarity      ,         
                                       
    scisel_0            => '0'               ,         
    scien_0             => '0'               ,         
    sciwritedata        => (others=>'0'),
    sciaddress          => (others=>'0'),
    scireaddata         => open,
    scienaux            => '0',
    sciselaux           => '0',
    scird               => '0',
    sciwstn             => '0',
    ffs_plol            => open, 
    ffs_rlol_ch0        => open, 
    flip_lanes          => flip_lanes,     
                                    
    PCLK                => pclk           ,
    PCLK_by_2           => sys_clk_125_int,
    TxDetectRx_Loopback => tx_detect_rx_lb,
    PhyStatus           => phy_status     ,
    PowerDown           => power_down     , 
    phy_l0              => phy_l0         , 
    phy_cfgln           => (others=>'0')  ,
    ctc_disable         => '0'
    );
   
end arch;
