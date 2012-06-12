`timescale 1ns / 1ps
`include "../rtl/setup.v"
//`define DEBUG

module top (
	input         cpci_reset,	// CPCI
	input         cpci_clk,

	input         gtx_clk,     // common TX clk reference 125MHz.
	// RGMII interfaces for 4 MACs
	output [3:0]  rgmii_0_txd,
	output        rgmii_0_tx_ctl,
	output        rgmii_0_txc,
	input  [3:0]  rgmii_0_rxd,
	input         rgmii_0_rx_ctl,
	input         rgmii_0_rxc,

	output [3:0]  rgmii_1_txd,
	output        rgmii_1_tx_ctl,
	output        rgmii_1_txc,
	input  [3:0]  rgmii_1_rxd,
	input         rgmii_1_rx_ctl,
	input         rgmii_1_rxc,

	output [3:0]  rgmii_2_txd,
	output        rgmii_2_tx_ctl,
	output        rgmii_2_txc,
	input  [3:0]  rgmii_2_rxd,
	input         rgmii_2_rx_ctl,
	input         rgmii_2_rxc,

	output [3:0]  rgmii_3_txd,
	output        rgmii_3_tx_ctl,
	output        rgmii_3_txc,
	input  [3:0]  rgmii_3_rxd,
	input         rgmii_3_rx_ctl,
	input         rgmii_3_rxc,

	input         PCLK2,		// PCI Clock
	inout  [31:0] AD_IO,            // PCI Ports -- do not modify names!
	output        AD_HIZ,
	inout   [3:0] CBE_IO,
	output        CBE_HIZ,
	inout         PAR_IO,
	output        PAR_HIZ,
	inout         FRAME_IO,
	output        FRAME_HIZ,
	inout         TRDY_IO,
	output        TRDY_HIZ,
	inout         IRDY_IO,
	output        IRDY_HIZ,
	inout         STOP_IO,
	output        STOP_HIZ,
	inout         DEVSEL_IO,
	output        DEVSEL_HIZ,
	input         IDSEL_I,
	output        INTA_O,
	inout         PERR_IO,
	output        PERR_HIZ,
	inout         SERR_IO,
	output        SERR_HIZ,
	output        REQ_O,
	input         GNT_I,

	input [3:0]   cpci_id,

	output        PASS_REQ,
	input         PASS_READY,
	output [31:0] cpci_debug_data,

	output        DEBUG_PIN0,
	output        DEBUG_PIN1
);

assign reset   = ~cpci_reset;
//assign sys_clk = cpci_clk;

wire rgmii_0_tx_clk, rgmii_1_tx_clk, rgmii_2_tx_clk, rgmii_3_tx_clk;

wire [7:0]    gmii_0_txd,   gmii_1_txd,   gmii_2_txd,   gmii_3_txd;
wire [7:0]    gmii_0_rxd,   gmii_1_rxd,   gmii_2_rxd,   gmii_3_rxd;
wire          gmii_0_link,  gmii_1_link,  gmii_2_link,  gmii_3_link;
wire [1:0]    gmii_0_speed, gmii_1_speed, gmii_2_speed, gmii_3_speed;
wire          gmii_0_duplex,gmii_1_duplex,gmii_2_duplex,gmii_3_duplex;

IBUF ibufg_gtx_clk (.I(gtx_clk), .O(gtx_clk_ibufg));
assign sys_clk = gtx_clk_ibufg;


