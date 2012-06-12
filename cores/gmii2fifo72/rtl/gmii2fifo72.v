module gmii2fifo72 # (
	parameter Gap = 4'h2
) (
	input         sys_rst,
	input         gmii_rx_clk,
	input         gmii_rx_dv,
	input  [7:0]  gmii_rxd,
	// FIFO
	output [71:0] din,
	input         full,
        output reg    wr_en,
	output        wr_clk
);

assign wr_clk = gmii_rx_clk;

//-----------------------------------
// logic
//-----------------------------------
reg [2:0] count = 3'h0;
reg [63:0] rxd = 64'h00;
reg [7:0] rxc = 8'h0;
reg [3:0] gap_count = 4'h0;
always @(posedge gmii_rx_clk) begin
	if (sys_rst) begin
		count <= 3'h0;
		gap_count <= 4'h0;
	end else begin
                wr_en <= 1'b0;
		if (gmii_rx_dv == 1'b1) begin
			count <= count + 3'h1;
			gap_count <= Gap;
			case (count)
				3'h0: begin
					rxd[63: 0] <= {56'h0, gmii_rxd[7:0]};
					rxc[7:0]   <= 8'b00000001;
				end
				3'h1: begin
					rxd[15: 8] <= gmii_rxd[7:0];
					rxc[1]     <= 1'b1;
				end
				3'h2: begin
					rxd[23:16] <= gmii_rxd[7:0];
					rxc[2]     <= 1'b1;
				end
				3'h3: begin
					rxd[31:24] <= gmii_rxd[7:0];
					rxc[3]     <= 1'b1;
				end
				3'h4: begin
					rxd[39:32] <= gmii_rxd[7:0];
					rxc[4]     <= 1'b1;
				end
				3'h5: begin
					rxd[47:40] <= gmii_rxd[7:0];
					rxc[5]     <= 1'b1;
				end
				3'h6: begin
					rxd[55:48] <= gmii_rxd[7:0];
					rxc[6]     <= 1'b1;
				end
				3'h7: begin
					rxd[63:56] <= gmii_rxd[7:0];
					rxc[7]     <= 1'b1;
                			wr_en <= 1'b1;
				end
			endcase
		end else begin
			if (count != 3'h0) begin
                		wr_en <= 1'b1;
				count <= 3'h0;
			end else if (gap_count != 4'h0) begin
				rxd[63: 0] <= 64'h0;
				rxc[7:0]   <= 8'h0;
                		wr_en <= 1'b1;
				gap_count <= gap_count - 4'h1;
			end
		end
	end
end

assign din[71:0] = {rxc[7:0], rxd[63:0]};

endmodule
