`timescale 1ps / 1ps
`define SIMULATION
module tb_measure();

/* 125MHz system clock */
reg sys_clk;
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

/* 33MHz PCI clock */
reg pci_clk;
initial pci_clk = 1'b0;
always #30 pci_clk = ~pci_clk;

/* 62.5MHz CPCI clock */
reg cpci_clk;
initial cpci_clk = 1'b0;
always #16 cpci_clk = ~cpci_clk;

/* 125MHz RX clock */
reg phy_rx_clk;
initial phy_rx_clk = 1'b0;
always #8 phy_rx_clk = ~phy_rx_clk;

/* 125MHz TX clock */
reg phy_tx_clk;
initial phy_tx_clk = 1'b0;
always #8 phy_tx_clk = ~phy_tx_clk;


reg sys_rst;
reg phy0_rx_dv, phy1_rx_dv, phy2_rx_dv, phy3_rx_dv;
reg [7:0] phy0_rxd, phy1_rxd, phy2_rxd, phy3_rxd;
wire [7:0] gmii_0_txd, gmii_1_txd, gmii_2_txd, gmii_3_txd;
wire gmii_0_tx_en, gmii_1_tx_en, gmii_2_tx_en, gmmi_3_tx_en;
wire [31:0] tx0_pps, rx1_pps, rx2_pps, rx3_pps;
wire [31:0] tx0_throughput, rx1_throughput, rx2_throughput, rx3_throughput;
wire [31:0] rx1_latency, rx2_latency, rx3_latency;

measure measure_inst (
        .sys_rst(sys_rst),
        .sys_clk(phy_rx_clk),
	.gmii_tx_clk(phy_tx_clk),

	.gmii_0_txd(gmii_0_txd),
	.gmii_0_tx_en(gmii_0_tx_en),
        .gmii_0_rxd(phy0_rxd),
        .gmii_0_rx_dv(phy0_rx_dv),
        .gmii_0_rx_clk(phy_rx_clk),

	.gmii_1_txd(gmii_1_txd),
	.gmii_1_tx_en(gmii_1_tx_en),
        .gmii_1_rxd(phy1_rxd),
        .gmii_1_rx_dv(phy1_rx_dv),
        .gmii_1_rx_clk(phy_rx_clk),

        .tx0_enable(1'b1),
        .tx0_frame_len(12'd64),
        .tx0_ipv4_srcip({8'd10,8'd0,8'd0,8'd1}),
        .tx0_src_mac(48'hba9876543210),
        .tx0_ipv4_gwip({8'd10,8'd0,8'd20,8'd1}),
        .tx0_ipv4_dstip({8'd10,8'd0,8'd21,8'd105}),
        .tx0_pps(tx0_pps),
        .tx0_throughput(tx0_throughput),

        .rx1_pps(rx1_pps),
        .rx1_throughput(rx1_throughput),
        .rx1_latency(rx1_latency),

        .rx2_pps(rx2_pps),
        .rx2_throughput(rx2_throughput),
        .rx2_latency(rx2_latency),

        .rx3_pps(rx3_pps),
        .rx3_throughput(rx3_throughput),
        .rx3_latency(rx3_latency)
);

task waitclock;
begin
	@(posedge sys_clk);
	#1;
end
endtask


// GMII_0_TXD に送信したデータを表示する
reg before_gmii_0_tx_en = 1'b0;
always @(posedge phy_tx_clk) begin
	before_gmii_0_tx_en <= gmii_0_tx_en;
	if (gmii_0_tx_en == 1'b1 && before_gmii_0_tx_en == 1'b0)
		$write("GMII_0_TXD : ");
	if (gmii_0_tx_en == 1'b0 && before_gmii_0_tx_en == 1'b1)
		$display("");
	if (gmii_0_tx_en == 1'b1)
		$write("%x ", gmii_0_txd);
end

// GMII_0_TXD に送信したデータは数クロック遅れて GMII_1_RXD に反映される
reg [7:0] rxd1, rxd2, rxd3, rxd4, rxd5, rxd6, rxd7, rxd8, rxd9, rxd10;
reg dv1, dv2, dv3, dv4, dv5, dv6, dv7, dv8, dv9, dv10;
always @(posedge phy_tx_clk) begin
	rxd1       <= gmii_0_txd;
	rxd2       <= rxd1;
	rxd3       <= rxd2;
	rxd4       <= rxd3;
	rxd5       <= rxd4;
	rxd6       <= rxd5;
	rxd7       <= rxd6;
	rxd8       <= rxd7;
	rxd9       <= rxd8;
	rxd10      <= rxd9;
	phy1_rxd   <= rxd10;
	dv1        <= gmii_0_tx_en;
	dv2        <= dv1;
	dv3        <= dv2;
	dv4        <= dv3;
	dv5        <= dv4;
	dv6        <= dv5;
	dv7        <= dv6;
	dv8        <= dv7;
	dv9        <= dv8;
	dv10       <= dv9;
	phy1_rx_dv <= dv10;
end


initial begin
        $dumpfile("./test.vcd");
	$dumpvars(0, tb_measure); 
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;

	waitclock;
	waitclock;

	sys_rst = 1'b0;

	waitclock;


	#300000;

	$finish;
end

endmodule
