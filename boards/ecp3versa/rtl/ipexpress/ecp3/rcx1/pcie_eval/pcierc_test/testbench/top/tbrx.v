// $Id: PCI_EXP_X1_11/technology/ver1.0/testbench/beh/tbrx.v 1.12 2006/08/30 16:37:31PDT uananthi Exp  $
// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2002 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS         
// Project          : PCI Express 4X 
// File             : tbrx.v
// Title            : RX User interface 
// Dependencies     : pci_exp_params.v
// Description      : This module implements the the PER VC user side RX interface 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        : Rajakumar
// Mod. Date        : Feb 14, 2006
// Changes Made     : Initial Creation
//
// =============================================================================

module tbrx 
   (
//---------Inputs------------
    input wire            sys_clk,           
    input wire            rst_n,           

    input wire [2:0]      rx_tc,

    input wire            rx_st,  
    input wire            rx_end,
    input wire [15:0]     rx_data, 
    `ifdef ECRC
       input wire         rx_ecrc_err,
    `endif
    input wire            rx_malf_tlp,
    input wire            rx_us_req,

    //---------Outputs------------
    output wire           tbrx_cmd_prsnt,
    output reg            ph_buf_status,
    output reg            pd_buf_status,
    output reg            nph_buf_status,
    output reg            npd_buf_status,
    output reg            cplh_buf_status,
    output reg            cpld_buf_status,
    output reg            ph_processed,
    output reg            pd_processed,
    output reg            nph_processed,
    output reg            npd_processed,
    output reg            cplh_processed,
    output reg            cpld_processed,
    output reg [7:0]      pd_num,
    output reg [7:0]      npd_num,
    output reg [7:0]      cpld_num,
    output reg [7:0]      INIT_PH_FC,
    output reg [7:0]      INIT_NPH_FC,
    output reg [7:0]      INIT_CPLH_FC,
    output reg [11:0]     INIT_PD_FC,
    output reg [11:0]     INIT_NPD_FC,
    output reg [11:0]     INIT_CPLD_FC 

    );

// =============================================================================
//`define DEBUG 1
// =============================================================================
`define  TBRX_UPPER32_ADDR  32'h1000_0000
`define  TBRX_REQ_ID        16'hAAAA
`define  TBRX_CPL_ID        16'hBBBB

parameter  R         = 1'b0;
parameter  HEAD_4DW  = 1'b1;
parameter  HEAD_3DW  = 1'b0;

parameter  MEM_TYPE  = 5'b0_0000;
parameter  IO_TYPE   = 5'b0_0010;
parameter  CFG0_TYPE = 5'b0_0100;
parameter  CFG1_TYPE = 5'b0_0101;
parameter  MSG_TYPE  = 5'b1_0xxx;
//parameter  MSG_TYPE  = 5'b1_0000;  //Chosen "Routed to Root Complex"
parameter  CPL_TYPE  = 5'b0_1010;

parameter MEM_RD     = 4'b0000;
parameter MEM_WR     = 4'b0001;
parameter IO_RD      = 4'b0010;
parameter IO_WR      = 4'b0011;
parameter CFG_RD     = 4'b0100;
parameter CFG_WR     = 4'b0101;
parameter MSG        = 4'b0110;
parameter MSG_D      = 4'b0111;
parameter CPL        = 4'b1000;
parameter CPL_D      = 4'b1001;
parameter TLP        = 4'b1010;

// Error Code Parameters for display Error
parameter TYPE_C       = 5'd0;
parameter FMT_C        = 5'd1;
parameter TC_C         = 5'd2;
parameter TD_C         = 5'd3;
parameter EP_C         = 5'd4;
parameter ATTR_C       = 5'd5;
parameter LEN_C        = 5'd6;
parameter RSRV_C       = 5'd7;
parameter REQ_ID_C     = 5'd8;
parameter TAG_C        = 5'd9;
parameter LastDW_BE_C  = 5'd10;
parameter FirstDW_BE_C = 5'd11;
parameter ADDR_C       = 5'd12;
parameter DATA_C       = 5'd13;
parameter MSG_C        = 5'd14;
parameter MSGCODE_C    = 5'd15;
parameter CPL_ID_C     = 5'd16;
parameter STATUS_C     = 5'd17;
parameter BCM_C        = 5'd18;
parameter BYTECNT_C    = 5'd19;
parameter LOWERADDR_C  = 5'd20;

parameter  TBRX_IDLE    = 2'b00;
parameter  TBRX_SOP     = 2'b01;
parameter  TBRX_DATA    = 2'b10;

parameter  CHECK_LSW    = 2'b01;
parameter  CHECK_MSW    = 2'b10;
parameter  CHECK_BOTH   = 2'b11;

//-------- ERROR Types 
parameter  NO_TLP_ERR     = 4'b0000;
parameter  ECRC_ERR       = 4'b0001;
parameter  UNSUP_ERR      = 4'b0010;
parameter  MALF_ERR       = 4'b0011;

parameter  FMT_TYPE_ERR   = 4'b1111;
/*****
parameter  NO_TLP_ERR     = 4'b0000;
parameter  LEN_MAXPL_ERR  = 4'b0001;  // For Pkts with Data (like mem_wr, cpld)
parameter  LEN_MORE_ERR   = 4'b0010;  // data is more than length field 
parameter  LEN_LESS_ERR   = 4'b0011;  // data is less than length field
parameter  LEN_ILLEGAL    = 4'b0100;  // CFG/IO ---- Len != 1

parameter  ECRC_ERR       = 4'b0101;
parameter  TC_ERR         = 4'b0110;  // CFG/IO ----- TC != 3'b000
parameter  ATTR_ERR       = 4'b0111;  // CFG/IO ----- ATTR != 2'b00
parameter  LASTDW_ERR     = 4'b1000;  // CFG/IO ----- Last Dw En != 4'b0000

parameter  RSRV_H1_ERR    = 4'b1001;  // Rsrv bits are not zero in first 32 bits of header
parameter  MSG_TYPE_ERR   = 4'b1010;  // Type[2:0] are from 110 to 111 (reserved may be)
parameter  CPL_STATUS_ERR = 4'b1011;  // Completion status is reserved (= from 101 to 111)
*****/

//-------- For Flow Control Tasks
parameter P    = 2'b00;
parameter NP   = 2'b01;
parameter CPLX = 2'b10;  //CPL is already used in some other paramter

parameter PH   = 3'b000;
parameter PD   = 3'b001;
parameter NPH  = 3'b010;
parameter NPD  = 3'b011;
parameter CPLH = 3'b100;
parameter CPLD = 3'b101;
// =============================================================================
// Define all inputs / outputs
// =============================================================================

// =============================================================================
// Define Wire & Registers 
// =============================================================================
//---- Registers

reg  [71:0]                 TBRX_WAIT_FIFO [1023:0];
reg  [3:0]                  TBRX_FIFO_TC [1023:0];
reg  [9:0]                  got_cnt;
reg  [9:0]                  wt_cnt;

reg                         pkt_inprogress;
reg                         rx_st_del1, rx_st_del2, rx_st_del3, rx_st_del4;
reg                         rx_st_del5, rx_st_del6, rx_st_del7, rx_st_del8;

reg  [1:0]                  tbrx_state;
reg                         TBRX_Error;
reg  [10:0]                 di, dj;

reg  [63:0]                 H1_got;
reg  [63:0]                 H2_got;
reg  [31:0]                 H1_ms_exp;
reg  [31:0]                 H1_ls_exp;
reg  [31:0]                 H2_ms_exp;
reg  [31:0]                 H2_ls_exp;

reg  [15:0]                 data0, data1;
reg  [31:0]                 D [9:0];   //For User Manual Data 

reg                         short_pkt;
reg                         exp_dwen;
reg                         fmt_type_err;
reg                         man_tlp_pkt;

reg  [1:0]                  stored_fmt;
reg  [4:0]                  stored_type;
reg  [9:0]                  stored_len;
reg  [3:0]                  stored_error;
reg  [3:0]                  stored_kind;

reg  [4:0]                  Error_code;
reg                         toggle;
reg  [15:0]                 d1, d2, d3, d4, d5, d6, d7, d8, rx_data_del;

//---- Wires
wire  [71:0]                wt_info;
wire  [71:0]                wt_info2;
wire  [3:0]                 tc_info;
wire                        wt_cfg;
wire [7:0]                  wt_be;
wire                        wt_hdr;
wire                        wt_td;
wire                        wt_ep;
wire [9:0]                  wt_len;
wire [31:0]                 wt_addr;
wire [3:0]                  wt_type;
wire [3:0]                  wt_et;

wire [11:0]                 wt_bytecnt;
wire [6:0]                  wt_loweraddr;
wire [2:0]                  wt_status;

wire [2:0]                  wt_tc;
wire                        wt_tc_set;

wire                        rx_st_x4, rx_st_x4_del;
// =============================================================================
// The following signals are task CHECK_HEADER internal signals
// Kept them outside so that ERROR_TASK can access these signals for display
// =============================================================================
reg        TD, EP; 
reg [7:0]  TAG;
reg [1:0]  ATTR;
reg [2:0]  TC;
reg [1:0]  fmt;
reg [4:0]  type;
reg [9:0]  len;
reg [3:0]  LastDW_BE;
reg [3:0]  FirstDW_BE;
reg [3:0]  Error_Type;

reg        R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12;
reg        TDx, EPx; 
reg [7:0]  TAGx;
reg [1:0]  ATTRx;
reg [2:0]  TCx;
reg [1:0]  fmtx;
reg [4:0]  typex;
reg [9:0]  lenx;
reg [3:0]  LastDW_BEx;
reg [3:0]  FirstDW_BEx;
reg [31:0] TBRX_UPPER32_ADDRx;
reg [15:0] TBRX_REQ_IDx;
reg [7:0]  TBRX_MSG_CODEx;
reg [15:0] TBRX_CPL_IDx;
reg [63:0] TBRX_MSG_TYPEx;
reg        TBRX_BCMx;

reg [31:0] wt_addrx;
reg [11:0] wt_bytecntx;
reg [6:0]  wt_loweraddrx;
reg [2:0]  wt_statusx;

reg [31:0] FirstDatax;
// =============================================================================
// -------- GLOBAL REGISTERS THAT CAN BE SET BY THE USER IN THE TEST  ----------
// TD : Set indicates Presence of TLP Digest (ECRC)
// EP : Set indicates data Poisoned 
// First DW BE :
// Last  DW BE :
// REQUESTER ID : 16 bits
// Tag  :8 bits 
// Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// =============================================================================
reg [31:0]  TBRX_UPPER32_ADDR;
reg [15:0]  TBRX_REQ_ID;
reg [15:0]  TBRX_CPL_ID;
reg [7:0]   TBRX_TAG;
reg         TBRX_TD;
reg         TBRX_EP;
reg         TBRX_BCM;  //For CPL Header
reg [2:0]   TBRX_TC;
reg [1:0]   TBRX_ATTR;
reg [9:0]   TBRX_LEN;
reg [3:0]   TBRX_LastDW_BE;
reg [2:0]   TBRX_MSG_ROUTE;
reg [7:0]   TBRX_MSG_CODE;
reg [63:0]  TBRX_MSG_TYPE;

reg  [3:0]  First_DW_BE;
reg  [3:0]  Last_DW_BE;

reg         TBRX_MANUAL_DATA;
reg         TBRX_FIXED_PATTERN;
// =============================================================================
// TX Request Fifo
// =============================================================================
assign tbrx_cmd_prsnt = (wt_cnt == got_cnt) ? 1'b0 : 1'b1;
initial begin

  TBRX_UPPER32_ADDR = `TBRX_UPPER32_ADDR; 
  TBRX_REQ_ID       = `TBRX_REQ_ID;
  TBRX_CPL_ID       = `TBRX_CPL_ID; 
  TBRX_TAG          = 8'h00;
  TBRX_TD           = 1'b0;
  TBRX_EP           = 1'b0;
  TBRX_BCM          = 1'b0;

  //For IO & CFG Pkts 
  TBRX_TC           = 3'b000;
  TBRX_ATTR         = 2'b00;
  TBRX_LEN          = 10'd1;
  TBRX_LastDW_BE    = 4'b0000;

  TBRX_MSG_ROUTE    = 3'b000; // Refer PNo 63
  TBRX_MSG_CODE     = 8'h00;  //Refer Page No 64-69
  TBRX_MSG_TYPE     = 64'h0000_0000_0000_0000;

  First_DW_BE       = 4'b1111;
  Last_DW_BE        = 4'b1111;

  D[0] = 0; D[1] = 0; D[2] = 0; D[3] = 0; D[4] = 0;
  D[5] = 0; D[6] = 0; D[7] = 0; D[8] = 0; D[9] = 0;
