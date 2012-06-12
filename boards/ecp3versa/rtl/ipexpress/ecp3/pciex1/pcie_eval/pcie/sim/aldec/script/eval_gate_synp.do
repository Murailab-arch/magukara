
    cd "D:/project/PCIe_IP/Native_PCIeBasic_SBx1/ispLeverGenCore/ecp3/pciex1/pcie_eval/pcie/sim/aldec/timing"
    workspace create pcie_space
    design create pcie_design .
    design open pcie_design
    cd "D:/project/PCIe_IP/Native_PCIeBasic_SBx1/ispLeverGenCore/ecp3/pciex1/pcie_eval/pcie/sim/aldec/timing"
    set sim_working_folder .

    #==============================================================================
    # Compile
    #==============================================================================
    vlog +define+USERNAME_EVAL_TOP=pcie_eval_top  +define+DEBUG=0 +define+SIMULATE  +define+SDF_SIM +incdir+../../../../pcie/testbench/top +incdir+../../../../pcie/testbench/tests +incdir+../../../../src/params +incdir+../../../../models/ecp3 +incdir+../../../../pcie/src/params ../../../../pcie/src/params/pci_exp_params.v  ../../../../pcie/testbench/top/eval_pcie.v  ../../../../pcie/testbench/top/eval_tbtx.v  ../../../../pcie/testbench/top/eval_tbrx.v   ../../../impl/synplify/pcie_eval.vo  

    #==============================================================================
    # Run
    #==============================================================================
    vsim -t 1ps pcie_design.tb_top -lib pcie_design  -L ovi_ecp3 -L pmi_work -L pcsd_aldec_work 
    
add wave {sim:/tb_top/u1_top/rst_n}
add wave {sim:/tb_top/u1_top/sys_clk_125}
add wave {sim:/tb_top/u_tbtx[0]/tx_st}
add wave {sim:/tb_top/u_tbtx[0]/tx_end}
add wave {sim:/tb_top/u_tbtx[0]/tx_data}
add wave {sim:/tb_top/u_tbtx[0]/tx_req}
add wave {sim:/tb_top/u_tbtx[0]/tx_rdy}
add wave {sim:/tb_top/u_tbrx[0]/rx_us_req}
add wave {sim:/tb_top/u_tbrx[0]/rx_st}
add wave {sim:/tb_top/u_tbrx[0]/rx_end}
add wave {sim:/tb_top/u_tbrx[0]/rx_data}
add wave {sim:/tb_top/u_tbrx[0]/rx_malf_tlp}
add wave sim:/tb_top/u1_top/hdoutp*
add wave sim:/tb_top/u1_top/hdoutn*
add wave sim:/tb_top/u1_top/hdinp*
add wave sim:/tb_top/u1_top/hdinn*
run -all
  
