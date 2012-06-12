
    cd "D:/project/PCIe_IP/Native_PCIeBasic_SBx1/ispLeverGenCore/ecp3/rcx1/pcie_eval/pcierc_test/sim/aldec/rtl"
    workspace create pcie_space
    design create pcie_design .
    design open pcie_design
    cd "D:/project/PCIe_IP/Native_PCIeBasic_SBx1/ispLeverGenCore/ecp3/rcx1/pcie_eval/pcierc_test/sim/aldec/rtl"
    set sim_working_folder .
    #==============================================================================
    # Compile
    #==============================================================================
    vlog +define+USERNAME_EVAL_TOP=pcierc_test_eval_top  -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/ecp3 +libext+.v -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/pmi +libext+.v   +define+DEBUG=0 +define+SIMULATE   +incdir+../../../../pcierc_test/testbench/top +incdir+../../../../pcierc_test/testbench/tests +incdir+../../../../src/params +incdir+../../../../models/ecp3 +incdir+../../../../pcierc_test/src/params ../../../../pcierc_test/src/params/pci_exp_params.v  ../../../../pcierc_test/testbench/top/tb_top_rc.v  ../../../../pcierc_test/testbench/top/tbtx.v  ../../../../pcierc_test/testbench/top/tbrx.v ../../../../models/ecp3/sync1s.v  ../../../../models/ecp3/ctc.v  ../../../../models/ecp3/pipe_top.v  ../../../../models/ecp3/rx_gear.v  ../../../../models/ecp3/tx_gear.v  ../../../../models/ecp3/PCSD.v  ../../../../models/ecp3/pcs_top.v  ../../../../models/ecp3/pcs_pipe_top.v  ../../../../../pcierc_test.v  ../../../../../pcierc_test_beh.v ../../../../pcierc_test/src/top/pcierc_test_top.v ../../../../pcierc_test/src/top/pcierc_test_eval_top.v  

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
add wave {sim:/tb_top/u_tbrx[0]/rx_st}
add wave {sim:/tb_top/u_tbrx[0]/rx_end}
add wave {sim:/tb_top/u_tbrx[0]/rx_data}
add wave {sim:/tb_top/u_tbrx[0]/rx_malf_tlp}
add wave sim:/tb_top/u1_top/hdoutp*
add wave sim:/tb_top/u1_top/hdoutn*
add wave sim:/tb_top/u1_top/hdinp*
add wave sim:/tb_top/u1_top/hdinn*
run -all
