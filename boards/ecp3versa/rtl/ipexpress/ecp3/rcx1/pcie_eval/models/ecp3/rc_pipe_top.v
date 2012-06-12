
module rc_pipe_top (
   input wire                   RESET_n, 
   input wire                   PCLK,
   input wire                   clk_250,

   input wire                   ffs_plol,
   input wire                   TxDetectRx_Loopback,
   input wire [1:0]             PowerDown,
   input wire                   ctc_disable,

   input wire                   TxElecIdle_in,

   input wire                   RxPolarity_in, 
   input wire [7:0]             RxData_in,
   input wire                   RxDataK_in, 
   input wire [2:0]             RxStatus_in,  
   input wire                   RxValid_in,
   input wire                   RxElecIdle_in,

   input wire                   ff_rx_fclk_chx, 

   //----------------- RK BEGIN ------------------------------
   input wire                   pcie_con_x,
   input wire                   pcs_wait_done,
   input wire                   start_mask,
   input wire                   detsm_done,

   output reg                   RxElecIdle_chx_8,  //Not from CTC
   //----------------- RK END --------------------------------
  
   output wire [7:0]           TxData_out,
   output wire                 TxDataK_out, 
   output wire                 TxElecIdle_out,

   output wire                 RxPolarity_out,

   `ifdef DataWidth_8    //--------- 8-bit PIPE 
      input wire [7:0]         TxData_in,
      input wire               TxDataK_in,

      output wire [7:0]        RxData_out,
      output wire              RxDataK_out, 
   `else                 //---------16-bit PIPE 
      input wire [15:0]        TxData_in,
      input wire [1:0]         TxDataK_in,

      output wire [15:0]       RxData_out,
      output wire [1:0]        RxDataK_out, 
   `endif

   output wire [2:0]           RxStatus_out,  
   output wire                 RxValid_out,
   output wire                 RxElecIdle_out,

   output reg                  ffc_fb_loopback 

  );
  
// =============================================================================
// Parameters
// =============================================================================
localparam  PCS_EDB         = 8'hFE;
localparam  PCS_COMMA       = 8'hBC;


// =============================================================================
// Wires & Regs
// =============================================================================
   wire                     ctc_skip_added;
   wire                     ctc_skip_removed;
   wire                     ctc_over_flow;
   wire                     ctc_under_flow;

   reg [7:0]                RxData_chx_reg /* synthesis syn_srlstyle="registers" */;
   reg                      RxDataK_chx_reg /* synthesis syn_srlstyle="registers" */; 
   reg                      RxValid_chx_reg /* synthesis syn_srlstyle="registers" */;
   //reg                      RxElecIdle_reg;
   reg [2:0]                RxStatus_chx_reg /* synthesis syn_srlstyle="registers" */; 

// =============================================================================
integer                   i, m;

wire [7:0]                RxData_chx_s;
wire                      RxDataK_chx_s; 
wire                      RxValid_chx_s;
wire                      RxElecIdle_chx_s;
wire [2:0]                RxStatus_chx_s; 

reg [7:0]                 TxData_chx_s /* synthesis syn_srlstyle="registers" */;
reg                       TxDataK_chx_s /* synthesis syn_srlstyle="registers" */;
`ifdef DataWidth_8    //--------- 8-bit PIPE 
   reg [7:0]              RxData_chx /* synthesis syn_srlstyle="registers" */;
   reg                    RxDataK_chx /* synthesis syn_srlstyle="registers" */;
   wire [7:0]             TxData_chx;
   wire                   TxDataK_chx;
`else                 //---------16-bit PIPE 
   reg [15:0]             RxData_chx /* synthesis syn_srlstyle="registers" */;
   reg [1:0]              RxDataK_chx /* synthesis syn_srlstyle="registers" */;
   wire [15:0]            TxData_chx;
   wire [1:0]             TxDataK_chx;
`endif

reg                       RxElecIdle_chx /* synthesis syn_srlstyle="registers" */;
reg                       RxValid_chx /* synthesis syn_srlstyle="registers" */;
reg [2:0]                 RxStatus_chx /* synthesis syn_srlstyle="registers" */;

`ifdef DataWidth_8    //--------- 8-bit PIPE 
   // COMMA alignment with RxValid Rising Edge
   wire                   comma_chx;
`endif

// CTC Outputs
wire[7:0]                 RxData_chx_8;
wire                      RxDataK_chx_8;
wire[2:0]                 RxStatus_chx_8;
//reg                       RxElecIdle_chx_8;  //Not from CTC   OUTPUT
wire                      RxValid_chx_8;

`ifdef DataWidth_16    //--------- 16-bit PIPE 
   reg                    drate_enable_tx;
   reg                    drate_enable_rx;
   reg                    PLOL_sync;
   reg                    PLOL_hclk /* synthesis syn_srlstyle="registers" */;

   // COMMA alignment with RxValid Rising Edge
   wire                   commaH_chx;
   wire                   commaL_chx;
   // RX_GEAR Outputs
   wire[27:0]             Rx_chx;
   wire [1:0]             RxDataK_chx_16;
   wire [15:0]            RxData_chx_16;
   wire [5:0]             RxStatus_chx_16;
   wire                   RxValid_chx_16;
   wire                   RxElecIdle_chx_16;
   // TX-PATH
   wire                   TxElecIdle_chx_8;
   wire[7:0]              TxData_chx_8;
   wire                   TxDataK_chx_8;
`endif

//---- X4 : Recoverd clks
//---- X1 : PLL 250 clk
`ifdef X4
   reg                    pcs_wait_done_chx_sync;
   reg                    ei_ctc_chx_sync;
   reg                    ei_ctc_chx /* synthesis syn_srlstyle="registers" */;
   wire                   chx_RESET_n;
`endif

reg                       pcs_wait_done_chx /* synthesis syn_srlstyle="registers" */;
reg                       ctc_reset_chx;


reg                       start_mask_sync;
reg                       start_mask_fclk /* synthesis syn_srlstyle="registers" */;
reg [15:0]                rxelec_ctc_delay_chx /* synthesis syn_srlstyle="registers" */;

reg [20:0]                rxvalid_delay_chx /* synthesis syn_srlstyle="registers" */;

reg                       TxElecIdle_chx_s /* synthesis syn_srlstyle="registers" */;



// =============================================================================
//-------- RX PATH INPUTS
//From SERDES (Inputs)
assign RxData_chx_s     = RxData_in;
assign RxDataK_chx_s    = RxDataK_in;
assign RxValid_chx_s    = RxValid_in;
assign RxStatus_chx_s   = RxStatus_in;
assign RxElecIdle_chx_s = RxElecIdle_in;

//--------- RX PATH OUTPUTS 
//X4 : From CTC/RX_GEAR (Outputs) TO PIPE
assign RxData_out       = RxData_chx;
assign RxDataK_out      = RxDataK_chx;
assign RxValid_out      = RxValid_chx ;
assign RxStatus_out     = RxStatus_chx;
assign RxElecIdle_out   = RxElecIdle_chx;


//-------- TX PATH INPUTS 
//From PIPE (Inputs)
assign TxData_chx       = TxData_in;
assign TxDataK_chx      = TxDataK_in;
assign TxElecIdle_chx   = TxElecIdle_in;

//-------- TX PATH OUTPUTS 
//From Input/TX_GEAR (Outputs) TO SERDES
assign TxData_out       = TxData_chx_s;
assign TxDataK_out      = TxDataK_chx_s;
assign TxElecIdle_out   = TxElecIdle_chx_s;

// =============================================================================

`ifdef X4   //X4 CTC --> Recovered clks
always @(posedge ff_rx_fclk_chx or negedge RESET_n) begin
   if(!RESET_n) begin
      pcs_wait_done_chx_sync <= 1'b0;
      pcs_wait_done_chx      <= 1'b0;
      ei_ctc_chx_sync        <= 1'b1;
      ei_ctc_chx             <= 1'b1;
      ctc_reset_chx          <= 1'b0;
   end
   else begin
      // For CTC write enable/RESET (RLOL qualified with EI)
      // RxEI should be LOW & pcs_wait_done should be HIGH for CTC 
      // to start, otherwise CTC will be held in RESET
      ctc_reset_chx          <= ~ei_ctc_chx & pcs_wait_done_chx;

      //Sync.
      // For RxValid Mask
      pcs_wait_done_chx_sync <= pcs_wait_done;
      pcs_wait_done_chx      <= pcs_wait_done_chx_sync;

      ei_ctc_chx_sync        <= RxElecIdle_chx_8;   //Masked RxElecIdle
      ei_ctc_chx             <= ei_ctc_chx_sync;
   end
end
`endif //X4
`ifdef X1   //X1 no CTC --> No Recovered clks
always @(posedge clk_250 or negedge RESET_n) begin
   if(!RESET_n) begin
      ctc_reset_chx          <= 1'b0;
      pcs_wait_done_chx      <= 1'b0;
   end
   else begin
      //No Sync is required
      ctc_reset_chx          <= ~RxElecIdle_chx_8 & pcs_wait_done_chx;
      pcs_wait_done_chx      <= pcs_wait_done;
   end
end
`endif //X1


// =============================================================================
// EI bypass CTC : Create equal delay  (250 PLL clk)
// No CDR clk when EI is HIGH
// =============================================================================
always @(posedge clk_250 or negedge RESET_n) begin
   if(!RESET_n) begin
      start_mask_sync       <= 1'b0;
      start_mask_fclk       <= 1'b0;
      RxElecIdle_chx_8      <= 1'b1;
      rxelec_ctc_delay_chx  <= 16'hFFFF;
   end
   else begin
      start_mask_sync  <= start_mask;
      start_mask_fclk  <= start_mask_sync;

      // Min. 12 : 250 clks for EI Mask
      // RxElecIdle_chx_8 is the Masked RxElecIdle siganl
      RxElecIdle_chx_8 <= rxelec_ctc_delay_chx[15] | start_mask_fclk;
      for (m= 0;m<15;m=m+1) begin
          if (m == 0) begin
             //rxelec_ctc_delay_chx[0] <= Int_RxElecIdle_chx;
             rxelec_ctc_delay_chx[0] <= RxElecIdle_chx_s;
             rxelec_ctc_delay_chx[1] <= rxelec_ctc_delay_chx[0];
          end
	  else begin
             rxelec_ctc_delay_chx[m+1] <= rxelec_ctc_delay_chx[m];
          end
      end
   end
end

// =============================================================================
//                          ====TX PATH===
//                           For X1 or X4 
// =============================================================================
always @(posedge clk_250 or negedge RESET_n) begin
   if(!RESET_n) begin
      TxData_chx_s     <= 0;
      TxDataK_chx_s    <= 0;
      TxElecIdle_chx_s <= 1'b1;
   end
   else begin  
   `ifdef DataWidth_8    //--------- 8-bit PIPE Take from PIPE --------
      TxData_chx_s     <= TxData_chx;
      TxDataK_chx_s    <= TxDataK_chx;
      TxElecIdle_chx_s <= TxElecIdle_chx;
   `endif // 8-bit
   `ifdef DataWidth_16   //---------16-bit PIPE Take from TX_GEAR -----
      TxData_chx_s     <= TxData_chx_8;
      TxDataK_chx_s    <= TxDataK_chx_8;
      TxElecIdle_chx_s <= TxElecIdle_chx_8;
   `endif // 16-bit
   end
end

// =============================================================================
//                          ====RX PATH===
//                           COMMON for X4/X1
// =============================================================================
// =============================================================================
// The RxValid_chx signal is going low early before the data comming
// out of PCS, so delay this signal
// Delayed by 21 Clocks * 4 ns = 84 ns;
// =============================================================================
wire   clk_new;
`ifdef X4
    assign clk_new = ff_rx_fclk_chx;
`endif
`ifdef X1
    assign clk_new = clk_250;
`endif
always @(posedge clk_new or negedge RESET_n) begin  //X1: clk 250   X4: Recovered clk
   if(!RESET_n) begin
      RxDataK_chx_reg     <= 1'b0;
      RxData_chx_reg      <= 8'h00;
      RxValid_chx_reg     <= 1'b0; 
      rxvalid_delay_chx   <= 0;
      RxStatus_chx_reg    <= 3'b000;
   end
   else begin  
      //X4: To CTC --- X1: To CTC Bypass 
      RxDataK_chx_reg     <= RxDataK_chx_s;
      RxData_chx_reg      <= RxData_chx_s;

      RxValid_chx_reg     <= rxvalid_delay_chx[20]; 
      RxStatus_chx_reg    <= RxStatus_chx_s;

      for (i= 0;i<20;i=i+1) begin
         if (i == 0) begin
           rxvalid_delay_chx[0] <= RxValid_chx_s & pcs_wait_done_chx;
           rxvalid_delay_chx[1] <= rxvalid_delay_chx[0];
         end
         else begin 
           rxvalid_delay_chx[i+1] <= rxvalid_delay_chx[i];
         end
      end
   end
end

// =================================================================
// RxData Input (From SERDES TO CTC )           -  8-bit PIPE
// RxData output (From CTC)                     -- 8-bit PIPE
//
// RxData Input (From SERDES TO CTC TO Rx_gear) - 16-bit PIPE
// RxData output (From Rx_gear)                 - 16-bit PIPE
// =============================================================================
`ifdef DataWidth_8    //--------- 8-bit PIPE Take from CTC ---------
   assign comma_chx = (RxDataK_chx_8 && (RxData_chx_8 == PCS_COMMA)) ? 1'b1 : 1'b0;

   always @(posedge PCLK  or negedge RESET_n) begin  //250 PLL clk
      if(!RESET_n) begin
         RxDataK_chx     <= 1'b0;
         RxData_chx      <= 8'h0;
         RxElecIdle_chx  <= 1'b1; 
         RxValid_chx     <= 1'b0; 
         RxStatus_chx    <= 3'b000;
      end
      else begin  
         RxData_chx  <= RxData_chx_8;
         RxDataK_chx <= RxDataK_chx_8;

         // RxValid Rising Edge should be with COMMA 
         if (RxValid_chx_8 && comma_chx)
            RxValid_chx     <= 1'b1;
         else if (~RxValid_chx_8)
            RxValid_chx     <= 1'b0;

         if (detsm_done) begin
            if (pcie_con_x) //No Sync. is required
               RxStatus_chx  <= 3'b011;  //DETECTED
            else
               RxStatus_chx  <= 3'b000;  //NOT DETECTED
         end
	 else begin
            RxStatus_chx  <= RxStatus_chx_8;
         end

         RxElecIdle_chx  <= RxElecIdle_chx_8; 
      end
   end
`endif  //--------- 8-bit PIPE -------------------------------------

`ifdef DataWidth_16   //---------16-bit PIPE Take from RX_GEAR -----
   assign RxData_chx_16      = {Rx_chx[27:20],Rx_chx[13:6]};
   assign RxDataK_chx_16     = {Rx_chx[19],Rx_chx[5]};
   assign RxStatus_chx_16    = {Rx_chx[18:16],Rx_chx[4:2]};
   assign RxElecIdle_chx_16  = (Rx_chx[15] | Rx_chx[1]);
   assign RxValid_chx_16     = (Rx_chx[14] | Rx_chx[0]);

   assign commaH_chx = (RxDataK_chx_16[1] && (RxData_chx_16[15:8] == PCS_COMMA)) ? 1'b1 : 1'b0;
   assign commaL_chx = (RxDataK_chx_16[0] && (RxData_chx_16[7:0]  == PCS_COMMA)) ? 1'b1 : 1'b0;

   always @(posedge PCLK  or negedge RESET_n) begin    //125 PLL clk
      if(!RESET_n) begin
         RxDataK_chx     <= 2'b0;
         RxData_chx      <= 16'h0;
         RxElecIdle_chx  <= 1'b1; 
         RxValid_chx     <= 1'b0; 
         RxStatus_chx    <= 3'b000;
      end
      else begin  
         RxData_chx  <= RxData_chx_16;
         RxDataK_chx <= RxDataK_chx_16;

         // RxValid Rising Edge should be with COMMA 
         if (RxValid_chx_16 && (commaH_chx || commaL_chx))
            RxValid_chx     <= 1'b1;
         else if (~RxValid_chx_16)
            RxValid_chx     <= 1'b0;

         if (detsm_done) begin
            if (pcie_con_x) //No Sync. is required
               RxStatus_chx  <= 3'b011;  //DETECTED
            else
               RxStatus_chx  <= 3'b000;  //NOT DETECTED
         end
	 else begin
	    if((RxStatus_chx_16[2:0] == 3'b001) || (RxStatus_chx_16[5:3] == 3'b001))
               RxStatus_chx  <= 3'b001; //SKIP added
	    else if((RxStatus_chx_16[2:0] == 3'b010) || (RxStatus_chx_16[5:3] == 3'b010))
               RxStatus_chx  <= 3'b010; //SKIP deleted
            else
               RxStatus_chx  <= 3'b000;
         end

         RxElecIdle_chx  <= RxElecIdle_chx_16; 
      end
   end

`endif  //---------16-bit PIPE -------------------------------------


// =================================================================
// CTC instantiation only for X4 
// =================================================================

`ifdef X4    //X4  8-bit/16-bit
   //Both should be HIGH for CTC to start
   assign chx_RESET_n = RESET_n & ctc_reset_chx; 

   ctc u0_ctc
      (
      //------- Inputs 
      .rst_n                  (chx_RESET_n),          
      .clk_in                 (ff_rx_fclk_chx),           
      .clk_out                (clk_250),         
      .ctc_disable            (ctc_disable),         
      .data_in                (RxData_chx_reg),        
      .kcntl_in               (RxDataK_chx_reg),        
      .status_in              (RxStatus_chx_reg),       
      .lanesync_in            (RxValid_chx_reg),

      //------- Outputs 
      .ctc_read_enable        (),
      .ctc_skip_added         (ctc_skip_added),     
      .ctc_skip_removed       (ctc_skip_removed),  
      .ctc_data_out           (RxData_chx_8),        
      .ctc_kcntl_out          (RxDataK_chx_8),        
      .ctc_status_out         (RxStatus_chx_8),       
      .ctc_lanesync_out       (RxValid_chx_8),
      .ctc_under_flow         (ctc_under_flow),  
      .ctc_over_flow          (ctc_over_flow)
    );

`else  //X1 8-bit/16-bit : Pass the Data as it is (bypass CTC)  

   assign RxData_chx_8    = (ctc_reset_chx) ? RxData_chx_reg : 0;
   assign RxDataK_chx_8   = (ctc_reset_chx) ? RxDataK_chx_reg : 0;
   assign RxStatus_chx_8  = (ctc_reset_chx) ? RxStatus_chx_reg : 0;
   assign RxValid_chx_8   = (ctc_reset_chx) ? RxValid_chx_reg : 0;

`endif // X4

// =============================================================================
// Rxdata : From CTC --> Rx_gear   -- 16-bit PIPE  -- X4/X1
// =============================================================================
`ifdef DataWidth_16   //---------16-bit PIPE RX/TX_GEAR ------------

   // ==========================================================================
   // Generating drate_enable_rx for rx_gear -- 125 Mhz clk
   // ==========================================================================
   always @(posedge PCLK or negedge RESET_n) begin
      if(!RESET_n) begin
         drate_enable_rx  <= 1'b0;
         PLOL_sync        <= 1'b1;
         PLOL_hclk        <= 1'b1;
      end
      else begin
         // Sync.
         PLOL_sync <= ffs_plol;
         PLOL_hclk <= PLOL_sync;
   
         if(PLOL_hclk == 1'b1) //No lock
            drate_enable_rx <= 1'b0;
         else // Enable required for RxElecIdle passing
            drate_enable_rx <= 1'b1;
   
      end
   end

   // ==========================================================================
   // Generating drate_enable_tx for tx_gear -- 125 Mhz clk
   // ==========================================================================
   always @(posedge PCLK or negedge RESET_n) begin
      if(!RESET_n) begin
         drate_enable_tx  <= 1'b0;
      end
      else begin
   
         if(PLOL_hclk == 1'b1) //No lock
            drate_enable_tx <= 1'b0;
         else if (detsm_done == 1'b1) // detection is done
            drate_enable_tx <= 1'b1;
      end
   end

   // convert 8 bit data to 16 bits  ----RX_GEAR
   rx_gear #( .GWIDTH(14)) u1_rx_gear   (
      // Clock and Reset
      .clk_125        ( PCLK ),
      .clk_250        ( clk_250 ),
      .rst_n          ( RESET_n ),
      // Inputs
      .drate_enable    (drate_enable_rx),
      .data_in        ({RxData_chx_8,RxDataK_chx_8,RxStatus_chx_8,RxElecIdle_chx_8,RxValid_chx_8}),
      // Outputs
      .data_out       (Rx_chx )
     ); 

   // convert 16 bit data to 8 bits ----TX_GEAR
   tx_gear #( .GWIDTH(20)) u1_tx_gear ( 
      // Clock and Reset  
      .clk_125        ( PCLK ),
      .clk_250        ( clk_250 ),
      .rst_n          ( RESET_n ),
      // Inputs
      .drate_enable   (drate_enable_tx ),
      .data_in        ( {TxElecIdle_chx,TxData_chx[15:8],TxDataK_chx[1],TxElecIdle_chx,TxData_chx[7:0],TxDataK_chx[0]}),
      // Outputs
      .data_out       ( {TxElecIdle_chx_8,TxData_chx_8,TxDataK_chx_8} )
      );

`endif  //---------16-bit PIPE -------------------------------------



// =============================================================================
//Assert slave loopback as long as TxDetectRx_Loopback is asserted by FPGA side
//when Serdes is in normal mode and TxElecIdle_ch0 is inactive.
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin
   if(!RESET_n) begin
      ffc_fb_loopback <= 1'b0;
   end
   else begin  
      ffc_fb_loopback <= ((PowerDown == 2'b00) & TxDetectRx_Loopback & !TxElecIdle_chx) ? 1'b1: 1'b0;
   end
end

// =============================================================================
// synchronize RxPolarity signal to RX recovered clock  (all modes)
// =============================================================================
reg sync1_RxPolarity ;
reg sync2_RxPolarity  /* synthesis syn_srlstyle="registers" */;
always @(posedge ff_rx_fclk_chx or negedge RESET_n) begin
   if(!RESET_n) begin
      sync1_RxPolarity <= 'h0;
      sync2_RxPolarity <= 'h0;
   end
   else begin
      sync1_RxPolarity <= RxPolarity_in ;
      sync2_RxPolarity <= sync1_RxPolarity ;
   end
end
assign RxPolarity_out = sync2_RxPolarity ;


endmodule
// =============================================================================


