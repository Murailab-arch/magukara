`timescale 1ns / 1ps
`include "../rtl/setup.v"
//`define DEBUG

module measure (
  input         sys_rst,
  input         sys_clk,
  input         pci_clk,

  // GMII interfaces for 4 MACs
  input         gmii_0_tx_clk,
  output [7:0]  gmii_0_txd,
  output        gmii_0_tx_en,
  input  [7:0]  gmii_0_rxd,
  input         gmii_0_rx_dv,
  input         gmii_0_rx_clk,

  input         gmii_1_tx_clk,
  output [7:0]  gmii_1_txd,
  output        gmii_1_tx_en,
  input  [7:0]  gmii_1_rxd,
  input         gmii_1_rx_dv,
  input         gmii_1_rx_clk,

  input         gmii_2_tx_clk,
  output [7:0]  gmii_2_txd,
  output        gmii_2_tx_en,
  input  [7:0]  gmii_2_rxd,
  input         gmii_2_rx_dv,
  input         gmii_2_rx_clk,

  input         gmii_3_tx_clk,
  output [7:0]  gmii_3_txd,
  output        gmii_3_tx_en,
  input  [7:0]  gmii_3_rxd,
  input         gmii_3_rx_dv,
  input         gmii_3_rx_clk,

  // PCI user registers
  input         tx0_enable,
  input         tx0_ipv6,
  input         tx0_fullroute,
  input         tx0_req_arp,
  input [15:0]  tx0_frame_len,
  input [31:0]  tx0_inter_frame_gap,
  input [31:0]  tx0_ipv4_srcip,
  input [47:0]  tx0_src_mac,
  input [31:0]  tx0_ipv4_gwip,
  input [127:0]  tx0_ipv6_srcip,
  input [127:0]  tx0_ipv6_dstip,
  output reg [47:0] tx0_dst_mac,
  input [31:0]  tx0_ipv4_dstip,
  output reg [31:0] tx0_pps,
  output reg [31:0] tx0_throughput,
  output [31:0] tx0_ipv4_ip,

  output [31:0] rx1_pps,
  output [31:0] rx1_throughput,
  output [23:0] rx1_latency,
  output [31:0] rx1_ipv4_ip,

  output [31:0] rx2_pps,
  output [31:0] rx2_throughput,
  output [23:0] rx2_latency,
  output [31:0] rx2_ipv4_ip,

  output [31:0] rx3_pps,
  output [31:0] rx3_throughput,
  output [23:0] rx3_latency,
  output [31:0] rx3_ipv4_ip
);

