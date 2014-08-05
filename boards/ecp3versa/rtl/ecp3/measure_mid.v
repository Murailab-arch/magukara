`default_nettype none
`include "setup.v"

module measure_mid (
	// System
	input pcie_clk,
	input sys_rst,
	// Management
	input [6:0] rx_bar_hit,
	input [7:0] bus_num,
	input [4:0] dev_num,
	input [2:0] func_num,
	// Receive
	input rx_st,
	input rx_end,
	input [15:0] rx_data,
	input rx_malf,
	// Transmit
	output tx_req,
	input tx_rdy,
	output tx_st,
	output tx_end,
	output [15:0] tx_data,
	input [8:0] tx_ca_ph,
	input [12:0] tx_ca_pd,
	input [8:0] tx_ca_nph,
	input [12:0] tx_ca_npd,
	input [8:0] tx_ca_cplh,
	input [12:0] tx_ca_cpld,
	input tx_ca_p_recheck,
	input tx_ca_cpl_recheck,
	// Receive credits
	output [7:0] pd_num,
	output ph_cr,
	output pd_cr,
	output nph_cr,
	output npd_cr,
	// Ethernet PHY#1
	input phy1_125M_clk,
	output phy1_tx_en,
	output [7:0] phy1_tx_data,
	input phy1_rx_clk,
	input phy1_rx_dv,
	input phy1_rx_er,
	input [7:0] phy1_rx_data,
	// Ethernet PHY#2
	input phy2_125M_clk,
	output phy2_tx_en,
	output [7:0] phy2_tx_data,
	input phy2_rx_clk,
	input phy2_rx_dv,
	input phy2_rx_er,
	input [7:0] phy2_rx_data,
	// LED and Switches
	input [7:0] dipsw,
	output [7:0] led,
	output [13:0] segled,
	input btn
);

// Slave bus
wire [6:0] slv_bar_i;
wire slv_ce_i;
wire slv_we_i;
wire [19:1] slv_adr_i;
wire [15:0] slv_dat_i;
wire [1:0] slv_sel_i;
wire [15:0] slv_dat_o, slv_dat1_o, slv_dat2_o;
reg [15:0] slv_dat0_o;

pcie_tlp inst_pcie_tlp (
	// System
	.pcie_clk(pcie_clk),
	.sys_rst(sys_rst),
	// Management
	.rx_bar_hit(rx_bar_hit),
	.bus_num(bus_num),
	.dev_num(dev_num),
	.func_num(func_num),
	// Receive
	.rx_st(rx_st),
	.rx_end(rx_end),
	.rx_data(rx_data),
	.rx_malf(rx_malf),
	// Transmit
	.tx_req(tx_req),
	.tx_rdy(tx_rdy),
	.tx_st(tx_st),
	.tx_end(tx_end),
	.tx_data(tx_data),
	.tx_ca_ph(tx_ca_ph),
	.tx_ca_pd(tx_ca_pd),
	.tx_ca_nph(tx_ca_nph),
	.tx_ca_npd(tx_ca_npd),
	.tx_ca_cplh(tx_ca_cplh),
	.tx_ca_cpld(tx_ca_cpld),
	.tx_ca_p_recheck(tx_ca_p_recheck),
	.tx_ca_cpl_recheck(tx_ca_cpl_recheck),
	//Receive credits
	.pd_num(pd_num),
	.ph_cr(ph_cr),
	.pd_cr(pd_cr),
	.nph_cr(nph_cr),
	.npd_cr(npd_cr),
	// Master FIFO
	.mst_rd_en(),
	.mst_empty(),
	.mst_dout(),
	.mst_wr_en(),
	.mst_full(),
	.mst_din(),
	// Slave BUS
	.slv_bar_i(slv_bar_i),
	.slv_ce_i(slv_ce_i),
	.slv_we_i(slv_we_i),
	.slv_adr_i(slv_adr_i),
	.slv_dat_i(slv_dat_i),
	.slv_sel_i(slv_sel_i),
	.slv_dat_o(slv_dat_o),
	// Slave FIFO
	.slv_rd_en(),
	.slv_empty(),
	.slv_dout(),
	.slv_wr_en(),
	.slv_full(),
	.slv_din(),
	// LED and Switches
	.dipsw(dipsw),
	.led(),
	.segled(),
	.btn(btn)
);

//-----------------------------------
// PCI user registers
//-----------------------------------
reg	 tx0_enable;
reg	 tx0_ipv6;
reg	 tx0_fullroute;
reg	 tx0_req_arp;
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
wire [31:0] global_counter;
wire [31:0] count_2976_latency;

