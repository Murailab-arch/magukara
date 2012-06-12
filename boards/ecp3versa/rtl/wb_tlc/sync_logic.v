// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2009 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice Semiconductor provides no warranty
//   regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                          503-268-8001 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
//  Project:           Flexible scaler core
//  File:              sync_logic.v
//  Title:             
//  Dependencies:      
//  Description:       
//
// --------------------------------------------------------------------
// Author : Xuelei Xuan
// Revision History :
// --------------------------------------------------------------------
// $Log: 
// Revision 0.1  2009-04-20   Xuelei Xuan
// Initial revision
//
// --------------------------------------------------------------------
module sync_logic #(
parameter c_DATA_WIDTH = 10
)
(
rstn,
wr_clk,
wr_data,
rd_clk,
rd_data
);
input rstn;
input wr_clk;
input [c_DATA_WIDTH-1:0] wr_data;
input rd_clk;
output [c_DATA_WIDTH-1:0] rd_data;

//registers driven by wr_clk               
reg [1:0] update_ack_dly;
reg update_strobe;
reg [c_DATA_WIDTH-1:0]  data_buf/* synthesis syn_preserve=1 */;
//registers driven by rd_clk
reg update_ack;                      
reg [3:0] update_strobe_dly;         
reg [c_DATA_WIDTH-1:0] data_buf_sync/* synthesis syn_preserve=1 */;

//************************************************************************************
always @(posedge wr_clk or negedge rstn)
   if (!rstn) begin
      update_ack_dly <= 0;
      update_strobe  <= 0;
      data_buf       <= 0;
   end
   else begin
      update_ack_dly <= {update_ack_dly[0], update_ack};
      if (update_strobe == update_ack_dly[1]) begin
         //latch new data 
         data_buf <= wr_data;
         update_strobe <= ~ update_strobe;
      end
   end   

//************************************************************************************
always @(posedge rd_clk or negedge rstn)
   if (!rstn) begin
      update_ack        <= 0;
      update_strobe_dly <= 0;
      data_buf_sync     <= 0;
   end
   else begin
      update_strobe_dly <= {update_strobe_dly[2:0], update_strobe};
      if (update_strobe_dly[3] != update_ack) begin
         data_buf_sync <= data_buf;
         update_ack    <= update_strobe_dly[3];
      end
   end

assign rd_data = data_buf_sync;
endmodule