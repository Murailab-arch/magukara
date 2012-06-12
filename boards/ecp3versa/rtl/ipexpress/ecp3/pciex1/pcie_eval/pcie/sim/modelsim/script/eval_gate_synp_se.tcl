
  #==============================================================================
  # Set up modelsim work library
  #==============================================================================
  vlib                  work
  vmap pcsc_mti_work "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/blackbox/pcsc_work"
  vmap pcsa_mti_work "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/blackbox/pcsa_work"
  vmap pcsd_mti_work "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/blackbox/pcsd_work"
  vlog -refresh -quiet -work pcsc_mti_work
  vlog -refresh -quiet -work pcsa_mti_work
  vlog -refresh -quiet -work pcsd_mti_work
  #==============================================================================
  # Make vlog and vsim commands
  #==============================================================================
  vlog -novopt +define+USERNAME_EVAL_TOP=pcie_eval_top  +define+DEBUG=0 +define+SIMULATE  +define+SDF_SIM +incdir+../../../../pcie/testbench/top +incdir+../../../../pcie/testbench/tests +incdir+../../../../src/params +incdir+../../../../models/ecp3 +incdir+../../../../pcie/src/params  -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/ecp3 +libext+.v -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/pmi +libext+.v  ../../../../pcie/src/params/pci_exp_params.v  ../../../../pcie/testbench/top/eval_pcie.v  ../../../../pcie/testbench/top/eval_tbtx.v  ../../../../pcie/testbench/top/eval_tbrx.v    ../../../impl/synplify/pcie_eval.vo  -work work
  vsim -novopt -t 1ps -c work.tb_top  -L work -L pcsd_mti_work     +no_tchk_msg  -v2k_int_delays +transport_int_delays +transport_path_delays    -l  eval_pcie.log   -wlf eval_pcie.wlf 
  do ../sim.do
  