end
initial begin
  wt_cnt            = 'd0;
  man_tlp_pkt       = 0;
end
// =============================================================================
// 4 + 4 + 32 + 10 + 1 + 1 + 1 + 4 + 4 +      11  = 72
// Error Type + kind + addr + len + 3dw/4dw + TD + EP + FirstDwBE + LastDwBE +
// Extra bits 11
// For Manual TLP type:  4 + 4 + 64 bit header = 72 bits
// =============================================================================
assign wt_info  = TBRX_WAIT_FIFO[got_cnt];
assign wt_info2 = TBRX_WAIT_FIFO[got_cnt+1];
assign tc_info  = TBRX_FIFO_TC[got_cnt];

//10:0 is not used for Normal Pkt, but for Manula TLP pkt
assign wt_cfg  = wt_info[11];  //For Config  (Config0 or Config1)
assign wt_be   = wt_info[18:11];
assign wt_ep   = wt_info[19];
assign wt_td   = wt_info[20];
assign wt_hdr  = wt_info[21];

assign wt_len  = wt_info[31:22];   // Len21h of Pkt
assign wt_addr = wt_info[63:32];   // Addr
assign wt_type = wt_info[67:64];   // Type of pkt
assign wt_et   = wt_info[71:68];   // Error Type

assign wt_bytecnt   = wt_addr[31:20];
assign wt_loweraddr = wt_addr[19:13];
assign wt_status    = wt_addr[12:10];

assign wt_tc     = tc_info[2:0];
assign wt_tc_set = tc_info[3];

