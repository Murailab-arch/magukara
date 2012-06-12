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
// File             : testcase.v
// Title            : Loob Back Test using SERDES/PCSC
// Dependencies     :
// Description      : The following test checks if the interface between core and SERDES/PCS
//                    are OK. As connection is looped back on serial lines, the LTSSM
//                    will not move from congig state. This ensures TS orderset flow
//                    and then switching to "no_training" will make LTSSM to go to LO
//                    directly. Then TLP trafic is tested. 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Mod. Date        : Sep 22, 2004
// Changes Made     : Initial Creation
//
// Version          : 2.0
// Mod. Date        : May 2, 2006
// Changes Made     : Modified for ECP3 PCIe x1
// =============================================================================

parameter       TCNT = 'd25 ;

reg           test_complete;
reg [9:0]     stlp_size;
reg [9:0]     stlp_size_r;
reg [9:0]     rtlp_size;
reg [9:0]     rtlp_size_r;
reg [31:0]    seed;
reg [31:0]    rand[0:1023];
reg [31:0]    tlps_count;
reg           test_flag1;

integer       sp ;
integer       rp ;
integer       tp ;
integer       xp ;

initial begin
   // Test Started
   $display("---INFO  : Test test_ecp3 STARTED at Time %0t", $time);
   RST_DUT;

//----------- for RTL sim ----------------
   $display("---INFO TESTCASE : Forcing Detect Result at Time %0t", $time);
   force u1_top.u1_pcs_pipe.ffs_pcie_con_0  = 1'b1;   // Receiver detected

   repeat (25) @ (posedge sys_clk_125);
   $display("---INFO TESTCASE : Waiting for rxp_valid at Time %0t", $time);
   wait (u1_top.u1_pcs_pipe.RxValid_0); //wait for lane sync

   release u1_top.u1_pcs_pipe.ffs_pcie_con_0 ;   //Receiver detected

   $display("---INFO TESTCASE : Waiting for SM to go to CFG at Time %0t", $time);
   wait ( u1_top.u1_dut.phy_ltssm_state == 4'd2);  // wait for DUT Config state
   repeat (200) @ (posedge sys_clk_125);
//--------------------------------------

   $display("---INFO TESTCASE : Forcing LTSSM to L0 at Time %0t", $time);
   `ifdef WISHBONE
      wb_write (13'h100C, 32'h0000_0001) ; // Set no_pcie_train
   `else
      force no_pcie_train = 1'b1; 
   `endif

   repeat (10) @ (posedge sys_clk_125);
   wait (dl_up);
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
       u_tbrx[0].nph_buf_status  <= 1'b0;
       u_tbrx[0].npd_buf_status  <= 1'b0;
   end
end


always @(posedge tb_sys_clk) begin
   if (rx_st) begin
       u_tbrx[0].ph_processed   <= 1'b1;
       u_tbrx[0].pd_processed   <= 1'b1;
       u_tbrx[0].nph_processed  <= 1'b1;
       u_tbrx[0].npd_processed  <= 1'b1;
   end
   else if (rx_end) begin
       u_tbrx[0].ph_processed   <= 1'b0;
       u_tbrx[0].pd_processed   <= 1'b0;
       u_tbrx[0].nph_processed  <= 1'b0;
       u_tbrx[0].npd_processed  <= 1'b0;
   end
end

always @(error or test_complete) 
begin
    // Test Completed
    if ((error == 1'b0) && (test_complete == 1'b1) && (tlps_count == TCNT)) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---INFO  : Test test_ecp3 PASSED at Time %t", $time);
      $finish;
    end

    if (error == 1'b1) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---ERROR : Test test_ecp3 FAILED at Time %t", $time);
      $finish;
    end
end
// =============================================================================
