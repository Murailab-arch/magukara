module fifo72togmii (
	// FIFO
	input         sys_rst,
	input [71:0]  dout,
	input         empty,
	output reg    rd_en,
	output        rd_clk,
	// GMII
	input         gmii_tx_clk,
	output        gmii_tx_en,
	output [7:0]  gmii_txd
);

assign rd_clk = gmii_tx_clk;

//-----------------------------------
// logic
//-----------------------------------
reg [2:0] count = 3'h0;
reg [7:0] txd;
reg tx_en;
always @(posedge gmii_tx_clk) begin
	if (sys_rst) begin
		count <= 3'h0;
	end else begin
		tx_en <= 1'b0;
		if (rd_en == 1'b1 || count != 3'h0) begin
			rd_en <= 1'b0;
			count <= count + 3'h1;
			case (count)
				3'h0: begin
					txd        <= dout[ 7: 0];
					if (dout[64] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h1: begin
					txd        <= dout[15: 8];
					if (dout[65] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h2: begin
					txd        <= dout[23:16];
					if (dout[66] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h3: begin
					txd        <= dout[31:24];
					if (dout[67] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h4: begin
					txd        <= dout[39:32];
					if (dout[68] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h5: begin
					txd        <= dout[47:40];
					if (dout[69] == 1'b1)
						tx_en <= 1'b1;
					else
						count <= 4'h0;
				end
				3'h6: begin
					txd        <= dout[55:48];
					if (dout[70] == 1'b1) begin
						tx_en <= 1'b1;
					end else
						count <= 4'h0;
				end
				3'h7: begin
					txd        <= dout[63:56];
					if (dout[71] == 1'b1) begin
						tx_en <= 1'b1;
                				rd_en  <= ~empty;
					end else
						count <= 4'h0;
				end
			endcase
		end else begin
			count <= 3'h0;
               		rd_en  <= ~empty;
		end
	end
end

assign gmii_tx_en = tx_en;
assign gmii_txd   = txd;

endmodule
