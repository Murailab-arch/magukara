`define ECP3VERSA

module top (
  input rstn,
  input FLIP_LANES,
  input refclkp,
  input refclkn,
  input hdinp,
  input hdinn,
  output hdoutp,
  output hdoutn,
  // Ethernet PHY#1
  output phy1_rst_n,
  input phy1_125M_clk,
  input phy1_tx_clk,
  output phy1_gtx_clk,
  output phy1_tx_en,
  output [7:0] phy1_tx_data,
  input phy1_rx_clk,
  input phy1_rx_dv,
  input phy1_rx_er,
  input [7:0] phy1_rx_data,
  input phy1_col,
  input phy1_crs,
  output phy1_mii_clk,
  inout phy1_mii_data,
  // Ethernet PHY#2
  output phy2_rst_n,
  input phy2_125M_clk,
  input phy2_tx_clk,
  output phy2_gtx_clk,
  output phy2_tx_en,
  output [7:0] phy2_tx_data,
  input phy2_rx_clk,
  input phy2_rx_dv,
  input phy2_rx_er,
  input [7:0] phy2_rx_data,
  input phy2_col,
  input phy2_crs,
  output phy2_mii_clk,
  inout phy2_mii_data,
  // Switch/LED
  input [7:0] dip_switch,
  output [13:0] led_out,
  output dp,
  input reset_n
);

reg  [20:0] rstn_cnt;
reg  core_rst_n;
wire [15:0] rx_data, tx_data,  tx_dout_wbm, tx_dout_ur;
wire [6:0] rx_bar_hit;
wire [7:0] pd_num, pd_num_ur, pd_num_wb;

wire [15:0] pcie_dat_i, pcie_dat_o;
wire [31:0] pcie_adr;
wire [1:0] pcie_sel;
wire [2:0] pcie_cti;
wire pcie_cyc;
wire pcie_we;
wire pcie_stb;
wire pcie_ack;

wire [7:0] bus_num;
wire [4:0] dev_num;
wire [2:0] func_num;

wire [8:0] tx_ca_ph;
wire [12:0] tx_ca_pd;
wire [8:0] tx_ca_nph;
wire [12:0] tx_ca_npd;
wire [8:0] tx_ca_cplh;
wire [12:0] tx_ca_cpld;
wire clk_125;
wire tx_eop_wbm;

// Reset management
always @(posedge clk_125 or negedge rstn) begin
  if (!rstn) begin
    rstn_cnt   <= 21'd0;
    core_rst_n <= 1'b0;
  end else begin
    if (rstn_cnt[20])            // 8ms in real hardware
      core_rst_n <= 1'b1;
    else
      rstn_cnt <= rstn_cnt + 1'b1;
  end
end

pcie_top pcie (
  .refclkp(refclkp),
  .refclkn(refclkn),
  .sys_clk_125(clk_125),
  .ext_reset_n(rstn),
  .rstn(core_rst_n),
  .flip_lanes(FLIP_LANES),
  .hdinp0(hdinp),
  .hdinn0(hdinn),
  .hdoutp0(hdoutp),
  .hdoutn0(hdoutn),
  .msi(8'd0),
  .inta_n(1'b1),
  // This PCIe interface uses dynamic IDs.
  .vendor_id(16'h3776),
  .device_id(16'h8000),
  .rev_id(8'h00),
  .class_code(24'h000000),
  .subsys_ven_id(16'h3776),
  .subsys_id(16'h8000),
  .load_id(1'b1),
  // Inputs
  .force_lsm_active(1'b0),
  .force_rec_ei(1'b0),
  .force_phy_status(1'b0),
  .force_disable_scr(1'b0),
  .hl_snd_beacon(1'b0),
  .hl_disable_scr(1'b0),
  .hl_gto_dis(1'b0),
  .hl_gto_det(1'b0),
  .hl_gto_hrst(1'b0),
  .hl_gto_l0stx(1'b0),
  .hl_gto_l1(1'b0),
  .hl_gto_l2(1'b0),
  .hl_gto_l0stxfts(1'b0),
  .hl_gto_lbk(1'd0),
  .hl_gto_rcvry(1'b0),
  .hl_gto_cfg(1'b0),
  .no_pcie_train(1'b0),
  // Power Management Interface
  .tx_dllp_val(2'd0),
  .tx_pmtype(3'd0),
  .tx_vsd_data(24'd0),
  .tx_req_vc0(tx_req),
  .tx_data_vc0(tx_data),
  .tx_st_vc0(tx_st),
  .tx_end_vc0(tx_end),
  .tx_nlfy_vc0(1'b0),
  .ph_buf_status_vc0(1'b0),
  .pd_buf_status_vc0(1'b0),
  .nph_buf_status_vc0(1'b0),
  .npd_buf_status_vc0(1'b0),
  .ph_processed_vc0(ph_cr),
  .pd_processed_vc0(pd_cr),
  .nph_processed_vc0(nph_cr),
  .npd_processed_vc0(npd_cr),
  .pd_num_vc0(pd_num),
  .npd_num_vc0(8'd1),
  // From User logic
  .cmpln_tout(1'b0),
  .cmpltr_abort_np(1'b0),
  .cmpltr_abort_p(1'b0),
  .unexp_cmpln(1'b0),
  .ur_np_ext(1'b0),
  .ur_p_ext(1'b0),
  .np_req_pend(1'b0),
  .pme_status(1'b0),
  .tx_rdy_vc0(tx_rdy),
  .tx_ca_ph_vc0(tx_ca_ph),
  .tx_ca_pd_vc0(tx_ca_pd),
  .tx_ca_nph_vc0(tx_ca_nph),
  .tx_ca_npd_vc0(tx_ca_npd),
  .tx_ca_cplh_vc0(tx_ca_cplh),
  .tx_ca_cpld_vc0(tx_ca_cpld),
  .tx_ca_p_recheck_vc0(tx_ca_p_recheck),
  .tx_ca_cpl_recheck_vc0(tx_ca_cpl_recheck),
  .rx_data_vc0(rx_data),
  .rx_st_vc0(rx_st),
  .rx_end_vc0(rx_end),
  .rx_us_req_vc0(rx_us_req),
  .rx_malf_tlp_vc0(rx_malf_tlp),
  .rx_bar_hit(rx_bar_hit),
  // From Config Registers
  .bus_num(bus_num),
  .dev_num(dev_num),
  .func_num(func_num)
);

reg rx_st_d;
reg tx_st_d;
reg [15:0] tx_tlp_cnt;
reg [15:0] rx_tlp_cnt;
always @(posedge clk_125 or negedge core_rst_n) begin
  if (!core_rst_n) begin
    tx_st_d    <= 0;
    rx_st_d    <= 0;
    tx_tlp_cnt <= 0;
    rx_tlp_cnt <= 0;
  end else begin
    tx_st_d <= tx_st;
    rx_st_d <= rx_st;
    if (tx_st_d)
      tx_tlp_cnt <= tx_tlp_cnt + 1;
    if (rx_st_d)
      rx_tlp_cnt <= rx_tlp_cnt + 1;
  end
end

ip_rx_crpr cr (
  .clk(clk_125), .rstn(core_rst_n), .rx_bar_hit(rx_bar_hit),
  .rx_st(rx_st), .rx_end(rx_end), .rx_din(rx_data),
  .pd_cr(pd_cr_ur), .pd_num(pd_num_ur), .ph_cr(ph_cr_ur), .npd_cr(npd_cr_ur), .nph_cr(nph_cr_ur)
);

ip_crpr_arb crarb (
  .clk(clk_125), .rstn(core_rst_n),
  .pd_cr_0(pd_cr_ur), .pd_num_0(pd_num_ur), .ph_cr_0(ph_cr_ur), .npd_cr_0(npd_cr_ur), .nph_cr_0(nph_cr_ur),
  .pd_cr_1(pd_cr_wb), .pd_num_1(pd_num_wb), .ph_cr_1(ph_cr_wb), .npd_cr_1(1'b0), .nph_cr_1(nph_cr_wb),
  .pd_cr(pd_cr), .pd_num(pd_num), .ph_cr(ph_cr), .npd_cr(npd_cr), .nph_cr(nph_cr)
);

UR_gen ur (
  .clk(clk_125), .rstn(core_rst_n),
  .rx_din(rx_data), .rx_sop(rx_st), .rx_eop(rx_end), .rx_us(rx_us_req), .rx_bar_hit(rx_bar_hit),
  .tx_rdy(tx_rdy_ur), .tx_ca_cpl_recheck(1'b0), .tx_ca_cplh(tx_ca_cplh),
  .tx_req(tx_req_ur), .tx_dout(tx_dout_ur), .tx_sop(tx_sop_ur), .tx_eop(tx_eop_ur),
  .comp_id({bus_num, dev_num, func_num})
);

ip_tx_arbiter #(.c_DATA_WIDTH (16))
tx_arb(
  .clk(clk_125), .rstn(core_rst_n), .tx_val(1'b1),
  .tx_req_0(tx_req_wbm), .tx_din_0(tx_dout_wbm), .tx_sop_0(tx_sop_wbm), .tx_eop_0(tx_eop_wbm), .tx_dwen_0(1'b0),
  .tx_req_1(1'b0), .tx_din_1(16'd0), .tx_sop_1(1'b0), .tx_eop_1(1'b0), .tx_dwen_1(1'b0),
  .tx_req_2(1'b0), .tx_din_2(16'd0), .tx_sop_2(1'b0), .tx_eop_2(1'b0), .tx_dwen_2(1'b0),
  .tx_req_3(tx_req_ur), .tx_din_3(tx_dout_ur), .tx_sop_3(tx_sop_ur), .tx_eop_3(tx_eop_ur), .tx_dwen_3(1'b0),
  .tx_rdy_0(tx_rdy_wbm), .tx_rdy_1(), .tx_rdy_2(), .tx_rdy_3(tx_rdy_ur),
  .tx_req(tx_req), .tx_dout(tx_data), .tx_sop(tx_st), .tx_eop(tx_end), .tx_dwen(), .tx_rdy(tx_rdy)
);

wb_tlc wb_tlc(
  .clk_125(clk_125), .wb_clk(clk_125), .rstn(core_rst_n), .rx_data(rx_data),
  .rx_st(rx_st), .rx_end(rx_end), .rx_bar_hit(rx_bar_hit),
  .wb_adr_o(pcie_adr), .wb_dat_o(pcie_dat_o), .wb_cti_o(pcie_cti), .wb_we_o(pcie_we), .wb_sel_o(pcie_sel),
  .wb_stb_o(pcie_stb), .wb_cyc_o(pcie_cyc), .wb_lock_o(),
  .wb_dat_i(pcie_dat_i), .wb_ack_i(pcie_ack),
  .pd_cr(pd_cr_wb), .pd_num(pd_num_wb), .ph_cr(ph_cr_wb), .npd_cr(npd_cr_wb), .nph_cr(nph_cr_wb),
  .tx_rdy(tx_rdy_wbm), .tx_req(tx_req_wbm), .tx_data(tx_dout_wbm), .tx_st(tx_sop_wbm), .tx_end(tx_eop_wbm),
  .tx_ca_cpl_recheck(1'b0), .tx_ca_cplh(tx_ca_cplh), .tx_ca_cpld(tx_ca_cpld),
  .comp_id({bus_num, dev_num, func_num}),
  .debug()
);

//-----------------------------------
// PCI user registers
//-----------------------------------
reg         tx0_enable;
reg         tx0_ipv6;
reg         tx0_fullroute;
reg         tx0_req_arp;
reg  [15:0] tx0_frame_len;
reg  [31:0] tx0_inter_frame_gap;
reg  [31:0] tx0_ipv4_srcip;
reg  [47:0] tx0_src_mac;
reg  [31:0] tx0_ipv4_gwip;
reg  [127:0] tx0_ipv6_srcip;
reg  [127:0] tx0_ipv6_dstip;
wire [47:0] tx0_dst_mac;
reg  [31:0] tx0_ipv4_dstip;
wire [31:0] tx0_pps;
wire [31:0] tx0_throughput;
wire [31:0] tx0_ipv4_ip;
wire [31:0] rx1_pps;
wire [31:0] rx1_throughput;
wire [23:0] rx1_latency;
wire [31:0] rx1_ipv4_ip;

measure measure_inst (
  .sys_rst(~core_rst_n),
  .sys_clk(clk_125),
  .pci_clk(clk_125),

  .gmii_0_tx_clk(phy1_125M_clk),
  .gmii_0_txd(phy1_tx_data),
  .gmii_0_tx_en(phy1_tx_en),
  .gmii_0_rxd(phy1_rx_data),
  .gmii_0_rx_dv(phy1_rx_dv),
  .gmii_0_rx_clk(phy1_rx_clk),

  .gmii_1_tx_clk(phy2_125M_clk),
  .gmii_1_txd(phy2_tx_data),
  .gmii_1_tx_en(phy2_tx_en),
  .gmii_1_rxd(phy2_rx_data),
  .gmii_1_rx_dv(phy2_rx_dv),
  .gmii_1_rx_clk(phy2_rx_clk),

  .tx0_enable(tx0_enable),
  .tx0_ipv6(tx0_ipv6),
  .tx0_fullroute(tx0_fullroute),
  .tx0_req_arp(tx0_req_arp),
  .tx0_frame_len(tx0_frame_len),
  .tx0_inter_frame_gap(tx0_inter_frame_gap),
  .tx0_ipv4_srcip(tx0_ipv4_srcip),
  .tx0_src_mac(tx0_src_mac),
  .tx0_ipv4_gwip(tx0_ipv4_gwip),
  .tx0_ipv6_srcip(tx0_ipv6_srcip),
  .tx0_ipv6_dstip(tx0_ipv6_dstip),
  .tx0_dst_mac(tx0_dst_mac),
  .tx0_ipv4_dstip(tx0_ipv4_dstip),
  .tx0_pps(tx0_pps),
  .tx0_throughput(tx0_throughput),
  .tx0_ipv4_ip(tx0_ipv4_ip),

  .rx1_pps(rx1_pps),
  .rx1_throughput(rx1_throughput),
  .rx1_latency(rx1_latency),
  .rx1_ipv4_ip(rx1_ipv4_ip)
);


assign rd = ~pcie_we && pcie_cyc && pcie_stb;
assign wr = pcie_we && pcie_cyc && pcie_stb;
reg [15:0] wb_dat;
reg wb_ack;
always @(posedge clk_125 or negedge core_rst_n) begin
  if (!core_rst_n) begin
    wb_dat              <= 16'h0;
    // PCI User Registers
    tx0_enable          <= 1'b1;
    tx0_ipv6            <= 1'b0;
    tx0_fullroute       <= 1'b0;
    tx0_req_arp         <= 1'b0;
    case (dip_switch[7:5])
        3'h0: tx0_frame_len       <= 16'd64;
        3'h1: tx0_frame_len       <= 16'd128;
        3'h2: tx0_frame_len       <= 16'd256;
        3'h3: tx0_frame_len       <= 16'd512;
        3'h4: tx0_frame_len       <= 16'd768;
        3'h5: tx0_frame_len       <= 16'd1024;
        3'h6: tx0_frame_len       <= 16'd1280;
        3'h7: tx0_frame_len       <= 16'd1518;
    endcase
    tx0_inter_frame_gap <= 32'd11 + (32'h1 << dip_switch[4:0]);
    tx0_src_mac         <= 48'h003776_000100;
    tx0_ipv4_gwip       <= {8'd10,8'd0,8'd20,8'd1};
    tx0_ipv4_srcip      <= {8'd10,8'd0,8'd20,8'd105};
    tx0_ipv4_dstip      <= {8'd10,8'd0,8'd21,8'd105};
    tx0_ipv6_srcip      <= 128'h3776_0000_0000_0020_0000_0000_0000_0105;
    tx0_ipv6_dstip      <= 128'h3776_0000_0000_0021_0000_0000_0000_0105;
  end else begin
    if (pcie_cyc) begin
      if (rd == 1'b1) begin
        case (pcie_adr[7:1])
        7'h00: // tx enable bit
          wb_dat <= {8'h00, tx0_enable, tx0_ipv6, 5'b0, tx0_fullroute};
        7'h01:
          wb_dat <= 16'h0;
        7'h03: // tx0 frame length
          wb_dat <= {tx0_frame_len[7:0], tx0_frame_len[15:8]};
        7'h04: // tx0 inter frame gap
          wb_dat <= {tx0_inter_frame_gap[23:16], tx0_inter_frame_gap[31:24]};
        7'h05:
          wb_dat <= {tx0_inter_frame_gap[7:0], tx0_inter_frame_gap[15:8]};
        7'h08: // tx0 ipv4_srcip
          wb_dat <= {tx0_ipv4_srcip[23:16], tx0_ipv4_srcip[31:24]};
        7'h09:
          wb_dat <= {tx0_ipv4_srcip[ 7: 0], tx0_ipv4_srcip[15: 8]};
        7'h0b: // tx0 src_mac 47-32bit
          wb_dat <= {tx0_src_mac[39:32], tx0_src_mac[47:40]};
        7'h0c: // tx0 src_mac 31-16bit
          wb_dat <= {tx0_src_mac[23:16], tx0_src_mac[31:24]};
        7'h0d: // tx0 src_mac 15- 0bit
          wb_dat <= {tx0_src_mac[ 7: 0], tx0_src_mac[15: 8]};
        7'h10: // tx0 ipv4_gwip
          wb_dat <= {tx0_ipv4_gwip[23:16], tx0_ipv4_gwip[31:24]};
        7'h11:
          wb_dat <= {tx0_ipv4_gwip[ 7: 0], tx0_ipv4_gwip[15: 8]};
        7'h13: // tx0 dst_mac 47-32bit
          wb_dat <= {tx0_dst_mac[39:32], tx0_dst_mac[47:40]};
        7'h14: // tx0 dst_mac 31-16bit
          wb_dat <= {tx0_dst_mac[23:16], tx0_dst_mac[31:24]};
        7'h15: // tx0 dst_mac 15- 0bit
          wb_dat <= {tx0_dst_mac[ 7: 0], tx0_dst_mac[15: 8]};
        7'h16: // tx0 ipv4_dstip
          wb_dat <= {tx0_ipv4_dstip[23:16], tx0_ipv4_dstip[31:24]};
        7'h17:
          wb_dat <= {tx0_ipv4_dstip[ 7: 0], tx0_ipv4_dstip[15: 8]};
        7'h20: // tx0 pps
          wb_dat <= {tx0_pps[23:16], tx0_pps[31:24]};
        7'h21:
          wb_dat <= {tx0_pps[ 7: 0], tx0_pps[15: 8]};
        7'h22: // tx0 throughput
          wb_dat <= {tx0_throughput[23:16], tx0_throughput[31:24]};
        7'h23:
          wb_dat <= {tx0_throughput[ 7: 0], tx0_throughput[15: 8]};
        7'h26: // tx0 ipv4_ip
          wb_dat <= {tx0_ipv4_ip[23:16], tx0_ipv4_ip[31:24]};
        7'h27:
          wb_dat <= {tx0_ipv4_ip[ 7: 0], tx0_ipv4_ip[15: 8]};
        7'h28: // rx1 pps
          wb_dat <= {rx1_pps[23:16], rx1_pps[31:24]};
        7'h29:
          wb_dat <= {rx1_pps[ 7: 0], rx1_pps[15: 8]};
        7'h2a: // rx1 throughput
          wb_dat <= {rx1_throughput[23:16], rx1_throughput[31:24]};
        7'h2b:
          wb_dat <= {rx1_throughput[ 7: 0], rx1_throughput[15: 8]};
        7'h2c: // rx1 latency
          wb_dat <= {rx1_latency[23:16], 8'h0};
        7'h2d:
          wb_dat <= {rx1_latency[ 7: 0], rx1_latency[15: 8]};
        7'h2e: // rx1 ipv4_ip
          wb_dat <= {rx1_ipv4_ip[23:16], rx1_ipv4_ip[31:24]};
        7'h2f:
          wb_dat <= {rx1_ipv4_ip[ 7: 0], rx1_ipv4_ip[15: 8]};
        7'h40: // tx0_ipv6_srcip
          wb_dat <= {tx0_ipv6_srcip[119:112], tx0_ipv6_srcip[127:120]};
        7'h41:
          wb_dat <= {tx0_ipv6_srcip[103: 96], tx0_ipv6_srcip[111:104]};
        7'h42:
          wb_dat <= {tx0_ipv6_srcip[ 87: 80], tx0_ipv6_srcip[ 95: 88]};
        7'h43:
          wb_dat <= {tx0_ipv6_srcip[ 71: 64], tx0_ipv6_srcip[ 79: 72]};
        7'h44:
          wb_dat <= {tx0_ipv6_srcip[ 55: 48], tx0_ipv6_srcip[ 63: 56]};
        7'h45:
          wb_dat <= {tx0_ipv6_srcip[ 39: 32], tx0_ipv6_srcip[ 47: 40]};
        7'h46:
          wb_dat <= {tx0_ipv6_srcip[ 23: 16], tx0_ipv6_srcip[ 31: 24]};
        7'h47:
          wb_dat <= {tx0_ipv6_srcip[  7:  0], tx0_ipv6_srcip[ 15:  8]};
        7'h48: // tx0_ipv6_dstip
          wb_dat <= {tx0_ipv6_dstip[119:112], tx0_ipv6_dstip[127:120]};
        7'h49:
          wb_dat <= {tx0_ipv6_dstip[103: 96], tx0_ipv6_dstip[111:104]};
        7'h4a:
          wb_dat <= {tx0_ipv6_dstip[ 87: 80], tx0_ipv6_dstip[ 95: 88]};
        7'h4b:
          wb_dat <= {tx0_ipv6_dstip[ 71: 64], tx0_ipv6_dstip[ 79: 72]};
        7'h4c:
          wb_dat <= {tx0_ipv6_dstip[ 55: 48], tx0_ipv6_dstip[ 63: 56]};
        7'h4d:
          wb_dat <= {tx0_ipv6_dstip[ 39: 32], tx0_ipv6_dstip[ 47: 40]};
        7'h4e:
          wb_dat <= {tx0_ipv6_dstip[ 23: 16], tx0_ipv6_dstip[ 31: 24]};
        7'h4f:
          wb_dat <= {tx0_ipv6_dstip[  7:  0], tx0_ipv6_dstip[ 15:  8]};
        default:
          wb_dat <= 16'h0;
        endcase
      end else if (wr == 1'b1) begin
        case (pcie_adr[7:1])
        7'h00: begin // tx enable bit
          if (pcie_sel[1])
            {tx0_enable, tx0_ipv6, tx0_fullroute} <= {pcie_dat_o[7:6], pcie_dat_o[0]};
        end
        7'h03: begin // tx0 frame length
          if (pcie_sel[0])
            tx0_frame_len[ 7:0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_frame_len[15:8] <= pcie_dat_o[7:0];
        end
        7'h04: begin // tx0 inter frame gap
          if (pcie_sel[0])
            tx0_inter_frame_gap[23:16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_inter_frame_gap[31:24] <= pcie_dat_o[7:0];
        end
        7'h05: begin
          if (pcie_sel[0])
            tx0_inter_frame_gap[ 7:0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_inter_frame_gap[15:8] <= pcie_dat_o[7:0];
        end
        7'h08: begin // tx0 ipv4 src ip
          if (pcie_sel[0])
            tx0_ipv4_srcip[23:16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_srcip[31:24] <= pcie_dat_o[7:0];
        end
        7'h09: begin
          if (pcie_sel[0])
            tx0_ipv4_srcip[ 7:0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_srcip[15:8] <= pcie_dat_o[7:0];
        end
        7'h0b: begin // tx0 src_mac 47-32bit
          if (pcie_sel[0])
            tx0_src_mac[39:32] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_src_mac[47:40] <= pcie_dat_o[7:0];
        end
        7'h0c: begin // tx0 src_mac 31-16bit
          if (pcie_sel[0])
            tx0_src_mac[23:16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_src_mac[31:24] <= pcie_dat_o[7:0];
        end
        7'h0d: begin // tx0 src_mac 15- 0bit
          if (pcie_sel[0])
            tx0_src_mac[ 7: 0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_src_mac[15: 8] <= pcie_dat_o[7:0];
        end
        7'h10: begin // tx0 ipv4_gwip
          if (pcie_sel[0])
            tx0_ipv4_gwip[23:16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_gwip[31:24] <= pcie_dat_o[7:0];
        end
        7'h11: begin
          if (pcie_sel[0])
            tx0_ipv4_gwip[ 7:0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_gwip[15:8] <= pcie_dat_o[7:0];
        end
        7'h16: begin // tx0 ipv4_dstip
          if (pcie_sel[0])
            tx0_ipv4_dstip[23:16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_dstip[31:24] <= pcie_dat_o[7:0];
        end
        7'h17: begin
          if (pcie_sel[0])
            tx0_ipv4_dstip[ 7: 0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv4_dstip[15: 8] <= pcie_dat_o[7:0];
        end
        7'h40: begin // tx0_ipv6_srcip
          if (pcie_sel[0])
            tx0_ipv6_srcip[119:112] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[127:120] <= pcie_dat_o[7:0];
        end
        7'h41: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[103: 96] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[111:104] <= pcie_dat_o[7:0];
        end
        7'h42: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[ 87: 80] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 95: 88] <= pcie_dat_o[7:0];
        end
        7'h43: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[ 71: 64] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 79: 72] <= pcie_dat_o[7:0];
        end
        7'h44: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[ 55: 48] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 63: 56] <= pcie_dat_o[7:0];
        end
        7'h45: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[ 39: 32] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 47: 40] <= pcie_dat_o[7:0];
        end
        7'h46: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[ 23: 16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 31: 24] <= pcie_dat_o[7:0];
        end
        7'h47: begin
          if (pcie_sel[0])
            tx0_ipv6_srcip[  7:  0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_srcip[ 15:  8] <= pcie_dat_o[7:0];
        end
        7'h48: begin // tx0_ipv6_dstip
          if (pcie_sel[0])
            tx0_ipv6_dstip[119:112] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[127:120] <= pcie_dat_o[7:0];
        end
        7'h49: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[103: 96] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[111:104] <= pcie_dat_o[7:0];
        end
        7'h4a: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[ 87: 80] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 95: 88] <= pcie_dat_o[7:0];
        end
        7'h4b: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[ 71: 64] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 79: 72] <= pcie_dat_o[7:0];
        end
        7'h4c: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[ 55: 48] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 63: 56] <= pcie_dat_o[7:0];
        end
        7'h4d: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[ 39: 32] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 47: 40] <= pcie_dat_o[7:0];
        end
        7'h4e: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[ 23: 16] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 31: 24] <= pcie_dat_o[7:0];
        end
        7'h4f: begin
          if (pcie_sel[0])
            tx0_ipv6_dstip[  7:  0] <= pcie_dat_o[15:8];
          if (pcie_sel[1])
            tx0_ipv6_dstip[ 15:  8] <= pcie_dat_o[7:0];
        end
        endcase
      end
    end
  end
end

always @(posedge clk_125 or negedge core_rst_n) begin
  if (!core_rst_n) begin
    wb_ack <= 0;
  end else begin
    wb_ack <= pcie_cyc & pcie_stb & (~wb_ack);
  end
end

assign pcie_dat_i = wb_dat;
assign pcie_ack = wb_ack;
assign phy1_mii_clk = 1'b0;
assign phy1_mii_data = 1'b0;
assign phy1_gtx_clk = phy1_125M_clk;
assign phy1_rst_n = core_rst_n & reset_n;
assign phy2_mii_clk = 1'b0;
assign phy2_mii_data = 1'b0;
assign phy2_gtx_clk = phy2_125M_clk;
assign phy2_rst_n = core_rst_n & reset_n;
assign led_out = 14'b0;

endmodule

