module async_pkt_fifo #(
parameter c_DATA_WIDTH = 10,
parameter c_ADDR_WIDTH = 10,
parameter c_AFULL_FLAG = 100,
parameter c_AEMPTY_FLAG = 10
)(
input WrEop,
input [c_DATA_WIDTH-1:0] Data, 
input WrClock, 
input RdClock, 
input WrEn, 
input RdEn, 
input Reset,

output [c_DATA_WIDTH-1:0] Q, 
output Empty, 
output reg AlmostEmpty, 
output reg AlmostFull
);

reg [c_ADDR_WIDTH-1:0] wr_addr;
reg [c_ADDR_WIDTH-1:0] wr_pointer;
wire [c_ADDR_WIDTH-1:0] wr_pointer_sync;
reg  [c_ADDR_WIDTH-1:0] rd_addr;
wire [c_ADDR_WIDTH-1:0] rd_addr_sync;
wire [c_ADDR_WIDTH-1:0] rd_addr_inc;
wire [c_ADDR_WIDTH-1:0] fifo_level = wr_addr - rd_addr_sync;

always @(posedge WrClock or posedge Reset)
   if (Reset) begin
      wr_addr    <= 0;
      wr_pointer <= 0;
      AlmostFull <= 0;
   end
   else begin
      if (WrEn)
         wr_addr <= wr_addr + 1;
      
      if (WrEop)
         wr_pointer <= WrEn ? (wr_addr + 1) : wr_addr;
         
      AlmostFull <= fifo_level >= c_AFULL_FLAG;
   end

sync_logic  #(
.c_DATA_WIDTH (c_ADDR_WIDTH)
)
I_rd2wr_sync(
.rstn        (~Reset        ),
.wr_clk      (RdClock       ),
.wr_data     (rd_addr       ),
.rd_clk      (WrClock       ),
.rd_data     (rd_addr_sync  )
);

pmi_ram_dp 
 #(.pmi_wr_addr_depth (1<<c_ADDR_WIDTH),
   .pmi_wr_addr_width (c_ADDR_WIDTH),
   .pmi_wr_data_width (c_DATA_WIDTH),
   .pmi_rd_addr_depth (1<<c_ADDR_WIDTH),
   .pmi_rd_addr_width (c_ADDR_WIDTH),
   .pmi_rd_data_width (c_DATA_WIDTH),
   .pmi_regmode       ("reg"),
   .pmi_gsr           ("disable"),
   .pmi_resetmode     ("sync"),
   .pmi_optimization  ("speed"),
   .pmi_init_file     ("none"),
   .pmi_init_file_format ("binary"),
   .pmi_family ("ecp3"),
   .module_type ("pmi_ram_dp")
   )
   I_pmi_ram_dp(
    .Data             (Data),
    .WrAddress        (wr_addr),
    .RdAddress        (rd_addr),
    .WrClock          (WrClock),
    .RdClock          (RdClock),
    .WrClockEn        (1'b1),
    .RdClockEn        (RdEn),
    .WE               (WrEn),
    .Reset            (1'b0),
    .Q                (Q)
    );/*synthesis syn_black_box */

sync_logic  #(
.c_DATA_WIDTH (c_ADDR_WIDTH)
)
I_wr2rd_sync(
.rstn        (~Reset           ),
.wr_clk      (WrClock          ),
.wr_data     (wr_pointer       ),
.rd_clk      (RdClock          ),
.rd_data     (wr_pointer_sync  )
);


assign Empty = wr_pointer_sync == rd_addr;
wire [c_ADDR_WIDTH-1:0] fifo_level_rd = wr_pointer_sync - rd_addr;
assign rd_addr_inc = rd_addr + 1;
always @(posedge RdClock or posedge Reset)
   if (Reset) begin
      rd_addr <= 0;
      AlmostEmpty <= 1;
   end
   else begin
      if (RdEn)
         rd_addr <= (rd_addr_inc == wr_pointer_sync) ? rd_addr : (rd_addr + 1);
      
      AlmostEmpty <= fifo_level_rd <= c_AEMPTY_FLAG;
   end
   
endmodule