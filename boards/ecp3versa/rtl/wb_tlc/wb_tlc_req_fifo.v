// $Id: wb_tlc_req_fifo.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $


`timescale 1ns / 100ps
module wb_tlc_req_fifo #(parameter c_DATA_WIDTH = 64)(rstn, clk_125, wb_clk,
                    din, din_bar, din_sop, din_eop, din_dwen, din_wrn, din_wen, 
                    dout, dout_sop, dout_eop, dout_dwen, dout_wrn, dout_bar, 
                    dout_ren, tlp_avail 
                     );

input         rstn;
input         clk_125;
input         wb_clk;
input  [c_DATA_WIDTH-1:0] din;
input  [6:0]  din_bar;
input         din_sop;
input         din_eop;
input         din_dwen;
input         din_wrn;
input         din_wen;

output [c_DATA_WIDTH-1:0] dout;
output        dout_sop;
output        dout_eop;
output        dout_dwen;
output        dout_wrn;
output [6:0]  dout_bar;
input         dout_ren;
output        tlp_avail;

localparam c_BUF_DATA_WIDTH = c_DATA_WIDTH+7+4;

wire [c_BUF_DATA_WIDTH-1:0] fifo_din, fifo_dout;
   
assign fifo_din = {din_bar, din_dwen, din_wrn, din_eop, din_sop, din};



//pmi_fifo_dc #(
//    .pmi_data_width_w(c_BUF_DATA_WIDTH),
//    .pmi_data_width_r(c_BUF_DATA_WIDTH),
//    .pmi_data_depth_w(1024),
//    .pmi_data_depth_r(1024),
//    .pmi_full_flag(1024),
//    .pmi_empty_flag(0),
//    .pmi_almost_full_flag(10), // 1 or more MRd or MWr TLPs in the FIFO
//    .pmi_almost_empty_flag(3),
//    .pmi_regmode("reg"), //enable EBR output register to improving timing
//    .pmi_resetmode("async"),
//    .pmi_family("ECP3") ,
//    .module_type("pmi_fifo_dc"),
//    .pmi_implementation("EBR")
//)
//fifo (
//  .Data(fifo_din),
//  .WrClock(clk_125),
//  .RdClock(wb_clk),
//  .WrEn(din_wen),
//  .RdEn(dout_ren),
//  .Reset(~rstn),
//  .RPReset(1'b0),
//  .Q(fifo_dout),
//  .Empty(empty),
//  .Full(),
//  .AlmostEmpty(AlmostEmpty),
//  .AlmostFull()
//); 
async_pkt_fifo #(
.c_DATA_WIDTH  (c_BUF_DATA_WIDTH    ),
.c_ADDR_WIDTH  (11    ),
.c_AFULL_FLAG  (100   ),
.c_AEMPTY_FLAG (3     )
)I_async_pkt_fifo(
.WrEop(din_eop),
.Data(fifo_din), 
.WrClock(clk_125), 
.RdClock(wb_clk), 
.WrEn(din_wen), 
.RdEn(dout_ren),
.Reset(~rstn),

.Q(fifo_dout), 
.Empty(empty),
.AlmostEmpty(AlmostEmpty), 
.AlmostFull()
);


assign dout = fifo_dout[c_DATA_WIDTH-1:0];
assign dout_sop = fifo_dout[c_DATA_WIDTH];
assign dout_eop = fifo_dout[c_DATA_WIDTH+1];
assign dout_wrn = fifo_dout[c_DATA_WIDTH+2];
assign dout_dwen = fifo_dout[c_DATA_WIDTH+3];
assign dout_bar = fifo_dout[c_BUF_DATA_WIDTH-1:c_BUF_DATA_WIDTH-7];

assign tlp_avail = ~AlmostEmpty;

endmodule