reg [13:0] segledr;

always @(posedge pcie_clk) begin
	if (sys_rst == 1'b1) begin
		slv_dat0_o <= 16'h0;
		// PCI User Registers
		tx0_enable	 <= 1'b1;
		tx0_ipv6	 <= 1'b0;
		tx0_fullroute    <= 1'b0;
		tx0_req_arp	 <= 1'b0;
		case (dipsw[7:5])
			3'h0: tx0_frame_len       <= 16'd64;
			3'h1: tx0_frame_len       <= 16'd128;
			3'h2: tx0_frame_len       <= 16'd256;
			3'h3: tx0_frame_len       <= 16'd512;
			3'h4: tx0_frame_len       <= 16'd768;
			3'h5: tx0_frame_len       <= 16'd1024;
			3'h6: tx0_frame_len       <= 16'd1280;
			3'h7: tx0_frame_len       <= 16'd1518;
		endcase
		tx0_inter_frame_gap <= 32'd11 + (32'h1 << dipsw[4:0]);
		tx0_src_mac	 <= 48'h003776_000100;
		tx0_ipv4_gwip    <= {8'd10,8'd0,8'd20,8'd1};
		tx0_ipv4_srcip   <= {8'd10,8'd0,8'd20,8'd105};
		tx0_ipv4_dstip   <= {8'd10,8'd0,8'd21,8'd105};
		tx0_ipv6_srcip   <= 128'h3776_0000_0000_0020_0000_0000_0000_0105;
		tx0_ipv6_dstip   <= 128'h3776_0000_0000_0021_0000_0000_0000_0105;
	end else begin
		if (slv_bar_i[0] & slv_ce_i) begin
			case (slv_adr_i[7:1])
				7'h00: begin // tx enable bit
					if (slv_we_i) begin
						if (slv_sel_i[1])
							{tx0_enable, tx0_ipv6, tx0_fullroute} <= {slv_dat_i[15:14], slv_dat_i[8]};
					end else
						slv_dat0_o <= {tx0_enable, tx0_ipv6, 5'b0, tx0_fullroute, 8'h00};
				end
				7'h03: begin // tx0 frame length
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_frame_len[ 7:0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_frame_len[15:8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_frame_len[15:8];
				end
				7'h04: begin // tx0 inter frame gap
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_inter_frame_gap[23:16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_inter_frame_gap[31:24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_inter_frame_gap[31:16];
				end
				7'h05: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_inter_frame_gap[ 7:0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_inter_frame_gap[15:8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_inter_frame_gap[15:0];
				end
				7'h08: begin // tx0 ipv4_srcip
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_srcip[23:16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_srcip[31:24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_srcip[31:16];
				end
				7'h09: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_srcip[ 7:0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_srcip[15:8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_srcip[15: 0];
				end
				7'h0b: begin // tx0 src_mac 47-32bit
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_src_mac[39:32] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_src_mac[47:40] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_src_mac[47:32];
				end
				7'h0c: begin // tx0 src_mac 31-16bit
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_src_mac[23:16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_src_mac[31:24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_src_mac[31:16];
				end
				7'h0d: begin // tx0 src_mac 15- 0bit
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_src_mac[ 7: 0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_src_mac[15: 8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_src_mac[15: 0];
				end
				7'h10: begin // tx0 ipv4_gwip
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_gwip[23:16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_gwip[31:24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_gwip[31:16];
				end
				7'h11: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_gwip[ 7:0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_gwip[15:8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_gwip[15: 0];
				end
				7'h13: begin // tx0 dst_mac 47-32bit
					slv_dat0_o <= tx0_dst_mac[47:32];
				end
				7'h14: begin // tx0 dst_mac 31-16bit
					slv_dat0_o <= tx0_dst_mac[31:16];
				end
				7'h15: begin // tx0 dst_mac 15- 0bit
					slv_dat0_o <= tx0_dst_mac[15: 0];
				end
				7'h16: begin // tx0 ipv4_dstip
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_dstip[23:16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_dstip[31:24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_dstip[31:16];
				end
				7'h17: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv4_dstip[ 7: 0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv4_dstip[15: 8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv4_dstip[15: 0];
				end
				7'h20: begin // tx0 pps
					slv_dat0_o <= tx0_pps[31:16];
				end
				7'h21: begin
					slv_dat0_o <= tx0_pps[15: 0];
				end
				7'h22: begin // tx0 throughput
					slv_dat0_o <= tx0_throughput[31:16];
				end
				7'h23: begin
					slv_dat0_o <= tx0_throughput[15: 0];
				end
				7'h26: begin // tx0 ipv4_ip
					slv_dat0_o <= tx0_ipv4_ip[31:16];
				end
				7'h27: begin
					slv_dat0_o <= tx0_ipv4_ip[15: 0];
				end
				7'h28: begin // rx1 pps
					slv_dat0_o <= rx1_pps[31:16];
				end
				7'h29: begin
					slv_dat0_o <= rx1_pps[15: 0];
				end
				7'h2a: begin // rx1 throughput
					slv_dat0_o <= rx1_throughput[31:16];
				end
				7'h2b: begin
					slv_dat0_o <= rx1_throughput[15: 0];
				end
				7'h2c: begin // rx1 latency
					slv_dat0_o <= {8'h0, rx1_latency[23:16]};
				end
				7'h2d: begin
					slv_dat0_o <= rx1_latency[15: 0];
				end
				7'h2e: begin // rx1 ipv4_ip
					slv_dat0_o <= rx1_ipv4_ip[31:16];
				end
				7'h2f: begin
					slv_dat0_o <= rx1_ipv4_ip[15: 0];
				end
				7'h40: begin // tx0_ipv6_srcip
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[119:112] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[127:120] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[127:112];
				end
				7'h41: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[103: 96] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[111:104] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[111: 96];
				end
				7'h42: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[ 87: 80] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 95: 88] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 95: 80];
				end
				7'h43: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[ 71: 64] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 79: 72] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 79: 64];
				end
				7'h44: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[ 55: 48] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 63: 56] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 63: 48];
				end
				7'h45: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[ 39: 32] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 47: 40] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 47: 32];
				end
				7'h46: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[ 23: 16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 31: 24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 31: 16];
				end
				7'h47: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_srcip[	7:	0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_srcip[ 15:	8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_srcip[ 15:  0];
				end
				7'h48: begin // tx0_ipv6_dstip
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[119:112] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[127:120] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[127:112];
				end
				7'h49: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[103: 96] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[111:104] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[111: 96];
				end
				7'h4a: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[ 87: 80] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 95: 88] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 95: 80];
				end
				7'h4b: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[ 71: 64] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 79: 72] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 79: 64];
				end
				7'h4c: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[ 55: 48] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 63: 56] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 63: 48];
				end
				7'h4d: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[ 39: 32] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 47: 40] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 47: 32];
				end
				7'h4e: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[ 23: 16] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 31: 24] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 31: 16];
				end
				7'h4f: begin
					if (slv_we_i) begin
						if (slv_sel_i[0])
							tx0_ipv6_dstip[	7:	0] <= slv_dat_i[7:0];
						if (slv_sel_i[1])
							tx0_ipv6_dstip[ 15:	8] <= slv_dat_i[15:8];
					end else
						slv_dat0_o <= tx0_ipv6_dstip[ 15:  0];
				end
				7'h50: begin // global_counter
					slv_dat0_o <= global_counter[ 31: 16];
				end
				7'h51: begin
					slv_dat0_o <= global_counter[ 15:  0];
				end
				7'h52: begin // count_2976_latency
					slv_dat0_o <= count_2976_latency[ 31: 16];
				end
				7'h53: begin
					slv_dat0_o <= count_2976_latency[ 15:  0];
				end
				default: begin
					slv_dat0_o <= 16'h00; // slv_adr_i[16:1];
				end
			endcase
		end
	end
end


wire [15:0] rom_dat_o;
// BIOS ROM
`ifdef ENABLE_EXPROM
biosrom biosrom_inst (
	.Address(slv_adr_i[10:1]),
	.OutClock(pcie_clk),
	.OutClockEn(slv_ce_i & (slv_bar_i[6])),
	.Reset(sys_rst),
	.Q({rom_dat_o[7:0],rom_dat_o[15:8]})
);
`endif


measure measure_inst (
  .sys_rst(sys_rst),
  .sys_clk(pcie_clk),
  .pci_clk(pcie_clk),

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
  .rx1_ipv4_ip(rx1_ipv4_ip),

  .global_counter(global_counter),
  .count_2976_latency(count_2976_latency)
);

`ifdef ENABLE_EXPROM
assign slv_dat_o = ( {16{slv_bar_i[0]}} & slv_dat0_o ) | ( {16{slv_bar_i[2]}} & slv_dat1_o ) | ( {16{slv_bar_i[6]}} & rom_dat_o );
`else
assign slv_dat_o = ( {16{slv_bar_i[0]}} & slv_dat0_o ) | ( {16{slv_bar_i[2]}} & slv_dat1_o );
`endif
assign segled = segledr;

endmodule
`default_nettype wire
