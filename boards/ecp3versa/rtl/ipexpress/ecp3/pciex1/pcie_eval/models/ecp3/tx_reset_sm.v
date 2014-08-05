`timescale 1ns/1ps
//THIS MODULE IS INSTANTIATED PER TX  QUAD

module tx_reset_sm
(
input        refclkdiv2,
input        rst_n,
input        tx_pll_lol_qd_s,
                                                                                              
output   reg    tx_pcs_rst_ch_c,      //TX Lane Reset (modified to have one bit)
output   reg    rst_qd_c          // QUAD Reset
);
                                                                                              
                                                                                              
parameter count_index = 17;
                                                                                              
                                                                                              
// States of LSM
localparam   QUAD_RESET      = 0,
             WAIT_FOR_TIMER1       = 1,
             CHECK_PLOL       = 2,
             WAIT_FOR_TIMER2       = 3,
             NORMAL    = 4;
                                                                                              
localparam STATEWIDTH =3;
// Flop variables
reg [STATEWIDTH-1:0]    cs /*synthesis syn_encoding="safe, gray"*/;               // current state of lsm
                                                                                              
                                                                                              
// Combinational logic variables
reg [STATEWIDTH-1:0]    ns;               // next state of lsm
                                                                                              
reg tx_pll_lol_qd_s_int;
reg tx_pll_lol_qd_s_int1;
reg    [3:0]   tx_pcs_rst_ch_c_int;      //TX Lane Reset
reg       rst_qd_c_int;          // QUAD Reset
                                                                                              
                                                                                              
                                                                                              
                                                                                              
//SEQUENTIAL
always @(posedge refclkdiv2 or negedge rst_n)
   begin
   if (rst_n == 1'b0)
      begin
      cs                     <= QUAD_RESET;
      tx_pll_lol_qd_s_int    <= 1;
      tx_pll_lol_qd_s_int1   <= 1;
      tx_pcs_rst_ch_c        <= 1'b1;
      rst_qd_c               <= 1;
      end
   else
      begin
      cs <= ns;
      tx_pll_lol_qd_s_int1   <= tx_pll_lol_qd_s;
      tx_pll_lol_qd_s_int    <= tx_pll_lol_qd_s_int1;
      tx_pcs_rst_ch_c        <= tx_pcs_rst_ch_c_int[0];
      rst_qd_c               <= rst_qd_c_int;
      end
   end
                                                                                              
//
reg reset_timer1, reset_timer2;
                                                                                              
                                                                                              
//TIMER1 = 20ns;
//Fastest REFLCK =312 MHZ, or 3 ns. We need 8 REFCLK cycles or 4 REFCLKDIV2 cycles
// A 2 bit counter ([1:0]) counts 4 cycles, so a 3 bit ([2:0]) counter will do if we set TIMER1 = bit[2]
localparam TIMER1WIDTH=3;
reg [TIMER1WIDTH-1:0] counter1;
reg TIMER1;
                                                                                              
always @(posedge refclkdiv2 or posedge reset_timer1)
   begin
   if (reset_timer1)
      begin
      counter1 <= 0;
      TIMER1 <= 0;
      end
   else
      begin
      if (counter1[2] == 1)
         TIMER1 <=1;
      else
         begin
         TIMER1 <=0;
         counter1 <= counter1 + 1 ;
         end
      end
   end
                                                                                              
//TIMER2 = 1,400,000 UI;
//WORST CASE CYCLES is with smallest multipier factor.
// This would be with X8 clock multiplier in DIV2 mode
// IN this casse, 1 UI = 2/8 REFCLK  CYCLES = 1/8 REFCLKDIV2 CYCLES
// SO 1,400,000 UI =1,400,000/8 = 175,000 REFCLKDIV2 CYCLES
// An 18 bit counter ([17:0]) counts 262144 cycles, so a 19 bit ([18:0]) counter will do if we set TIMER2 = bit[18]
                                                                                              
//localparam TIMER2WIDTH=19;

//1,400,000 * 400 ps / 20 ns = 28000
// so a 16 bit counter is enough
localparam TIMER2WIDTH=18;
reg [TIMER2WIDTH-1:0] counter2;
reg TIMER2;
                                                                                              
always @(posedge refclkdiv2 or posedge reset_timer2)
   begin
   if (reset_timer2)
      begin
      counter2 <= 0;
      TIMER2 <= 0;
      end
   else
      begin
//    `ifdef   SIM   //IF SIM parameter is set, define lower value
//          //TO SAVE SIMULATION TIME
//    if (counter2[4] == 1)
//    `else
//    if (counter2[18] == 1)
//    `endif
      if (counter2[count_index] == 1)
         TIMER2 <=1;
      else
         begin
         TIMER2 <=0;
         counter2 <= counter2 + 1 ;
         end
      end
   end
                                                                                              
                                                                                              
always @(*)
   begin : NEXT_STATE
   reset_timer1 = 0;
   reset_timer2 = 0;
         case (cs)
                                                                                              
            QUAD_RESET: begin
               tx_pcs_rst_ch_c_int = 4'hF;
               rst_qd_c_int = 1;
               reset_timer1 = 1;
               ns = WAIT_FOR_TIMER1;
               end
                                                                                              
            WAIT_FOR_TIMER1: begin
               tx_pcs_rst_ch_c_int = 4'hF;
               rst_qd_c_int = 1;
               if (TIMER1)
                  ns = CHECK_PLOL;
               else
                  ns = WAIT_FOR_TIMER1;
            end
                                                                                              
            CHECK_PLOL: begin
               tx_pcs_rst_ch_c_int = 4'hF;
               rst_qd_c_int = 0;
               reset_timer2 = 1;
               ns = WAIT_FOR_TIMER2;
            end
                                                                                              
            WAIT_FOR_TIMER2: begin
               tx_pcs_rst_ch_c_int = 4'hF;
               rst_qd_c_int = 0;
               if (TIMER2)
                  if (tx_pll_lol_qd_s_int)
                     ns = QUAD_RESET;
                  else
                     ns = NORMAL;
               else
                     ns = WAIT_FOR_TIMER2;
            end
                                                                                              
            NORMAL: begin
               tx_pcs_rst_ch_c_int = 4'h0;
               rst_qd_c_int = 0;
               if (tx_pll_lol_qd_s_int)
                  ns = QUAD_RESET;
               else
                  ns = NORMAL;
            end
                                                                                              
                                                                                              
                                                                                              
            // prevent lockup in undefined state
            default: begin
               tx_pcs_rst_ch_c_int = 4'hF;
               rst_qd_c_int = 1;
               ns = QUAD_RESET;
            end
         endcase // case
                                                                                              
   end //NEXT_STATE
                                                                                              
endmodule
