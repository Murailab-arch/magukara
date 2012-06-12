// $Id: ip_crpr_arb.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

module ip_crpr_arb(clk, rstn,               
                  pd_cr_0, pd_num_0, ph_cr_0, npd_cr_0, nph_cr_0,
                  pd_cr_1, pd_num_1, ph_cr_1, npd_cr_1, nph_cr_1,
                  pd_cr, pd_num, ph_cr, npd_cr, nph_cr
                  
);

input clk;
input rstn;

input pd_cr_0;
input [7:0] pd_num_0;
input ph_cr_0;
input npd_cr_0;
input nph_cr_0;

input pd_cr_1;
input [7:0] pd_num_1;
input ph_cr_1;
input npd_cr_1;
input nph_cr_1;

output pd_cr;
output [7:0] pd_num;
output ph_cr;
output npd_cr;
output nph_cr;

reg pd_cr;
reg [7:0] pd_num;
reg ph_cr;
reg npd_cr;
reg nph_cr;

reg pd_cr_1p;
reg [7:0] pd_num_1p;
reg ph_cr_1p;
reg npd_cr_1p;
reg nph_cr_1p;

reg del_p1, del_np1;

// This arbiter works on an assumption that there is at least 1 clock cycle of gap between credits
// The arbiter will select the port that is active.  If both are active it will delay port1 and use 
// that data on the next clock cycle.  

always @(posedge clk or negedge rstn)
begin
  if (~rstn)
  begin
    pd_cr <= 1'b0;
    pd_num <= 8'd0;
    ph_cr <= 1'b0;
    npd_cr <= 1'b0;
    nph_cr <= 1'b0;
    pd_cr_1p <= 1'b0;
    pd_num_1p <= 8'd0;
    ph_cr_1p <= 1'b0;
    npd_cr_1p <= 1'b0;
    nph_cr_1p <= 1'b0;
    del_p1 <= 1'b0;
    del_np1 <= 1'b0;
  end
  else
  begin
    pd_cr_1p <=  pd_cr_1;
    pd_num_1p <= pd_num_1;
    ph_cr_1p <=  ph_cr_1;
    npd_cr_1p <= npd_cr_1;
    nph_cr_1p <= nph_cr_1;
    
    if (del_p1)
    begin
      ph_cr <= ph_cr_1p;
      pd_cr <= pd_cr_1p;
      pd_num <= pd_num_1p;
      del_p1 <= 1'b0;      
    end
    else
    begin    
      case ({ph_cr_1, ph_cr_0})
      2'b00:
      begin
        ph_cr <= 1'b0;
        pd_cr <= 1'b0;
        pd_num <= 8'd0;
      end
      2'b01:
      begin
        ph_cr <= ph_cr_0;
        pd_cr <= pd_cr_0;
        pd_num <= pd_num_0;
        
      end
      2'b10:
      begin
        ph_cr <= ph_cr_1;
        pd_cr <= pd_cr_1;   
        pd_num <= pd_num_1; 
      end
      2'b11:
      begin
        ph_cr <= ph_cr_0;
        pd_cr <= pd_cr_0;
        pd_num <= pd_num_0;
        del_p1 <= 1'b1;
      end
      endcase
    end
  
    if (del_np1)
    begin
      nph_cr <= nph_cr_1p;
      npd_cr <= npd_cr_1p;
      del_np1 <= 1'b0;      
    end
    else
    begin    
      case ({nph_cr_1, nph_cr_0})
      2'b00:
      begin
        nph_cr <= 1'b0;
        npd_cr <= 1'b0;
      end
      2'b01:
      begin
        nph_cr <= nph_cr_0;
        npd_cr <= npd_cr_0;
      end
      2'b10:
      begin
        nph_cr <= nph_cr_1;
        npd_cr <= npd_cr_1;    
      end
      2'b11:
      begin
        nph_cr <= nph_cr_0;
        npd_cr <= npd_cr_0;
        del_np1 <= 1'b1;
      end
      endcase
    end 
  
    
  end // clk
end


endmodule


  