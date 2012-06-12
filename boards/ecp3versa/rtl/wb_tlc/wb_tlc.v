// $Id: wb_tlc.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

module wb_tlc (clk_125, wb_clk, rstn, 
               rx_data, rx_st, rx_end, rx_bar_hit,
               wb_adr_o, wb_dat_o, wb_cti_o, wb_we_o, wb_sel_o, wb_stb_o, wb_cyc_o, wb_lock_o, 
               wb_dat_i, wb_ack_i,
               pd_cr, ph_cr, pd_num, npd_cr, nph_cr,               
               tx_rdy, tx_ca_cpl_recheck, tx_ca_cplh, tx_ca_cpld,
               tx_req, tx_data, tx_st, tx_end, 
               comp_id,
               debug
);
                    
input clk_125;
input wb_clk;
input rstn;

input [15:0] rx_data;
input rx_st;
input rx_end;
input [6:0] rx_bar_hit;

output [31:0] wb_adr_o;
output [15:0] wb_dat_o;
output [2:0] wb_cti_o;
output wb_we_o;
output [1:0] wb_sel_o;
output wb_stb_o;
output wb_cyc_o;
output wb_lock_o;
input wb_ack_i;
input [15:0] wb_dat_i;

output pd_cr, ph_cr, npd_cr, nph_cr;
output [7:0] pd_num;
input tx_rdy;
output tx_req;
output [15:0] tx_data;
output tx_st;
output tx_end;
input  tx_ca_cpl_recheck;
input  [8:0] tx_ca_cplh;
input  [12:0] tx_ca_cpld;
input [15:0] comp_id; // completer id = {bus_num, dev_num, func_num}

output [31:0] debug;

wire [15:0] to_req_fifo_dout;
wire to_req_fifo_sop;
wire to_req_fifo_eop;
wire to_req_fifo_dwen;
wire to_req_fifo_wrn;
wire to_req_fifo_wen;
wire [6:0] to_req_fifo_bar;

wire [15:0] from_req_fifo_dout;
wire from_req_fifo_sop;
wire from_req_fifo_eop;
wire from_req_fifo_wrn;
wire tlp_avail;

wire [15:0] read_data;
wire [9:0] tran_len;
wire [23:0] tran_id;
wire [7:0] tran_be;
wire [4:0] tran_addr;
wire [2:0] tran_tc;
wire [1:0] tran_attr;


wire [15:0] cmpl_d;
wire [6:0] from_req_fifo_bar;

reg ph_cr_wb;
reg [7:0] pd_num_wb;
reg read_comp_d;
reg [7:0] pd_num;
wb_tlc_dec #(.c_DATA_WIDTH (16)) dec(.clk_125(clk_125), .rstn(rstn),
               .rx_din(rx_data), .rx_sop(rx_st), .rx_eop(rx_end), .rx_dwen(1'b0), .rx_bar_hit(rx_bar_hit),
               .fifo_dout(to_req_fifo_dout), .fifo_sop(to_req_fifo_sop), .fifo_eop(to_req_fifo_eop),  
               .fifo_dwen(to_req_fifo_dwen), .fifo_wrn(to_req_fifo_wrn), .fifo_wen(to_req_fifo_wen),
               .fifo_bar(to_req_fifo_bar)
);                                           

wb_tlc_req_fifo #(.c_DATA_WIDTH (16)) req_fifo (.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk),
                    .din(to_req_fifo_dout), .din_bar(to_req_fifo_bar), .din_sop(to_req_fifo_sop), .din_eop(to_req_fifo_eop), 
                    .din_wrn(to_req_fifo_wrn),.din_dwen(1'b0), .din_wen(to_req_fifo_wen), 
                    .dout(from_req_fifo_dout), .dout_sop(from_req_fifo_sop), .dout_eop(from_req_fifo_eop), .dout_wrn(from_req_fifo_wrn), 
                    .dout_bar(from_req_fifo_bar), .dout_dwen(),
                    .dout_ren(to_req_fifo_ren), .tlp_avail(tlp_avail)
                    
);

always @(posedge wb_clk or negedge rstn)
   if (!rstn) begin
      ph_cr_wb <= 0;
      pd_num_wb <= 8'd1;
   end
   else begin
      ph_cr_wb <= from_req_fifo_sop & from_req_fifo_wrn;
      if (ph_cr_wb)
         pd_num_wb <= (from_req_fifo_dout[1:0] == 2'b00) ? from_req_fifo_dout[9:2] : (from_req_fifo_dout[9:2] + 1);
   end

wb_tlc_cr phcr(.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk), .cr_wb(ph_cr_wb), .cr_125(ph_cr));
assign pd_cr = ph_cr;          

always @(posedge clk_125 or negedge rstn)
   if (!rstn)
      pd_num <= 8'd1;
   else
      pd_num <= pd_num_wb;
      





wb_intf intf (.rstn(rstn), .wb_clk(wb_clk), 
               .din(from_req_fifo_dout), .din_sop(from_req_fifo_sop), .din_eop(from_req_fifo_eop), 
               .din_bar(from_req_fifo_bar), .din_wrn(from_req_fifo_wrn),
               .din_ren(to_req_fifo_ren), .tlp_avail(tlp_avail),
               .tran_id(tran_id), .tran_length(tran_len), .tran_be(tran_be), .tran_addr(tran_addr), .tran_tc(tran_tc), .tran_attr(tran_attr),
               .wb_adr_o(wb_adr_o), .wb_dat_o(wb_dat_o), .wb_cti_o(wb_cti_o), .wb_we_o(wb_we_o), .wb_sel_o(wb_sel_o), .wb_stb_o(wb_stb_o), .wb_cyc_o(wb_cyc_o), .wb_lock_o(wb_lock_o), .wb_ack_i(wb_ack_i)                              
);              


assign read_data = {wb_dat_i[7:0], wb_dat_i[15:8]}; // order bytes back to PCIe order

assign read_comp = wb_cyc_o && (~ wb_we_o);
assign read = read_comp && (~ read_comp_d);

always @(posedge wb_clk or negedge rstn)
   if (!rstn) begin
      read_comp_d <= 0;
   end
   else begin
      read_comp_d <= read_comp;
   end

wb_tlc_cpld  cpld (.wb_clk(wb_clk), .rstn(rstn),
                .din(read_data), .sel(wb_sel_o), .read(read), .valid(wb_ack_i),
                .tran_id(tran_id), .tran_length(tran_len), .tran_be(tran_be), .tran_addr(tran_addr), .tran_tc(tran_tc), .tran_attr(tran_attr), .comp_id(comp_id),
                .dout(cmpl_d), .dout_sop(cmpl_sop), .dout_eop(cmpl_eop),  .dout_wen(cmpl_wen)                
);


wb_tlc_cpld_fifo #(.c_DATA_WIDTH (16)) cpld_fifo(.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk),
                    .din(cmpl_d), .din_sop(cmpl_sop), .din_eop(cmpl_eop),  .din_dwen(1'b0), .din_wen(cmpl_wen),                  
                    .tx_data(tx_data), .tx_st(tx_st), .tx_end(tx_end), .tx_dwen(),  .tx_ca_cpl_recheck(tx_ca_cpl_recheck), .tx_ca_cplh(tx_ca_cplh), .tx_ca_cpld(tx_ca_cpld),
                    .tx_rdy(tx_rdy), .tx_req(tx_req)
); 

assign nph_cr = tx_st;
assign npd_cr = 1'b0;

endmodule
