 
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
// Project          : PCI Express 4X 
// File             : ctc.v
// Title            : Clock Tolerance Compensation 
// Dependencies     : 
// Description      : This module implements the CTC logic 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        :  
// Mod. Date        : Dec 18, 2006
// Changes Made     : Initial Creation
//
// =============================================================================
// =============================================================================
//                        REVISION HISTORY
// =============================================================================
// Version |   Date     |                     Notes
// -----------------------------------------------------------------------------
//   1.0   | 12/18/2006 | Initial Release  
// -----------------------------------------------------------------------------
//   2.0   | 12/12/2007 | Updates: 
//         |            |  1. Threshold for reading FIFO.
//         |            |  2. Remove rcvr_detected from case statement to output
//         |            |     ctc_status_out. This case is handled outside CTC    
//         |            |     with merging per-channel RxStatus.    
// =============================================================================
//


module ctc 
   (
   //------- Inputs 
   rst_n,              // system reset
   clk_in,             // Write clock input 
   clk_out,            // Read clock input 

   ctc_disable,        // Disable CTC SKP ADD or DELETE
   data_in,            // Write data 
   kcntl_in,           // Write data control
   status_in,          // Status input
   lanesync_in,        // Lane Sync input

   //------- Outputs 
   ctc_read_enable,    // CTC Read started for rx_gear
   ctc_skip_added,     // signal Indicating Skip was added
   ctc_skip_removed,   // signal Indicating Skip was removed
   ctc_data_out,       // Clock compensated data   
   ctc_kcntl_out,      // Clock compensated control 
   ctc_status_out,     // Status output
   ctc_lanesync_out,   // Lane Sync
   ctc_under_flow,     // Overflow error
   ctc_over_flow       // Underflow error
   );

// =============================================================================
// Define all inputs / outputs
// =============================================================================
//---------Inputs------------
input                     rst_n;           
input                     clk_in;           
input                     clk_out;           

input                     ctc_disable;
input [7:0]               data_in;
input                     kcntl_in;
input [2:0]               status_in;
input                     lanesync_in;

//---------Output-------------
output                    ctc_read_enable;
output                    ctc_skip_added;  
output                    ctc_skip_removed; 
output [7:0]              ctc_data_out;     
output                    ctc_kcntl_out;    
output [2:0]              ctc_status_out;     
output                    ctc_lanesync_out;   
output                    ctc_over_flow;
output                    ctc_under_flow;

wire                      ctc_read_enable;
reg [7:0]                 ctc_data_out /* synthesis syn_srlstyle="registers" */;     
reg                       ctc_kcntl_out /* synthesis syn_srlstyle="registers" */;    
reg [2:0]                 ctc_status_out; 
reg                       ctc_lanesync_out /* synthesis syn_srlstyle="registers" */;   
reg                       ctc_skip_added;
reg                       ctc_skip_removed;  
wire                      ctc_over_flow;
wire                      ctc_under_flow;

// =============================================================================
// Define Wire & Registers 
// =============================================================================
//---- Wires
wire [12:0] write_data;
wire        fifo_partial_full;
wire        fifo_partial_empty;
wire        full;
wire        empty;
wire        out_det_BC_1C;
wire        out_skip_removed;
wire [12:0] fifo_dout;
wire [7:0]  data_in_d0;

//---- Regs
reg         over_flow;
reg         under_flow;
reg  [12:0] write_data_d0 /* synthesis syn_srlstyle="registers" */;
reg  [12:0] write_data_d1 /* synthesis syn_srlstyle="registers" */;
reg  [12:0] write_data_d2 /* synthesis syn_srlstyle="registers" */;
reg         in_det_BC_1C;
reg         write_enable;
reg         write_enable_d0 /* synthesis syn_srlstyle="registers" */;
reg         in_skip_removed;
reg         read_enable;
reg         skip_added;
reg         wait_for_data;  
reg         fifo_partial_empty_d1 /* synthesis syn_srlstyle="registers" */;
reg         fifo_partial_empty_d2 /* synthesis syn_srlstyle="registers" */;

