// $Id: wb_tlc_cpld_fifo.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

`timescale 1ns / 100ps
module wb_tlc_cpld_fifo #(parameter c_DATA_WIDTH = 64)(rstn, clk_125, wb_clk,
                    din, din_sop, din_eop, din_dwen, din_wen,                    
                    tx_data, tx_st, tx_end, tx_dwen,  
                    tx_rdy, tx_req, tx_ca_cpl_recheck, tx_ca_cplh, tx_ca_cpld
                           
);

input         rstn;
input         clk_125;
input         wb_clk;
input  [c_DATA_WIDTH-1:0] din;
input         din_sop;
input         din_eop;
input         din_dwen;
input         din_wen;
output [c_DATA_WIDTH-1:0] tx_data;
output        tx_st;
output        tx_end;
output        tx_dwen;
output        tx_req;
input         tx_rdy;
input  tx_ca_cpl_recheck;
input  [8:0] tx_ca_cplh;
input  [12:0] tx_ca_cpld;


localparam c_BUF_DATA_WIDTH = c_DATA_WIDTH + 2;
localparam c_BUF_ADDR_WIDTH = 11;

wire [c_BUF_DATA_WIDTH-1:0] fifo_in, fifo_out;
reg rd_en;
assign fifo_in = {din_sop, din_eop, din};
assign fifo_wen = din_wen;

//pmi_fifo_dc #(
//    .pmi_data_width_w(c_BUF_DATA_WIDTH),
//    .pmi_data_width_r(c_BUF_DATA_WIDTH),
//    .pmi_data_depth_w(2048), // singe EBR
//    .pmi_data_depth_r(2048),
//    .pmi_full_flag(2048),
//    .pmi_empty_flag(0),
//    .pmi_almost_full_flag(2), // 1 or more MRd or MWr TLPs in the FIFO
//    .pmi_almost_empty_flag(1),
//    .pmi_regmode("noreg"),
//    .pmi_resetmode("async"),
//    .pmi_family("SC") ,
//    .module_type("pmi_fifo_dc"),
//    .pmi_implementation("EBR")
//)
//fifo (
//  .Data(fifo_in),
//  .WrClock(wb_clk),
//  .RdClock(clk_125),
//  .WrEn(fifo_wen),
//  .RdEn(fifo_rden),
//  .Reset(~rstn),
//  .RPReset(1'b0),
//  .Q(fifo_out),
//  .Empty(),
//  .Full(),
//  .AlmostEmpty(empty),
//  .AlmostFull()
//); 
   
async_pkt_fifo #(
.c_DATA_WIDTH  (c_BUF_DATA_WIDTH    ),
.c_ADDR_WIDTH  (c_BUF_ADDR_WIDTH    ),
.c_AFULL_FLAG  (100   ),
.c_AEMPTY_FLAG (3     )
)I_async_pkt_fifo(
.WrEop(din_eop),
.Data(fifo_in), 
.WrClock(wb_clk), 
.RdClock(clk_125), 
.WrEn(fifo_wen), 
.RdEn(fifo_rd_en),
.Reset(~rstn),

.Q(fifo_out), 
.Empty(empty),
.AlmostEmpty(AlmostEmpty), 
.AlmostFull()
);

localparam e_idle     = 0;
localparam e_wait     = 1;
localparam e_check_ca = 2;
localparam e_req      = 3;
localparam e_xmit     = 4;

reg [2:0] state;
wire [14:0] tx_ca_cpld_ext = {tx_ca_cpld, 2'd0};
reg [c_DATA_WIDTH-1:0] tx_data;
reg        tx_st;
reg        tx_end;
wire [c_DATA_WIDTH-1:0] tx_data_i;
reg [c_DATA_WIDTH-1:0] tx_data_i_d;

assign tx_data_i = fifo_out[c_DATA_WIDTH-1:0];
assign tx_end_i  = fifo_out[c_DATA_WIDTH];
assign tx_st_i  = fifo_out[c_DATA_WIDTH+1]; 
assign tx_dwen = 1'b0;

assign credit_is_ok = (tx_ca_cplh != 0) && (tx_ca_cpld_ext >= tx_data_i[9:0]);
assign tx_req = state == e_req;
assign fifo_rd_en = rd_en && (~ ((state == e_xmit) && tx_end_i));
always @(posedge clk_125 or negedge rstn)
begin
  if (~rstn)
  begin
    rd_en    <= 0;
    state    <= e_idle;
    tx_st    <= 0;
    tx_data  <= 0;
    tx_end   <= 0;
    tx_data_i_d <= 0;
  end
  else 
  begin
       
    case (state)
       e_idle: begin 
          rd_en    <= 0;
          tx_st    <= 0;       
          tx_data  <= 0;       
          tx_end   <= 0;       
          if (~AlmostEmpty) begin
             state <= e_wait;
             rd_en <= 1'b1;
          end
          else
             rd_en <= 1'b0;
       end
       e_wait: begin
          if (tx_st_i) begin
             state <= e_check_ca;
             tx_data_i_d <= tx_data_i;
             rd_en <= 1'b0;
          end
          else
             rd_en <= 1'b1;
       end
       e_check_ca: begin
          rd_en <= 1'b0;
          if (~ tx_st_i) begin
             if (credit_is_ok & (~ tx_ca_cpl_recheck))
                state <= e_req;
          end
          else 
             rd_en <= ~ rd_en;
       end
       e_req: begin
          if (tx_ca_cpl_recheck)
             state <= e_check_ca;
          else if (tx_rdy )begin
             rd_en <= 1'b1;
             state <= e_xmit;
             tx_st <= 1'b1;
             tx_data <= tx_data_i_d;
             tx_end <= 1'b0;
          end
       end
       e_xmit: begin
          tx_st <= 1'b0;
          tx_data <= tx_data_i;
          tx_end <= tx_end_i;       
       
          if (tx_end_i) begin
             state <= e_idle;
             rd_en <= 1'b0;
          end
       end
       default:
          state <= e_idle;
    endcase
  end  
end




endmodule

