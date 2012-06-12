// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2002 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS         
// Project          : PCI_EXP_X1_11 
// File             : tx_gear.v
// Title            : 
// Dependencies     : 
// Description      :  Rate conversion bridge for Tx path. 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        :
// Mod. Date        : Jan 26, 2006
// Changes Made     : Initial Creation
// =============================================================================
`timescale 1 ns / 1 ps

module tx_gear #(
                parameter GWIDTH = 20
                ) 
   (
   input wire                clk_125 ,    // 125 Mhz clock.
   input wire                clk_250 ,    // 250 Mhz clock.
   input wire                rst_n ,      // asynchronous system reset.

   input wire                drate_enable,  //Enable for Counters
   input wire [GWIDTH-1:0]   data_in ,    // Data In

   output reg [GWIDTH/2-1:0] data_out     // Data Out
   );
// =============================================================================

reg [1:0]                 wr_pntr;    // Write Pointer
reg [1:0]                 rd_pntr;    // Read Pointer
reg                       rd_en;      // Read Pointer Enable

wire [GWIDTH/2-1:0]       rd_data0;   // Read Data
wire [GWIDTH/2-1:0]       rd_data1;   // Read Data

integer                   i;
integer                   j;

// RAM's : Expected to inferred as distributed ram
reg [GWIDTH/2-1:0]        rf_0[0:3] ;
reg [GWIDTH/2-1:0]        rf_1[0:3] ;

reg                       drate_f0 /* synthesis syn_srlstyle="registers" */;
reg                       drate_f1 /* synthesis syn_srlstyle="registers" */;
reg                       drate_s0;

reg                       rd_enable;
reg[2:0]                  rd_cnt;

//synchronize drate_enable to 250mhz clock
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n) begin
      drate_f0 <= 1'b0;
      drate_f1 <= 1'b0;
   end
   else begin
      drate_f0 <= drate_enable;
      drate_f1 <= drate_f0;
   end
end

// delay drate_enable by a 125mhz clock 
// to adjust synchronizer delay
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      drate_s0 <= 1'b0;
   else 
      drate_s0 <= drate_enable;
end

// =============================================================================
// Write 8 bits each into different memories out of incomming 
// 16 bits data at 125 Mhz.
// Read 8 bits of data, alternatively from each memory at 250 Mhz.
// =============================================================================

// Write Pointer
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      wr_pntr <= 2'b00;
   else if(drate_s0)
      wr_pntr <= wr_pntr + 2'b01;
   else
      wr_pntr <= wr_pntr;
end

// Read Pointer Enable for half-rate 
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n)
      rd_en <= 1'b0;
   else if(~drate_f1)
      rd_en <= 1'b0;
   else
      rd_en <= ~rd_en;
end

// Read Pointer
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n)
      rd_pntr <= 2'b10;
   else if (rd_en & drate_f1)
      rd_pntr <= rd_pntr + 2'b01;
end

// Output Data Select
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n)
      data_out <= 0;
   else begin
      if(rd_enable) 
         data_out <= rd_en ? rd_data0 : rd_data1;
      else
         data_out <= 10'b1000000000; // Bit 9 is TxElecIdle
   end
end

// =============================================================================


always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      for (i=0;i<=3;i=i+1) 
         rf_0[i] <= 0;
   else 
      rf_0[wr_pntr] <= data_in[GWIDTH/2-1:0] ;
end
assign rd_data0 = rf_0[rd_pntr] ;

always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      for (j=0;j<=3;j=j+1) 
         rf_1[j] <= 0;
   else 
      rf_1[wr_pntr] <= data_in[GWIDTH-1:GWIDTH/2] ;
end
assign rd_data1 = rf_1[rd_pntr] ;

// =============================================================================
// Avoid RESET data from Dist. Memory
// Take Read data after Writing, until then EI is HIGH
// Wait for 8 (250 Mhz) clks after enable
// =============================================================================
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n) begin
      rd_cnt    <= 3'b000;
      rd_enable <= 1'b0;
   end
   else begin
      if(drate_f1)
         rd_cnt <= rd_cnt + 3'b001;
      else
         rd_cnt <= 3'b000;

      if(~drate_f1)
         rd_enable <= 1'b0;
      else if(rd_cnt == 3'b111) 
         rd_enable <= 1'b1;
   end
end

endmodule
