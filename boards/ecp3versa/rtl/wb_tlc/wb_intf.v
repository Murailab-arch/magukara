// $Id: wb_intf.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

`timescale 1ns / 100ps
module wb_intf(rstn, wb_clk, 
              din, din_bar, din_sop, din_eop, din_wrn, 
              din_ren, tlp_avail,
              tran_id, tran_length, tran_be, tran_addr, tran_tc, tran_attr,            
              wb_adr_o, wb_dat_o, wb_we_o, wb_sel_o, wb_stb_o, wb_cyc_o, wb_lock_o, wb_cti_o,
              wb_ack_i              
);              
  
input         rstn;
input         wb_clk;
input  [15:0] din;
input  [6:0]  din_bar;
input         din_sop;
input         din_eop;
input         din_wrn;
output        din_ren;
input         tlp_avail;
output [23:0] tran_id;
output [9:0]  tran_length;
output [7:0]  tran_be;
output [4:0]  tran_addr;
output [2:0]  tran_tc;
output [1:0]  tran_attr;
output [15:0] wb_dat_o;
output [31:0] wb_adr_o;
output [2:0]  wb_cti_o;
output        wb_we_o;
output [1:0]  wb_sel_o;
output        wb_stb_o;
output        wb_cyc_o;
output        wb_lock_o;
input         wb_ack_i;

reg din_ren_inner;
reg [23:0] tran_id;
reg write;
reg [9:0] length, tran_length;
reg [31:0] wb_adr_o;
reg [2:0] wb_cti_o;
reg [4:0] tran_addr;
reg [2:0] tran_tc;
reg [1:0] tran_attr;
reg wb_cyc_o;
reg wb_stb_o;
reg [7:0] tran_be;


reg [3:0] first_be, last_be;


reg [2:0] sm;
reg [10:0] word_cnt;
reg long_head;
reg [1:0]  wb_sel_o;
reg [15:0] wb_dat_o;
parameter IDLE   = 3'd0,
          READ   = 3'd1,    
          HEADER = 3'd2,
          ADR    = 3'd3,
          DAT_1  = 3'd4,
          DAT    = 3'd5,
          CLEAR  = 3'd6;


wire [9:0] length_minus1 = length - 1;
assign din_ren = din_ren_inner || ((sm == DAT) && write && wb_ack_i && (~ din_eop));

always @(negedge rstn or posedge wb_clk)
begin
  if (~rstn)
  begin
    din_ren_inner <= 1'b0;
    sm <= IDLE;
    length <= 10'd0;
    tran_length <= 10'd0;
    tran_addr <= 5'd0;
    tran_tc <= 3'd0;
    tran_attr <= 2'b00;
    wb_adr_o <= 32'd0;    
    wb_stb_o <= 0;
    wb_cti_o <= 0;
    tran_id <= 24'd0;                 
    write <= 1'b0;
    wb_cyc_o <= 1'b0;        
        
    first_be <= 4'd0;
    last_be <= 4'd0;
    tran_be <= 8'd0;
    word_cnt <= 0;
    long_head <= 0;
    wb_sel_o <= 0;
    wb_dat_o <= 0;
  end
  else
  begin    
    tran_be <= {first_be, last_be}; 
      
    
    case (sm)
     IDLE:
     begin
       write <= 1'b0;
       if (tlp_avail)
       begin
         din_ren_inner <= 1'b1;            
         sm <= READ;
       end
     end
     READ: begin  //decode byte 0 and byte 1
        if (din_sop) begin
           tran_tc <= din[6:4];
           sm <= HEADER;
           write <= din_wrn;
           long_head <= din[13];
           word_cnt <= 1;
        end
     end
     HEADER:     //decode common request header
     begin
       if (~ din_sop)
          word_cnt <= word_cnt + 1;
          
       if (word_cnt == 3)
          sm <= ADR;
            
         
       if (word_cnt == 1) begin
         tran_attr <= din[13:12];
         length <= din[9:0];                  
         tran_length <= din[9:0];         
       end
       
       if (word_cnt == 2)
         tran_id[23:8] <= din;
         
       if (word_cnt == 3) begin
         tran_id[7:0]  <= din[15:8];
         first_be <= din[3:0];   
         last_be <= din[7:4];
       end          
     end      
     ADR: // address field of TLP
     begin     
       // Adjust WB addr for BAR
       word_cnt <= word_cnt + 1;
       wb_cti_o <= 3'b000;
       if (long_head) begin //4DW header
          if (word_cnt == 6) begin 
             wb_adr_o[31:16] <= {14'd0, din[1:0]};
             din_ren_inner <= write;
          end
             
          if (word_cnt == 7) begin 
             wb_adr_o[15:0]  <= din;
             tran_addr <= din[6:2];
             sm <= DAT_1;
             word_cnt <= 1;
             din_ren_inner <= write;
          end   
       end
       else begin //3DW header
          if (word_cnt == 4) begin
             wb_adr_o[31:16] <= {14'd0, din[1:0]};
             din_ren_inner <= write;
          end
             
          if (word_cnt == 5) begin
             wb_adr_o[15:0]  <= din;
             tran_addr <= din[6:2];
             sm <= DAT_1;       
             word_cnt <= 1;
             din_ren_inner <= write;
          end   
       end
     end
     DAT_1: begin
        din_ren_inner <= 1'b0;
        wb_sel_o <= {first_be[0], first_be[1]};//first_be[1:0];
        wb_cti_o <= 3'b000;
        wb_dat_o <= {din[7:0], din[15:8]};
        sm <= DAT;
     end
     DAT: // start length counter
     begin      
       wb_cyc_o <= 1'b1;
       wb_stb_o <= 1'b1;              
       din_ren_inner <= 1'b0;
       if (wb_ack_i) begin
          wb_adr_o <= wb_adr_o + 2;
          wb_dat_o <= {din[7:0], din[15:8]};
          
          if (word_cnt == {length, 1'b0}) begin
             sm <= CLEAR;
             wb_cyc_o <= 1'b0;
             wb_stb_o <= 1'b0;
          end
          else begin
             word_cnt <= word_cnt + 1;
          end
          
          if (word_cnt == 1) //second
             wb_sel_o <= {first_be[2], first_be[3]};//first_be[3:2];
          else if (word_cnt == {length_minus1, 1'b0})
             wb_sel_o <= {last_be[0], last_be[1]};//last_be[1:0];
          else if (word_cnt == {length_minus1, 1'b1})
             wb_sel_o <= {last_be[2], last_be[3]};//last_be[3:2];
          else
             wb_sel_o <= 2'b11;
             
          if (word_cnt == {length_minus1, 1'b1})
             wb_cti_o <= 3'b111; 
          else
             wb_cti_o <= 3'b000;              
       end
     end
     CLEAR: // wait state
     begin          
           wb_cyc_o <= 1'b0;
           wb_stb_o <= 1'b0;  
           write <= 1'b0;
           sm <= IDLE;        
     end 
    endcase
    
  
  end // clk
end 



// order byte enables for WB little endian

assign wb_we_o = write;         
assign wb_lock_o = wb_cyc_o;

endmodule


