`default_nettype none
`include "setup.v"
`define ECP3VERSA

module top (
	// PCI Express
	input rstn,
	input board_clk,
	input FLIP_LANES,
	input refclkp,
	input refclkn,
	input hdinp,
	input hdinn,
	output hdoutp,
	output hdoutn,
	// Ethernet PHY#1
	output reg phy1_rst_n,
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
	output reg phy2_rst_n,
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
	// GPIO
	input [7:0] dip_switch,
	output [7:0] led,
	output [13:0] led_out,
	output dp,
	input reset_n
);

reg  [20:0] rstn_cnt;
reg  sys_rst_n;
wire sys_rst = ~sys_rst_n;
wire [15:0] rx_data, tx_data;
wire [6:0] rx_bar_hit;
wire [7:0] pd_num;
wire ph_cr, pd_cr, nph_cr, npd_cr;
wire [7:0] bus_num ;
wire [4:0] dev_num ;
wire [2:0] func_num ;

wire rx_st, rx_end;
wire rx_us_req, rx_malf_tlp ;
wire tx_req, tx_rdy, tx_st, tx_end;

wire [8:0] tx_ca_ph ;
wire [12:0] tx_ca_pd  ;
wire [8:0] tx_ca_nph ;
wire [12:0] tx_ca_npd ;
wire [8:0] tx_ca_cplh;
wire [12:0] tx_ca_cpld ;
wire tx_ca_p_recheck ;
wire tx_ca_cpl_recheck ;
wire clk_125;
// Reset management
always @(posedge clk_125 or negedge rstn) begin
	if (!rstn) begin
		rstn_cnt <= 21'd0 ;
		sys_rst_n <= 1'b0 ;
	end else begin
		if (rstn_cnt[20])		// 4ms in real hardware
			sys_rst_n <= 1'b1 ;
		else
			rstn_cnt <= rstn_cnt + 1'b1 ;
	end
end

pcie_top pcie(
	.refclkp			( refclkp ),
	.refclkn			( refclkn ),
	.sys_clk_125			( clk_125 ),
	.ext_reset_n			( rstn ),
	.rstn				( sys_rst_n ),
	.flip_lanes			( FLIP_LANES ),
	.hdinp0				( hdinp ),
	.hdinn0				( hdinn ),
	.hdoutp0			( hdoutp ),
	.hdoutn0			( hdoutn ),
	.msi				( 8'd0 ),
	.inta_n				( 1'b1 ),
	// This PCIe interface uses dynamic IDs.
	.vendor_id			(16'h3776),
	.device_id			(16'h8000),
	.rev_id				(8'h00),
	.class_code			({8'h00, 8'h00, 8'h00}),
	.subsys_ven_id			(16'h3776),
	.subsys_id			(16'h8000),
	.load_id			(1'b1),
	// Inputs
	.force_lsm_active		( 1'b0 ),
	.force_rec_ei			( 1'b0 ),
	.force_phy_status		( 1'b0 ),
	.force_disable_scr		( 1'b0 ),
	.hl_snd_beacon			( 1'b0 ),
	.hl_disable_scr			( 1'b0 ),
	.hl_gto_dis			( 1'b0 ),
	.hl_gto_det			( 1'b0 ),
	.hl_gto_hrst			( 1'b0 ),
	.hl_gto_l0stx			( 1'b0 ),
	.hl_gto_l1			( 1'b0 ),
	.hl_gto_l2			( 1'b0 ),
	.hl_gto_l0stxfts		( 1'b0 ),
	.hl_gto_lbk			( 1'd0 ),
	.hl_gto_rcvry			( 1'b0 ),
	.hl_gto_cfg			( 1'b0 ),
	.no_pcie_train			( 1'b0 ),
	// Power Management Interface
	.tx_dllp_val			( 2'd0 ),
	.tx_pmtype			( 3'd0 ),
	.tx_vsd_data			( 24'd0 ),
	.tx_req_vc0			( tx_req ),
	.tx_data_vc0			( tx_data ),
	.tx_st_vc0			( tx_st ),
	.tx_end_vc0			( tx_end ),
	.tx_nlfy_vc0			( 1'b0 ),
	.ph_buf_status_vc0		( 1'b0 ),
	.pd_buf_status_vc0		( 1'b0 ),
	.nph_buf_status_vc0		( 1'b0 ),
	.npd_buf_status_vc0		( 1'b0 ),
	.ph_processed_vc0		( ph_cr ),
	.pd_processed_vc0		( pd_cr ),
	.nph_processed_vc0		( nph_cr ),
	.npd_processed_vc0		( npd_cr ),
	.pd_num_vc0			( pd_num ),
	.npd_num_vc0			( 8'd1 ),
	// From User logic
	.cmpln_tout			( 1'b0 ),
	.cmpltr_abort_np		( 1'b0 ),
	.cmpltr_abort_p			( 1'b0 ),
	.unexp_cmpln			( 1'b0 ),
	.ur_np_ext			( 1'b0 ),
	.ur_p_ext			( 1'b0 ),
	.np_req_pend			( 1'b0 ),
	.pme_status			( 1'b0 ),
	.tx_rdy_vc0			( tx_rdy ),
	.tx_ca_ph_vc0			( tx_ca_ph ),
	.tx_ca_pd_vc0			( tx_ca_pd ),
	.tx_ca_nph_vc0			( tx_ca_nph ),
	.tx_ca_npd_vc0			( tx_ca_npd ),
	.tx_ca_cplh_vc0			( tx_ca_cplh ),
	.tx_ca_cpld_vc0			( tx_ca_cpld ),
	.tx_ca_p_recheck_vc0		( tx_ca_p_recheck ),
	.tx_ca_cpl_recheck_vc0		( tx_ca_cpl_recheck ),
	.rx_data_vc0			( rx_data ),
	.rx_st_vc0			( rx_st ) ,
	.rx_end_vc0			( rx_end ),
	.rx_us_req_vc0			( rx_us_req ),
	.rx_malf_tlp_vc0		( rx_malf_tlp ),
	.rx_bar_hit			( rx_bar_hit ),
	// From Config Registers
	.bus_num			( bus_num ),
	.dev_num			( dev_num ),
	.func_num			( func_num )
);

measure_mid measure_mid_inst (
	// System
	.pcie_clk(clk_125),
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
	.rx_malf(rx_malf_tlp),
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
	// Phy
	.phy1_125M_clk(phy1_125M_clk),
	.phy1_tx_en(phy1_tx_en),
	.phy1_tx_data(phy1_tx_data),
	.phy1_rx_clk(phy1_rx_clk),
	.phy1_rx_dv(phy1_rx_dv),
	.phy1_rx_er(phy1_rx_er),
	.phy1_rx_data(phy1_rx_data),
	.phy2_125M_clk(phy2_125M_clk),
	.phy2_tx_en(phy2_tx_en),
	.phy2_tx_data(phy2_tx_data),
	.phy2_rx_clk(phy2_rx_clk),
	.phy2_rx_dv(phy2_rx_dv),
	.phy2_rx_er(phy2_rx_er),
	.phy2_rx_data(phy2_rx_data),
	// LED and Switches
	.dipsw(dip_switch),
	.led(led),
	.segled(led_out),
	.btn(reset_n)
);

//-------------------------------------
// PYH cold reset
//-------------------------------------
reg [7:0] count_rst = 8'd0;
always @(posedge board_clk) begin
    if (reset_n == 1'b0) begin
        phy1_rst_n <= 1'b0;
        phy2_rst_n <= 1'b0;
        count_rst <= 8'b0000_0000;
    end else begin
        if (count_rst[7:0] != 8'b1111_1101) begin
            count_rst <= count_rst + 8'd1;
            phy1_rst_n <= 1'b0;
            phy2_rst_n <= 1'b0;
        end else begin
            phy1_rst_n <= reset_n;
            phy2_rst_n <= reset_n;
        end
    end
end

assign phy1_mii_clk = 1'b0;
assign phy1_mii_data = 1'b0;
assign phy1_gtx_clk = phy1_125M_clk;
assign phy2_mii_clk = 1'b0;
assign phy2_mii_data = 1'b0;
assign phy2_gtx_clk = phy2_125M_clk;

endmodule
`default_nettype wire