// =============================================================================
// FIFO Parameters 
// =============================================================================
// Using following options only in simulation since bug in pmi_fifo_dc with depth of 16 
`ifdef SIMULATE
parameter FIFO_DEPTH     = 64;
parameter FIFO_HI_THRESH = 48;
parameter FIFO_LO_THRESH = 16;
`else
parameter FIFO_DEPTH     = 16;
parameter FIFO_HI_THRESH = 12;
parameter FIFO_LO_THRESH = 4;
`endif


parameter FIFO_DEVICE_FAMILY = "EC";
parameter FIFO_IMPL = "LUT"; // EBR/LUT

assign ctc_read_enable = read_enable;
// =============================================================================
// pipeline incoming data
// =============================================================================
assign write_data = {lanesync_in,status_in,kcntl_in,data_in};
always @(posedge clk_in or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      write_data_d0 <= 0;
      write_data_d1 <= 0;
      write_data_d2 <= 0;
   end
   else begin
      write_data_d0 <= write_data; 
      write_data_d1 <= write_data_d0; 
      write_data_d2 <= write_data_d1; 
   end
end

assign data_in_d0  = write_data_d0[7:0]; 
assign kcntl_in_d0 = write_data_d0[8];

// =============================================================================
// Detect Clock Compensation pattern
// COM,SKP
// =============================================================================
always @(posedge clk_in or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      in_det_BC_1C    <= 1'b0;
   end
   else begin
      // detect first half of CTC code group (0xBC,0x1C)
      if (kcntl_in_d0 == 1'b1 && data_in_d0 == 8'hBC && kcntl_in == 1'b1 && data_in == 8'h1C) 
         in_det_BC_1C <= 1'b1;
      else 
         in_det_BC_1C <= 1'b0;
   end
end


// =============================================================================
// WRITE Logic 
// (Deletes SKP(1C) When FIFO Partial Full)
// =============================================================================
always @(posedge clk_in or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      write_enable    <= 1'b0;
      write_enable_d0 <= 1'b0;
      in_skip_removed <= 1'b0;
   end
   else begin
      // don't write to fifo when partial full 
      // and detect start of idle code group
      if (fifo_partial_full && in_det_BC_1C && ctc_disable == 1'b0) begin
         write_enable     <= 1'b0;
         in_skip_removed  <= 1'b1;
      end
      else begin // otherwise allow fifo writing
         write_enable     <= 1'b1;
         in_skip_removed  <= 1'b0;
      end	
      write_enable_d0 <= write_enable; 
   end
end

// =============================================================================
// Read Logic 
// (Adds SKP(1C) When FIFO Partial Empty)
// =============================================================================
always @(posedge clk_out or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      read_enable          <= 1'b0;
      skip_added           <= 1'b0;
      ctc_skip_added       <= 0; 
      ctc_skip_removed  <= 0; 
      wait_for_data     <= 0;
      fifo_partial_empty_d1 <= 1'b1;
      fifo_partial_empty_d2 <= 1'b1;
   end
   else begin
      //If Partial Empty Flag is set for 4,
      // start reading at 6/7 
      fifo_partial_empty_d1 <= fifo_partial_empty;
      fifo_partial_empty_d2 <= fifo_partial_empty_d1;

      // Wait for data to be written until FIFO Partial FULL before beginning
      // to READ
      if (fifo_partial_empty == 1'b0)
         wait_for_data <= 1'b1;
      else
         wait_for_data <= 1'b0;

      // don't write to fifo when partial full 
      // and detect start of idle code group
      if (fifo_partial_empty && out_det_BC_1C && ctc_disable == 1'b0) begin
         read_enable  <= 1'b0;
         skip_added   <= 1'b1;
      end
      // otherwise allow fifo reading
      else if (wait_for_data) begin
         read_enable  <= 1'b1;
         skip_added   <= 1'b0;
      end	
      ctc_skip_added   <= skip_added;
      ctc_skip_removed <= out_skip_removed; 
   end
end

// =============================================================================
// Output data mux logic 
// =============================================================================
always @(posedge clk_out or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      ctc_data_out      <= 0;
      ctc_kcntl_out     <= 0;
      ctc_lanesync_out  <= 0;
   end
   else begin
      if (ctc_skip_added == 1'b1) begin
         ctc_data_out      <= 8'h1C;
         ctc_kcntl_out     <= 1'b1;
      end
      else begin
         ctc_data_out      <= fifo_dout[7:0];
         ctc_kcntl_out     <= fifo_dout[8];
      end
      ctc_lanesync_out  <= fifo_dout[12];
   end
end

always @(posedge clk_out or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      ctc_status_out <= 0;
   end
   else begin
      casex({skip_added,out_skip_removed}) 
         2'b10:  ctc_status_out <= 3'b001;  
         2'b01:  ctc_status_out <= 3'b010;  
         2'b11:  ctc_status_out <= 3'b000;  
	 //PCS RxStatus got stuck at DETECT Result
         //default: ctc_status_out <= fifo_dout[11:9]; 
         default: ctc_status_out <= 3'b000;  
      endcase
   end
end

// =============================================================================
// FIFO Instantiation 
// =============================================================================
pmi_fifo_dc #(
	.pmi_data_width_w(15),
	.pmi_data_width_r(15),
	.pmi_data_depth_w(FIFO_DEPTH),
	.pmi_data_depth_r(FIFO_DEPTH),
	.pmi_full_flag(FIFO_DEPTH),
	.pmi_empty_flag(0),
	.pmi_almost_full_flag(FIFO_HI_THRESH),
	.pmi_almost_empty_flag(FIFO_LO_THRESH),
	.pmi_regmode("reg"),
	.pmi_resetmode("async"),
	.pmi_family(FIFO_DEVICE_FAMILY),
	.module_type("pmi_fifo_dc"),
	.pmi_implementation(FIFO_IMPL)) ctc_fifo_U  
   (
   .Reset       (~rst_n), 
   .RPReset     (~rst_n), 

   .WrClock     (clk_in), 
   .WrEn        (write_enable_d0), 
   .Data        ({in_skip_removed,in_det_BC_1C,write_data_d2}), 

   .RdClock     (clk_out), 
   .RdEn        (read_enable), 
   .Q           ({out_skip_removed,out_det_BC_1C,fifo_dout}), 

   .Empty       (empty), 
   .Full        (full), 
   .AlmostEmpty (fifo_partial_empty), 
   .AlmostFull  (fifo_partial_full)
   );

// =============================================================================
// Detect overflow error
// =============================================================================
always @(posedge clk_in or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      over_flow <= 1'b0;
   end
   else if (full & write_enable) begin
      over_flow <= 1'b1;
   end
   else begin
      over_flow <= 1'b0;
   end
end

// Sync over_flow using clk_out
sync1s #(1) u1_sync1s 
   (
   .f_clk     (clk_in) ,
   .s_clk     (clk_out) ,
   .rst_n     (rst_n),
   .in_fclk   (over_flow),
   .out_sclk  (ctc_over_flow)
   );

// =============================================================================
// Detect underflow error
// =============================================================================
always @(posedge clk_out or negedge rst_n)
begin
   if (rst_n == 1'b0) begin
      under_flow <= 1'b0;
   end
   else if (empty & read_enable) begin
      under_flow <= 1'b1;
   end
   else begin
      under_flow <= 1'b0;
   end
end
assign ctc_under_flow = under_flow;


endmodule

