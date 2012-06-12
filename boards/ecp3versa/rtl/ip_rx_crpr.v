// $Id: ip_rx_crpr.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

module ip_rx_crpr(clk, rstn,
               rx_st, rx_end, rx_din, rx_bar_hit,
               pd_cr, pd_num, ph_cr, npd_cr, nph_cr
);

input clk;
input rstn;

input rx_st;
input rx_end;
input [15:0] rx_din;
input [6:0] rx_bar_hit;

output pd_cr;
output [7:0] pd_num;
output ph_cr;
output npd_cr;
output nph_cr;

localparam e_IDLE     = 0;
localparam e_DATA_LEN = 1;
localparam e_WAIT     = 2;

reg pd_cr;
reg [7:0] pd_num;
reg ph_cr;
reg npd_cr;
reg nph_cr;

reg one_nph;
reg one_ph;
reg one_pd;
reg one_npd;

reg [1:0] sm;


always @(posedge clk or negedge rstn)
begin
  if (~rstn)
  begin
    pd_cr <= 1'b0;
    pd_num <= 8'd0;
    ph_cr <= 1'b0;
    npd_cr <= 1'b0;
    nph_cr <= 1'b0;
    one_ph <= 1'b0;
    one_pd <= 1'b0;
    one_nph <= 1'b0;
    one_npd <= 1'b0;
   
    sm <= e_IDLE;
  end
  else
  begin
  
    case (sm)    
    e_IDLE: // wait for TLP
    begin  
      // Decode Type of Request
      if (rx_st) begin
        sm <= e_WAIT;
        casex (rx_din[15:8])
        //8'h00: // MRd to BAR other than 0 or 1
        8'b00x0_0000: //0000_0000 for 3DW mrd; 0010_0000 for 4DW mrd; 
        begin
          if (~(rx_bar_hit[1] || rx_bar_hit[0])) //8'h40: // MWr to BAR other than 0 or 1
            one_nph <= 1'b1;
        end
        8'b00x0_0001: //0000_0001 for 3DW mrdlk; 0010_0001 for 4DW mrdlk 
          one_nph <= 1'b1;
        8'b01x0_0000: //0100_0000 for 3DW mwr; 0110_0000 for 4DW mwr
        begin
          if (~(rx_bar_hit[1] || rx_bar_hit[0]))
          begin            
            one_ph <= 1'b1;
            one_pd <= 1'b1;
            sm <= e_DATA_LEN;
          end
        end
        8'b0000_0010: begin //IO Rd
           one_nph <= 1'b1;
        end
        8'b0100_0010: begin //IO Wr
           one_nph <= 1'b1;
           one_npd <= 1'b1;
        end
        8'b00110xxx: // Msg
        begin
          one_ph <= 1'b1;
        end      
        8'b01110xxx: // MsgD
        begin
          one_ph <= 1'b1;
          one_pd <= 1'b1;
          sm <= e_DATA_LEN;
          //pd_num <= rx_din[38:32]; // get length
          //pd_num <= (rx_din[1:0] == 2'b00) ? rx_din[9:2] : (rx_din[9:2] + 1); // get length        
        end      
        8'h44: // CfgWr0
        begin
          one_nph <= 1'b1;
          one_npd <= 1'b1;
        end      
        8'h04: // CfgRd0
        begin
          one_nph <= 1'b1;
        end              
        8'h45: // CfgWr1
        begin
          one_nph <= 1'b1;
          one_npd <= 1'b1;
        end      
        8'h05: // CfgRd1
        begin
          one_nph <= 1'b1;
        end              
        default:  
        begin          
        end
        endcase    
      end
      else
      begin
        one_ph <= 1'b0;
        one_pd <= 1'b0;
        one_nph <= 1'b0;
        one_npd <= 1'b0;
      end
      
      ph_cr <= 1'b0;
      pd_cr <= 1'b0;
      nph_cr <= 1'b0;
      npd_cr <= 1'b0;
      
    end
    e_DATA_LEN: begin
      //pd_num <= rx_din[38:32]; // get length          
      pd_num <= (rx_din[1:0] == 2'b00) ? rx_din[9:2] : (rx_din[9:2] + 1); // get length     
      sm <= e_WAIT;
    end
    e_WAIT:  // process credits
    begin
      if (rx_end) begin
         ph_cr <= one_ph;
         one_ph <= 1'b0;
         
         nph_cr <= one_nph;
         one_nph <= 1'b0;
         
         npd_cr <= one_npd;
         one_npd <= 1'b0;
         
         pd_cr <= one_pd;      
         one_pd <= 1'b0;
      
         sm <= e_IDLE;
      end
          
    end
    default:
    begin
       sm <= e_IDLE; 
    end
    endcase
    
  end // clk
end


endmodule


  