wire tx_clk0, tx_clk90;
DCM RGMII_TX_DCM (
	.CLKIN(gtx_clk_ibufg),
	.CLKFB(rgmii_tx_clk_int),
	.DSSEN(1'b0),
	.PSINCDEC(1'b0),
	.PSEN(1'b0),
	.PSCLK(1'b0),
	.RST(reset),
	.CLK0(tx_clk0),
	.CLK90(tx_clk90),
	.CLK180(),
	.CLK270(),
	.CLK2X(),
	.CLK2X180(),
	.CLKDV(),
	.CLKFX(),
	.CLKFX180(),
	.PSDONE(),
	.STATUS(),
	.LOCKED());
BUFGMUX BUFGMUX_TXCLK (
	.O(rgmii_tx_clk_int),
	.I0(tx_clk0),
	.I1(tx_clk90),  // not used
	.S(1'b0)
);
BUFGMUX BUFGMUX_TXCLK90 (
	.O(rgmii_tx_clk90),
	.I1(tx_clk0),  // not used
	.I0(tx_clk90),
	.S(1'b0)
);
FDDRRSE gmii_0_tx_clk_ddr_iob (
	.Q (rgmii_0_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_1_tx_clk_ddr_iob (
	.Q (rgmii_1_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_2_tx_clk_ddr_iob (
	.Q (rgmii_2_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_3_tx_clk_ddr_iob (
	.Q (rgmii_3_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
OBUF drive_rgmii_0_txc (.I(rgmii_0_txc_obuf), .O(rgmii_0_txc));
OBUF drive_rgmii_1_txc (.I(rgmii_1_txc_obuf), .O(rgmii_1_txc));
OBUF drive_rgmii_2_txc (.I(rgmii_2_txc_obuf), .O(rgmii_2_txc));
OBUF drive_rgmii_3_txc (.I(rgmii_3_txc_obuf), .O(rgmii_3_txc));

assign not_rgmii_tx_clk   = ~rgmii_tx_clk_int;
assign rgmii_tx_clk       = not_rgmii_tx_clk;

rgmii_io rgmii_0_io (
	.rgmii_txd             (rgmii_0_txd),
	.rgmii_tx_ctl          (rgmii_0_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_0_rxd),
	.rgmii_rx_ctl          (rgmii_0_rx_ctl),
	.rgmii_rx_clk          (~rgmii_0_rxc),
	.gmii_txd              (gmii_0_txd),
	.gmii_tx_en            (gmii_0_tx_en),
	.gmii_tx_er            (gmii_0_tx_er),
	.gmii_rxd              (gmii_0_rxd),
	.gmii_rx_dv            (gmii_0_rx_dv),
	.gmii_rx_er            (gmii_0_rx_er),
	.link                  (gmii_0_link),
	.speed                 (gmii_0_speed),
	.duplex                (gmii_0_duplex),
	.reset                 (reset)
);

rgmii_io rgmii_1_io (
	.rgmii_txd             (rgmii_1_txd),
	.rgmii_tx_ctl          (rgmii_1_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_1_rxd),
	.rgmii_rx_ctl          (rgmii_1_rx_ctl),
	.rgmii_rx_clk          (~rgmii_1_rxc),
	.gmii_txd              (gmii_1_txd),
	.gmii_tx_en            (gmii_1_tx_en),
	.gmii_tx_er            (gmii_1_tx_er),
	.gmii_rxd              (gmii_1_rxd),
	.gmii_rx_dv            (gmii_1_rx_dv),
	.gmii_rx_er            (gmii_1_rx_er),
	.link                  (gmii_1_link),
	.speed                 (gmii_1_speed),
	.duplex                (gmii_1_duplex),
	.reset                 (reset)
);

`ifdef ENABE_RGMII2
rgmii_io rgmii_2_io (
	.rgmii_txd             (rgmii_2_txd),
	.rgmii_tx_ctl          (rgmii_2_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_2_rxd),
	.rgmii_rx_ctl          (rgmii_2_rx_ctl),
	.rgmii_rx_clk          (~rgmii_2_rxc),
	.gmii_txd              (gmii_2_txd),
	.gmii_tx_en            (gmii_2_tx_en),
	.gmii_tx_er            (gmii_2_tx_er),
	.gmii_rxd              (gmii_2_rxd),
	.gmii_rx_dv            (gmii_2_rx_dv),
	.gmii_rx_er            (gmii_2_rx_er),
	.link                  (gmii_2_link),
	.speed                 (gmii_2_speed),
	.duplex                (gmii_2_duplex),
	.reset                 (reset)
);
`else
assign rgmii_2_txd     = 4'hz;
assign rgmii_2_tx_ctl  = 1'h0;
assign rgmii_2_txc     = 1'hz;
`endif

`ifdef ENABE_RGMII3
rgmii_io rgmii_3_io (
	.rgmii_txd             (rgmii_3_txd),
	.rgmii_tx_ctl          (rgmii_3_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_3_rxd),
	.rgmii_rx_ctl          (rgmii_3_rx_ctl),
	.rgmii_rx_clk          (~rgmii_3_rxc),
	.gmii_txd              (gmii_3_txd),
	.gmii_tx_en            (gmii_3_tx_en),
	.gmii_tx_er            (gmii_3_tx_er),
	.gmii_rxd              (gmii_3_rxd),
	.gmii_rx_dv            (gmii_3_rx_dv),
	.gmii_rx_er            (gmii_3_rx_er),
	.link                  (gmii_3_link),
	.speed                 (gmii_3_speed),
	.duplex                (gmii_3_duplex),
	.reset                 (reset)
);
`else
assign rgmii_3_txd     = 4'hz;
assign rgmii_3_tx_ctl  = 1'h0;
assign rgmii_3_txc     = 1'hz;
`endif

//-----------------------------------
// PCI user registers
//-----------------------------------
wire        tx0_enable;
wire        tx0_ipv6;
wire        tx0_fullroute;
wire        tx0_req_arp;
wire [11:0] tx0_frame_len;
wire [31:0] tx0_inter_frame_gap;
wire [31:0] tx0_ipv4_srcip;
wire [47:0] tx0_src_mac;
wire [31:0] tx0_ipv4_gwip;
wire [127:0] tx0_ipv6_srcip;
wire [127:0] tx0_ipv6_dstip;
wire [47:0] tx0_dst_mac;
wire [31:0] tx0_ipv4_dstip;
wire [31:0] tx0_pps;
wire [31:0] tx0_throughput;
wire [31:0] tx0_ipv4_ip;
wire [31:0] rx1_pps;
wire [31:0] rx1_throughput;
wire [23:0] rx1_latency;
wire [31:0] rx1_ipv4_ip;
wire [31:0] rx2_pps;
wire [31:0] rx2_throughput;
wire [23:0] rx2_latency;
wire [31:0] rx2_ipv4_ip;
wire [31:0] rx3_pps;
wire [31:0] rx3_throughput;
wire [23:0] rx3_latency;
wire [31:0] rx3_ipv4_ip;


measure measure_inst (
	.sys_rst(reset),
	.sys_clk(sys_clk),
	.pci_clk(PCLK2),

	.gmii_tx_clk(rgmii_tx_clk),

	.gmii_0_txd(gmii_0_txd),
	.gmii_0_tx_en(gmii_0_tx_en),
	.gmii_0_rxd(gmii_0_rxd),
	.gmii_0_rx_dv(gmii_0_rx_dv),
	.gmii_0_rx_clk(rgmii_0_rxc),

	.gmii_1_txd(gmii_1_txd),
	.gmii_1_tx_en(gmii_1_tx_en),
	.gmii_1_rxd(gmii_1_rxd),
	.gmii_1_rx_dv(gmii_1_rx_dv),
	.gmii_1_rx_clk(rgmii_1_rxc),

	.gmii_2_txd(gmii_2_txd),
	.gmii_2_tx_en(gmii_2_tx_en),
	.gmii_2_rxd(gmii_2_rxd),
	.gmii_2_rx_dv(gmii_2_rx_dv),
	.gmii_2_rx_clk(rgmii_2_rxc),

	.gmii_3_txd(gmii_3_txd),
	.gmii_3_tx_en(gmii_3_tx_en),
	.gmii_3_rxd(gmii_3_rxd),
	.gmii_3_rx_dv(gmii_3_rx_dv),
	.gmii_3_rx_clk(rgmii_3_rxc),

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

	.rx2_pps(rx2_pps),
	.rx2_throughput(rx2_throughput),
	.rx2_latency(rx2_latency),
	.rx2_ipv4_ip(rx2_ipv4_ip),

	.rx3_pps(rx3_pps),
	.rx3_throughput(rx3_throughput),
	.rx3_latency(rx3_latency),
	.rx3_ipv4_ip(rx3_ipv4_ip)
);

assign gmii_0_tx_er = 1'b0;
assign gmii_1_tx_er = 1'b0;
assign gmii_2_tx_er = 1'b0;
assign gmii_3_tx_er = 1'b0;

pci pci_inst (
	.sys_rst(reset),
	.pci_clk(PCLK2),

	.AD_IO(AD_IO),
	.AD_HIZ(AD_HIZ),
	.CBE_IO(CBE_IO),
	.CBE_HIZ(CBE_HIZ),
	.PAR_IO(PAR_IO),
	.PAR_HIZ(PAR_HIZ),
	.FRAME_IO(FRAME_IO),
	.FRAME_HIZ(FRAME_HIZ),
	.TRDY_IO(TRDY_IO),
	.TRDY_HIZ(TRDY_HIZ),
	.IRDY_IO(IRDY_IO),
	.IRDY_HIZ(IRDY_HIZ),
	.STOP_IO(STOP_IO),
	.STOP_HIZ(STOP_HIZ),
	.DEVSEL_IO(DEVSEL_IO),
	.DEVSEL_HIZ(DEVSEL_HIZ),
	.IDSEL_I(IDSEL_I),
	.INTA_O(INTA_O),
	.PERR_IO(PERR_IO),
	.PERR_HIZ(PERR_HIZ),
	.SERR_IO(SERR_IO),
	.SERR_HIZ(SERR_HIZ),
	.REQ_O(REQ_O),
	.GNT_I(GNT_I),

	.cpci_id(cpci_id),

	.PASS_REQ(PASS_REQ),
	.PASS_READY(PASS_READY),
	.cpci_debug_data(cpci_debug_data),

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

	.rx2_pps(rx2_pps),
	.rx2_throughput(rx2_throughput),
	.rx2_latency(rx2_latency),
	.rx2_ipv4_ip(rx2_ipv4_ip),

	.rx3_pps(rx3_pps),
	.rx3_throughput(rx3_throughput),
	.rx3_latency(rx3_latency),
	.rx3_ipv4_ip(rx3_ipv4_ip)
);


`ifdef DEBUG
//-----------------------------------
// Chipscope Pro Module
//-----------------------------------
wire [35 : 0] CONTROL;
wire [ 7: 0] TRIG;
wire [31: 0] DATA;

cs_icon INST_ICON (
        .CONTROL0(CONTROL)
);

cs_ila INST_ILA (
        .CLK(rgmii_1_rxc),
        .CONTROL(CONTROL),
        .TRIG0(TRIG),
        .DATA(DATA)
);
assign DATA[7:0]    = gmii_0_rxd[7:0];
assign DATA[8]      = gmii_0_rx_dv;
assign DATA[9]      = gmii_0_rx_er;
assign DATA[10]     = gmii_0_link;
assign DATA[12:11]  = gmii_0_speed[1:0];
assign DATA[13]     = gmii_0_duplex;
assign DATA[23:16]  = gmii_1_rxd[7:0];
//assign DATA[24]     = gmii_1_rx_dv;
//assign DATA[25]     = gmii_1_rx_er;
assign DATA[26]     = gmii_1_link;
assign DATA[28:27]  = gmii_1_speed[1:0];
assign DATA[29]     = gmii_1_duplex;
assign DATA[31:30]  = 2'h0;
assign TRIG[0]      = gmii_0_rx_dv;
//assign TRIG[1]      = gmii_1_rx_dv;
`endif
endmodule
