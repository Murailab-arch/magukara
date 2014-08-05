# Synplicity, Inc. constraint file
# C:\shared\PROJECTS\PCI_EXP_X1_11\PCI_EXP_X1_11\technology\ver1.0\syn\exp2m\config1\synplicity\core\pci_exp_x1_core.sdc
# Written on Tue May 09 09:19:01 2006
# by Synplify for Lattice, Synplify for Lattice 8.5D Scope Editor

#
# Clocks
#
define_clock            -name {CLK_I}  -freq 50.000 -clockgroup default_clkgroup_0
define_clock            -name {sys_clk_125}  -freq 200.000 -clockgroup default_clkgroup_1
define_clock            -name {sys_clk_250}  -freq 350.000 -clockgroup default_clkgroup_2

#
# Clock to Clock
#

#
# Inputs/Outputs
#
define_input_delay -disable      -default -improve 0.00 -route 0.00
define_output_delay -disable     -default -improve 0.00 -route 0.00
define_output_delay -disable     {ACK_O} -improve 0.00 -route 0.00
define_input_delay -disable      {ADR_I[12:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {bus_num[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {CHAIN_ACK_in} -improve 0.00 -route 0.00
define_input_delay -disable      {CHAIN_RDAT_in[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {cmd_reg_out[3:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {cmpln_tout} -improve 0.00 -route 0.00
define_input_delay -disable      {cmpltr_abort} -improve 0.00 -route 0.00
define_input_delay -disable      {cpld_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {cpld_processed_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {cplh_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {cplh_processed_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {CYC_I} -improve 0.00 -route 0.00
define_input_delay -disable      {DAT_I[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {DAT_O[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {dev_cntl_out[14:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {dev_num[4:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {dl_active} -improve 0.00 -route 0.00
define_output_delay -disable     {dl_inactive} -improve 0.00 -route 0.00
define_output_delay -disable     {dl_init} -improve 0.00 -route 0.00
define_output_delay -disable     {dl_up} -improve 0.00 -route 0.00
define_output_delay -disable     {func_num[2:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_CPLD_FC_VC0[11:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_CPLH_FC_VC0[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_NPD_FC_VC0[11:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_NPH_FC_VC0[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_PD_FC_VC0[11:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_PH_FC_VC0[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_000[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_008[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_00C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_010[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_014[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_018[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_01C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_020[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_024[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_028[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_02C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_030[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_03C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_040[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_044[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_048[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_04C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_050[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_054[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_058[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_05C[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_064[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_068[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_104[31:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {INIT_REG_108[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {IRQ_O} -improve 0.00 -route 0.00
define_output_delay -disable     {lnk_cntl_out[7:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {mes_data[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {mes_laddr[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {mes_uaddr[31:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {mm_enable[2:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {msi_enable} -improve 0.00 -route 0.00
define_input_delay -disable      {np_req_pend} -improve 0.00 -route 0.00
define_input_delay -disable      {npd_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {npd_processed_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {nph_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {nph_processed_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {pd_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {pd_processed_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {ph_buf_status_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {ph_processed_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {phy_cfgln_sum[2:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {phy_enable_align} -improve 0.00 -route 0.00
define_output_delay -disable     {phy_ltssm_state[3:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {phy_realign_req} -improve 0.00 -route 0.00
define_input_delay -disable      {phy_status} -improve 0.00 -route 0.00
define_output_delay -disable     {pm_data_select[3:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {pm_power_state[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {power_down[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {reset_n} -improve 0.00 -route 0.00
define_input_delay -disable      {RST_I} -improve 0.00 -route 0.00
define_input_delay -disable      {rst_n} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_data_vc0[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_end_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_lbk_data[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_lbk_kcntl[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_malf_tlp_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_st_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {rx_us_req_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {rxp_data[7:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {rxp_data_k} -improve 0.00 -route 0.00
define_input_delay -disable      {rxp_elec_idle} -improve 0.00 -route 0.00
define_output_delay -disable     {rxp_polarity} -improve 0.00 -route 0.00
define_input_delay -disable      {rxp_status[2:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {rxp_valid} -improve 0.00 -route 0.00
define_input_delay -disable      {SEL_I[3:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {STB_I} -improve 0.00 -route 0.00
define_input_delay -disable      {sts_reg_in[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_cpld_vc0[12:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_cplh_vc0[8:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_npd_vc0[12:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_nph_vc0[8:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_pd_vc0[12:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_ca_ph_vc0[8:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_data_vc0[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_end_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_lbk_data[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_lbk_kcntl[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_lbk_rdy} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_nlfy_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {tx_rdy_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_req_vc0} -improve 0.00 -route 0.00
define_input_delay -disable      {tx_st_vc0} -improve 0.00 -route 0.00
define_output_delay -disable     {txp_compliance} -improve 0.00 -route 0.00
define_output_delay -disable     {txp_data[7:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {txp_data_k} -improve 0.00 -route 0.00
define_output_delay -disable     {txp_detect_rx} -improve 0.00 -route 0.00
define_output_delay -disable     {txp_elec_idle} -improve 0.00 -route 0.00
define_input_delay -disable      {unexp_cmpln} -improve 0.00 -route 0.00
define_input_delay -disable      {WE_I} -improve 0.00 -route 0.00

#
# Registers
#

#
# Multicycle Path
#

#
# False Path
#

#
# Path Delay
#

#
# Attributes
#
#define_global_attribute          syn_netlist_hierarchy {0}
define_global_attribute syn_multstyle logic

#
# I/O standards
#

#
# Other Constraints
#
