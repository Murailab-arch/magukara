`include "../rtl/setup.v"

module measure_core # (
  parameter     Int_ipv4_addr  = {8'd10, 8'd0, 8'd21, 8'd105},
                Int_ipv6_addr  = 128'h3776_0000_0000_0021_0000_0000_0000_0105,
                Int_mac_addr = 48'h003776_000101
) (
  input         sys_rst,
  input         sys_clk,
  input         pci_clk,
  input         sec_oneshot,
  input [31:0]  global_counter,

  // GMII interfaces for 4 MACs
  output [7:0]  gmii_txd,
  output        gmii_tx_en,
  input         gmii_tx_clk,
  input  [7:0]  gmii_rxd,
  input         gmii_rx_dv,
  input         gmii_rx_clk,

  // PCI user registers
  output reg [31:0] rx_pps,
  output reg [31:0] rx_throughput,
  output reg [23:0] rx_latency,
  output reg [31:0] rx_ipv4_ip,

  // mode
  input          tx_ipv6
);

reg [31:0] rx_pps1, rx_pps2;
reg [31:0] rx_throughput1, rx_throughput2;
reg [23:0] rx_latency1, rx_latency2;
reg [31:0] rx_ipv4_ip1, rx_ipv4_ip2;

always @(posedge pci_clk) begin
  rx_pps2 <= rx_pps1;
  rx_throughput2 <= rx_throughput1;
  rx_latency2 <= rx_latency1;
  rx_ipv4_ip2 <= rx_ipv4_ip1;
  rx_pps <= rx_pps2;
  rx_throughput <= rx_throughput2;
  rx_latency <= rx_latency2;
  rx_ipv4_ip <= rx_ipv4_ip2;
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
        .wr_clk(gmii_rx_clk),

        .dout(rxq_dout),
        .empty(rxq_empty),
        .rd_en(rxq_rd_en),
        .rd_clk(gmii_tx_clk),

        .rst(sys_rst)
);
`endif
`ifdef ECP3VERSA
asfifo9_4 rxq (
        .Data(rxq_din),
        .Full(rxq_full),
        .WrEn(rxq_wr_en),
        .WrClock(gmii_rx_clk),

        .Q(rxq_dout),
        .Empty(rxq_empty),
        .RdEn(rxq_rd_en),
        .RdClock(gmii_tx_clk),

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
        .wr_clk(gmii_rx_clk),

        .dout(rxq_dout),
        .empty(rxq_empty),
        .rd_en(rxq_rd_en),
        .rd_clk(gmii_tx_clk),

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

        .gmii_rx_clk(gmii_rx_clk),
        .gmii_rx_dv(gmii_rx_dv),
        .gmii_rxd(gmii_rxd),

        .din(rxq_din),
        .full(rxq_full),
        .wr_en(rxq_wr_en),
        .wr_clk()
);

//-----------------------------------
// Recive logic
//-----------------------------------
reg [15:0] rx_count = 0;
reg [39:0] rx_magic;
reg [31:0] counter_start;
reg [31:0] counter_end;
reg [31:0] pps;
reg [31:0] throughput;
reg [15:0] rx_type;         // frame type
reg  [47:0] rx_src_mac;
reg  [31:0] rx_ipv4_srcip;
reg  [15:0] rx_opcode;
reg  [ 7:0] v6type;
reg arp_request;
reg neighbor_replay;
reg  [47:0] tx_dst_mac;
reg  [31:0] tx_ipv4_dstip;
reg  [31:0] rx_arp_dst;

wire [7:0] rx_data = rxq_dout[7:0];

always @(posedge gmii_tx_clk) begin
  if (sys_rst) begin
    rx_count    <= 16'h0;
    rx_magic    <= 40'b0;
    counter_start     <= 32'h0;
    counter_end       <= 32'h0;
    pps <= 32'h0;
    throughput <= 32'h0;
    rx_pps1 <= 32'h0;
    rx_throughput1 <= 32'h0;
    rx_ipv4_ip1 <= 32'h0;
    rx_type <= 16'h0;
    rx_opcode <= 16'h0;
    rx_src_mac <= 48'h0;
    rx_ipv4_srcip <= 32'h0;
    v6type <= 8'h0;
    arp_request <= 1'b0;
    neighbor_replay <= 1'b0;
    tx_dst_mac <= 48'h0;
    tx_ipv4_dstip <= 32'h0;
    rx_arp_dst <= 32'h0;
  end else begin
    rxq_rd_en <= ~rxq_empty;
    if (sec_oneshot == 1'b1) begin
      rx_pps1 <= pps;
      rx_throughput1 <= throughput;
      pps <= 32'h0;
      throughput <= 32'h0;
    end
    if (rxq_rd_en == 1'b1) begin
      rx_count <= rx_count + 16'h1;
      if (rxq_dout[8] == 1'b1) begin
        case (rx_count)
        16'h00: if (sec_oneshot == 1'b0)
            pps <= pps + 32'h1;
        16'h06: rx_src_mac[47:40] <= rx_data;// Ethernet hdr: Source MAC
        16'h07: rx_src_mac[39:32] <= rx_data;
        16'h08: rx_src_mac[31:24] <= rx_data;
        16'h09: rx_src_mac[23:16] <= rx_data;
        16'h0a: rx_src_mac[15: 8] <= rx_data;
        16'h0b: rx_src_mac[ 7: 0] <= rx_data;
        16'h0c: rx_type[15:8] <= rx_data;    // Type: IP=0800,ARP=0806
        16'h0d: rx_type[ 7:0] <= rx_data;
        16'h14: rx_opcode[15:8] <= rx_data;  // ARP: Operation (ARP reply: 0x0002)
        16'h15: rx_opcode[ 7:0] <= rx_data;  // Opcode ARP Request=1
        16'h1c: rx_ipv4_srcip[31:24] <= rx_data;  // ARP: Source IP address
        16'h1d: rx_ipv4_srcip[23:16] <= rx_data;
        16'h1e: begin
          rx_ipv4_srcip[15: 8] <= rx_data;
          rx_ipv4_ip1[31:24]   <= rx_data;
        end
        16'h1f: begin
          rx_ipv4_srcip[ 7: 0] <= rx_data;
          rx_ipv4_ip1[23:16] <= rx_data;
        end
        16'h20: rx_ipv4_ip1[15: 8] <= rx_data;
        16'h21: rx_ipv4_ip1[ 7: 0] <= rx_data;
        16'h26: rx_arp_dst[31:24]  <= rx_data; // target IP for ARP
        16'h27: rx_arp_dst[23:16]  <= rx_data;
        16'h28: rx_arp_dst[15: 8]  <= rx_data;
        16'h29: rx_arp_dst[ 7: 0]  <= rx_data;
        16'h2a: rx_magic[39:32] <= rx_data;
        16'h2b: rx_magic[31:24] <= rx_data;
        16'h2c: rx_magic[23:16] <= rx_data;
        16'h2d: rx_magic[15:8]  <= rx_data;
        16'h2e: rx_magic[7:0]   <= rx_data;
        16'h2f: counter_start[31:24] <= rx_data;
        16'h30: counter_start[23:16] <= rx_data;
        16'h31: counter_start[15:8]  <= rx_data;
        16'h32: counter_start[7:0]   <= rx_data;
        16'h33: begin
          if (rx_magic[39:0] == `MAGIC_CODE) begin
            rx_latency1   <= global_counter - counter_start;
          end else if (rx_type == 16'h0806 && rx_opcode == 16'h1 && rx_arp_dst == Int_ipv4_addr) begin  // rx_magic[39:8] is Target IP Addres (ARP)
            tx_dst_mac    <= rx_src_mac;
            tx_ipv4_dstip <= rx_ipv4_srcip;
            arp_request <= 1'b1;
          end
        end
        16'h36: v6type            <= rx_data;
        16'h3e: rx_magic[39:32] <= rx_data;
        16'h3f: rx_magic[31:24] <= rx_data;
        16'h40: rx_magic[23:16] <= rx_data;
        16'h41: rx_magic[15:8]  <= rx_data;
        16'h42: rx_magic[7:0]   <= rx_data;
        16'h43: counter_start[31:24] <= rx_data;
        16'h44: counter_start[23:16] <= rx_data;
        16'h45: counter_start[15:8]  <= rx_data;
        16'h46: counter_start[7:0]   <= rx_data;
        16'h47: begin
          if (rx_magic[39:0] == `MAGIC_CODE) begin
            rx_latency1 <= global_counter - counter_start;
          end
        end
        // frame type=IPv6(0x86dd) && Next Header=ICMPv6(0x3a) && Type=Router Advertisement(134)
        16'h48:  if (rx_type == 16'h86dd && rx_opcode[15:8] == 8'h3a && v6type == 8'h86) begin
            tx_dst_mac <= rx_src_mac;
            neighbor_replay <= 1'b1;
          end
        endcase
      end else begin
        arp_request <= 1'b0;
        neighbor_replay <= 1'b0;
        if (rx_count != 16'h0 && sec_oneshot == 1'b0) begin
          throughput <= throughput + {16'h0, rx_count};
        end
        rx_count <= 16'h0;
      end
    end
  end
end

//-----------------------------------
// ARP/ICMPv6 CRC
//-----------------------------------
reg [6:0] arp_count;
reg [6:0] neighbor_count;
reg [7:0] tx_data;
assign arp_crc_init = (arp_count == 7'h08) || (neighbor_count == 7'h08);
wire [31:0] arp_crc_out;
reg arp_crc_rd;
assign arp_crc_data_en = ~arp_crc_rd;
crc_gen arp_crc_inst (
  .Reset(sys_rst),
  .Clk(gmii_tx_clk),
  .Init(arp_crc_init),
  .Frame_data(tx_data),
  .Data_en(arp_crc_data_en),
  .CRC_rd(arp_crc_rd),
  .CRC_end(),
  .CRC_out(arp_crc_out)
);

//-----------------------------------
// ARP/ICMPv6 logic
//-----------------------------------
wire [47:0] tx_src_mac    = Int_mac_addr;
wire [31:0] tx_ipv4_srcip = Int_ipv4_addr;
wire [127:0] tx_ipv6_srcip = Int_ipv6_addr;
reg tx_en;
reg [1:0] arp_state;
parameter ARP_IDLE = 2'h0;
parameter ARP_SEND = 2'h1;
parameter NEIGHBOR_SEND = 2'h2;

always @(posedge gmii_tx_clk) begin
  if (sys_rst) begin
    tx_data <= 8'h00;
    tx_en  <= 1'b0;
    arp_crc_rd  <= 1'b0;
    arp_count <= 7'h0;
    neighbor_count <= 7'h0;
    arp_state <= ARP_IDLE;
  end else begin
    case (arp_state)
    ARP_IDLE: begin
      if (tx_ipv6 == 1'b0 && arp_request == 1'b1) begin
        arp_count <= 7'h0;
        arp_state <= ARP_SEND;
      end else if (tx_ipv6 == 1'b1 && sec_oneshot == 1'b1) begin
        neighbor_count <= 7'h0;
        arp_state <= NEIGHBOR_SEND;
      end
    end
    ARP_SEND: begin
      case (arp_count)
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
      7'h08: tx_data <= tx_dst_mac[47:40];   // Ethernet hdr: Destination MAC
      7'h09: tx_data <= tx_dst_mac[39:32];
      7'h0a: tx_data <= tx_dst_mac[31:24];
      7'h0b: tx_data <= tx_dst_mac[23:16];
      7'h0c: tx_data <= tx_dst_mac[15:8];
      7'h0d: tx_data <= tx_dst_mac[7:0];
      7'h0e: tx_data <= tx_src_mac[47:40];   // Ethernet hdr: Source MAC
      7'h0f: tx_data <= tx_src_mac[39:32];
      7'h10: tx_data <= tx_src_mac[31:24];
      7'h11: tx_data <= tx_src_mac[23:16];
      7'h12: tx_data <= tx_src_mac[15:8];
      7'h13: tx_data <= tx_src_mac[7:0];
      7'h14: tx_data <= 8'h08;     // Ethernet hdr: Protocol type: ARP
      7'h15: tx_data <= 8'h06;
      7'h16: tx_data <= 8'h00;     // ARP: Hardware type: Ethernet (1)
      7'h17: tx_data <= 8'h01;
      7'h18: tx_data <= 8'h08;     // ARP: Protocol type: IPv4 (0x0800)
      7'h19: tx_data <= 8'h00;
      7'h1a: tx_data <= 8'h06;     // ARP: MAC length
      7'h1b: tx_data <= 8'h04;     // ARP: IP address length
      7'h1c: tx_data <= 8'h00;     // ARP: Operation (ARP reply: 0x0002)
      7'h1d: tx_data <= 8'h02;
      7'h1e: tx_data <= tx_src_mac[47:40];   // ARP: Source MAC
      7'h1f: tx_data <= tx_src_mac[39:32];
      7'h20: tx_data <= tx_src_mac[31:24];
      7'h21: tx_data <= tx_src_mac[23:16];
      7'h22: tx_data <= tx_src_mac[15:8];
      7'h23: tx_data <= tx_src_mac[7:0];
      7'h24: tx_data <= tx_ipv4_srcip[31:24];  // ARP: Source IP address
      7'h25: tx_data <= tx_ipv4_srcip[23:16];
      7'h26: tx_data <= tx_ipv4_srcip[15:8];
      7'h27: tx_data <= tx_ipv4_srcip[7:0];
      7'h28: tx_data <= tx_dst_mac[47:40];   // ARP: Destination MAC
      7'h29: tx_data <= tx_dst_mac[39:32];
      7'h2a: tx_data <= tx_dst_mac[31:24];
      7'h2b: tx_data <= tx_dst_mac[23:16];
      7'h2c: tx_data <= tx_dst_mac[15:8];
      7'h2d: tx_data <= tx_dst_mac[7:0];
      7'h2e: tx_data <= tx_ipv4_dstip[31:24];  // ARP: Destination Address
      7'h2f: tx_data <= tx_ipv4_dstip[23:16];
      7'h30: tx_data <= tx_ipv4_dstip[15:8];
      7'h31: tx_data <= tx_ipv4_dstip[7:0];
      7'h32: tx_data <= 8'h00;     // Padding (frame size = 64 byte)
      7'h33: tx_data <= 8'h00;
      7'h34: tx_data <= 8'h00;
      7'h35: tx_data <= 8'h00;
      7'h36: tx_data <= 8'h00;
      7'h37: tx_data <= 8'h00;
      7'h38: tx_data <= 8'h00;
      7'h39: tx_data <= 8'h00;
      7'h3a: tx_data <= 8'h00;
      7'h3b: tx_data <= 8'h00;
      7'h3c: tx_data <= 8'h00;
      7'h3d: tx_data <= 8'h00;
      7'h3e: tx_data <= 8'h00;
      7'h3f: tx_data <= 8'h00;
      7'h40: tx_data <= 8'h00;
      7'h41: tx_data <= 8'h00;
      7'h42: tx_data <= 8'h00;
      7'h43: tx_data <= 8'h00;
      7'h44: begin         // FCS (CRC)
        arp_crc_rd  <= 1'b1;
        tx_data <= arp_crc_out[31:24];
      end
      7'h45: tx_data <= arp_crc_out[23:16];
      7'h46: tx_data <= arp_crc_out[15:8];
      7'h47: tx_data <= arp_crc_out[7:0];
      7'h48: begin
        tx_en   <= 1'b0;
        arp_crc_rd  <= 1'b0;
        tx_data <= 8'h0;
        arp_state <= ARP_IDLE;
      end
      default: tx_data <= 8'h00;
      endcase
      arp_count <= arp_count + 7'h1;
    end
    NEIGHBOR_SEND: begin
      case (neighbor_count)
      7'h00: begin
        tx_data <= 8'h55;
        tx_en <= 1'b1;
      end
      7'h01: tx_data <= 8'h55;    // preamble
      7'h02: tx_data <= 8'h55;
      7'h03: tx_data <= 8'h55;
      7'h04: tx_data <= 8'h55;
      7'h05: tx_data <= 8'h55;
      7'h06: tx_data <= 8'h55;
      7'h07: tx_data <= 8'hd5;    // preamble + SFD (0b1101_0101)
      7'h08: tx_data <= 8'hff;  // Ethernet hdr: Destination MAC
      7'h09: tx_data <= 8'hff;
      7'h0a: tx_data <= 8'hff;
      7'h0b: tx_data <= 8'hff;
      7'h0c: tx_data <= 8'hff;
      7'h0d: tx_data <= 8'hff;
      7'h0e: tx_data <= tx_src_mac[47:40];  // Ethernet hdr: Source MAC
      7'h0f: tx_data <= tx_src_mac[39:32];
      7'h10: tx_data <= tx_src_mac[31:24];
      7'h11: tx_data <= tx_src_mac[23:16];
      7'h12: tx_data <= tx_src_mac[15:8];
      7'h13: tx_data <= tx_src_mac[7:0];
      7'h14: tx_data <= 8'h86;    // Ethernet hdr: Protocol type:IPv6
      7'h15: tx_data <= 8'hdd;
      7'h16: tx_data <= 8'h60;    // Version:6 Flowlabel: 0x00000
      7'h17: tx_data <= 8'h00;
      7'h18: tx_data <= 8'h00;
      7'h19: tx_data <= 8'h00;
      7'h1a: tx_data <= 8'h00;    // Payload Length: 8
      7'h1b: tx_data <= 8'h08;
      7'h1c: tx_data <= 8'h3a;    // Next header: ICMPv6 (0x3a)
      7'h1d: tx_data <= 8'hff;    // Hop limit: 255
      7'h1e: tx_data <= 8'hfe;                // Source IPv6
      7'h1f: tx_data <= 8'h80;
      7'h20: tx_data <= 8'h00;
      7'h21: tx_data <= 8'h00;
      7'h22: tx_data <= 8'h00;
      7'h23: tx_data <= 8'h00;
      7'h24: tx_data <= 8'h00;
      7'h25: tx_data <= 8'h00;
      7'h26: tx_data <= 8'h00;
      7'h27: tx_data <= 8'h00;
      7'h28: tx_data <= tx_src_mac[ 47: 40];
      7'h29: tx_data <= tx_src_mac[ 39: 32];
      7'h2a: tx_data <= tx_src_mac[ 31: 24];
      7'h2b: tx_data <= tx_src_mac[ 23: 16];
      7'h2c: tx_data <= tx_src_mac[ 15:  8];
      7'h2d: tx_data <= tx_src_mac[  7:  0];
      7'h2e: tx_data <= 8'hff;                // dest IPv6 (All routers address: ff02::2)
      7'h2f: tx_data <= 8'h02;
      7'h30: tx_data <= 8'h00;
      7'h31: tx_data <= 8'h00;
      7'h32: tx_data <= 8'h00;
      7'h33: tx_data <= 8'h00;
      7'h34: tx_data <= 8'h00;
      7'h35: tx_data <= 8'h00;
      7'h36: tx_data <= 8'h00;
      7'h37: tx_data <= 8'h00;
      7'h38: tx_data <= 8'h00;
      7'h39: tx_data <= 8'h00;
      7'h3a: tx_data <= 8'h00;
      7'h3b: tx_data <= 8'h00;
      7'h3c: tx_data <= 8'h00;
      7'h3d: tx_data <= 8'h02;
      7'h3e: tx_data <= 8'h85;    // Type: Router Solicitation (type: 133)
      7'h3f: tx_data <= 8'h00;    // Code: 0
      7'h40: tx_data <= 8'h00;    // Checksum
      7'h41: tx_data <= 8'h00;
      7'h42: tx_data <= 8'h00;    // Reserved
      7'h43: tx_data <= 8'h00;
      7'h44: tx_data <= 8'h00;
      7'h45: tx_data <= 8'h00;
      7'h46: begin         // FCS (CRC)
        arp_crc_rd  <= 1'b1;
        tx_data <= arp_crc_out[31:24];
      end
      7'h47: tx_data <= arp_crc_out[23:16];
      7'h48: tx_data <= arp_crc_out[15:8];
      7'h49: tx_data <= arp_crc_out[7:0];
      7'h4a: begin
        tx_en   <= 1'b0;
        arp_crc_rd  <= 1'b0;
        tx_data <= 8'h0;
        arp_state <= ARP_IDLE;
      end
      default: tx_data <= 8'h00;
      endcase
      neighbor_count <= neighbor_count + 7'h1;
    end
    endcase
  end
end

assign gmii_txd = tx_data;
assign gmii_tx_en = tx_en;

endmodule
