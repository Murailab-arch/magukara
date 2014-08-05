//
//`define ENABLE_EXPROM

`default_nettype none
module pcie_tlp (
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
	output reg tx_req = 1'b0,
	input tx_rdy,
	output reg tx_st = 1'b0,
	output tx_end,
	output reg [15:0] tx_data,
	input [8:0] tx_ca_ph,
	input [12:0] tx_ca_pd,
	input [8:0] tx_ca_nph,
	input [12:0] tx_ca_npd,
	input [8:0] tx_ca_cplh,
	input [12:0] tx_ca_cpld,
	input tx_ca_p_recheck,
	input tx_ca_cpl_recheck,
	// Receive credits
	output reg [7:0] pd_num = 8'h0,
	output reg ph_cr = 1'b0,
	output reg pd_cr = 1'b0,
	output reg nph_cr = 1'b0,
	output reg npd_cr = 1'b0,
	// Master FIFO
	output reg mst_rd_en,
	input  mst_empty,
	input  [17:0] mst_dout,
	output reg mst_wr_en,
	input  mst_full,
	output reg [17:0] mst_din,
	// Slave BUS
	output reg [6:0] slv_bar_i,
	output reg slv_ce_i,
	output reg slv_we_i,
	output reg [19:1] slv_adr_i,
	output reg [15:0] slv_dat_i,
	output reg [1:0] slv_sel_i,
	input  [15:0] slv_dat_o,
	// Slave FIFO
	output reg slv_rd_en,
	input  slv_empty,
	input  [17:0] slv_dout,
	output reg slv_wr_en,
	input  slv_full,
	output reg [17:0] slv_din,
	// LED and Switches
	input [7:0] dipsw,
	output [7:0] led,
	output [13:0] segled,
	input btn
);

parameter [2:0]
	TLP_MR   = 3'h0,
	TLP_MRdLk= 3'h1,
	TLP_IO   = 3'h2,
	TLP_Cfg0 = 3'h3,
	TLP_Cfg1 = 3'h4,
	TLP_Msg  = 3'h5,
	TLP_Cpl  = 3'h6,
	TLP_CplLk= 3'h7;

reg [2:0] rx_comm = 3'h0;

//-----------------------------------------------------------------
// TLP receive
//-----------------------------------------------------------------
parameter [3:0]
	RX_HEAD0 = 4'h0,
	RX_HEAD1 = 4'h1,
	RX_REQ2  = 4'h2,
	RX_REQ3  = 4'h3,
	RX_REQ4  = 4'h4,
	RX_REQ5  = 4'h5,
	RX_REQ6  = 4'h6,
	RX_REQ7  = 4'h7,
	RX_REQ   = 4'h8,
	RX_COMP2 = 4'h9,
	RX_COMP3 = 4'ha,
	RX_COMP4 = 4'hb,
	RX_COMP5 = 4'hc,
	RX_COMP6 = 4'hd,
	RX_COMP7 = 4'he,
	RX_COMP  = 4'hf;
reg [3:0]  rx_status = RX_HEAD0;
reg [1:0]  rx_fmt = 2'b00;
reg [4:0]  rx_type = 5'b00000;
reg [2:0]  rx_tc = 2'b00;
reg        rx_td = 1'b0, rx_ep = 1'b0;
reg [1:0]  rx_attr = 2'b00;
reg [9:0]  rx_length = 10'h0;
reg [15:0] rx_reqid = 16'h0;
reg [7:0]  rx_tag = 8'h0;
reg [3:0]  rx_lastbe = 4'h0, rx_firstbe = 4'h0;
reg [47:2] rx_addr = 46'h0000000000000000;
reg        rx_tlph_valid = 1'b0;
reg [15:0] rx_data2 = 16'h0;
reg rx_end2 = 1'b0;

always @(posedge pcie_clk) begin
	if (sys_rst) begin
		rx_status <= RX_HEAD0;
		rx_tlph_valid <= 1'b0;
		pd_num <= 8'h0;
		ph_cr <= 1'b0;
		pd_cr <= 1'b0;
		nph_cr <= 1'b0;
		npd_cr <= 1'b0;
		rx_data2[15:0] <= 16'h0;
		rx_end2 <= 1'b0;
	end else begin
		rx_tlph_valid <= 1'b0;
		pd_num <= 8'h0;
		ph_cr <= 1'b0;
		pd_cr <= 1'b0;
		nph_cr <= 1'b0;
		npd_cr <= 1'b0;
		rx_data2 <= rx_data;
		rx_end2 <= rx_end;
		if ( rx_end == 1'b1 ) begin
			case ( rx_comm )
				TLP_MR, TLP_MRdLk: begin
`ifndef ENABLE_EXPROM
					if ( rx_bar_hit[6:0] != 7'b0000000 ) begin
`endif
						if ( rx_fmt[1] == 1'b0 ) begin
							nph_cr  <= 1'b1;
						end else begin
							ph_cr <= 1'b1;
							pd_cr <= rx_fmt[1];
							pd_num <= rx_length[1:0] == 2'b00 ? rx_length[9:2] : (rx_length[9:2] + 8'h1);
						end
`ifndef ENABLE_EXPROM
					end
`endif
				end
				TLP_IO, TLP_Cfg0, TLP_Cfg1: begin
					nph_cr <= 1'b1;
					npd_cr <= rx_fmt[1];
				end
				TLP_Msg: begin
					ph_cr <= 1'b1;
					if ( rx_fmt[1] == 1'b1 ) begin
						pd_cr <=  1'b1;
						pd_num <= rx_length[1:0] == 2'b00 ? rx_length[9:2] : (rx_length[9:2] + 8'h1);
					end
				end
				TLP_Cpl: begin
				end
				TLP_CplLk: begin
				end
			endcase
			rx_status <= RX_HEAD0;
		end
		case ( rx_status )
			RX_HEAD0: begin
				if ( rx_st == 1'b1 ) begin
					rx_fmt [1:0] <= rx_data[14:13];
					rx_type[4:0] <= rx_data[12: 8];
					rx_tc  [2:0] <= rx_data[ 6: 4];
					if ( rx_data[12] == 1'b1 ) begin
						rx_comm <= TLP_Msg;
					end else begin
						if ( rx_data[11] == 1'b0) begin
							case ( rx_data[10:8] )
								3'b000: rx_comm <= TLP_MR;
								3'b001: rx_comm <= TLP_MRdLk;
								3'b010: rx_comm <= TLP_IO;
								3'b100: rx_comm <= TLP_Cfg0;
								default:rx_comm <= TLP_Cfg1;
							endcase
						end else begin
							if ( rx_data[8] == 1'b0 )
								rx_comm <= TLP_Cpl;
							else
								rx_comm <= TLP_CplLk;
						end
					end
					rx_status <= RX_HEAD1;
				end
			end
			RX_HEAD1: begin
				rx_td          <= rx_data[15:15];
				rx_ep          <= rx_data[14:14];
				rx_attr[1:0]   <= rx_data[13:12];
				rx_length[9:0] <= rx_data[ 9: 0];
				if ( rx_type[3] == 1'b0 )
					rx_status <= RX_REQ2;
				else
					rx_status <= RX_COMP2;
			end
			RX_REQ2: begin
				rx_reqid[15:0] <= rx_data[15:0];
				rx_status <= RX_REQ3;
			end
			RX_REQ3: begin
				rx_tag[7:0]    <= rx_data[15:8];
				rx_lastbe[3:0]  <= rx_data[7:4];
				rx_firstbe[3:0]  <= rx_data[3:0];
				if ( rx_fmt[0] == 1'b0 ) begin	// 64 or 32bit ??
					rx_addr[47:32] <= 16'h0;
					rx_status <= RX_REQ6;
				end else
					rx_status <= RX_REQ4;
			end
			RX_REQ4: begin
				rx_status <= RX_REQ5;
			end
			RX_REQ5: begin
				rx_addr[47:32] <= rx_data[15:0];
				rx_status <= RX_REQ6;
			end
			RX_REQ6: begin
				rx_addr[31:16] <= rx_data[15:0];
				rx_tlph_valid <= 1'b1;
				rx_status <= RX_REQ7;
			end
			RX_REQ7: begin
				rx_addr[15: 2] <= rx_data[15:2];
				if ( rx_end == 1'b0 )
					rx_status <= RX_REQ;
			end
			RX_REQ: begin
			end
		endcase
	 end
end

//-----------------------------------------------------------------
// TLP transmit
//-----------------------------------------------------------------
parameter [4:0]
	TX_IDLE  = 5'h0,
	TX_WAIT  = 5'h1,
	TX1_HEAD0= 5'h2,
	TX1_HEAD1= 5'h3,
	TX1_COMP2= 5'h4,
	TX1_COMP3= 5'h5,
	TX1_COMP4= 5'h6,
	TX1_COMP5= 5'h7,
	TX1_DATA = 5'h8,
	TX2_HEAD0= 5'h9,
	TX2_HEAD1= 5'hA,
	TX2_COMP2= 5'hB,
	TX2_COMP3= 5'hC,
	TX2_COMP4= 5'hD,
	TX2_COMP5= 5'hE,
	TX2_COMP6= 5'hF,
	TX2_COMP7= 5'h10,
	TX2_DATA = 5'h11;
reg [4:0]  tx_status = TX_IDLE;
reg        tx_lastch = 1'b0;

reg [15:0] tx1_data;
reg        tx1_tlph_valid = 1'b0;
reg        tx1_tlpd_ready = 1'b0;
reg        tx1_tlpd_done  = 1'b0;
reg [1:0]  tx1_fmt = 2'b00;
reg [4:0]  tx1_type = 5'b00000;
reg [2:0]  tx1_tc = 2'b00;
reg        tx1_td = 1'b0, tx1_ep = 1'b0;
reg [1:0]  tx1_attr = 2'b00;
reg [10:0] tx1_length = 11'h0;
reg [2:0]  tx1_cplst = 3'h0;
reg        tx1_bcm = 1'b0;
reg [11:0] tx1_bcount = 12'h0;
reg [15:0] tx1_reqid = 16'h0;
reg [7:0]  tx1_tag = 8'h0;
reg [7:0]  tx1_lowaddr = 8'h0;
reg [3:0]  tx1_lastbe = 4'h0, tx1_firstbe = 4'h0;

reg [15:0] tx2_data;
reg        tx2_tlph_valid = 1'b0;
reg        tx2_tlpd_ready = 1'b0;
reg        tx2_tlpd_done  = 1'b0;
reg [1:0]  tx2_fmt = 2'b00;
reg [4:0]  tx2_type = 5'b00000;
reg [2:0]  tx2_tc = 2'b00;
reg        tx2_td = 1'b0, tx2_ep = 1'b0;
reg [1:0]  tx2_attr = 2'b00;
reg [10:0] tx2_length = 11'h0;
reg [11:0] tx2_bcount = 12'h0;
reg [15:0] tx2_reqid = 16'h0;
reg [7:0]  tx2_tag = 8'h0;
reg [7:0]  tx2_lowaddr = 8'h0;
reg [3:0]  tx2_lastbe = 4'h0, tx2_firstbe = 4'h0;
reg [47:2] tx2_addr = 46'h0000000000000000;

always @(posedge pcie_clk) begin
	if (sys_rst) begin
		tx_status <= TX_IDLE;
		tx_data[15:0] <= 16'h0;
		tx_req <= 1'b0;
		tx_st <= 1'b0;
	        tx1_tlpd_ready <= 1'b0;
	        tx2_tlpd_ready <= 1'b0;
		tx_lastch <= 1'b0;
	end else begin
		tx_st <= 1'b0;
		case ( tx_status )
			TX_IDLE: begin
				if ( tx1_tlph_valid == 1'b1 || tx2_tlph_valid == 1'b1 ) begin
					tx_lastch <= tx2_tlph_valid;
					tx_req <= 1'b1;
					tx_status <= TX_WAIT;
				end
			end
			TX_WAIT: begin
				if ( tx_rdy == 1'b1 ) begin
					tx_req <= 1'b0;
					if ( tx_lastch == 1'b1 )
						tx_status <= TX2_HEAD0;
					else
						tx_status <= TX1_HEAD0;
				end
			end
			TX1_HEAD0: begin
				tx_data[15:0] <= {1'b0, tx1_fmt[1:0], tx1_type[4:0], 1'b0, tx1_tc[2:0], 4'b000};
				tx_st <= 1'b1;
				tx_status <= TX1_HEAD1;
			end
			TX1_HEAD1: begin
				tx_data[15:0] <= {tx1_td, tx1_ep, tx1_attr[1:0], 2'b00, tx1_length[10:1]};
				tx_status <= TX1_COMP2;
			end
			TX1_COMP2: begin
				tx_data[15:0] <= {bus_num, dev_num, func_num};	// CplID
				tx1_tlpd_ready <= 1'b1;
				tx_status <= TX1_COMP3;
			end
			TX1_COMP3: begin
				tx_data[15:0] <= { tx1_cplst[2:0], tx1_bcm, tx1_bcount[11:0] };
				tx_status <= TX1_COMP4;
			end
			TX1_COMP4: begin
				tx_data[15:0] <= tx1_reqid[15:0];
				tx_status <= TX1_COMP5;
			end
			TX1_COMP5: begin
				tx_data[15:0] <= { tx1_tag[7:0], 1'b0, tx1_lowaddr[6:0] };
				tx_status <= TX1_DATA;
			end
			TX1_DATA: begin
				tx_data[15:0] <= tx1_data[15:0];
				if (tx1_tlpd_done == 1'b1) begin
					tx_status <= TX_IDLE;
	        			tx1_tlpd_ready <= 1'b0;
				end
			end
			TX2_HEAD0: begin
				tx_data[15:0] <= {1'b0, tx2_fmt[1:0], tx2_type[4:0], 1'b0, tx2_tc[2:0], 4'b000};
				tx_st <= 1'b1;
				tx_status <= TX2_HEAD1;
			end
			TX2_HEAD1: begin
				tx_data[15:0] <= {tx2_td, tx2_ep, tx2_attr[1:0], 2'b00, tx2_length[10:1]};
				tx_status <= TX2_COMP2;
			end
			TX2_COMP2: begin
				tx_data[15:0] <= {bus_num, dev_num, func_num};	// Request ID
				tx_status <= TX2_COMP3;
			end
			TX2_COMP3: begin
				tx_data[15:0] <= { tx2_tag[7:0], tx2_lastbe[3:0], tx2_firstbe[3:0] };

				if ( tx2_fmt[0] == 1'b0 ) begin // 64 or 32bit ??
					tx2_tlpd_ready <= 1'b1;
					tx_status <= TX2_COMP6;
				end else
					tx_status <= TX2_COMP4;
			end
			TX2_COMP4: begin
				tx_data[15:0] <= 16'h0000;
				tx2_tlpd_ready <= 1'b1;
				tx_status <= TX2_COMP5;
			end
			TX2_COMP5: begin
				tx_data[15:0] <= tx2_addr[47:32];
				tx_status <= TX2_COMP6;
			end
			TX2_COMP6: begin
				tx_data[15:0] <= tx2_addr[31:16];
				tx_status <= TX2_COMP7;
			end
			TX2_COMP7: begin
				tx_data[15:0] <= { tx2_addr[15: 2], 2'b00 };
				tx_status <= TX2_DATA;
			end
			TX2_DATA: begin
				tx_data[15:0] <= tx2_data[15:0];
				if (tx2_tlpd_done == 1'b1) begin
					tx_status <= TX_IDLE;
	        			tx2_tlpd_ready <= 1'b0;
				end
			end
		endcase
	end
end

//-----------------------------------------------------------------
// Slave Seaquencer
//-----------------------------------------------------------------
parameter [3:0]
	SLV_IDLE   = 3'h0,
	SLV_MREADH = 3'h1,
	SLV_MREADD = 3'h2,
	SLV_MWRITEH= 3'h3,
	SLV_MWRITED= 3'h4,
	SLV_COMP   = 3'h7;
reg [3:0] slv_status = SLV_IDLE;
always @(posedge pcie_clk) begin
	if (sys_rst) begin
		tx1_tlph_valid <= 1'b0;
		tx1_tlpd_done  <= 1'b0;
		slv_status <= SLV_IDLE;
		slv_bar_i <= 7'h0;
		slv_ce_i <= 1'b0;
		slv_we_i <= 1'b0;
		slv_adr_i <= 20'h0;
		slv_dat_i <= 16'b0;
		slv_sel_i <= 2'b00;
	end else begin
		tx1_tlpd_done  <= 1'b0;
		slv_ce_i <= 1'b0;
		slv_we_i <= 1'b0;
		case ( slv_status )
			SLV_IDLE: begin
				tx1_tlph_valid <= 1'b0;
				slv_bar_i <= 7'h0;
				if ( rx_tlph_valid == 1'b1 ) begin
					case ( rx_comm )
						TLP_MR: begin
`ifdef ENABLE_EXPROM
							slv_bar_i <= rx_bar_hit == 7'h0 ? 7'b1000000 : rx_bar_hit;
`else
							slv_bar_i <= rx_bar_hit;
`endif
							if ( rx_fmt[1] == 1'b0 ) begin
								slv_status <= SLV_MREADH;
							end else begin
								slv_status <= SLV_MWRITEH;
							end
						end
						TLP_MRdLk: begin
						end
						TLP_IO: begin
						end
						TLP_Cfg0: begin
						end
						TLP_Cfg1: begin
						end
						TLP_Msg: begin
						end
						TLP_Cpl: begin
						end
						TLP_CplLk: begin
						end
					endcase
				end
			end
			SLV_MREADH: begin
				tx1_fmt[1:0] <= 2'b10;		// 3DW with data
				tx1_type[4:0] <= 5'b01010;	// Cpl with data
				tx1_tc[2:0] <= 3'b000;
				tx1_td <= 1'b0;
				tx1_ep <= 1'b0;
				tx1_attr[1:0] <= 2'b00;
				tx1_cplst[2:0] <= 3'b000;
				tx1_bcm <= 1'b0;
				casex( {rx_firstbe[3:0], rx_lastbe[3:0]} )
					8'b1xx10000: tx1_bcount[11:0] <= 12'h004;
					8'b01x10000: tx1_bcount[11:0] <= 12'h003;
					8'b1x100000: tx1_bcount[11:0] <= 12'h003;
					8'b00110000: tx1_bcount[11:0] <= 12'h002;
					8'b01100000: tx1_bcount[11:0] <= 12'h002;
					8'b11000000: tx1_bcount[11:0] <= 12'h002;
					8'b00010000: tx1_bcount[11:0] <= 12'h001;
					8'b00100000: tx1_bcount[11:0] <= 12'h001;
					8'b01000000: tx1_bcount[11:0] <= 12'h001;
					8'b10000000: tx1_bcount[11:0] <= 12'h001;
					8'b00000000: tx1_bcount[11:0] <= 12'h001;
					8'bxxx11xxx: tx1_bcount[11:0] <= (rx_length*4);
					8'bxxx101xx: tx1_bcount[11:0] <= (rx_length*4) - 1;
					8'bxxx1001x: tx1_bcount[11:0] <= (rx_length*4) - 2;
					8'bxxx10001: tx1_bcount[11:0] <= (rx_length*4) - 3;
					8'bxx101xxx: tx1_bcount[11:0] <= (rx_length*4) - 1;
					8'bxx1001xx: tx1_bcount[11:0] <= (rx_length*4) - 2;
					8'bxx10001x: tx1_bcount[11:0] <= (rx_length*4) - 3;
					8'bxx100001: tx1_bcount[11:0] <= (rx_length*4) - 4;
					8'bx1001xxx: tx1_bcount[11:0] <= (rx_length*4) - 2;
					8'bx10001xx: tx1_bcount[11:0] <= (rx_length*4) - 3;
					8'bx100001x: tx1_bcount[11:0] <= (rx_length*4) - 4;
					8'bx1000001: tx1_bcount[11:0] <= (rx_length*4) - 5;
					8'b10001xxx: tx1_bcount[11:0] <= (rx_length*4) - 3;
					8'b100001xx: tx1_bcount[11:0] <= (rx_length*4) - 4;
					8'b1000001x: tx1_bcount[11:0] <= (rx_length*4) - 5;
					8'b10000001: tx1_bcount[11:0] <= (rx_length*4) - 6;
				endcase
				tx1_reqid[15:0] <= rx_reqid[15:0];
				tx1_tag[7:0] <= rx_tag[7:0];
				casex (rx_firstbe[3:0])
					4'b0000: tx1_lowaddr[7:0] <= {rx_addr[7:2], 2'b00};
					4'bxxx1: tx1_lowaddr[7:0] <= {rx_addr[7:2], 2'b00};
					4'bxx10: tx1_lowaddr[7:0] <= {rx_addr[7:2], 2'b01};
					4'bx100: tx1_lowaddr[7:0] <= {rx_addr[7:2], 2'b10};
					4'b1000: tx1_lowaddr[7:0] <= {rx_addr[7:2], 2'b11};
				endcase
				tx1_length[10:0] <= {rx_length[9:0], 1'b1};
				slv_adr_i[19:1] <= ({rx_addr[19:2],1'b0} - 19'h1);
				tx1_tlph_valid <= 1'b1;
				slv_status <= SLV_MREADD;
			end
			SLV_MREADD: begin
				if ( tx1_tlpd_ready == 1'b1 ) begin
					tx1_tlph_valid <= 1'b0;
					tx1_length <= tx1_length - 11'h1;
					if ( tx1_length[10:1] != 10'h000)
						slv_adr_i[19:1] <= slv_adr_i[19:1] + 19'h1;
					if ( tx1_length == 11'h7ff ) begin
						slv_status <= SLV_IDLE;
						tx1_tlpd_done  <= 1'b1;
					end else
						slv_ce_i <= 1'b1;
					tx1_data[15:0] <= slv_dat_o[15:0];
				end
			end
			SLV_MWRITEH: begin
				tx1_length[10:0] <= 11'h0;
				slv_adr_i[19:1] <= ({rx_addr[19:2],1'b0} - 19'h1);
				slv_status <= SLV_MWRITED;
			end
			SLV_MWRITED: begin
				tx1_length <= tx1_length + 11'h1;
				slv_adr_i[19:1] <= slv_adr_i[19:1] + 19'h1;
				slv_ce_i <= 1'b1;
				slv_we_i <= 1'b1;
				slv_dat_i <= rx_data2[15:0];
				if ( tx1_length[10:1] == 10'h0 ) begin
					if ( tx1_length[0] == 1'b0 ) begin
						slv_sel_i[1:0] <= { rx_firstbe[0], rx_firstbe[1] };
					end else begin
						slv_sel_i[1:0] <= { rx_firstbe[2], rx_firstbe[3] };
					end
				end else if ( tx1_length[10:1] == (rx_length[9:0] - 10'h1) )
					if ( tx1_length[0] == 1'b0 ) begin
						slv_sel_i[1:0] <= { rx_lastbe[0], rx_lastbe[1] };
					end else begin
						slv_sel_i[1:0] <= { rx_lastbe[2], rx_lastbe[3] };
						slv_status <= SLV_IDLE;
					end
				else begin
					slv_sel_i[1:0] <= 2'b11;
				end
				if ( rx_end2 == 1'b1 )
					slv_status <= SLV_IDLE;
			end
		endcase
	end
end


//-----------------------------------------------------------------
// Master Seaquencer
//-----------------------------------------------------------------
parameter [3:0]
	MST_IDLE    = 3'h0,
	MST_MWRITE64= 3'h1,
	MST_MWRITE48= 3'h2,
	MST_MWRITE32= 3'h3,
	MST_MWRITE16= 3'h4,
	MST_MWRITED = 3'h5,
	MST_COMP    = 3'h7;
reg [3:0] mst_status = MST_IDLE;
reg [47:1] mst_adr;
reg mst_rd_wait;
always @(posedge pcie_clk) begin
	if (sys_rst) begin
		tx2_tlph_valid <= 1'b0;
		tx2_tlpd_done  <= 1'b0;
		mst_status <= MST_IDLE;
		mst_rd_en <= 1'b0;
		mst_rd_wait <= 1'b0;
	end else begin
		tx2_tlpd_done  <= 1'b0;
		mst_rd_en <= ~mst_empty & ~mst_rd_wait;
		if ( ( mst_rd_en == 1'b1 && mst_empty == 1'b0 ) || ( mst_status == MST_MWRITED )  ) begin
			case ( mst_status )
				MST_IDLE: begin
					tx2_tlph_valid <= 1'b0;
					if ( mst_dout[17] == 1'b1 ) begin
						tx2_addr[47:32] <= 14'h0;
						tx2_length[10:0] <= {4'b0000, mst_dout[13:8], 1'b0};
						{tx2_lastbe[3:0], tx2_firstbe[3:0]} <= mst_dout[7:0];
						case ( mst_dout[15:14] )
							2'b00: mst_status <= MST_MWRITE32;
							2'b01: mst_status <= MST_MWRITE64;
							2'b10: mst_status <= MST_MWRITE32;
							2'b11: mst_status <= MST_MWRITE64;
						endcase
					end
				end
				MST_MWRITE64: begin
					mst_status <= MST_MWRITE48;
				end
				MST_MWRITE48: begin
					tx2_addr[47:32] <= mst_dout[15:0];
					mst_status <= MST_MWRITE32;
				end
				MST_MWRITE32: begin
					tx2_addr[31:16] <= mst_dout[15:0];
					mst_status <= MST_MWRITE16;
				end
				MST_MWRITE16: begin
					tx2_addr[15: 2] <= mst_dout[15:2];
					tx2_fmt[1:0] <= 2'b11;		// 4DW, with DATA
					tx2_type[4:0] <= 5'b00000;	// Memory write request
					tx2_tc[2:0] <= 3'b000;
					tx2_td <= 1'b0;
					tx2_ep <= 1'b0;
					tx2_attr[1:0] <= 2'b00;
					tx2_tag[7:0] <= 8'h01;
					mst_adr[47:1] <= {tx2_addr[47:16], mst_dout[15:2], 1'b0};
					tx2_tlph_valid <= 1'b1;
					mst_rd_en <= 1'b0;
					mst_rd_wait <= 1'b1;
					mst_status <= MST_MWRITED;
				end
				MST_MWRITED: begin
					if ( tx2_tlpd_ready == 1'b1 ) begin
						tx2_tlph_valid <= 1'b0;
						tx2_length <= tx2_length - 11'h1;
						if ( tx2_length[10:1] != 10'h000)
							mst_adr[47:1] <= mst_adr[47:1] + 19'h1;
						if ( tx2_length == 11'h7ff || tx2_length == 11'h7fe ) begin
							mst_rd_en <= 1'b0;
						end
						if ( tx2_length == 11'h7fe ) begin
							tx2_tlpd_done  <= 1'b1;
							mst_status <= MST_IDLE;
						end
						tx2_data[15:0] <= mst_dout[15:0];
						mst_rd_wait <= 1'b0;
					end
				end
`ifdef NO
				MST_MWRITEH: begin
					tx2_length[10:0] <= 11'h0;
					mst_adr[19:1] <= ({rx_addr[19:2],1'b0} - 19'h1);
					mst_status <= MST_MWRITED;
				end
				MST_MWRITED: begin
					tx2_length <= tx2_length + 11'h1;
					mst_adr[19:1] <= mst_adr[19:1] + 19'h1;
					mst_din <= rx_data2[15:0];
					if ( tx2_length[10:1] == (rx_length[9:0] - 10'h1) )
						if ( tx2_length[0] == 1'b1 ) begin
							mst_status <= MST_IDLE;
						end
					if ( rx_end2 == 1'b1 )
						mst_status <= MST_IDLE;
				end
`endif
			endcase
		end
	end
end

assign tx_end = tx1_tlpd_done | tx2_tlpd_done;
//assign tx_end = tx1_tlpd_done;

//assign led = 8'b11111111;
//assign led = ~(btn ? rx_addr[31:24] : rx_addr[23:16]);
assign led = ~(btn ? rx_length[7:0] : {rx_lastbe[3:0], rx_firstbe[3:0]} );
//assign segled = ~{12'b000000000000, rx_length[9:8] };

endmodule
`default_nettype wire
