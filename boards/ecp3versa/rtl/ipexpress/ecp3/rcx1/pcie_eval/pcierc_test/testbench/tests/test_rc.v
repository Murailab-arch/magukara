// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
// U.S.A                                    email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_exp
// File             : test_sc.v
// Title            : Check the retry buffer behaviour 
// Dependencies     :
// Description      : The following test checks if the interface between core and SERDES/PCS
//                    are OK. As connection is looped back on serial lines, the LTSSM
//                    will not move from congig state. This ensures TS orderset flow
//                    and then switching to "no_training" will make LTSSM to go to LO
//                    directly. Then TLP trafic is tested. 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        :   
// Mod. Date        : Sep 22, 2004
// Changes Made     : Initial Creation
//
// Version          : 2.0
// Author(s)        :  
// Mod. Date        : May 2, 2006
// Changes Made     : Modified for ECP2M PCIe x1
// =============================================================================
parameter       TCNT = 'd50 ;

reg           test_complete;
reg [9:0]     stlp_size;
reg [9:0]     stlp_size_r;
reg [9:0]     rtlp_size;
reg [9:0]     rtlp_size_r;
reg [31:0]    seed;
reg [31:0]    rand[0:1023];
reg [31:0]    tlps_count;

wire          rx_valid_all ;

integer       sp ;
integer       rp ;
integer       tp ;
integer       xp ;
assign   rx_valid_all = (u1_top.u1_pcie_top.rxp_valid) ? 1'b1 : 1'b0;

initial begin
   // Test Started
   $display("---INFO  : Test test_ecp2m STARTED at Time %0t", $time);
   RST_DUT;

   $display("---INFO TESTCASE : Waiting for rx_valid at Time %0t", $time);
   wait (rx_valid_all);

   $display("---INFO TESTCASE : Waiting for SM to go to CFG at Time %0t", $time);
   wait ( u1_top.u1_pcie_top.phy_ltssm_state == 4'd2);  // wait for DUT Config state

   $display("---INFO TESTCASE : Forcing LTSSM to L0 at Time %0t", $time); 
   force u1_top.u1_pcie_top.phy_ltssm_cntl[0] = 1'b1; // force no_pcie_train to go to L0.     

   $display("---INFO TESTCASE : Waiting for dl_up at Time %0t", $time);
   wait (u1_top.u1_pcie_top.dll_status[0]);
   $display("---INFO TESTCASE : FCI is done, dl_up asserted at Time %0t", $time);

   fork 
      test_complete = 1'b0 ; 
      begin 
         seed = 'd9;
         // Send Packet from TX user Interface 
         for (sp = 0 ; sp < TCNT; sp = sp+1) begin
            repeat (1) @ (posedge tb_sys_clk);
            stlp_size_r = {$random(seed)} % 31;       
            stlp_size = (stlp_size_r <= 2) ? 3 : stlp_size_r;
            rand[sp] = stlp_size ; 
            tbtx_mem_wr(3'd0, 32'hFFFF_FF80, stlp_size, 1'b0, 10'd0, 1'b0); 
            $display("---INFO : TLP No. %0d scheduled from TBTX at Time %0t", sp, $time);
         end
      end
      begin 
         // Check Packet from RX user Interface 
         for (rp = 0 ; rp < TCNT; rp = rp+1) begin
            repeat (1) @ (posedge tb_sys_clk);
            rtlp_size = rand[rp];
            tbrx_mem_wr(3'd0, 32'hFFFF_FF80, rtlp_size, 1'b0, 4'd0);
         end
      end
      begin 
         tlps_count = 'd0;
         for (tp = 0 ; tp < TCNT; tp = tp+1) begin
            wait (rx_end) ;
            $display("---INFO : TLP No. %0d received at TBRX at Time %0t", tp, $time);
            tlps_count = tlps_count + 1;
            repeat (2) @ (posedge tb_sys_clk);
         end
      end

      // Wait until packet is received by RX TB
      begin 
         wait (|tbrx_cmd_prsnt == 1'b1) ;
         wait (|tbrx_cmd_prsnt == 1'b0) ;
         test_complete = 1'b1 ; 
      end
   join
end

always @(posedge tb_sys_clk) begin
   if (tlps_count%30 == 0) begin
       u_tbrx[0].ph_buf_status   <= 1'b1;
       u_tbrx[0].pd_buf_status   <= 1'b1;
       u_tbrx[0].nph_buf_status  <= 1'b1;
       u_tbrx[0].npd_buf_status  <= 1'b1;
   end
   else if (tlps_count%30 == 2) begin
       u_tbrx[0].ph_buf_status   <= 1'b0;
       u_tbrx[0].pd_buf_status   <= 1'b0;
   end
end


always @(posedge tb_sys_clk) begin
   if (rx_st) begin
       u_tbrx[0].ph_processed   <= 1'b1;
       u_tbrx[0].pd_processed   <= 1'b1;
   end
   else if (rx_end) begin
       u_tbrx[0].ph_processed   <= 1'b0;
       u_tbrx[0].pd_processed   <= 1'b0;
   end
end

always @(error or test_complete) 
begin
    // Test Completed
    if ((error == 1'b0) && (test_complete == 1'b1) && (tlps_count == TCNT)) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---INFO  : Eval Test PASSED at Time %t", $time);
      $finish;
    end

    if (error == 1'b1) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---ERROR : Eval Test FAILED at Time %t", $time);
      $finish;
    end
end
// =============================================================================
