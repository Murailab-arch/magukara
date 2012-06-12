`define	PCI_MAGIC_WORD	32'h10dead10

module pci (
	input         sys_rst,
	input         pci_clk,

	inout  [31:0] AD_IO,            // PCI Ports -- do not modify names!
	output        AD_HIZ,
	inout   [3:0] CBE_IO,
	output reg    CBE_HIZ = 1'b1,
	inout         PAR_IO,
	output reg    PAR_HIZ = 1'b1,
	inout         FRAME_IO,
	output reg    FRAME_HIZ = 1'b1,
	inout         TRDY_IO,
	output reg    TRDY_HIZ = 1'b1,
	inout         IRDY_IO,
	output reg    IRDY_HIZ = 1'b1,
	inout         STOP_IO,
	output reg    STOP_HIZ = 1'b1,
	inout         DEVSEL_IO,
	output reg    DEVSEL_HIZ = 1'b1,
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

	// PCI user register
	output reg    tx0_enable,
	output reg    tx0_ipv6,
	output reg    tx0_fullroute,
	output reg    tx0_req_arp,
	output reg [11:0] tx0_frame_len,
	output reg [31:0] tx0_inter_frame_gap,
	output reg [31:0] tx0_ipv4_srcip,
	output reg [47:0] tx0_src_mac,
	output reg [31:0] tx0_ipv4_gwip,
	input      [47:0] tx0_dst_mac,
	output reg [31:0] tx0_ipv4_dstip,
	output reg [127:0] tx0_ipv6_srcip,
	output reg [127:0] tx0_ipv6_dstip,
	input [31:0]  tx0_pps,
	input [31:0]  tx0_throughput,
	input [31:0]  tx0_ipv4_ip,
	input [31:0]  rx1_pps,
	input [31:0]  rx1_throughput,
	input [23:0]  rx1_latency,
	input [31:0]  rx1_ipv4_ip,
	input [31:0]  rx2_pps,
	input [31:0]  rx2_throughput,
	input [23:0]  rx2_latency,
	input [31:0]  rx2_ipv4_ip,
	input [31:0]  rx3_pps,
	input [31:0]  rx3_throughput,
	input [23:0]  rx3_latency,
	input [31:0]  rx3_ipv4_ip
);

//-----------------------------------
// PCI control register
//-----------------------------------
reg [3:0] PCI_BusCommand = 4'h0;
reg [31:0] PCI_Address = 32'h0;
reg PCI_IDSel = 1'b0;

//-----------------------------------
// Port register
//-----------------------------------
reg [31:0] AD_Port       = 32'h0;
reg DEVSEL_Port          = 1'b1;
reg TRDY_Port            = 1'b1;
reg STOP_Port            = 1'b1;

reg REQ_Port             = 1'b1;
reg SLAD_HIZ             = 1'b1;
wire [3:0] CBE_Port;
reg FRAME_Port           = 1'b1;
reg IRDY_Port            = 1'b1;

parameter PCI_IO_CYCLE		= 3'b001;
parameter PCI_IO_READ_CYCLE	= 4'b0010;
parameter PCI_IO_WRITE_CYCLE	= 4'b0011;
parameter PCI_MEM_CYCLE		= 3'b011;
parameter PCI_MEM_READ_CYCLE	= 4'b0110;
parameter PCI_MEM_WRITE_CYCLE	= 4'b0111;
parameter PCI_CFG_CYCLE		= 3'b101;
parameter PCI_CFG_READ_CYCLE	= 4'b1010;
parameter PCI_CFG_WRITE_CYCLE	= 4'b1011;

parameter TGT_IDLE		= 3'h0;
parameter TGT_ADDR_COMPARE	= 3'h1;
parameter TGT_BUS_BUSY		= 3'h2;
parameter TGT_WAIT_IRDY		= 3'h3;
parameter TGT_WAIT_LOCAL_ACK	= 3'h4;
parameter TGT_ACC_COMPLETE	= 3'h5;
parameter TGT_DISCONNECT	= 3'h6;
parameter TGT_TURN_AROUND	= 3'h7;

parameter INI_IDLE		= 3'h0;
//parameter INI_BUS_PARK	= 3'h1;
parameter INI_WAIT_GNT		= 3'h1;
parameter INI_ADDR2DATA		= 3'h2;
parameter INI_WAIT_DEVSEL	= 3'h3;
parameter INI_WAIT_COMPLETE	= 3'h4;
parameter INI_ABORT		= 3'h5;
parameter INI_TURN_AROUND	= 3'h6;

parameter SEQ_IDLE		= 3'b000;
parameter SEQ_IO_ACCESS		= 3'b001;
parameter SEQ_MEM_ACCESS	= 3'b010;
parameter SEQ_CFG_ACCESS	= 3'b011;
parameter SEQ_ROM_ACCESS	= 3'b100;
parameter SEQ_COMPLETE		= 3'b111;

reg [2:0] target_next_state = TGT_IDLE;
reg [2:0] initiator_next_state = INI_IDLE;
reg [2:0] seq_next_state = SEQ_IDLE;

//-----------------------------------
// PCI configuration parameter/registers
//-----------------------------------
parameter CFG_VendorID		= 16'h3776;
parameter CFG_DeviceID		= 16'h8000;
parameter CFG_Command		= 16'h0000;
parameter CFG_Status		= 16'h0200;
parameter CFG_BaseClass 	= 8'h00;
parameter CFG_SubClass 		= 8'h00;
parameter CFG_ProgramIF		= 8'h00;
parameter CFG_RevisionID	= 8'h00;
parameter CFG_HeaderType	= 8'h00;
parameter CFG_Int_Pin		= 8'h00;
reg CFG_Cmd_Mst = 1'b0;
reg CFG_Cmd_Mem = 1'b0;
reg CFG_Cmd_IO  = 1'b0;
reg CFG_Cmd_IntDis = 1'b0;
reg CFG_Sta_IntSta;
reg CFG_Sta_MAbt;
reg CFG_Sta_TAbt;
reg [31:24] CFG_Base_Addr0 = 8'h0;
reg [15:5]  CFG_Base_Addr1 = 11'h0;
reg [7:0] CFG_Int_Line = 0;

reg CFG_Sta_MAbt_Clr = 1'b0;
reg CFG_Sta_TAbt_Clr = 1'b0;


assign Hit_IO = (PCI_BusCommand[3:1] == PCI_IO_CYCLE) & (PCI_Address[31:5] == {16'h0,CFG_Base_Addr1[15:5]}) & CFG_Cmd_IO;
assign Hit_Memory = (PCI_BusCommand[3:1] == PCI_MEM_CYCLE) & (PCI_Address[31:24] == CFG_Base_Addr0) & CFG_Cmd_Mem;
assign Hit_Config = (PCI_BusCommand[3:1] == PCI_CFG_CYCLE) & PCI_IDSel & (PCI_Address[10:8] == 3'b000) & (PCI_Address[1:0] == 2'b00);
assign Hit_Device = Hit_IO | Hit_Memory | Hit_Config;

reg Local_Bus_Start = 1'b0;
reg Local_DTACK = 1'b0;

//-----------------------------------
// PCI user registers
//-----------------------------------
reg[31:0] sora = 32'h0;

//-----------------------------------
// Target
//-----------------------------------
always @(posedge pci_clk) begin
	if (sys_rst) begin
		target_next_state <= TGT_IDLE;
		SLAD_HIZ <= 1'b1;
		DEVSEL_HIZ <= 1'b1;
		DEVSEL_Port <= 1'b1;
		TRDY_HIZ <= 1'b1;
		TRDY_Port <= 1'b1;
		STOP_HIZ <= 1'b1;
		STOP_Port <= 1'b1;
		PCI_BusCommand <= 4'h0;
		PCI_Address <= 32'h0;
		PCI_IDSel <= 1'b0;
		Local_Bus_Start <= 1'b0;
	end else begin
		case (target_next_state)
			TGT_IDLE: begin
				if (~FRAME_IO & IRDY_IO & ~PASS_READY) begin
					PCI_BusCommand <= CBE_IO;
					PCI_Address <= AD_IO;
					PCI_IDSel <= IDSEL_I;
					target_next_state <= TGT_ADDR_COMPARE;
				end
			end
			TGT_ADDR_COMPARE: begin
				if (Hit_Device) begin
					DEVSEL_Port <= 1'b0;
					DEVSEL_HIZ <= 1'b0;
					TRDY_HIZ <= 1'b0;
					STOP_HIZ <= 1'b0;
					target_next_state <= TGT_WAIT_IRDY;
				end else
					target_next_state <= TGT_BUS_BUSY;
			end
			TGT_BUS_BUSY: begin
				if (FRAME_IO & IRDY_IO)
					target_next_state <= TGT_IDLE;
			end
			TGT_WAIT_IRDY: begin
				if (~IRDY_IO) begin
					if (PCI_BusCommand[0] == 1'b0)
						SLAD_HIZ <= 1'b0;
					Local_Bus_Start <= 1'b1;
					target_next_state <= TGT_WAIT_LOCAL_ACK;
				end
			end
			TGT_WAIT_LOCAL_ACK: begin
				Local_Bus_Start <= 1'b0;
				if (Local_DTACK) begin
					TRDY_Port <= 1'b0;
					STOP_Port <= 1'b0;
					target_next_state <= TGT_ACC_COMPLETE;
				end
			end
			TGT_ACC_COMPLETE: begin
				TRDY_Port <= 1'b1;
				SLAD_HIZ <= 1'b1;
				if (~FRAME_IO) begin
					target_next_state <= TGT_DISCONNECT;
				end else begin
					DEVSEL_Port <= 1'b1;
					STOP_Port <= 1'b1;
					target_next_state <= TGT_TURN_AROUND;
				end
			end
			TGT_DISCONNECT: begin
				if (FRAME_IO) begin
					DEVSEL_Port <= 1'b1;
					STOP_Port <= 1'b1;
					target_next_state <= TGT_TURN_AROUND;
				end
			end
			TGT_TURN_AROUND: begin
				DEVSEL_HIZ <= 1'b1;
				TRDY_HIZ <= 1'b1;
				STOP_HIZ <= 1'b1;
				target_next_state <= TGT_IDLE;
			end
			default: begin
				target_next_state <= TGT_TURN_AROUND;
			end
		endcase 
	end
end

//-----------------------------------
// Sequencer
//-----------------------------------
always @(posedge pci_clk) begin
	if (sys_rst) begin
		seq_next_state <= SEQ_IDLE;
		AD_Port <= 32'h0;
		// Configurartion Register
		CFG_Cmd_Mst <= 1'b0;
		CFG_Cmd_Mem <= 1'b0;
		CFG_Cmd_IO  <= 1'b0;
		CFG_Cmd_IntDis <= 1'b0;
		CFG_Base_Addr0 <= 8'h0;
		CFG_Base_Addr1 <= 11'h0;
		CFG_Int_Line <= 0;
		CFG_Sta_MAbt_Clr <= 1'b0;
		CFG_Sta_TAbt_Clr <= 1'b0;

		Local_DTACK   <= 1'b0;
		// PCI User Registers
		tx0_enable    <= 1'b1;
		tx0_ipv6      <= 1'b0;
		tx0_fullroute <= 1'b0;
		tx0_req_arp   <= 1'b0;
		tx0_frame_len <= 12'd64;
		tx0_inter_frame_gap <= 32'd12;
		tx0_src_mac   <= 48'h003776_000100;
		tx0_ipv4_gwip <= {8'd10,8'd0,8'd20,8'd1};
		tx0_ipv4_srcip<= {8'd10,8'd0,8'd20,8'd105};
		tx0_ipv4_dstip<= {8'd10,8'd0,8'd21,8'd105};
		tx0_ipv6_srcip<= 128'h3776_0000_0000_0020_0000_0000_0000_0105;
		tx0_ipv6_dstip<= 128'h3776_0000_0000_0021_0000_0000_0000_0105;
	end else begin
		tx0_req_arp   <= 1'b0;
		case (seq_next_state)
			SEQ_IDLE: begin
				if (Local_Bus_Start) begin
					if (Hit_IO)
						seq_next_state <= SEQ_IO_ACCESS;
					else if (Hit_Memory)
						seq_next_state <= SEQ_MEM_ACCESS;
					else if (Hit_Config)
						seq_next_state <= SEQ_CFG_ACCESS;
				end
			end
			SEQ_IO_ACCESS: begin
				Local_DTACK <= 1'b1;
				seq_next_state <= SEQ_COMPLETE;
			end
			SEQ_MEM_ACCESS: begin // memory read
				if (~PCI_BusCommand[0]) begin
					case (PCI_Address[7:2])
						6'h00: // tx enable bit
							AD_Port[31:0] <= {24'h0, tx0_enable, tx0_ipv6, 5'b0, tx0_fullroute};
						6'h01: // tx0 frame length
							AD_Port[31:0] <= {tx0_frame_len[7:0], 4'b0, tx0_frame_len[11:8], 16'h0};
						6'h02: // tx0 inter_frame_gap
							AD_Port[31:0] <= {tx0_inter_frame_gap[7:0],tx0_inter_frame_gap[15:8],tx0_inter_frame_gap[23:16],tx0_inter_frame_gap[31:24]};
						6'h04: // tx0 ipv4_src_ip
							AD_Port[31:0] <= {tx0_ipv4_srcip[7:0],tx0_ipv4_srcip[15:8],tx0_ipv4_srcip[23:16],tx0_ipv4_srcip[31:24]};
						6'h05: // tx0 src_mac 47-32bit
							AD_Port[31:0] <= {tx0_src_mac[39:32],tx0_src_mac[47:40],16'h00};
						6'h06: // tx0 src_mac 31-00bit
							AD_Port[31:0] <= {tx0_src_mac[7:0],tx0_src_mac[15:8],tx0_src_mac[23:16],tx0_src_mac[31:24]};
						6'h08: // tx0 ipv4_gwip
							AD_Port[31:0] <= {tx0_ipv4_gwip[7:0],tx0_ipv4_gwip[15:8],tx0_ipv4_gwip[23:16],tx0_ipv4_gwip[31:24]};
						6'h09: // tx0 dst_mac 47-32bit
							AD_Port[31:0] <= {tx0_dst_mac[39:32],tx0_dst_mac[47:40],16'h00};
						6'h0a: // tx0 dst_mac 31-00bit
							AD_Port[31:0] <= {tx0_dst_mac[7:0],tx0_dst_mac[15:8],tx0_dst_mac[23:16],tx0_dst_mac[31:24]};
						6'h0b: // tx0 ipv4_dstip
							AD_Port[31:0] <= {tx0_ipv4_dstip[7:0],tx0_ipv4_dstip[15:8],tx0_ipv4_dstip[23:16],tx0_ipv4_dstip[31:24]};
						6'h10: // tx0 pps
							AD_Port[31:0] <= {tx0_pps[7:0],tx0_pps[15:8],tx0_pps[23:16],tx0_pps[31:24]};
						6'h11: // tx0 throughput
							AD_Port[31:0] <= {tx0_throughput[7:0],tx0_throughput[15:8],tx0_throughput[23:16],tx0_throughput[31:24]};
						6'h13: // tx0_ipv4_ip
							AD_Port[31:0] <= {tx0_ipv4_ip[7:0],tx0_ipv4_ip[15:8],tx0_ipv4_ip[23:16],tx0_ipv4_ip[31:24]};
						6'h14: // rx1 pps
							AD_Port[31:0] <= {rx1_pps[7:0],rx1_pps[15:8],rx1_pps[23:16],rx1_pps[31:24]};
						6'h15: // rx1 throughput
							AD_Port[31:0] <= {rx1_throughput[7:0],rx1_throughput[15:8],rx1_throughput[23:16],rx1_throughput[31:24]};
						6'h16: // rx1_latency
							AD_Port[31:0] <= {rx1_latency[7:0],rx1_latency[15:8],rx1_latency[23:16],8'h0};
						6'h17: // rx1_ipv4_ip
							AD_Port[31:0] <= {rx1_ipv4_ip[7:0],rx1_ipv4_ip[15:8],rx1_ipv4_ip[23:16],rx1_ipv4_ip[31:24]};
						6'h18: // rx2 pps
							AD_Port[31:0] <= {rx2_pps[7:0],rx2_pps[15:8],rx2_pps[23:16],rx2_pps[31:24]};
						6'h19: // rx2 throughput
							AD_Port[31:0] <= {rx2_throughput[7:0],rx2_throughput[15:8],rx2_throughput[23:16],rx2_throughput[31:24]};
						6'h1a: // rx2_latency
							AD_Port[31:0] <= {rx2_latency[7:0],rx2_latency[15:8],rx2_latency[23:16],8'h0};
						6'h1b: // rx2_ipv4_ip
							AD_Port[31:0] <= {rx2_ipv4_ip[7:0],rx2_ipv4_ip[15:8],rx2_ipv4_ip[23:16],rx2_ipv4_ip[31:24]};
						6'h1c: // rx3 pps
							AD_Port[31:0] <= {rx3_pps[7:0],rx3_pps[15:8],rx3_pps[23:16],rx3_pps[31:24]};
						6'h1d: // rx3 throughput
							AD_Port[31:0] <= {rx3_throughput[7:0],rx3_throughput[15:8],rx3_throughput[23:16],rx3_throughput[31:24]};
						6'h1e: // rx3_latency
							AD_Port[31:0] <= {rx3_latency[7:0],rx3_latency[15:8],rx3_latency[23:16],8'h0};
						6'h1f: // rx3_ipv4_ip
							AD_Port[31:0] <= {rx3_ipv4_ip[7:0],rx3_ipv4_ip[15:8],rx3_ipv4_ip[23:16],rx3_ipv4_ip[31:24]};
						6'h20: // tx0_ipv6_srcip
							AD_Port[31:0] <= {tx0_ipv6_srcip[103:96],tx0_ipv6_srcip[111:104],tx0_ipv6_srcip[119:112],tx0_ipv6_srcip[127:120]};
						6'h21:	AD_Port[31:0] <= {tx0_ipv6_srcip[71:64],tx0_ipv6_srcip[79:72],tx0_ipv6_srcip[87:80],tx0_ipv6_srcip[95:88]};
						6'h22:	AD_Port[31:0] <= {tx0_ipv6_srcip[39:32],tx0_ipv6_srcip[47:40],tx0_ipv6_srcip[55:48],tx0_ipv6_srcip[63:56]};
						6'h23:	AD_Port[31:0] <= {tx0_ipv6_srcip[ 7: 0],tx0_ipv6_srcip[15: 8],tx0_ipv6_srcip[23:16],tx0_ipv6_srcip[31:24]};
						6'h24: // tx0_ipv6_dstip
							AD_Port[31:0] <= {tx0_ipv6_dstip[103:96],tx0_ipv6_dstip[111:104],tx0_ipv6_dstip[119:112],tx0_ipv6_dstip[127:120]};
						6'h25:	AD_Port[31:0] <= {tx0_ipv6_dstip[71:64],tx0_ipv6_dstip[79:72],tx0_ipv6_dstip[87:80],tx0_ipv6_dstip[95:88]};
						6'h26:	AD_Port[31:0] <= {tx0_ipv6_dstip[39:32],tx0_ipv6_dstip[47:40],tx0_ipv6_dstip[55:48],tx0_ipv6_dstip[63:56]};
						6'h27:	AD_Port[31:0] <= {tx0_ipv6_dstip[ 7: 0],tx0_ipv6_dstip[15: 8],tx0_ipv6_dstip[23:16],tx0_ipv6_dstip[31:24]};
						default:
							AD_Port[31:0] <= 32'h0;
					endcase
				end
				else begin     // memory write
					case (PCI_Address[7:2])
						6'h00: begin // tx enable bit
							if (~CBE_IO[0]) begin
								tx0_enable <= AD_IO[7];
								tx0_ipv6   <= AD_IO[6];
								tx0_fullroute <= AD_IO[0];
							end
						end
						6'h01: begin // tx0 frame length
							if (~CBE_IO[3])
								tx0_frame_len[ 7:0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_frame_len[11:8] <= AD_IO[19:16];
						end
						6'h02: begin // tx0 ipv4_inter_frame_gap
							if (~CBE_IO[3])
								tx0_inter_frame_gap[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_inter_frame_gap[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_inter_frame_gap[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_inter_frame_gap[31:24] <= AD_IO[7:0];
						end
						6'h03: begin // tx0 arp request command
							tx0_req_arp   <= 1'b1;
						end
						6'h04: begin // tx0 ipv4_src_ip
							if (~CBE_IO[3])
								tx0_ipv4_srcip[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv4_srcip[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv4_srcip[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv4_srcip[31:24] <= AD_IO[7:0];
						end
						6'h05: begin // tx0 src_mac 47-32bit
							if (~CBE_IO[3])
								tx0_src_mac[39:32] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_src_mac[47:40] <= AD_IO[23:16];
						end
						6'h06: begin // tx0 src_mac 31-00bit
							if (~CBE_IO[3])
								tx0_src_mac[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_src_mac[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_src_mac[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_src_mac[31:24] <= AD_IO[7:0];
						end
						6'h08: begin // tx0 ipv4_gwip
							if (~CBE_IO[3])
								tx0_ipv4_gwip[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv4_gwip[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv4_gwip[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv4_gwip[31:24] <= AD_IO[7:0];
						end
						6'h0b: begin // tx0 ipv4_dstip
							if (~CBE_IO[3])
								tx0_ipv4_dstip[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv4_dstip[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv4_dstip[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv4_dstip[31:24] <= AD_IO[7:0];
						end
						6'h20: begin // tx0_ipv6_srcip
							if (~CBE_IO[3])
								tx0_ipv6_srcip[103:96] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_srcip[111:104] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_srcip[119:112] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_srcip[127:120] <= AD_IO[7:0];
						end
						6'h21: begin
							if (~CBE_IO[3])
								tx0_ipv6_srcip[71:64] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_srcip[79:72] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_srcip[87:80] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_srcip[95:88] <= AD_IO[7:0];
						end
						6'h22: begin
							if (~CBE_IO[3])
								tx0_ipv6_srcip[39:32] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_srcip[47:40] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_srcip[55:48] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_srcip[63:56] <= AD_IO[7:0];
						end
						6'h23: begin
							if (~CBE_IO[3])
								tx0_ipv6_srcip[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_srcip[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_srcip[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_srcip[31:24] <= AD_IO[7:0];
						end
						6'h24: begin // tx0_ipv6_dstip
							if (~CBE_IO[3])
								tx0_ipv6_dstip[103:96] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_dstip[111:104] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_dstip[119:112] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_dstip[127:120] <= AD_IO[7:0];
						end
						6'h25: begin
							if (~CBE_IO[3])
								tx0_ipv6_dstip[71:64] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_dstip[79:72] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_dstip[87:80] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_dstip[95:88] <= AD_IO[7:0];
						end
						6'h26: begin
							if (~CBE_IO[3])
								tx0_ipv6_dstip[39:32] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_dstip[47:40] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_dstip[55:48] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_dstip[63:56] <= AD_IO[7:0];
						end
						6'h27: begin
							if (~CBE_IO[3])
								tx0_ipv6_dstip[ 7: 0] <= AD_IO[31:24];
							if (~CBE_IO[2])
								tx0_ipv6_dstip[15: 8] <= AD_IO[23:16];
							if (~CBE_IO[1])
								tx0_ipv6_dstip[23:16] <= AD_IO[15:8];
							if (~CBE_IO[0])
								tx0_ipv6_dstip[31:24] <= AD_IO[7:0];
						end
					endcase
				end
				Local_DTACK <= 1'b1;
				seq_next_state <= SEQ_COMPLETE;
			end
			SEQ_CFG_ACCESS: begin
				if (~PCI_BusCommand[0]) begin
					case (PCI_Address[7:2])
						6'b000000: begin	// Vendor/Device ID
							AD_Port[31:16] <= CFG_DeviceID;
							AD_Port[15:0]  <= CFG_VendorID;
						end
						6'b000001: begin	// Command/Status Register
							AD_Port[31:30] <= CFG_Status[15:14];
							AD_Port[29]    <= CFG_Sta_MAbt;
							AD_Port[28]    <= CFG_Sta_TAbt;
							AD_Port[27:20] <= CFG_Status[11:4];
							AD_Port[19]    <= CFG_Sta_IntSta;
							AD_Port[18:16] <= CFG_Status[2:0];
							AD_Port[15:11] <= CFG_Command[15:11];
							AD_Port[10]    <= CFG_Cmd_IntDis;
							AD_Port[9:3]   <= CFG_Command[9:3];
							AD_Port[2]     <= CFG_Cmd_Mst;
							AD_Port[1]     <= CFG_Cmd_Mem;
							AD_Port[0]     <= CFG_Cmd_IO;
						end
						6'b000010: begin	// Class Code
							AD_Port[31:24] <= CFG_BaseClass;
							AD_Port[23:16] <= CFG_SubClass;
							AD_Port[15:8]  <= CFG_ProgramIF;
							AD_Port[7:0]   <= CFG_RevisionID;
						end
						6'b000011: 		// Header Type/other
							AD_Port[31:0]  <= {8'b0, CFG_HeaderType, 16'b0};
						6'b000100: 		// Base Addr Register 0
							AD_Port[31:0]  <= {CFG_Base_Addr0, 24'b0};
						6'b000101: 		// Base Addr Register 1
							AD_Port[31:0]  <= {16'h0, CFG_Base_Addr1, 5'b00001};
						6'b001011:		// Sub System Vendor/Sub System ID
							AD_Port[31:0]  <= {CFG_DeviceID, CFG_VendorID};
						6'b001111:		// Interrupt Register
							AD_Port[31:0]  <= {16'b0, CFG_Int_Pin, CFG_Int_Line};
						default:
							AD_Port[31:0]  <= 32'h0;
					endcase
				end else begin
					case (PCI_Address[7:2])
						6'b000001: begin	// Command/Status Register
							if (~CBE_IO[3]) begin
								CFG_Sta_MAbt_Clr <= AD_IO[29];
								CFG_Sta_TAbt_Clr <= AD_IO[28];
							end
							if (~CBE_IO[1]) begin
								CFG_Cmd_IntDis <= AD_IO[10];
							end
							if (~CBE_IO[0]) begin
								CFG_Cmd_Mst <= AD_IO[2];
								CFG_Cmd_Mem <= AD_IO[1];
								CFG_Cmd_IO  <= AD_IO[0];
							end
						end
						6'b000100: begin	// Base Addr Register 0
							if(~CBE_IO[3]) begin
								CFG_Base_Addr0[31:24] <= AD_IO[31:24];
							end
						end
						6'b000101: begin	// Base Addr Register 1
							if(~CBE_IO[1]) begin
								CFG_Base_Addr1[15:8]  <= AD_IO[15:8];
							end
							if(~CBE_IO[0]) begin
								CFG_Base_Addr1[7:5]   <= AD_IO[7:5];
							end
						end
						6'b001111: begin	// Interrupt Register
							if(~CBE_IO[0]) begin
								CFG_Int_Line[7:0] <= AD_IO[7:0];
							end
						end
					endcase
				end
				Local_DTACK <= 1'b1;
				seq_next_state <= SEQ_COMPLETE;
			end
			SEQ_COMPLETE: begin
				Local_DTACK <= 1'b0;
				seq_next_state <= SEQ_IDLE;
			end
			default:
				seq_next_state <= SEQ_IDLE;
		endcase
	end
end

// PCI BUS
assign CBE_IO    = CBE_HIZ    ? 4'hz  : CBE_Port;
assign AD_IO     = AD_HIZ     ? 32'hz : AD_Port;
assign AD_HIZ    = SLAD_HIZ;
assign PAR_IO    = 1'hz;
assign FRAME_IO  = FRAME_HIZ  ? 1'hz  : FRAME_Port;
assign IRDY_IO   = IRDY_HIZ   ? 1'hz  : IRDY_Port;
assign TRDY_IO   = TRDY_HIZ   ? 1'hz  : TRDY_Port;
assign STOP_IO   = STOP_HIZ   ? 1'hz  : STOP_Port;
assign DEVSEL_IO = DEVSEL_HIZ ? 1'hz  : DEVSEL_Port;
assign INTA_O    = 1'hz;
assign REQ_O     = REQ_Port;
assign PERR_HIZ  = 1'b1;
assign SERR_HIZ  = 1'b1;

assign PASS_REQ  = 1'b0;
assign cpci_debug_data = `PCI_MAGIC_WORD;

endmodule
