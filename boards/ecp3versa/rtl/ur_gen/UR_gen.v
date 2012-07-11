// $Id: UR_gen.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

// This module is the catch all for any TLP that is not supported by the other
// clients.  
// Currently this module will generate UR for MRdLk, IO, Cfg1, Cpl, and Memory reads other than BAR1


`timescale 1ns / 100ps
module UR_gen(rstn, clk,
               rx_din, rx_sop, rx_eop, rx_us, rx_bar_hit,
               tx_rdy, tx_ca_cpl_recheck, tx_ca_cplh,
               tx_req, tx_dout, tx_sop, tx_eop,
               comp_id          
);
              
  

input         rstn;
input         clk;
input  [15:0] rx_din;
input         rx_sop;
input         rx_eop;
input         rx_us;
input [6:0]   rx_bar_hit;
input         tx_rdy;
input         tx_ca_cpl_recheck;
input [8:0]   tx_ca_cplh;
output        tx_req;
output [15:0] tx_dout;
output        tx_sop;
output        tx_eop;
input [15:0]  comp_id; 

localparam e_idle        = 0;
localparam e_rcv_req     = 1;
localparam e_check       = 2;
localparam e_wait        = 3;
localparam e_xmit        = 4;

reg  [15:0] tx_dout;
reg         tx_sop;
reg         tx_eop;
reg         tx_req;
reg [2:0] sm;
reg [15:0] req_id;
wire [2:0] sts;
reg [7:0] rcv_tag;
reg [2:0] traffic_class;
reg [1:0] attribute_field;
reg [2:0] word_cnt;
reg expected_ur;
reg mrd_lk;
assign sts = 3'b001; //unsupportted completion

always @(negedge rstn or posedge clk)
begin
  if (~rstn)
  begin
    word_cnt <= 0;
    expected_ur <= 0;
    traffic_class <= 0;
    attribute_field <= 0;
    rcv_tag <= 0;
    tx_req <= 1'b0;
    tx_sop <= 1'b0;
    tx_eop <= 1'b0;
    tx_dout <= 16'd0;
    sm <= 3'b000;
    req_id <= 24'd0;
    mrd_lk <= 0;
  end
  else
  begin
    case (sm)
       e_idle: begin // Decode Type of Request
         word_cnt <= 0;
         tx_sop   <= 1'b0;
         tx_req   <= 1'b0;
         tx_eop   <= 1'b0;
         if (rx_sop) begin
            sm <= e_rcv_req;
            traffic_class <= rx_din[6:4];
            mrd_lk <= (rx_din[14] == 1'b0) && (rx_din[12:8] == 5'b0_0001);
            casex(rx_din[15:8]) //decode fmt type
               8'b0000_0010: expected_ur <= 1'b1; // IORd
               8'b0100_0010: expected_ur <= 1'b1; // IOWr
               8'b00x0_0000: expected_ur <= ~ (rx_bar_hit[1] || rx_bar_hit[0]); // MRd 3DW or 4DW
               default: expected_ur <= 1'b0;
            endcase
         end
       end
       e_rcv_req: begin //
          word_cnt <= word_cnt + 1;
          if (word_cnt == 0) attribute_field <= rx_din[8+5:8+4];
          if (word_cnt == 1) req_id <= rx_din;
          if (word_cnt == 2) rcv_tag <= rx_din[15:8];
          
          if (rx_eop) begin
             if (expected_ur || rx_us)  // IP core indicates CfgWr1, CfgRd1, MRdLk, CplLk, CplDLk, Msg (Vendor Defined) 
                sm <= e_check;
             else
                sm <= e_idle;
          end
       end
       e_check: begin
          if ((tx_ca_cplh != 0) && (~ tx_ca_cpl_recheck))
             sm <= e_wait;
       end
       e_wait: begin // Send completion
          word_cnt <= 0; 
          tx_req   <= 1'b1;
          if (tx_ca_cpl_recheck) begin
             sm <= e_check;
             tx_req <= 1'b0;
          end
          else if (tx_rdy) begin
             sm <= e_xmit;
             tx_req   <= 1'b0;
             tx_sop <= 1'b1; 
             tx_eop <= 1'b0; 
             tx_dout <= {7'b0000101, mrd_lk, 1'b0, traffic_class, 4'd0};
          end
          else
             tx_req   <= 1'b1;
       end
       e_xmit: begin
          word_cnt <= word_cnt + 1;
          case (word_cnt)
             0      : begin tx_sop <= 1'b0; tx_eop <= 1'b0; tx_dout <= {1'b0, 1'b0, attribute_field, 2'b0, 10'd0}; end
             1      : begin tx_sop <= 1'b0; tx_eop <= 1'b0; tx_dout <= comp_id; end
             2      : begin tx_sop <= 1'b0; tx_eop <= 1'b0; tx_dout <= {sts, 13'd4}; end
             3      : begin tx_sop <= 1'b0; tx_eop <= 1'b0; tx_dout <= req_id; end
             default: begin tx_sop <= 1'b0; tx_eop <= 1'b1; tx_dout <= {rcv_tag, 1'b0, 7'd0}; end
          endcase
          
          if (word_cnt == 3'd4) sm <= e_idle;           
       end
       default:
          sm <= e_idle;
     endcase
  end // end clk
end 

endmodule

