
  #==============================================================================
  # Set up modelsim work library
  #==============================================================================
  vlib                  work
  vmap pcsc_mti_work "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/blackbox/pcsc_work"
  vmap pcsd_mti_work "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/blackbox/pcsd_work"
  vlog -refresh -quiet -work pcsc_mti_work
  vlog -refresh -quiet -work pcsd_mti_work
  #==============================================================================
  # Make vlog and vsim commands
  #==============================================================================
  vlog +define+USERNAME_EVAL_TOP=pcierc_test_eval_top -novopt  +define+DEBUG=0 +define+SIMULATE   \
  +incdir+../../../../pcierc_test/testbench/top \
  +incdir+../../../../pcierc_test/testbench/tests \
  +incdir+../../../../src/params \
  +incdir+../../../../models/ecp3 \
  +incdir+../../../../pcierc_test/src/params  \
  -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/ecp3 +libext+.v \
  -y C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../../cae_library/simulation/verilog/pmi +libext+.v  \
  ../../../../pcierc_test/src/params/pci_exp_params.v  \
  ../../../../pcierc_test/testbench/top/tb_top_rc.v  \
  ../../../../pcierc_test/testbench/top/tbtx.v  \
  ../../../../pcierc_test/testbench/top/tbrx.v \
  ../../../../models/ecp3/sync1s.v  \
  ../../../../models/ecp3/ctc.v  \
  ../../../../models/ecp3/pipe_top.v \
  ../../../../models/ecp3/rx_gear.v  \
  ../../../../models/ecp3/tx_gear.v  \
  ../../../../models/ecp3/PCSD.v  \
  ../../../../models/ecp3/pcs_top.v  \
  ../../../../models/ecp3/pcs_pipe_top.v  \
  ../../../../../pcierc_test.v  \
  ../../../../../pcierc_test_beh.v \
  ../../../../pcierc_test/src/top/pcierc_test_top.v \
  ../../../../pcierc_test/src/top/pcierc_test_eval_top.v  -work work

  vsim -novopt -t 1ps -c work.tb_top  -L work -L pcsd_mti_work    -l  eval_pcie.log   -wlf eval_pcie.wlf  
  do ../sim.do
  
