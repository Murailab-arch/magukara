// $Id: ip_tx_arbiter.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

module ip_tx_arbiter #(parameter c_DATA_WIDTH = 64)
(clk, rstn, tx_val,
                  tx_req_0, tx_din_0, tx_sop_0, tx_eop_0, tx_dwen_0,                 
                  tx_req_1, tx_din_1, tx_sop_1, tx_eop_1, tx_dwen_1,
                  tx_req_2, tx_din_2, tx_sop_2, tx_eop_2, tx_dwen_2,
                  tx_req_3, tx_din_3, tx_sop_3, tx_eop_3, tx_dwen_3,
                  tx_rdy_0, tx_rdy_1, tx_rdy_2, tx_rdy_3,
                  tx_req, tx_dout, tx_sop, tx_eop, tx_dwen,
                  tx_rdy                  
);  

input clk;
input rstn;
input tx_val;

input tx_req_0;
input [c_DATA_WIDTH-1:0] tx_din_0;
input tx_sop_0;
input tx_eop_0;
input tx_dwen_0;
output tx_rdy_0;

input tx_req_1;
input [c_DATA_WIDTH-1:0] tx_din_1;
input tx_sop_1;
input tx_eop_1;
input tx_dwen_1;
output tx_rdy_1;

input tx_req_2;
input [c_DATA_WIDTH-1:0] tx_din_2;
input tx_sop_2;
input tx_eop_2;
input tx_dwen_2;
output tx_rdy_2;

input tx_req_3;
input [c_DATA_WIDTH-1:0] tx_din_3;
input tx_sop_3;
input tx_eop_3;
input tx_dwen_3;
output tx_rdy_3;

output tx_req;
output [c_DATA_WIDTH-1:0] tx_dout;
output tx_sop;
output tx_eop;
output tx_dwen;
input tx_rdy;

reg tx_req;
reg [c_DATA_WIDTH-1:0] tx_dout;
reg tx_sop;
reg tx_eop;
reg tx_dwen;
reg tx_rdy_0;
reg tx_rdy_1;
reg tx_rdy_2;
reg tx_rdy_3;

reg [1:0] rr;
reg tx_rdy_p;
reg tx_rdy_p2;


always @(rr or tx_rdy or 
         tx_req_0 or tx_din_0 or tx_sop_0 or tx_eop_0 or tx_dwen_0 or
         tx_req_1 or tx_din_1 or tx_sop_1 or tx_eop_1 or tx_dwen_1 or
         tx_req_2 or tx_din_2 or tx_sop_2 or tx_eop_2 or tx_dwen_2 or
         tx_req_3 or tx_din_3 or tx_sop_3 or tx_eop_3 or tx_dwen_3  ) 

begin
  
   case (rr)
   2'b00: // Service 0
   begin
     tx_req <= tx_req_0;
     tx_dout <= tx_din_0;
     tx_sop <= tx_sop_0;
     tx_eop <= tx_eop_0;
     tx_dwen <= tx_dwen_0;     
     tx_rdy_0 <= tx_rdy;
     tx_rdy_3 <= 1'b0;
     tx_rdy_2 <= 1'b0;
     tx_rdy_1 <= 1'b0;

   end
   2'b01: // Service 1
   begin
     tx_req <= tx_req_1;
     tx_dout <= tx_din_1;
     tx_sop <= tx_sop_1;
     tx_eop <= tx_eop_1;
     tx_dwen <= tx_dwen_1;     
     tx_rdy_1 <= tx_rdy;
     tx_rdy_3 <= 1'b0;
     tx_rdy_2 <= 1'b0;
     tx_rdy_0 <= 1'b0;

   end
   2'b10: // Service 2
   begin
     tx_req <= tx_req_2;
     tx_dout <= tx_din_2;
     tx_sop <= tx_sop_2;
     tx_eop <= tx_eop_2;
     tx_dwen <= tx_dwen_2;      
     tx_rdy_2 <= tx_rdy;
     tx_rdy_3 <= 1'b0;
     tx_rdy_1 <= 1'b0;
     tx_rdy_0 <= 1'b0;

   end 
   2'b11: // Service 3
   begin
     tx_req <= tx_req_3;
     tx_dout <= tx_din_3;
     tx_sop <= tx_sop_3;
     tx_eop <= tx_eop_3;
     tx_dwen <= tx_dwen_3;      
     tx_rdy_3 <= tx_rdy;
     tx_rdy_2 <= 1'b0;
     tx_rdy_1 <= 1'b0;
     tx_rdy_0 <= 1'b0;

   end 
   default:
   begin
   end
   endcase

end


// mux control
always @(posedge clk or negedge rstn)
begin
  if (~rstn)
  begin
    rr <= 2'b00;    
    tx_rdy_p <= 1'b0;
    tx_rdy_p2 <= 1'b0;
  end
  else
  begin
    tx_rdy_p <= tx_rdy; // use pipe of tx_rdy to account for getting the tx_end through
    tx_rdy_p2 <= tx_rdy_p;
  
    if (tx_val && ~tx_rdy_p2 && ~tx_rdy_p && ~tx_rdy)
    begin
      if (tx_req_0 && ~tx_req)
        rr <= 2'b00;
      else if (tx_req_1 && ~tx_req)
        rr <= 2'b01;
      else if (tx_req_2 && ~tx_req)
        rr <= 2'b10;
      else if (tx_req_3 && ~tx_req)
        rr <= 2'b11;
    end
  end
end

endmodule