//-----------------------------------
// One second clock
//-----------------------------------
reg sec_oneshot;
reg [26:0] sec_counter;
always @(posedge gmii_0_tx_clk) begin
  if (sys_rst) begin
    sec_counter <= 27'd125000000;
    sec_oneshot <= 1'b0;
  end else begin
    if (sec_counter == 27'd0) begin
      sec_counter <= 27'd125000000;
      sec_oneshot <= 1'b1;
    end else begin
      sec_counter <= sec_counter - 27'd1;
      sec_oneshot <= 1'b0;
    end
  end
end

//-----------------------------------
// Transmitte logic
//-----------------------------------
reg [15:0] tx_count = 16'h0;
reg [7:0] tx_data;
reg tx_en = 1'b0;

//-----------------------------------
// CRC
//-----------------------------------
assign crc_init = (tx_count ==  16'h08);
wire [31:0] crc_out;
reg crc_rd;
assign crc_data_en = ~crc_rd;
crc_gen crc_inst (
  .Reset(sys_rst),
  .Clk(gmii_0_tx_clk),
  .Init(crc_init),
  .Frame_data(tx_data),
  .Data_en(crc_data_en),
  .CRC_rd(crc_rd),
  .CRC_end(),
  .CRC_out(crc_out)
); 

//-----------------------------------
// Global counter
//-----------------------------------
reg [31:0] global_counter;
always @(posedge gmii_0_tx_clk) begin
  if (sys_rst) begin
    global_counter <= 32'h0;
  end else begin
    global_counter <= global_counter + 32'h1;
  end
end

//-----------------------------------
// RX FIFO (rxq)
//-----------------------------------
wire [8:0] rxq_din, rxq_dout;
wire rxq_full, rxq_wr_en;
wire rxq_empty;
reg rxq_rd_en;
`ifndef SIMULATION
`ifdef NETFPGA
asfifo9_4 rxq (
        .din(rxq_din),
        .full(rxq_full),
        .wr_en(rxq_wr_en),
        .wr_clk(gmii_0_rx_clk),

        .dout(rxq_dout),
        .empty(rxq_empty),
        .rd_en(rxq_rd_en),
        .rd_clk(gmii_0_tx_clk),

        .rst(sys_rst)
);
`endif
`ifdef ECP3VERSA
asfifo9_4 rxq (
  .Data(rxq_din),
  .Full(rxq_full),
  .WrEn(rxq_wr_en),
  .WrClock(gmii_0_rx_clk),

  .Q(rxq_dout),
  .Empty(rxq_empty),
  .RdEn(rxq_rd_en),
  .RdClock(gmii_0_tx_clk),

  .RPReset(),
  .Reset(sys_rst)
);
`endif
`else
asfifo # (
        .DATA_WIDTH(3),
        .ADDRESS_WIDTH(4)
) rx0fifo (
        .din(rxq_din),
        .full(rxq_full),
        .wr_en(rxq_wr_en),
        .wr_clk(gmii_0_rx_clk),

        .dout(rxq_dout),
        .empty(rxq_empty),
        .rd_en(rxq_rd_en),
        .rd_clk(gmii_0_tx_clk),

        .rst(sys_rst)
);
`endif

//-----------------------------------
// GMII2FIFO9 module
//-----------------------------------
gmii2fifo9 # (
        .Gap(4'h8)
) rxgmii2fifo (
        .sys_rst(sys_rst),

        .gmii_rx_clk(gmii_0_rx_clk),
        .gmii_rx_dv(gmii_0_rx_dv),
        .gmii_rxd(gmii_0_rxd),

        .din(rxq_din),
        .full(rxq_full),
        .wr_en(rxq_wr_en),
        .wr_clk()
);

//-----------------------------------
// ARP Recive logic
//-----------------------------------
reg [13:0] rx_count = 0;
reg [15:0] rx_type;         // frame type
reg  [47:0] rx_src_mac, rx_dst_mac;
reg  [31:0] rx_ipv4_srcip;
reg  [15:0] rx_opcode;
reg  [31:0] rx_arp_dst;
reg arp_reply;

wire [7:0] rx_data = rxq_dout[7:0];

always @(posedge gmii_0_tx_clk) begin
  if (sys_rst) begin
    rx_count    <= 14'h0;
    rx_type <= 16'h0;
    rx_src_mac <= 48'h0;
    rx_dst_mac <= 48'h0;
    rx_ipv4_srcip <= 32'h0;
    rx_opcode <= 16'h0;
    rx_arp_dst <= 32'h0;
    tx0_dst_mac <= 48'h0;
    arp_reply <= 1'b0;
  end else begin
    rxq_rd_en <= ~rxq_empty;
    if (tx0_req_arp == 1'b1) begin
      tx0_dst_mac   <= 48'h0;
    end
    if (rxq_rd_en == 1'b1) begin
      rx_count <= rx_count + 14'h1;
      if (rxq_dout[8] == 1'b1) begin
        case (rx_count)
        14'h00: rx_dst_mac[47:40] <= rx_data;// Ethernet hdr: Dest MAC
        14'h01: rx_dst_mac[39:32] <= rx_data;
        14'h02: rx_dst_mac[31:24] <= rx_data;
        14'h03: rx_dst_mac[23:16] <= rx_data;
        14'h04: rx_dst_mac[15: 8] <= rx_data;
        14'h05: rx_dst_mac[ 7: 0] <= rx_data;
        14'h06: rx_src_mac[47:40] <= rx_data;// Ethernet hdr: Source MAC
        14'h07: rx_src_mac[39:32] <= rx_data;
        14'h08: rx_src_mac[31:24] <= rx_data;
        14'h09: rx_src_mac[23:16] <= rx_data;
        14'h0a: rx_src_mac[15: 8] <= rx_data;
        14'h0b: rx_src_mac[ 7: 0] <= rx_data;
        14'h0c: rx_type[15:8] <= rx_data;    // Type: IP=0800,ARP=0806
        14'h0d: rx_type[ 7:0] <= rx_data;
        14'h14: rx_opcode[15:8] <= rx_data;  // ARP: Operation (ARP reply: 0x0002)
        14'h15: rx_opcode[ 7:0] <= rx_data;  // Opcode ARP Reply=2
        14'h1c: rx_ipv4_srcip[31:24] <= rx_data;  // ARP: Source IP address
        14'h1d: rx_ipv4_srcip[23:16] <= rx_data;
        14'h1e: rx_ipv4_srcip[15: 8] <= rx_data;
        14'h1f: rx_ipv4_srcip[ 7: 0] <= rx_data;
        14'h26: rx_arp_dst[31:24]  <= rx_data; // target IP for ARP
        14'h27: rx_arp_dst[23:16]  <= rx_data;
        14'h28: rx_arp_dst[15: 8]  <= rx_data;
        14'h29: rx_arp_dst[ 7: 0]  <= rx_data;
        14'h2a: begin
          if (rx_type == 16'h0806 && rx_opcode == 16'h2 && rx_ipv4_srcip == tx0_ipv4_gwip && rx_arp_dst == tx0_ipv4_srcip && rx_src_mac[40] == 1'b0 && tx0_req_arp == 1'b0) begin  // rx_magic[39:8] is Target IP Addres (ARP)
            tx0_dst_mac   <= rx_src_mac;
            arp_reply <= 1'b1;
          end
        end endcase
      end else begin
        rx_count    <= 14'h0;
        arp_reply <= 1'b0;
      end
    end
  end
end

//-----------------------------------
// scenario parameter
//-----------------------------------
wire [39:0] magic_code       = `MAGIC_CODE;
reg [16:0] ipv4_id           = 16'h0;
reg [7:0]  ipv4_ttl          = 8'h40;      // IPv4: default TTL value (default: 64)
reg [31:0] pps;
reg [31:0] throughput;
reg [23:0] full_ipv4;
reg [23:0] ip_sum;
reg [15:0] arp_wait_count;

wire [15:0] frame_crc1_count = tx0_frame_len + 16'h4;
wire [15:0] frame_crc2_count = tx0_frame_len + 16'h5;
wire [15:0] frame_crc3_count = tx0_frame_len + 16'h6;
wire [15:0] frame_crc4_count = tx0_frame_len + 16'h7;
wire [15:0] frame_end_count  = tx0_frame_len + 16'h8;

reg [2:0] tx_state;
reg [31:0] gap_count;
parameter TX_REQ_ARP     = 3'h0;  // Send ARP request
parameter TX_WAIT_ARPREP = 3'h1;  // Wait ARP reply
parameter TX_V4_SEND     = 3'h2;  // IPv4 Payload
parameter TX_V6_SEND     = 3'h3;  // IPv6 Payload
parameter TX_GAP         = 3'h4;  // Inter Frame Gap

wire [31:0] ipv4_dstip = (tx0_fullroute == 1'b0) ? tx0_ipv4_dstip[31:0] : {full_ipv4[23:0],8'h1};  // IPv4: Destination Address
wire [15:0] tx0_udp_len = tx0_frame_len - 16'h26;  // UDP Length
wire [15:0] tx0_ip_len  = tx0_frame_len - 16'd18;  // IP Length (Frame Len - FCS Len - EtherFrame Len)

reg [23:0] tmp_counter;
always @(posedge gmii_0_tx_clk) begin
  if (sys_rst) begin
    tx_count       <= 16'h0;
    tmp_counter    <= 24'h0;
    ipv4_id        <= 16'h0;
    tx_en          <= 1'b0;
    crc_rd         <= 1'b0;
    tx_state       <= TX_REQ_ARP;
    gap_count      <= 32'h0;
    pps            <= 32'h0;
    throughput     <= 32'h0;
    tx0_pps        <= 32'h0;
    tx0_throughput <= 32'h0;
    full_ipv4      <= 24'h0;
    arp_wait_count <= 16'h0;
  end else begin
    if (sec_oneshot == 1'b1) begin
      tx0_pps        <= pps;
      tx0_throughput <= throughput;
      pps            <= 32'h0;
      throughput     <= 32'h0;
    end
    case (tx_state)
    TX_REQ_ARP: begin
      case (tx_count[6:0])
      7'h00: begin
        tx_data <= 8'h55;
        tx_en <= 1'b1;
      end
      7'h01: tx_data <= 8'h55;     // preamble
      7'h02: tx_data <= 8'h55;
      7'h03: tx_data <= 8'h55;
      7'h04: tx_data <= 8'h55;
      7'h05: tx_data <= 8'h55;
      7'h06: tx_data <= 8'h55;
      7'h07: tx_data <= 8'hd5;     // preamble + SFD (0b1101_0101)
      7'h08: tx_data <= 8'hff;     // Ethernet hdr: Destination MAC
      7'h09: tx_data <= 8'hff;
      7'h0a: tx_data <= 8'hff;
      7'h0b: tx_data <= 8'hff;
      7'h0c: tx_data <= 8'hff;
      7'h0d: tx_data <= 8'hff;
      7'h0e: tx_data <= tx0_src_mac[47:40];   // Ethernet hdr: Source MAC
      7'h0f: tx_data <= tx0_src_mac[39:32];
      7'h10: tx_data <= tx0_src_mac[31:24];
      7'h11: tx_data <= tx0_src_mac[23:16];
      7'h12: tx_data <= tx0_src_mac[15:8];
      7'h13: tx_data <= tx0_src_mac[7:0];
      7'h14: tx_data <= 8'h08;     // Ethernet hdr: Protocol type: ARP
      7'h15: tx_data <= 8'h06;
      7'h16: tx_data <= 8'h00;     // ARP: Hardware type: Ethernet (1)
      7'h17: tx_data <= 8'h01;
      7'h18: tx_data <= 8'h08;     // ARP: Protocol type: IPv4 (0x0800)
      7'h19: tx_data <= 8'h00;
      7'h1a: tx_data <= 8'h06;     // ARP: MAC length
      7'h1b: tx_data <= 8'h04;     // ARP: IP address length
      7'h1c: tx_data <= 8'h00;     // ARP: Operation (ARP request:0x0001)
      7'h1d: tx_data <= 8'h01;
      7'h1e: tx_data <= tx0_src_mac[47:40];   // ARP: Source MAC
      7'h1f: tx_data <= tx0_src_mac[39:32];
      7'h20: tx_data <= tx0_src_mac[31:24];
      7'h21: tx_data <= tx0_src_mac[23:16];
      7'h22: tx_data <= tx0_src_mac[15:8];
      7'h23: tx_data <= tx0_src_mac[7:0];
      7'h24: tx_data <= tx0_ipv4_srcip[31:24]; // ARP: Source IP address
      7'h25: tx_data <= tx0_ipv4_srcip[23:16];
      7'h26: tx_data <= tx0_ipv4_srcip[15:8];
      7'h27: tx_data <= tx0_ipv4_srcip[7:0];
      7'h28: tx_data <= 8'h00;     // ARP: Destination MAC
      7'h29: tx_data <= 8'h00;
      7'h2a: tx_data <= 8'h00;
      7'h2b: tx_data <= 8'h00;
      7'h2c: tx_data <= 8'h00;
      7'h2d: tx_data <= 8'h00;
      7'h2e: tx_data <= tx0_ipv4_gwip[31:24];  // ARP: Destination Address
      7'h2f: tx_data <= tx0_ipv4_gwip[23:16];
      7'h30: tx_data <= tx0_ipv4_gwip[15:8];
      7'h31: tx_data <= tx0_ipv4_gwip[7:0];
      7'h44: begin         // FCS (CRC)
        crc_rd  <= 1'b1;
        tx_data <= crc_out[31:24];
      end
      7'h45: tx_data <= crc_out[23:16];
      7'h46: tx_data <= crc_out[15:8];
      7'h47: tx_data <= crc_out[7:0];
      7'h48: begin
        tx_en   <= 1'b0;
        crc_rd  <= 1'b0;
        tx_data <= 8'h0;
`ifndef SIMULATION
        arp_wait_count <= 16'hffff;
`else
        arp_wait_count <= 16'h10;
`endif
        tx_state <= TX_WAIT_ARPREP;
      end
      default: tx_data <= 8'h00;
      endcase
      tx_count <= tx_count + 16'h1;
    end
    TX_WAIT_ARPREP: begin
      tx_count       <= 16'h0;
      arp_wait_count <= arp_wait_count - 16'd1;
`ifdef ECP3VERSA
      if (tx0_ipv6 == 1'b0)
        tx_state <= TX_V4_SEND;
      else
        tx_state <= TX_V6_SEND;
`else
      if (arp_reply == 1'b1) begin
        tx_state <= TX_V4_SEND;
      end else if (arp_wait_count == 16'h0) begin
        if (tx0_ipv6 == 1'b0)
          tx_state <= TX_REQ_ARP;
        else
          tx_state <= TX_V6_SEND;
      end
`endif
    end
    TX_V4_SEND: begin
      case (tx_count)
      16'h00: begin
        if (sec_oneshot == 1'b0)
          pps <= pps + 32'h1;
        tx_data <= 8'h55;
        ip_sum <= 16'h4500 + {4'h0,tx0_ip_len[11:0]} + ipv4_id[15:0] + {ipv4_ttl[7:0],8'h11} + tx0_ipv4_srcip[31:16] + tx0_ipv4_srcip[15:0] + ipv4_dstip[31:16] + ipv4_dstip[15:0];
        if (tx0_enable == 1'b1)
          tx_en <= 1'b1;
      end
      16'h01: tx_data <= 8'h55;                  // preamble
      16'h02: tx_data <= 8'h55;
      16'h03: tx_data <= 8'h55;
      16'h04: begin
        tx_data <= 8'h55;
        ip_sum <= ~(ip_sum[15:0] + ip_sum[23:16]);
      end
      16'h05: tx_data <= 8'h55;
      16'h06: tx_data <= 8'h55;
      16'h07: tx_data <= 8'hd5;                  // preamble + SFD (0b1101_0101)
      16'h08: tx_data <= tx0_dst_mac[47:40];     // Destination MAC
      16'h09: tx_data <= tx0_dst_mac[39:32];
      16'h0a: tx_data <= tx0_dst_mac[31:24];
      16'h0b: tx_data <= tx0_dst_mac[23:16];
      16'h0c: tx_data <= tx0_dst_mac[15:8];
      16'h0d: tx_data <= tx0_dst_mac[7:0];
      16'h0e: tx_data <= tx0_src_mac[47:40];     // Source MAC
      16'h0f: tx_data <= tx0_src_mac[39:32];
      16'h10: tx_data <= tx0_src_mac[31:24];
      16'h11: tx_data <= tx0_src_mac[23:16];
      16'h12: tx_data <= tx0_src_mac[15:8];
      16'h13: tx_data <= tx0_src_mac[7:0];
      16'h14: tx_data <= 8'h08;                  // Protocol type: IPv4
      16'h15: tx_data <= 8'h00;
      16'h16: tx_data <= 8'h45;                  // IPv4: Version, Header length, ToS
      16'h17: tx_data <= 8'h00;
      16'h18: tx_data <= {4'h0,tx0_ip_len[11:8]};// IPv4: Total length (not fixed)
      16'h19: tx_data <= tx0_ip_len[7:0];
      16'h1a: tx_data <= ipv4_id[15:8];          // IPv4: Identification
      16'h1b: tx_data <= ipv4_id[7:0];
      16'h1c: tx_data <= 8'h00;                  // IPv4: Flag, Fragment offset
      16'h1d: tx_data <= 8'h00;
      16'h1e: tx_data <= ipv4_ttl[7:0];          // IPv4: TTL
      16'h1f: tx_data <= 8'h11;                  // IPv4: Protocol (testing: fake UDP)
      16'h20: tx_data <= ip_sum[15:8];                  // IPv4: Checksum (not fixed)
      16'h21: tx_data <= ip_sum[7:0];
      16'h22: tx_data <= tx0_ipv4_srcip[31:24];  // IPv4: Source Address
      16'h23: tx_data <= tx0_ipv4_srcip[23:16];
      16'h24: tx_data <= tx0_ipv4_srcip[15:8];
      16'h25: tx_data <= tx0_ipv4_srcip[7:0];
      16'h26: tx_data <= ipv4_dstip[31:24];      // IPv4: Destination Address
      16'h27: tx_data <= ipv4_dstip[23:16];
      16'h28: tx_data <= ipv4_dstip[15:8];
      16'h29: tx_data <= ipv4_dstip[7:0];
      16'h2a: tx_data <= 8'h0d;                  // Src  Port=3422 (USB over IP)
      16'h2b: tx_data <= 8'h5e;
      16'h2c: tx_data <= 8'h0d;                  // Dst  Port,
      16'h2d: tx_data <= 8'h5e;
      16'h2e: tx_data <= {4'h0,tx0_udp_len[11:8]}; // UDP Length(udp header(0c)+data length)
      16'h2f: tx_data <= tx0_udp_len[7:0];
      16'h30: tx_data <= 8'h00;                  // Check Sum
      16'h31: tx_data <= 8'h00;
      16'h32: tx_data <= magic_code[39:32];      // Data: Magic code (40 bit: 0xCC00CC00CC)
      16'h33: tx_data <= magic_code[31:24];
      16'h34: tx_data <= magic_code[23:16];
      16'h35: tx_data <= magic_code[15:8];
      16'h36: tx_data <= magic_code[7:0];
      16'h37: begin
        tx_data           <= global_counter[31:24];         // Data: Counter (32 bit) (not fixed)
        tmp_counter[23:0] <= global_counter[23:0];
      end
      16'h38: tx_data <= tmp_counter[23:16];
      16'h39: tx_data <= tmp_counter[15:8];
      16'h3a: tx_data <= tmp_counter[7:0];
      {2'b0, frame_crc1_count}: begin                              // FCS (CRC)
        crc_rd  <= 1'b1;
        tx_data <= crc_out[31:24];
      end
      frame_crc2_count: tx_data <= crc_out[23:16];
      frame_crc3_count: tx_data <= crc_out[15:8];
      frame_crc4_count: tx_data <= crc_out[7:0];
      frame_end_count : begin
        tx_en   <= 1'b0;
        crc_rd  <= 1'b0;
        tx_data <= 8'h0;
        ipv4_id <= ipv4_id + 16'b1;
        full_ipv4 <= full_ipv4 + 24'h1;
        if (tx0_inter_frame_gap >= 32'd2)
          gap_count<= tx0_inter_frame_gap - 32'd2;   // Inter Frame Gap = 12 (offset value -2)
        else
          gap_count<= 32'd2;   // Inter Frame Gap = 14 (offset value -2)
        tx_state <= TX_GAP;
        if (sec_oneshot == 1'b0)
          throughput <= throughput + {16'h0, tx_count} - 32'h8;
      end
      default: tx_data <= 8'h00;
      endcase
      tx_count <= tx_count + 16'h1;
    end
    TX_V6_SEND: begin
      case (tx_count)
      16'h00: begin
        if (sec_oneshot == 1'b0)
          pps <= pps + 32'h1;
        tx_data <= 8'h55;
        ip_sum <= 16'h4500 + {4'h0,tx0_ip_len[11:0]} + ipv4_id[15:0] + {ipv4_ttl[7:0],8'h11} + tx0_ipv4_srcip[31:16] + tx0_ipv4_srcip[15:0] + ipv4_dstip[31:16] + ipv4_dstip[15:0];
        if (tx0_enable == 1'b1)
          tx_en <= 1'b1;
      end
      16'h01: tx_data <= 8'h55;                  // preamble
      16'h02: tx_data <= 8'h55;
      16'h03: tx_data <= 8'h55;
      16'h04: begin
        tx_data <= 8'h55;
        ip_sum <= ~(ip_sum[15:0] + ip_sum[23:16]);
      end
      16'h05: tx_data <= 8'h55;
      16'h06: tx_data <= 8'h55;
      16'h07: tx_data <= 8'hd5;                  // preamble + SFD (0b1101_0101)
      16'h08: tx_data <= tx0_dst_mac[47:40];     // Destination MAC
      16'h09: tx_data <= tx0_dst_mac[39:32];
      16'h0a: tx_data <= tx0_dst_mac[31:24];
      16'h0b: tx_data <= tx0_dst_mac[23:16];
      16'h0c: tx_data <= tx0_dst_mac[15:8];
      16'h0d: tx_data <= tx0_dst_mac[7:0];
      16'h0e: tx_data <= tx0_src_mac[47:40];     // Source MAC
      16'h0f: tx_data <= tx0_src_mac[39:32];
      16'h10: tx_data <= tx0_src_mac[31:24];
      16'h11: tx_data <= tx0_src_mac[23:16];
      16'h12: tx_data <= tx0_src_mac[15:8];
      16'h13: tx_data <= tx0_src_mac[7:0];
      16'h14: tx_data <= 8'h86;                  // Protocol type: IPv6 (0x86dd)
      16'h15: tx_data <= 8'hdd;
      16'h16: tx_data <= 8'h60;                  // Version:6 Traffic class: 0x0000
      16'h17: tx_data <= 8'h00;
      16'h18: tx_data <= 8'h00;
      16'h19: tx_data <= 8'h00;
      16'h1a: tx_data <= 8'h00;                  // IPv6: Payload length: 22
      16'h1b: tx_data <= 8'h16;
      16'h1c: tx_data <= 8'h11;                  // Next header: UDP (0x11)
      16'h1d: tx_data <= 8'h40;       // Hop limit: 64
      16'h1e: tx_data <= tx0_ipv6_srcip[127:120];// IPv6: Source IP
      16'h1f: tx_data <= tx0_ipv6_srcip[119:112];
      16'h20: tx_data <= tx0_ipv6_srcip[111:104];
      16'h21: tx_data <= tx0_ipv6_srcip[103: 96];
      16'h22: tx_data <= tx0_ipv6_srcip[ 95: 88];
      16'h23: tx_data <= tx0_ipv6_srcip[ 87: 80];
      16'h24: tx_data <= tx0_ipv6_srcip[ 79: 72];
      16'h25: tx_data <= tx0_ipv6_srcip[ 71: 64];
      16'h26: tx_data <= tx0_ipv6_srcip[ 63: 56];
      16'h27: tx_data <= tx0_ipv6_srcip[ 55: 48];
      16'h28: tx_data <= tx0_ipv6_srcip[ 47: 40];
      16'h29: tx_data <= tx0_ipv6_srcip[ 39: 32];
      16'h2a: tx_data <= tx0_ipv6_srcip[ 31: 24];
      16'h2b: tx_data <= tx0_ipv6_srcip[ 23: 16];
      16'h2c: tx_data <= tx0_ipv6_srcip[ 15:  8];
      16'h2d: tx_data <= tx0_ipv6_srcip[  7:  0];
      16'h2e: tx_data <= tx0_ipv6_dstip[127:120];// IPv6: Destination IP
      16'h2f: tx_data <= tx0_ipv6_dstip[119:112];
      16'h30: tx_data <= tx0_ipv6_dstip[111:104];
      16'h31: tx_data <= tx0_ipv6_dstip[103: 96];
      16'h32: tx_data <= tx0_ipv6_dstip[ 95: 88];
      16'h33: tx_data <= tx0_ipv6_dstip[ 87: 80];
      16'h34: tx_data <= tx0_ipv6_dstip[ 79: 72];
      16'h35: tx_data <= tx0_ipv6_dstip[ 71: 64];
      16'h36: tx_data <= tx0_ipv6_dstip[ 63: 56];
      16'h37: tx_data <= tx0_ipv6_dstip[ 55: 48];
      16'h38: tx_data <= tx0_ipv6_dstip[ 47: 40];
      16'h39: tx_data <= tx0_ipv6_dstip[ 39: 32];
      16'h3a: tx_data <= tx0_ipv6_dstip[ 31: 24];
      16'h3b: tx_data <= tx0_ipv6_dstip[ 23: 16];
      16'h3c: tx_data <= tx0_ipv6_dstip[ 15:  8];
      16'h3d: tx_data <= tx0_ipv6_dstip[  7:  0];
      16'h3e: tx_data <= 8'hdb;       // Source port: 56173
      16'h3f: tx_data <= 8'h6d;
      16'h40: tx_data <= 8'h0d;       // Dest   port: rusb-sys-port(3422)
      16'h41: tx_data <= 8'h5e;
      16'h42: tx_data <= 8'h00;       // UDP Length: 22 (0x0016)
      16'h43: tx_data <= 8'h16;
      16'h44: tx_data <= 8'h00;       // UDP Checksum
      16'h45: tx_data <= 8'h00;
      16'h46: tx_data <= magic_code[39:32];      // Data: Magic code (40 bit: 0xCC00CC00CC)
      16'h47: tx_data <= magic_code[31:24];
      16'h48: tx_data <= magic_code[23:16];
      16'h49: tx_data <= magic_code[15:8];
      16'h4a: tx_data <= magic_code[7:0];
      16'h4b: begin
        tx_data           <= global_counter[31:24];         // Data: Counter (32 bit) (not fixed)
        tmp_counter[23:0] <= global_counter[23:0];
      end
      16'h4c: tx_data <= tmp_counter[23:16];
      16'h4d: tx_data <= tmp_counter[15:8];
      14'h4e: tx_data <= tmp_counter[7:0];
      frame_crc1_count: begin                              // FCS (CRC)
        crc_rd  <= 1'b1;
        tx_data <= crc_out[31:24];
      end
      frame_crc2_count: tx_data <= crc_out[23:16];
      frame_crc3_count: tx_data <= crc_out[15:8];
      frame_crc4_count: tx_data <= crc_out[7:0];
      frame_end_count : begin
        tx_en   <= 1'b0;
        crc_rd  <= 1'b0;
        tx_data <= 8'h0;
        if (tx0_inter_frame_gap >= 32'd2)
          gap_count<= tx0_inter_frame_gap - 32'd2;   // Inter Frame Gap = 12 (offset value -2)
        else
          gap_count<= 32'd2;   // Inter Frame Gap = 14 (offset value -2)
        tx_state <= TX_GAP;
        if (sec_oneshot == 1'b0)
          throughput <= throughput + {16'h0, tx_count} - 32'h8;
      end
      default: tx_data <= 8'h00;
      endcase
      tx_count <= tx_count + 16'h1;
    end
    TX_GAP: begin
      gap_count <= gap_count - 32'h1;
      tx_count  <= 16'h0;
      if (gap_count == 32'h0) begin
        if (tx0_ipv6 == 1'b0) begin
`ifdef ECP3VERSA
            tx_state <= TX_V4_SEND;
`else
          if (tx0_dst_mac != 48'h0)
            tx_state <= TX_V4_SEND;
          else
            tx_state <= TX_REQ_ARP;
`endif
        end else begin
          tx_state <= TX_V6_SEND;
        end
      end
    end
    endcase
  end
end

assign tx0_ipv4_ip  = ipv4_dstip;
assign gmii_0_txd   = tx_data;
assign gmii_0_tx_en = tx_en;

//-----------------------------------
// RX#1 Recive port logic
//-----------------------------------
measure_core # (
  .Int_ipv4_addr({8'd10, 8'd0, 8'd21, 8'd105}),
  .Int_ipv6_addr(128'h3776_0000_0000_0021_0000_0000_0000_0105),
  .Int_mac_addr(48'h003776_000101)
) measure_phy1 (
  .sys_rst(sys_rst),
  .sys_clk(gmii_0_tx_clk),
  .pci_clk(pci_clk),
  .sec_oneshot(sec_oneshot),
  .global_counter(global_counter),

  .gmii_txd(gmii_1_txd),
  .gmii_tx_en(gmii_1_tx_en),
  .gmii_tx_clk(gmii_1_tx_clk),
  .gmii_rxd(gmii_1_rxd),
  .gmii_rx_dv(gmii_1_rx_dv),
  .gmii_rx_clk(gmii_1_rx_clk),

  .rx_pps(rx1_pps),
  .rx_throughput(rx1_throughput),
  .rx_latency(rx1_latency),
  .rx_ipv4_ip(rx1_ipv4_ip),
  .tx_ipv6(tx_ipv6)
);

`ifdef ENABE_RGMII2
//-----------------------------------
// RX#2 Recive port logic
//-----------------------------------
measure_core # (
  .Int_ipv4_addr({8'd10, 8'd0, 8'd22, 8'd105}),
  .Int_ipv6_addr(128'h3776_0000_0000_0022_0000_0000_0000_0105),
  .Int_mac_addr(48'h003776_000102)
) measure_phy2 (
  .sys_rst(sys_rst),
  .sys_clk(gmii_0_tx_clk),
  .pci_clk(pci_clk),
  .sec_oneshot(sec_oneshot),
  .global_counter(global_counter),

  .gmii_txd(gmii_2_txd),
  .gmii_tx_en(gmii_2_tx_en),
  .gmii_tx_clk(gmii_2_tx_clk),
  .gmii_rxd(gmii_2_rxd),
  .gmii_rx_dv(gmii_2_rx_dv),
  .gmii_rx_clk(gmii_2_rx_clk),

  .rx_pps(rx2_pps),
  .rx_throughput(rx2_throughput),
  .rx_latency(rx2_latency),
  .rx_ipv4_ip(rx2_ipv4_ip),
  .tx_ipv6(tx_ipv6)
);
`endif

`ifdef ENABE_RGMII3
//-----------------------------------
// RX#3 Recive port logic
//-----------------------------------
measure_core # (
  .Int_ipv4_addr({8'd10, 8'd0, 8'd23, 8'd105}),
  .Int_ipv6_addr(128'h3776_0000_0000_0023_0000_0000_0000_0105),
  .Int_mac_addr(48'h003776_000103)
) measure_phy3 (
  .sys_rst(sys_rst),
  .sys_clk(gmii_0_tx_clk),
  .pci_clk(pci_clk),
  .sec_oneshot(sec_oneshot),
  .global_counter(global_counter),

  .gmii_txd(gmii_3_txd),
  .gmii_tx_en(gmii_3_tx_en),
  .gmii_tx_clk(gmii_3_tx_clk),
  .gmii_rxd(gmii_3_rxd),
  .gmii_rx_dv(gmii_3_rx_dv),
  .gmii_rx_clk(gmii_3_rx_clk),

  .rx_pps(rx3_pps),
  .rx_throughput(rx3_throughput),
  .rx_latency(rx3_latency),
  .rx_ipv4_ip(rx3_ipv4_ip),
  .tx_ipv6(tx_ipv6)
);
`endif

endmodule