reg [1:0] NEW_fmt;
always @(*) begin
    case (wt_type)
       MEM_RD : NEW_fmt = {1'b0, wt_hdr};
       MEM_WR : NEW_fmt = {1'b1, wt_hdr};
       CFG_RD : NEW_fmt = {1'b0, 1'b0};
       CFG_WR : NEW_fmt = {1'b1, 1'b0};
       IO_RD  : NEW_fmt = {1'b0, 1'b0};
       IO_WR  : NEW_fmt = {1'b1, 1'b0};
       MSG    : NEW_fmt = {1'b0, 1'b1};
       MSG_D  : NEW_fmt = {1'b1, 1'b1};
       CPL    : NEW_fmt = {1'b0, 1'b0};
       CPL_D  : NEW_fmt = {1'b1, 1'b0};
       TLP    : NEW_fmt = wt_info[62:61];
    endcase
end

reg [39:0] HEADER_s;
always @(*) begin
    case (NEW_fmt)
       2'b00 : HEADER_s = "3DW  "; //3DW with No data
       2'b01 : HEADER_s = "4DW  "; //4DW with No data
       2'b10 : HEADER_s = "3DW_D"; //3DW with data  (may be 1 or more)
       2'b11 : HEADER_s = "4DW_D"; //4DW with data  (may be 1 or more)
    endcase
end

reg [47:0] TYPE_EXP_s;
always @(*) begin
    case (wt_type)
       MEM_RD : TYPE_EXP_s = "MEM_RD";
       MEM_WR : TYPE_EXP_s = "MEM_WR";
       CFG_RD : TYPE_EXP_s = "CFG_RD";
       CFG_WR : TYPE_EXP_s = "CFG_WR";
       IO_RD  : TYPE_EXP_s = "IO_RD";
       IO_WR  : TYPE_EXP_s = "IO_WR";
       MSG    : TYPE_EXP_s = "MSG";
       MSG_D  : TYPE_EXP_s = "MSG_D";
       CPL    : TYPE_EXP_s = "CPL";
       CPL_D  : TYPE_EXP_s = "CPL_D";
       TLP    : TYPE_EXP_s = "TLP";
    endcase
end

reg [31:0] TBRX_STATE_s;
always @(*) begin
    case(tbrx_state)
       TBRX_IDLE : TBRX_STATE_s = "IDLE";
       TBRX_SOP  : TBRX_STATE_s = "SOP ";
       TBRX_DATA : TBRX_STATE_s = "DATA";
    endcase
end

// =============================================================================
// Unsupported TLP : fmt & Type field errors (? Undefined) + Locked transactions
// Malfunction TLP : Max len err + length error + undefined TLP + IO & CFG VCID err
// =============================================================================
assign rx_st_x4     = (rx_st | rx_st_del1 | rx_st_del2 | rx_st_del3);
assign rx_st_x4_del = (rx_st_del4 | rx_st_del5 | rx_st_del6 | rx_st_del7);
always @(posedge sys_clk or negedge rst_n) begin
   if (!rst_n)  begin  
      pkt_inprogress  <= 1'b0;
      rx_st_del1      <= 1'b0; rx_st_del2      <= 1'b0; rx_st_del3      <= 1'b0; rx_st_del4      <= 1'b0;
      rx_st_del5      <= 1'b0; rx_st_del6      <= 1'b0; rx_st_del7      <= 1'b0; rx_st_del8      <= 1'b0;
      tbrx_state      <= TBRX_IDLE;
      got_cnt          = 0;
      H1_got           = 0;
      H2_got           = 0;
      di               = 0;
      data0            = 0;
      data1            = 0;
   end
   else begin
      rx_st_del1 <= rx_st;      rx_st_del2 <= rx_st_del1; rx_st_del3 <= rx_st_del2; rx_st_del4 <= rx_st_del3;
      rx_st_del5 <= rx_st_del4; rx_st_del6 <= rx_st_del5; rx_st_del7 <= rx_st_del6; rx_st_del8 <= rx_st_del7;

      if(rx_st) 
         pkt_inprogress <= 1'b1;
      else if(rx_end)
         pkt_inprogress <= 1'b0;

      //State Machine for Header & Data check
      //d1 = d2; d2 = d3 ; d3 = d4 ; d4 = rx_data;
      d1  = (rx_st) ? rx_data : d1;
      d2  = (rx_st_del1) ? rx_data : d2;
      d3  = (rx_st_del2) ? rx_data : d3;
      d4  = (rx_st_del3) ? rx_data : d4;
      d5  = (rx_st_del4) ? rx_data : d5;
      d6  = (rx_st_del5) ? rx_data : d6;
      d7  = (rx_st_del6) ? rx_data : d7;
      d8  = (rx_st_del7) ? rx_data : d8;
      rx_data_del <= rx_data;
      case(tbrx_state)
         TBRX_IDLE : begin 
            if(wt_cnt != got_cnt) begin
               tbrx_state  <= TBRX_SOP;
            end
         end
         TBRX_SOP : begin   //Wait for SOP, Header & check the Header 
            //------------Header check ---------------
            if(rx_st_x4) 
               H1_got = {d1, d2, d3, d4};
            if(rx_st_x4_del) 
               H2_got = {d5, d6, d7, d8};
               //H2_got = {d1, d2, d3, d4};

            //if(rx_st_del1) begin 
            if(rx_st_del7 || (rx_st_del5 && (NEW_fmt == 2'b00))) begin   //3dw with no data or Others
               CHECK_HEADER;
               if(!fmt_type_err) begin
                  if(stored_fmt == 2'b10)  //3dw with data
                     CHECK_DATA(0);
               end
               else begin
                  if(rx_end)
                     if(!rx_malf_tlp && !rx_us_req) begin   //FMT/TYPE error found
                     //if(!rx_malf_tlp && (stored_error != NO_TLP_ERR)) begin
                        $display ("TBRX-TC%d: **** ERROR **** : MALF PKT - rx_malf_tlp is not Asserted at time %0t", rx_tc, $time);
                        TBRX_Error = 1'b1;
                     end
               end
            end

            //------------Error Signal check ---------------
            di = stored_fmt[0] ? 0 : 1;   //3dw or 4dw header
            toggle = 0;
            //if(rx_st_del1) begin 
            if(rx_st_del7 || (rx_st_del5 && (NEW_fmt == 2'b00))) begin   //3dw with no data or Others
               if(rx_end) begin
                  EOP_TASK;
                  tbrx_state  <= TBRX_IDLE;
                  got_cnt     = (man_tlp_pkt) ? (got_cnt + 2) : (got_cnt + 1);
                  rx_st_del6 <= 0; rx_st_del7 <= 0; rx_st_del8 <= 0;
               end
               else
                  tbrx_state  <= TBRX_DATA;
            end
         end
         TBRX_DATA : begin 
            if(!fmt_type_err) begin
               if(toggle) begin
                  //------------Data check ---------------
                  CHECK_DATA(di);

                  //------------Len check ---------------
                  di = di+1;
                  if(rx_end) begin
                     if((di > stored_len) || (di < stored_len)) begin 
                        if(!rx_malf_tlp) begin
                           $display ("TBRX-TC%d: **** ERROR **** : Length & Actual Data Length Mismatch at time %0t", rx_tc, $time);
                           TBRX_Error = 1'b1;
                        end
                        else begin
                           if (`DEBUG) $display ("TBRX-TC%d: INFO: RECEIVED MALFORMED TLP at time %0t", rx_tc, $time);
                        end
                     end
                     else begin
                        `ifdef ECRC
                        if(!rx_ecrc_err && !rx_malf_tlp && !rx_us_req && (stored_error != NO_TLP_ERR)) begin
                       `else
                        if(!rx_malf_tlp && !rx_us_req && (stored_error != NO_TLP_ERR)) begin
                       `endif
                           $display ("TBRX-TC%d: **** ERROR **** : MALF PKT - rx_malf_tlp is not Asserted at time %0t", rx_tc, $time);
                           TBRX_Error = 1'b1;
                        end
                     end //rx_end check
                  end
               end //toggle check
               else if(rx_end) begin
                  $display ("TBRX-TC%d: **** ERROR **** : Non-Dword aligned pkt at time %0t", rx_tc, $time);
                  TBRX_Error = 1'b1;
               end
            end //fmt_type_err
            else begin
               if(rx_end)
                  if(!rx_malf_tlp && !rx_us_req) begin   //FMT/TYPE error found
                  //if(!rx_malf_tlp && (stored_error != NO_TLP_ERR)) begin
                     $display ("TBRX-TC%d: **** ERROR **** : MALF PKT - rx_malf_tlp is not Asserted at time %0t", rx_tc, $time);
                     TBRX_Error = 1'b1;
                  end
            end

            //------------Error Signal check ---------------
            if(rx_end) begin
               EOP_TASK;
               tbrx_state  <= TBRX_IDLE;
               got_cnt     = (man_tlp_pkt) ? (got_cnt + 2) : (got_cnt + 1);
            end
            toggle = ~toggle;
         end
      endcase

      //SOP & EOP checking 
      case(tbrx_state)
         TBRX_IDLE : begin 
            if((wt_cnt == got_cnt) && (rx_st || rx_end)) begin
               $display ("TBRX-TC%d: **** ERROR **** : Unexpected SOP/EOP signals at time %0t", rx_tc, $time);
               TBRX_Error = 1'b1;
            end
         end
         TBRX_SOP : begin
            if(rx_st && rx_end) begin
               TBRX_Error = 1'b1;
               $display ("TBRX-TC%d: **** ERROR **** : SOP & EOP at the same time at time %0t", rx_tc, $time);
            end
            /*****
            if(rx_st_del5 && short_pkt && !rx_end) begin
               TBRX_Error = 1'b1;
               $display ("TBRX-TC%d: **** ERROR **** : Short Pkt, but EOP missing at time %0t", rx_tc, $time);
            end 
            *****/
            if(!fmt_type_err) begin
               /*****
               if((rx_st_x4 || rx_st_del4 || rx_st_del5) && !short_pkt && rx_end) begin
                  TBRX_Error = 1'b1;
                  $display ("TBRX-TC%d: **** ERROR **** : Not a Short Pkt, but EOP has come at time %0t", rx_tc, $time);
               end 
               *****/
               if((rx_st_x4 || rx_st_del4) && rx_end) begin
                  TBRX_Error = 1'b1;
                  $display ("TBRX-TC%d: **** ERROR **** : PKT smaller than 3 Dwords at time %0t", rx_tc, $time);
               end 
            end 
         end
         TBRX_DATA : begin 
            if(!fmt_type_err) begin
            if(rx_st) begin
               $display ("TBRX-TC%d: **** ERROR **** : SOP before the end of current PKT at time %0t", rx_tc, $time);
               TBRX_Error = 1'b1;
            end
            end 
         end 
      endcase

   end
end

// =============================================================================
// HEADER Check for the Received Pkt
// =============================================================================
// Input is H1_got & H2_got 
task CHECK_HEADER;
begin
    TAG        = TBRX_TAG + 1;
    TBRX_TAG   = TAG;
    TAG        = {3'b000, TBRX_TAG[4:0]};

    TD         = wt_td;
    EP         = wt_ep;
    Error_Type = wt_et;

    //Reset First
    {R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12} = 12'd0;
    TBRX_UPPER32_ADDRx  = TBRX_UPPER32_ADDR;
    FirstDatax          = 32'd0;

    short_pkt    = 0; //no data OR 3 DW with 1 data
    exp_dwen     = 0;
    fmt_type_err = 0;
    man_tlp_pkt  = 0;

    case (wt_type)
       MEM_RD,
       MEM_WR :  begin
          //TC         = rx_tc;
          TC         = (wt_tc_set) ? wt_tc : rx_tc;
          ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          fmt[1]     = (wt_type == MEM_RD) ? 1'b0 : 1'b1;
          fmt[0]     = (wt_hdr) ? 1'b1 : 1'b0;   //32-bit /64-bit addressing (3 DW /4 DW)
          type       = MEM_TYPE;
          len        = wt_len;
          FirstDW_BE = wt_be[7:4];
          LastDW_BE  = wt_be[3:0];

          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx}  = H1_got[63:32]; 
          {TBRX_REQ_IDx, TAGx, LastDW_BEx, FirstDW_BEx}                   = H1_got[31:0];
          if(wt_hdr) //64-bit Addr / 4 DW header
             {TBRX_UPPER32_ADDRx, wt_addrx[31:2], R9, R10}  = H2_got;
          //else if(wt_type == MEM_RD)    //3DW with No data  -- 03.17.06
             //{wt_addrx[31:2], R11, R12}         = H2_got[31:0];
          else  //3 DW with data
             {wt_addrx[31:2], R11, R12, FirstDatax}         = H2_got;

          `ifdef DIS_TAG_CHK
          TAG = TAGx;
          `endif

          //First 8 bytes of Header
          H1_ms_exp  = {R, fmt, type, R, TC, R,R,R,R, TD, EP, ATTR, R,R, len};
          H1_ls_exp  = {TBRX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};

          //Second 4 bytes of Header
          if(wt_hdr) begin  //64-bit Addr / 4 DW header
             H2_ms_exp  = TBRX_UPPER32_ADDR;
             H2_ls_exp  = {wt_addr[31:2], R, R};
          end
          else begin 
             H2_ms_exp  = {wt_addr[31:2], R, R};
             H2_ls_exp  = H2_got[31:0];  //This is not header , but may be first data
          end

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = (TBRX_REQ_IDx != TBRX_REQ_ID) ? REQ_ID_C : Error_code;
          Error_code = (TAGx != TAG) ? TAG_C : Error_code;
          Error_code = (LastDW_BEx != LastDW_BE) ? LastDW_BE_C : Error_code;
          Error_code = (FirstDW_BEx != FirstDW_BE) ? FirstDW_BE_C : Error_code;

          Error_code = (wt_addrx[31:2] != wt_addr[31:2]) ? ADDR_C : Error_code;
          //Error_code = (FirstDatax != 32'd0) ? DATA_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12} != 12'd0) ? RSRV_C : Error_code;

          //MEM_RD with 3DW/4DW, MEM_WR with 3DW Header & 1 data
          if((wt_type == MEM_RD) || ((wt_type == MEM_WR) && (wt_hdr == 0) && (len == 1))) begin
             short_pkt  = 1;
             exp_dwen   = ((wt_type == MEM_RD) && (!wt_hdr)) ? 1'b0 : 1'b1;
          end
          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got != {H2_ms_exp, H2_ls_exp})) begin
             if(wt_type == MEM_RD)
                $display ("TBRX-TC%d: **** ERROR in Mem RD Header **** : at time %0t", rx_tc, $time);
             else
                $display ("TBRX-TC%d: **** ERROR in Mem WR Header **** : at time %0t", rx_tc, $time);
             TBRX_Error = 1;
             ERROR_TASK;
          end

       end
       CFG_RD,
       CFG_WR : begin
          //TC         = 3'b000;  //Always
          //ATTR       = 2'b00;   //Always
          //len        = 10'd1;   //Always
          //LastDW_BE  = 4'b0000; //Always
          TC         = TBRX_TC;
          ATTR       = TBRX_ATTR; 
          LastDW_BE  = TBRX_LastDW_BE;
          len        = TBRX_LEN; 

          fmt[1]     = (wt_type == CFG_RD) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b0;    //Always 3 DW 
          type       = (wt_cfg) ? CFG1_TYPE : CFG0_TYPE;
          FirstDW_BE = wt_be[7:4];

          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx} = H1_got[63:32];
          {TBRX_REQ_IDx, TAGx, LastDW_BEx, FirstDW_BEx}                  = H1_got[31:0];
          wt_addrx  = H2_got[63:32];

          `ifdef DIS_TAG_CHK
          TAG = TAGx;
          `endif

          //First 8 bytes of Header
          H1_ms_exp  = {R, fmt, type, R, TC, R,R,R,R, TD, EP, ATTR, R,R, len};
          H1_ls_exp  = {TBRX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};

          //Second 4 bytes of Header
          H2_ms_exp  = wt_addr;
          H2_ls_exp  = 32'd0;

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = (TBRX_REQ_IDx != TBRX_REQ_ID) ? REQ_ID_C : Error_code;
          Error_code = (TAGx != TAG) ? TAG_C : Error_code;
          Error_code = (LastDW_BEx != LastDW_BE) ? LastDW_BE_C : Error_code;
          Error_code = (FirstDW_BEx != FirstDW_BE) ? FirstDW_BE_C : Error_code;

          Error_code = (wt_addrx[31:2] != wt_addr[31:2]) ? ADDR_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8} != 8'd0) ? RSRV_C : Error_code;

          short_pkt  = 1;
          exp_dwen   = (wt_type == CFG_RD) ? 1'b0 : 1'b1;
          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got[63:32] != H2_ms_exp)) begin
             case({wt_cfg, fmt[1]})  //or wt_type
                2'b00 : $display ("TBRX-TC%d: **** ERROR in CFG0 RD Header **** : at time %0t", rx_tc, $time);
                2'b01 : $display ("TBRX-TC%d: **** ERROR in CFG0 WR Header **** : at time %0t", rx_tc, $time);
                2'b10 : $display ("TBRX-TC%d: **** ERROR in CFG1 RD Header **** : at time %0t", rx_tc, $time);
                2'b11 : $display ("TBRX-TC%d: **** ERROR in CFG1 WR Header **** : at time %0t", rx_tc, $time);
             endcase
             TBRX_Error = 1;
             ERROR_TASK;
          end

       end
       IO_RD,
       IO_WR  : begin
          //TC         = 3'b000;  //Always
          //ATTR       = 2'b00;   //Always
          //len        = 10'd1;   //Always
          //LastDW_BE  = 4'b0000; //Always
          TC         = TBRX_TC;
          ATTR       = TBRX_ATTR; 
          LastDW_BE  = TBRX_LastDW_BE;
          len        = TBRX_LEN; 

          fmt[1]     = (wt_type == IO_RD) ? 1'b0 : 1'b1;
          //fmt[0]     = (wt_hdr) ? 1'b1 : 1'b0;   //32-bit /64-bit addressing (3 DW /4 DW)
          fmt[0]     = 1'b0;    //Always 3 DW 
          type       = IO_TYPE;
          FirstDW_BE = wt_be[7:4];

          //Second 4/8 bytes of Header
          /****
          if(wt_hdr) begin  //64-bit Addr / 4 DW header
             H2_ms_exp  = TBRX_UPPER32_ADDR;
             H2_ls_exp  = {wt_addr[31:2], R, R};
          end
          else begin 
             H2_ms_exp  = {wt_addr[31:2], R, R};
             H2_ls_exp  = H2_got[31:0];  //This is not header , but may be first data
          end
          ****/

          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx}  = H1_got[63:32]; 
          {TBRX_REQ_IDx, TAGx, LastDW_BEx, FirstDW_BEx}                   = H1_got[31:0];
          if(wt_hdr) //64-bit Addr / 4 DW header
             {TBRX_UPPER32_ADDRx, wt_addrx[31:2], R9, R10}  = H2_got;
          else 
             {wt_addrx[31:2], R11, R12, FirstDatax}         = H2_got;

          `ifdef DIS_TAG_CHK
          TAG = TAGx;
          `endif

          //First 8 bytes of Header
          H1_ms_exp  = {R, fmt, type, R, TC, R,R,R,R, TD, EP, ATTR, R,R, len};
          H1_ls_exp  = {TBRX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};
          //Second 4/8 bytes of Header
          H2_ms_exp  = {wt_addr[31:2], R, R};
          H2_ls_exp  = H2_got[31:0];  //This is not header , but may be first data

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = (TBRX_REQ_IDx != TBRX_REQ_ID) ? REQ_ID_C : Error_code;
          Error_code = (TAGx != TAG) ? TAG_C : Error_code;
          Error_code = (LastDW_BEx != LastDW_BE) ? LastDW_BE_C : Error_code;
          Error_code = (FirstDW_BEx != FirstDW_BE) ? FirstDW_BE_C : Error_code;

          Error_code = (wt_addrx[31:2] != wt_addr[31:2]) ? ADDR_C : Error_code;
          //Error_code = (FirstDatax != 32'd0) ? DATA_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12} != 12'd0) ? RSRV_C : Error_code;

          //IO_RD with 3DW/4DW, IO_WR with 3DW Header & 1 data
          //if((wt_type == IO_RD) || ((wt_type == IO_WR) && (wt_hdr == 0) && (len == 1))) begin
             short_pkt  = 1;
             exp_dwen   = (wt_type == IO_RD) ? 1'b0 : 1'b1;
          //end
          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got != {H2_ms_exp, H2_ls_exp})) begin
             if(wt_type == IO_RD)
                $display ("TBRX-TC%d: **** ERROR in IO RD Header **** : at time %0t", rx_tc, $time);
             else
                $display ("TBRX-TC%d: **** ERROR in IO WR Header **** : at time %0t", rx_tc, $time);
             TBRX_Error = 1;
             ERROR_TASK;
          end

       end
       MSG,
       MSG_D  : begin
          //TC         = rx_tc;
          TC         = (wt_tc_set) ? wt_tc : rx_tc;
          //ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          ATTR       = TBRX_ATTR; 
          fmt[1]     = (wt_type == MSG) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b1;    //Always 4 DW 
          type       = {MSG_TYPE[4:3], TBRX_MSG_ROUTE};
          len        = wt_len;

          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx}  = H1_got[63:32]; 
          {TBRX_REQ_IDx, TAGx, TBRX_MSG_CODEx}                   = H1_got[31:0];
          TBRX_MSG_TYPEx   = H2_got;

          `ifdef DIS_TAG_CHK
          TAG = TAGx;
          `endif
          `ifdef DIS_TC_CHK
          TC = TCx;
          `endif

          //First 8 bytes of Header
          H1_ms_exp  = {R, fmt, type, R, TC, R,R,R,R, TD, EP, ATTR, R,R, len};
          H1_ls_exp  = {TBRX_REQ_ID, TAG, TBRX_MSG_CODE};
          //Second 8 bytes of Header
          {H2_ms_exp, H2_ls_exp} = TBRX_MSG_TYPE;

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = (TBRX_REQ_IDx != TBRX_REQ_ID) ? REQ_ID_C : Error_code;
          Error_code = (TAGx != TAG) ? TAG_C : Error_code;

          Error_code = (TBRX_MSG_CODEx != TBRX_MSG_CODE) ? MSGCODE_C : Error_code;
          Error_code = (TBRX_MSG_TYPEx != TBRX_MSG_TYPE) ? MSG_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8} != 8'd0) ? RSRV_C : Error_code;

          if(wt_type == MSG) begin
             short_pkt  = 1;
             exp_dwen   = 1;
          end
          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got != {H2_ms_exp, H2_ls_exp})) begin
             TBRX_Error = 1;
             ERROR_TASK;
          end

       end
       CPL,
       CPL_D  : begin
          //TC         = rx_tc;
          TC         = (wt_tc_set) ? wt_tc : rx_tc;
          ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          fmt[1]     = (wt_type == CPL) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b0;    //Always 3 DW 
          type       = CPL_TYPE;
          len        = wt_len;

          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx}  = H1_got[63:32]; 
          {TBRX_CPL_IDx, wt_statusx, TBRX_BCMx, wt_bytecntx}              = H1_got[31:0];
          {TBRX_REQ_IDx, TAGx, R9, wt_loweraddrx}                         = H2_got[63:32];

          `ifdef DIS_TAG_CHK
          TAG = TAGx;
          `endif

          //First 8 bytes of Header
          H1_ms_exp  = {R, fmt, type, R, TC, R,R,R,R, TD, EP, ATTR, R,R, len};
          H1_ls_exp  = {TBRX_CPL_ID, wt_status, TBRX_BCM, wt_bytecnt};
          //Second 4 bytes of Header
          H2_ms_exp  = {TBRX_REQ_ID, TAG, R, wt_loweraddr};
          H2_ls_exp  = 32'd0;

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = (TBRX_CPL_IDx != TBRX_CPL_ID) ? CPL_ID_C : Error_code;
          Error_code = (wt_statusx != wt_status) ? STATUS_C : Error_code;
          Error_code = (TBRX_BCMx != TBRX_BCM) ? BCM_C : Error_code;
          Error_code = (wt_bytecntx != wt_bytecnt) ? BYTECNT_C : Error_code;

          Error_code = (TBRX_REQ_IDx != TBRX_REQ_ID) ? REQ_ID_C : Error_code;
          Error_code = (TAGx != TAG) ? TAG_C : Error_code;
          Error_code = (wt_loweraddrx != wt_loweraddr) ? LOWERADDR_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8,R9} != 9'd0) ? RSRV_C : Error_code;

          if((wt_type == CPL) || ((wt_type == CPL_D) && len == 1)) begin
             short_pkt  = 1;
             exp_dwen   = (wt_type == CPL) ? 1'b0 : 1'b1;
          end
          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got[63:32] != H2_ms_exp)) begin
             TBRX_Error = 1;
             ERROR_TASK;
          end
       end
       TLP  : begin
          fmt_type_err  = (Error_Type == FMT_TYPE_ERR) ?  1'b1 : 1'b0; 
          man_tlp_pkt   = 1;

          H1_ms_exp  = wt_info[63:32];
          H1_ls_exp  = wt_info[31:0];
          H2_ms_exp  = wt_info2[63:32];
          H2_ls_exp  = (wt_info2[64]) ? wt_info2[31:0] : H2_got[31:0];  //For 3DW header dont check [31:0] 

          fmt        = wt_info[62:61];
          type       = wt_info[60:56];
          TC         = wt_info[54:52];
          TD         = wt_info[47];
          EP         = wt_info[46];
          ATTR       = wt_info[45:44];
          len        = wt_info[41:32];

          //{R,  fmt,  type,  R,  TC,  R,R,R,R,     TD,  EP,  ATTR,  R,R,   len}   = wt_info[63:32];
          {R1, fmtx, typex, R2, TCx, R3,R4,R5,R6, TDx, EPx, ATTRx, R7,R8, lenx}  = H1_got[63:32]; 

          Error_code = (typex != type) ? TYPE_C : Error_code;   //_C : Code
          Error_code = (fmtx != fmt) ? FMT_C : Error_code;
          Error_code = (TCx != TC) ? TC_C : Error_code;
          Error_code = (TDx != TD) ? TD_C : Error_code;
          Error_code = (EPx != EP) ? EP_C : Error_code;
          Error_code = (ATTRx != ATTR) ? ATTR_C : Error_code;
          Error_code = (lenx != len) ? LEN_C : Error_code;
          Error_code = ({R1,R2,R3,R4,R5,R6,R7,R8} != 8'd0) ? RSRV_C : Error_code;

          if((H1_got != {H1_ms_exp, H1_ls_exp}) || (H2_got != {H2_ms_exp, H2_ls_exp})) begin
             TBRX_Error = 1;
             ERROR_TASK;
          end
       end
    endcase
    stored_type     = type;
    stored_fmt      = fmt;
    stored_len      = len;
    stored_error    = Error_Type;
    stored_kind     = wt_type;  //Mem or cfg or IO or TLP (rd or wr)

end
endtask

// =============================================================================
// TD : Set indicates Presence of TLP Digest (ECRC)
// EP : Set indicates data Poisoned 
// First DW BE :
// Last  DW BE :
// REQUESTER ID : 16 bits
// Tag  :8 bits 
// Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// =============================================================================

// =============================================================================
// 4 + 4 + 32 + 10 + 1 + 1 + 1 + 4 + 4  = 61
// Error Type + kind + addr + len + 3dw/4dw + TD + EP + FirstDwBE + LastDwBE
// For TLP type:  4 + 4 + 64 bit header = 72 bits
// =============================================================================
// =============================================================================
task tbrx_mem_rd;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_RD, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_mem_wr;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   if(length == 1)
      TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_WR, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   else
      TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_WR, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, Last_DW_BE, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_msg;
input [9:0]   length;
input  [3:0]   Error_Type;
begin
   //Meassge Route & Meassge Code are default values
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MSG, 32'd0, length, HEAD_4DW, TBRX_TD, TBRX_EP, 4'b0, 4'b0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_msg_d;
input [9:0]   length;
input  [3:0]  Error_Type;
begin
   //Meaasge Route & Meassge Code are default values
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MSG_D, 32'd0, length, HEAD_4DW, TBRX_TD, TBRX_EP, 4'b0, 4'b0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input [9:0]   length;
input  [3:0]   Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, CFG_RD, addr, length, HEAD_3DW, TBRX_TD, TBRX_EP, First_DW_BE, 3'h0, cfg, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input [9:0]   length;
input  [3:0]   Error_Type;
begin
   //addr = {Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, CFG_WR, addr, length, HEAD_3DW, TBRX_TD, TBRX_EP, First_DW_BE, 3'h0, cfg, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_io_rd;
input  [31:0]  addr;
input [9:0]   length;
input  [3:0]   Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, IO_RD, addr, length, HEAD_3DW, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_io_wr;
input  [31:0]  addr;
input [9:0]   length;
input  [3:0]   Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, IO_WR, addr, length, HEAD_3DW, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_cpl;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [3:0]  Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, CPL, byte_cnt, lower_addr, status, 10'd0,  length,  HEAD_3DW, TBRX_TD, TBRX_EP, 8'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_cpl_d;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [3:0]  Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, CPL_D, byte_cnt, lower_addr, status,  10'd0, length,  HEAD_3DW, TBRX_TD, TBRX_EP, 8'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// Good Pkt : User has to form the Header
// Malformed Pkt : For sending a pkt with fmt & Type Error Only
// =============================================================================
task tbrx_tlp;  //When Giving Malformed TLP (Only fmt & Type error)
input  [3:0]  Error_Type;
input         hdr_type;  //3 DW or 4 DW 
input [31:0]  h1_msb;
input [31:0]  h1_lsb;
input [31:0]  h2_msb;
input [31:0]  h2_lsb;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, TLP, h1_msb, h1_lsb};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
   TBRX_WAIT_FIFO[wt_cnt] = {7'b0, hdr_type, h2_msb, h2_lsb};
   TBRX_FIFO_TC[wt_cnt]   = 0;
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// TASKS that require TC change
// =============================================================================
task tbrx_mem_rd_tc;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_RD, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = {1'b1, tc};
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbrx_mem_wr_tc;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW 
input  [3:0]   Error_Type;
begin
   if(length == 1)
      TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_WR, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, 4'h0, 11'd0};
   else
      TBRX_WAIT_FIFO[wt_cnt] = {Error_Type, MEM_WR, addr, length, hdr_type, TBRX_TD, TBRX_EP, First_DW_BE, Last_DW_BE, 11'd0};
   TBRX_FIFO_TC[wt_cnt]   = {1'b1, tc};
   wt_cnt = wt_cnt + 1;
end
endtask

// =============================================================================
// FLOW CONTROL Tasks
// =============================================================================
initial begin
   //Init Flow Control Credits
   ph_buf_status   <= 1'b0;
   pd_buf_status   <= 1'b0;
   nph_buf_status  <= 1'b0;
   npd_buf_status  <= 1'b0;
   cplh_buf_status <= 1'b0;
   cpld_buf_status <= 1'b0;
   ph_processed    <= 1'b0;
   pd_processed    <= 1'b0;
   nph_processed   <= 1'b0;
   npd_processed   <= 1'b0;
   cplh_processed  <= 1'b0;
   cpld_processed  <= 1'b0;
   pd_num          <= 8'd1;
   npd_num         <= 8'd1;
   cpld_num        <= 8'd1;
   INIT_PH_FC      <= 0;   // Inifinite
   INIT_PD_FC      <= 0;
   INIT_NPH_FC     <= 0;
   INIT_NPD_FC     <= 0;
   INIT_CPLH_FC    <= 0;
   INIT_CPLD_FC    <= 0;
end

// =============================================================================
// Setting INIT values
// =============================================================================
task FC_INIT;
input  [1:0]  type;  // p/np/cpl
input  [7:0]  hdr;
input  [11:0] data;
begin
   case(type)
      P   : begin
         INIT_PH_FC   <= hdr;
         INIT_PD_FC   <= data;
      end
      NP  : begin
         INIT_NPH_FC  <= hdr;
         INIT_NPD_FC  <= data;
      end
      CPLX : begin
         INIT_CPLH_FC <= hdr;
         INIT_CPLD_FC <= data;
      end
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of buf_status signals
// =============================================================================
task FC_BUF_STATUS;
input  [2:0]  type;  // ph/pd/nph/npd/cpl/cpld
input         set;   // Set=1: Assert the signal  , Set=0, De-assert the signal
begin
   case(type)
      PH   : ph_buf_status   <= set;
      PD   : pd_buf_status   <= set;
      NPH  : nph_buf_status  <= set;
      NPD  : npd_buf_status  <= set;
      CPLH : cplh_buf_status <= set;
      CPLD : cpld_buf_status <= set;
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of Processed signals
// Onle pulse
// =============================================================================
task FC_PROCESSED;
input  [2:0]  type;  // ph/pd/nph/npd/cpl/cpld
begin
   case(type)
      PH   : begin
         ph_processed   <= 1'b1;
      end
      PD   : begin
         pd_processed   <= 1'b1;
         pd_num         <= 8'd1;
      end
      NPH  : begin
         nph_processed  <= 1'b1;
      end
      NPD  : begin
         npd_processed  <= 1'b1;
         npd_num        <= 8'd1;
      end
      CPLH : begin
         cplh_processed <= 1'b1;
      end
      CPLD : begin
         cpld_processed <= 1'b1;
         cpld_num       <= 8'd1;
      end
   endcase
   @( posedge sys_clk) 
   case(type)
      PH   : begin
         ph_processed   <= 1'b0;
      end
      PD   : begin
         pd_processed   <= 1'b0;
         pd_num         <= 8'd0;
      end
      NPH  : begin
         nph_processed  <= 1'b0;
      end
      NPD  : begin
         npd_processed  <= 1'b0;
         npd_num        <= 8'd0;
      end
      CPLH : begin
         cplh_processed <= 1'b0;
      end
      CPLD : begin
         cpld_processed <= 1'b0;
         cpld_num       <= 8'd0;
      end
   endcase
end
endtask

task FC_PROCESSED_NUM;
input  [2:0]  type;  // ph/pd/nph/npd/cpl/cpld
input  [7:0]  num;   // no. of data pd/npd/cpld  (no. of credits : 4DW is 1 credit)
begin
   case(type)
      PH   : begin
         ph_processed   <= 1'b1;
      end
      PD   : begin
         pd_processed   <= 1'b1;
         pd_num         <= num;
      end
      NPH  : begin
         nph_processed  <= 1'b1;
      end
      NPD  : begin
         npd_processed  <= 1'b1;
         npd_num        <= num;
      end
      CPLH : begin
         cplh_processed <= 1'b1;
      end
      CPLD : begin
         cpld_processed <= 1'b1;
         cpld_num       <= num;
      end
   endcase
   @( posedge sys_clk) 
   case(type)
      PH   : begin
         ph_processed   <= 1'b0;
      end
      PD   : begin
         pd_processed   <= 1'b0;
         pd_num         <= 8'd0;
      end
      NPH  : begin
         nph_processed  <= 1'b0;
      end
      NPD  : begin
         npd_processed  <= 1'b0;
         npd_num        <= 8'd0;
      end
      CPLH : begin
         cplh_processed <= 1'b0;
      end
      CPLD : begin
         cpld_processed <= 1'b0;
         cpld_num       <= 8'd0;
      end
   endcase
end
endtask

// =============================================================================
// 1) Error Signal Assertion Check during EOP
// 2) Length check for IO, CFG (length == 1)
// =============================================================================
task EOP_TASK;
begin
  // Length check for IO & CFG
   /*
   case(stored_type)
       IO_RD,
       IO_WR,
       CFG_RD,
       CFG_WR : begin
          if((stored_len != TBRX_LEN) && (!rx_malf_tlp)) begin  //length should be 1
             TBRX_Error = 1;
             $display ("TBRX-TC%d: **** ERROR **** :  length error for IO/CFG pkt at time %0t", rx_tc, $time);
          end
       end
  endcase 
  */

  // Checking the Error Signal Assertion
  case(stored_error)
     ECRC_ERR :  begin
     `ifdef ECRC
        if(!rx_ecrc_err) begin
           TBRX_Error = 1;
           $display ("TBRX-TC%d: **** ERROR **** :  Expecting ERROR PKT", rx_tc);
           $display ("TBRX-TC%d: **** ERROR **** :  rx_ecrc_err is NOT ASSERTED at time %0t", rx_tc, $time);
        end
     `endif
     end
     UNSUP_ERR :  begin
        if(!rx_us_req) begin
           TBRX_Error = 1;
           $display ("TBRX-TC%d: **** ERROR **** :  Expecting ERROR PKT", rx_tc);
           $display ("TBRX-TC%d: **** ERROR **** :  rx_us_req is NOT ASSERTED at time %0t", rx_tc, $time);
        end
     end
     MALF_ERR : begin
        if(!rx_malf_tlp) begin
           TBRX_Error = 1;
           $display ("TBRX-TC%d: **** ERROR **** :  Expecting ERROR PKT", rx_tc);
           $display ("TBRX-TC%d: **** ERROR **** :  rx_malf_tlp is NOT ASSERTED at time %0t", rx_tc, $time);
        end
     end
     FMT_TYPE_ERR :  begin
        if(!rx_malf_tlp && !rx_us_req) begin
           TBRX_Error = 1;
           $display ("TBRX-TC%d: **** ERROR **** :  Expecting ERROR PKT", rx_tc);
           $display ("TBRX-TC%d: **** ERROR **** :  rx_malf_tlp/rx_us_req is NOT ASSERTED at time %0t", rx_tc, $time);
        end
     end
     default : begin
     `ifdef ECRC
        if(rx_ecrc_err || rx_malf_tlp || rx_us_req) begin
     `else
        if(rx_malf_tlp || rx_us_req) begin
     `endif
           TBRX_Error = 1;
           $display ("TBRX-TC%d: **** ERROR **** :  Unexpected error signal assertion for a good PKT at time %0t", rx_tc, $time);
        end
     end
  endcase

  if(!TBRX_Error && (`DEBUG==1)) begin
     $display ("TBRX-TC%d: SUCCESSFUL PKT TRANSFER (Pkt no:%0d) at time %0t", rx_tc, got_cnt,$time);
  end

end
endtask
// =============================================================================
// Data Generation & Checking
// =============================================================================
task CHECK_DATA;
input  [10:0] data_no;
reg    [31:0] data32;
integer       i,j;
begin
   i = data_no*2;
   j = i + 1;
   if(TBRX_MANUAL_DATA) begin
      {data0, data1}  = D[i];
   end
   else if(TBRX_FIXED_PATTERN) begin
      case(data_no[4:0])
         0  : {data0, data1} = 32'h0000_1111;
         1  : {data0, data1} = 32'h2222_3333;
         2  : {data0, data1} = 32'h4444_5555;
         3  : {data0, data1} = 32'h6666_7777;
         4  : {data0, data1} = 32'h8888_9999;
         5  : {data0, data1} = 32'hAAAA_BBBB;
         6  : {data0, data1} = 32'hCCCC_DDDD;
         7  : {data0, data1} = 32'hEEEE_FFFF;
         8  : {data0, data1} = 32'h1010_1111;
         9  : {data0, data1} = 32'h1212_1313;
         10 : {data0, data1} = 32'h1414_1515;
         11 : {data0, data1} = 32'h1616_1717;
         12 : {data0, data1} = 32'h1818_1919;
         13 : {data0, data1} = 32'h1A1A_1B1B;
         14 : {data0, data1} = 32'h1C1C_1D1D;
         15 : {data0, data1} = 32'h1E1E_1F1F;
         16 : {data0, data1} = 32'h2020_2121;
         17 : {data0, data1} = 32'h2222_2323;
         18 : {data0, data1} = 32'h2424_2525;
         19 : {data0, data1} = 32'h2626_2727;
         20 : {data0, data1} = 32'h2828_2929;
         21 : {data0, data1} = 32'h2A2A_2B2B;
         22 : {data0, data1} = 32'h2C2C_2D2D;
         23 : {data0, data1} = 32'h2E2E_2F2F;
         24 : {data0, data1} = 32'h3030_3131;
         25 : {data0, data1} = 32'h3232_3333;
         26 : {data0, data1} = 32'h3434_3535;
         27 : {data0, data1} = 32'h3636_3737;
         28 : {data0, data1} = 32'h3838_3939;
         29 : {data0, data1} = 32'h3A3A_3B3B;
         30 : {data0, data1} = 32'h3C3C_3D3D;
         31 : {data0, data1} = 32'h3E3E_3F3F;
      endcase
   end
   else begin  //Default - Incremental Data
      data0 = i;
      data1 = j;
   end

   data32 = {data0, data1};
   if(data32 != {rx_data_del, rx_data})
      TBRX_Error = 1'b1;

   if(TBRX_Error) begin
      $display ("TBRX-TC%d: **** ERROR **** : Data Mismatch at time %0t", rx_tc, $time);
      $display ("          DataNo=%0d, Exp data=%h, Rcvd Data=%h_%h", data_no, data32, rx_data_del, rx_data);
   end

   /****** for DEBUG 
   $display ("TBRX-TC%d: --------- CHECK --------- at time %0t", rx_tc, $time);
   $display ("          DataNo=%0d, Exp data=%h, Rcvd Data=%h_%h", data_no, data32, rx_data_del, rx_data);
   ******/
end
endtask

// =============================================================================
// ERROR Conditions : Simulation stopped
// =============================================================================
always @(TBRX_Error) begin
   if(TBRX_Error) begin
      repeat (100) @(posedge sys_clk);
      $display ("TBRX: -- Sim stopped by TBRX -- at time %0t", $time);
      $finish;
   end
end

// =============================================================================
task ERROR_TASK;
begin
   $display ("TBRX-TC%d: **** ERROR **** : HEADER Mismatch at time %0t", rx_tc, $time);
   case(Error_code)
      TYPE_C       : $display ("        TYPE error: Exp TYPE=%b, Rcvd TYPE=%b",type, typex);
      FMT_C        : $display ("        FMT error: Exp FMT=%b, Rcvd FMT=%b", fmt, fmtx);
      TC_C         : $display ("        TC/VC error: Exp TC=%d, Rcvd TC=%d", TC,TCx);
      TD_C         : $display ("        TD error: Exp TD=%b, Rcvd TD=%b", TD,TDx);
      EP_C         : $display ("        EP error: Exp EP=%b, Rcvd EP=%b", EP,EPx);
      ATTR_C       : $display ("        ATTR error: Exp ATTR=%b, Rcvd ATTR=%b", ATTR, ATTRx);
      LEN_C        : $display ("        Length error: Exp Length=%d, Rcvd Length=%d", len,lenx);
      RSRV_C       : $display ("        RESERVED Bits error");
      REQ_ID_C     : $display ("        REQ_ID error: Exp REQ_ID=%h, Rcvd REQ_ID=%h", TBRX_REQ_ID, TBRX_REQ_IDx);
      TAG_C        : $display ("        TAG error: Exp TAG=%h, Rcvd TAG=%h", TAG,TAGx);
      LastDW_BE_C  : $display ("        LastDW_BE error: Exp LastDW_BE=%h, Rcvd LastDW_BE=%h", LastDW_BE, LastDW_BEx);
      FirstDW_BE_C : $display ("        FirstDW_BE error: Exp FirstDW_BE=%h, Rcvd FirstDW_BE=%h", FirstDW_BE, FirstDW_BEx);
      ADDR_C       : $display ("        Addr error: Exp Addr=%h, Rcvd Addr=%h", wt_addr, wt_addrx);
      //DATA_C       : $display ("        Data error: Exp Data=%h, Rcvd Data=%h", FirstData, FirstDatax);
      MSG_C        : $display ("        MSG Type error: Exp MSG Type=%h, Rcvd MSG Type=%h", TBRX_MSG_TYPE,TBRX_MSG_TYPEx);
      MSGCODE_C    : $display ("        MSG CODE error: Exp MSG Code=%h, Rcvd MSG Code=%h", TBRX_MSG_CODE,TBRX_MSG_CODEx);
      CPL_ID_C     : $display ("        CPL ID error: Exp CPL ID=%h, Rcvd CPL ID=%h", TBRX_CPL_ID, TBRX_CPL_IDx);
      STATUS_C     : $display ("        CPL Status Field error: Exp Status Field=%h, Rcvd Status Field=%h", wt_status,wt_statusx);
      BCM_C        : $display ("        CPL BCM error: Exp BCM=%h, Rcvd BCM=%h", TBRX_BCM, TBRX_BCMx);
      BYTECNT_C    : $display ("        CPL ByteCount error: Exp ByteCount=%h, Rcvd ByteCount=%h", wt_bytecnt, wt_bytecntx);
      LOWERADDR_C  : $display ("        CPL LowerAddr error: Exp LowerAddr=%h, Rcvd LowerAddr=%h", wt_loweraddr, wt_loweraddrx);
   endcase
   $display ("\n");
end
endtask

endmodule
// =============================================================================
// $Id: PCI_EXP_X1_11/technology/ver1.0/testbench/beh/tbrx.v 1.12 2006/08/30 16:37:31PDT uananthi Exp  $
