// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised
// by a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement
// from Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation    TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                        408-826-6000 (other locations)
// Hillsboro, OR 97124                  web  : http://www.latticesemi.com/
// U.S.A                                email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_exp
// File             : tb_params1.v
// Title            :
// Dependencies     : 
// Description      : Test bench environment parameters
//                    (Not dependent on testcase re-declarations) 
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        : Gopi  
// Mod. Date        : Apr 09, 2004
// Changes Made     : Initial Creation
// =============================================================================

//==============================================================================
// Core Defines
//==============================================================================
// Defines SKP insertion frequency Range 1180/2 =590  to 1538/2 = 769 
//==============================================================================
`define      SKP_INS_CNT       10'd670 

//==============================================================================
// TX DLLP Generation, ACK NAK Latency Timer in clks. This is calculated in the 
// following way 
// Max Packet Length       Num Of clocks      Margin    Total
// 4096                    4096/2 = 2048      13        2061
// 2048                    2048/2 = 1024      13        1037
// 1024                    1024/2 =  512      13         525 
//  512                     512/2 =  256      13         269 
// In worst case senario a Ack/NACK will be sent after (2061)+(TX Max Pkt Length)
//==============================================================================
`ifdef MAX_TLP_4K
   `define      ACKNAK_LAT_TIME    14'd2061
`else
   `ifdef MAX_TLP_2K
      `define      ACKNAK_LAT_TIME    14'd1037
   `else
      `ifdef MAX_TLP_1K
         `define      ACKNAK_LAT_TIME    14'd525
      `else
         `define      ACKNAK_LAT_TIME    14'd269
      `endif
   `endif
`endif


//==============================================================================
// RX Flow Control
// Sending Frquency of Update FC DLLP 
// For eg: Send for every 8 headers are processed OR every 1024 dwords of data 
// is processed by RX for each type (if Max Pkt length supported is 4K bytes).
//==============================================================================
// Value of the Update Freq counter
`define UPDATE_FREQ_PH     7'd8
`define UPDATE_FREQ_PD     11'd255
`define UPDATE_FREQ_NPH    7'd8
`define UPDATE_FREQ_NPD    11'd8

//==============================================================================
// RX Flow Control
// Update FC DLLP has to be sent at least once in every 30 Micrsec  (-0%/+50%)
// Take 45 Micro sec (this will be multiplied by 4 times if Exteneded sync bit of 
// Control Link Register is set).
// Taking a 12-bit counter (12'hFFF=4095 clks) & it will be 14-bit counter
// if Ext. Sync bit is set.
//==============================================================================
`define      UPDATE_TIMER 12'd4095



//==============================================================================

// Define the path for the parameters so that these can be changed in 
// the tests.
`define  st_seq_num       u1_dut.u1_dll.u1_txtp.u1_txtp_seq.ST_SEQ_NUM
`define  cal_seq_num      u1_dut.u1_dll.u1_txtp.u1_txtp_seq.CAL_SEQ_NUM
`define  ackd_seq         u1_dut.u1_dll.u1_rxdp.u1_rxdp_acknak.ACKD_SEQ
`define  txtp_reptim      u1_dut.u1_dll.u1_txtp.u1_txtp_rtry.RPLY_TMR_VAL


`define  CONF_UP_STATE           u1_dut.u1_phy.u1_ltssm.u1_cfg_up_sm.cs_cfg_sm
`define  LTSSM_MAIN_STATE        u1_dut.u1_phy.u1_ltssm.u1_main_sm.cs_main_sm
`define  CONF_UP_STATE_PCS       u1_dut.u1_phy.u1_ltssm.u1_cfg_up_sm.cs_cfg_sm
`define  LTSSM_MAIN_STATE_PCS    u1_top.u1_dut.u1_phy.u1_ltssm.u1_main_sm.cs_main_sm


`define  TB_CNT_1T1       u1_dut.u1_phy.u1_ltssm.CNT_1T1

`define  TB_CNT_1MS       u1_dut.u1_phy.u1_ltssm.CNT_1MS
`define  TB_CNT_1024T1    u1_dut.u1_phy.u1_ltssm.CNT_1024T1
`define  TB_CNT_2MS       u1_dut.u1_phy.u1_ltssm.CNT_2MS
`define  TB_CNT_12MS      u1_dut.u1_phy.u1_ltssm.CNT_12MS
`define  TB_CNT_24MS      u1_dut.u1_phy.u1_ltssm.CNT_24MS
`define  TB_CNT_48MS      u1_dut.u1_phy.u1_ltssm.CNT_48MS
`define  TB_CNT_100MS     u1_dut.u1_phy.u1_ltssm.CNT_100MS

// Define DLLP type fields
`define ACK      8'b0000_0000
`define NACK     8'b0001_0000

// Testbench Clock period 
parameter PERIOD  = 16;

// =============================================================================
// K & Special Symbols decodes.
`define K27_7     8'hFB 
`define K28_0     8'h1C 
`define K28_2     8'h5C 
`define K28_3     8'h7C 
`define K28_5     8'hBC 
`define K29_7     8'hFD 
`define K30_7     8'hFE 
`define D5_2      8'h45 
`define D10_2     8'h4A 
`define D21_5     8'hB5 
`define D26_5     8'hBA 

`define COM       `K28_5 
`define STP       `K27_7 
`define SDP       `K28_2 
`define END       `K29_7 
`define EDB       `K30_7 
`define SKP       `K28_0 
`define PAD       8'hF7 
`define FTS       8'h3C
`define IDL       8'h7C 

//--LTSSM Module Main State Machine states
`define      DETECT            4'd0
`define      POLLING           4'd1
`define      CONFIG            4'd2
`define      L0                4'd3
`define      L0s               4'd4
`define      L1                4'd5
`define      L2                4'd6
`define      RECOVERY          4'd7
`define      LOOPBACK          4'd8
`define      HOTRST            4'd9
`define      DISABLED          4'd10

// =============================================================================
// TBRX Defines
// =============================================================================
`define  TBRX_UPPER32_ADDR  32'h1000_0000
`define  TBRX_REQ_ID        16'hAAAA
`define  TBRX_CPL_ID        16'hBBBB

// =============================================================================
// TBTX Defines
// =============================================================================
`ifdef EN_VC0
   `define TBTX_UPPER32_ADDR_0  = tbtx[0].TBTX_UPPER32_ADDR;     // 32 bits
   `define TBTX_REQ_ID_0        = tbtx[0].TBTX_REQ_ID;           // 16 bits
   `define TBTX_CPL_ID_0        = tbtx[0].TBTX_CPL_ID;           // 16 bits
   `define TBTX_TAG_0           = tbtx[0].TBTX_TAG;              // 8 bits
   `define TBTX_TD_0            = tbtx[0].TBTX_TD;               //
   `define TBTX_EP_0            = tbtx[0].TBTX_EP;               //
   `define TBTX_BCM_0           = tbtx[0].TBTX_BCM;              //
   `define TBTX_MSG_RO_0        = tbtx[0].TBTX_MSG_ROUTE;        // 3 bits
   `define TBTX_MSG_CODE_0      = tbtx[0].TBTX_MSG_CODE;         // 8 bits
   `define TBTX_MSG_TYPE_0      = tbtx[0].TBTX_MSG_TYPE;         // 64 bits
   `define First_DW_BE_0        = tbtx[0].First_DW_BE;           // 4 bits
   `define Last_DW_BE_0         = tbtx[0].Last_DW_BE;            // 4 bits
   `define TBTX_MANUAL_DATA_0   = tbtx[0].TBTX_MANUAL_DATA;      //
   `define TBTX_FIXED_PATTERN_0 = tbtx[0].TBTX_FIXED_PATTERN;    //
`endif

`ifdef EN_VC1
   `define TBTX_UPPER32_ADDR_1  = tbtx[1].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_1        = tbtx[1].TBTX_REQ_ID;
   `define TBTX_CPL_ID_1        = tbtx[1].TBTX_CPL_ID;
   `define TBTX_TAG_1           = tbtx[1].TBTX_TAG;
   `define TBTX_TD_1            = tbtx[1].TBTX_TD;
   `define TBTX_EP_1            = tbtx[1].TBTX_EP;
   `define TBTX_BCM_1           = tbtx[1].TBTX_BCM;
   `define TBTX_MSG_RO_1        = tbtx[1].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_1      = tbtx[1].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_1      = tbtx[1].TBTX_MSG_TYPE;
   `define First_DW_BE_1        = tbtx[1].First_DW_BE;
   `define Last_DW_BE_1         = tbtx[1].Last_DW_BE;
   `define TBTX_MANUAL_DATA_1   = tbtx[1].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_1 = tbtx[1].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC2
   `define TBTX_UPPER32_ADDR_2  = tbtx[2].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_2        = tbtx[2].TBTX_REQ_ID;
   `define TBTX_CPL_ID_2        = tbtx[2].TBTX_CPL_ID;
   `define TBTX_TAG_2           = tbtx[2].TBTX_TAG;
   `define TBTX_TD_2            = tbtx[2].TBTX_TD;
   `define TBTX_EP_2            = tbtx[2].TBTX_EP;
   `define TBTX_BCM_2           = tbtx[2].TBTX_BCM;
   `define TBTX_MSG_RO_2        = tbtx[2].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_2      = tbtx[2].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_2      = tbtx[2].TBTX_MSG_TYPE;
   `define First_DW_BE_2        = tbtx[2].First_DW_BE;
   `define Last_DW_BE_2         = tbtx[2].Last_DW_BE;
   `define TBTX_MANUAL_DATA_2   = tbtx[2].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_2 = tbtx[2].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC3
   `define TBTX_UPPER32_ADDR_3  = tbtx[3].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_3        = tbtx[3].TBTX_REQ_ID;
   `define TBTX_CPL_ID_3        = tbtx[3].TBTX_CPL_ID;
   `define TBTX_TAG_3           = tbtx[3].TBTX_TAG;
   `define TBTX_TD_3            = tbtx[3].TBTX_TD;
   `define TBTX_EP_3            = tbtx[3].TBTX_EP;
   `define TBTX_BCM_3           = tbtx[3].TBTX_BCM;
   `define TBTX_MSG_RO_3        = tbtx[3].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_3      = tbtx[3].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_3      = tbtx[3].TBTX_MSG_TYPE;
   `define First_DW_BE_3        = tbtx[3].First_DW_BE;
   `define Last_DW_BE_3         = tbtx[3].Last_DW_BE;
   `define TBTX_MANUAL_DATA_3   = tbtx[3].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_3 = tbtx[3].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC4
   `define TBTX_UPPER32_ADDR_4  = tbtx[4].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_4        = tbtx[4].TBTX_REQ_ID;
   `define TBTX_CPL_ID_4        = tbtx[4].TBTX_CPL_ID;
   `define TBTX_TAG_4           = tbtx[4].TBTX_TAG;
   `define TBTX_TD_4            = tbtx[4].TBTX_TD;
   `define TBTX_EP_4            = tbtx[4].TBTX_EP;
   `define TBTX_BCM_4           = tbtx[4].TBTX_BCM;
   `define TBTX_MSG_RO_4        = tbtx[4].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_4      = tbtx[4].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_4      = tbtx[4].TBTX_MSG_TYPE;
   `define First_DW_BE_4        = tbtx[4].First_DW_BE;
   `define Last_DW_BE_4         = tbtx[4].Last_DW_BE;
   `define TBTX_MANUAL_DATA_4   = tbtx[4].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_4 = tbtx[4].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC5
   `define TBTX_UPPER32_ADDR_5  = tbtx[5].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_5        = tbtx[5].TBTX_REQ_ID;
   `define TBTX_CPL_ID_5        = tbtx[5].TBTX_CPL_ID;
   `define TBTX_TAG_5           = tbtx[5].TBTX_TAG;
   `define TBTX_TD_5            = tbtx[5].TBTX_TD;
   `define TBTX_EP_5            = tbtx[5].TBTX_EP;
   `define TBTX_BCM_5           = tbtx[5].TBTX_BCM;
   `define TBTX_MSG_RO_5        = tbtx[5].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_5      = tbtx[5].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_5      = tbtx[5].TBTX_MSG_TYPE;
   `define First_DW_BE_5        = tbtx[5].First_DW_BE;
   `define Last_DW_BE_5         = tbtx[5].Last_DW_BE;
   `define TBTX_MANUAL_DATA_5   = tbtx[5].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_5 = tbtx[5].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC6
   `define TBTX_UPPER32_ADDR_6  = tbtx[6].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_6        = tbtx[6].TBTX_REQ_ID;
   `define TBTX_CPL_ID_6        = tbtx[6].TBTX_CPL_ID;
   `define TBTX_TAG_6           = tbtx[6].TBTX_TAG;
   `define TBTX_TD_6            = tbtx[6].TBTX_TD;
   `define TBTX_EP_6            = tbtx[6].TBTX_EP;
   `define TBTX_BCM_6           = tbtx[6].TBTX_BCM;
   `define TBTX_MSG_RO_6        = tbtx[6].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_6      = tbtx[6].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_6      = tbtx[6].TBTX_MSG_TYPE;
   `define First_DW_BE_6        = tbtx[6].First_DW_BE;
   `define Last_DW_BE_6         = tbtx[6].Last_DW_BE;
   `define TBTX_MANUAL_DATA_6   = tbtx[6].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_6 = tbtx[6].TBTX_FIXED_PATTERN;
`endif

`ifdef EN_VC7
   `define TBTX_UPPER32_ADDR_7  = tbtx[7].TBTX_UPPER32_ADDR;
   `define TBTX_REQ_ID_7        = tbtx[7].TBTX_REQ_ID;
   `define TBTX_CPL_ID_7        = tbtx[7].TBTX_CPL_ID;
   `define TBTX_TAG_7           = tbtx[7].TBTX_TAG;
   `define TBTX_TD_7            = tbtx[7].TBTX_TD;
   `define TBTX_EP_7            = tbtx[7].TBTX_EP;
   `define TBTX_BCM_7           = tbtx[7].TBTX_BCM;
   `define TBTX_MSG_RO_7        = tbtx[7].TBTX_MSG_ROUTE;
   `define TBTX_MSG_CODE_7      = tbtx[7].TBTX_MSG_CODE;
   `define TBTX_MSG_TYPE_7      = tbtx[7].TBTX_MSG_TYPE;
   `define First_DW_BE_7        = tbtx[7].First_DW_BE;
   `define Last_DW_BE_7         = tbtx[7].Last_DW_BE;
   `define TBTX_MANUAL_DATA_7   = tbtx[7].TBTX_MANUAL_DATA;
   `define TBTX_FIXED_PATTERN_7 = tbtx[7].TBTX_FIXED_PATTERN;
`endif

// =============================================================================
// To drive Init value bus of config registers.
// =============================================================================
// For type0 registers
parameter INIT_REG_03C = 32'h0000_0000 ,
          INIT_REG_038 = 32'h0000_0000 ,
          INIT_REG_034 = 32'h0000_0040 ,
          INIT_REG_030 = 32'hFFFF_0000 ,
          INIT_REG_02C = 32'h0000_0000 ,
          INIT_REG_028 = 32'h0000_0000 ,
          INIT_REG_024 = 32'h0000_0000 ,
          INIT_REG_020 = 32'h0000_0000 ,
          INIT_REG_01C = 32'h0000_0000 ,
          INIT_REG_018 = 32'h0000_0000 ,
          INIT_REG_014 = 32'h0000_0000 ,
          INIT_REG_010 = 32'hFFFF_0000 ,
          INIT_REG_00C = 32'h0000_0000 ,
          INIT_REG_008 = 32'h0000_0000 , 
          INIT_REG_004 = 32'h0000_0000 ,
          INIT_REG_000 = 32'h0000_0000 ;

// For PM capability structure registers
parameter INIT_REG_054 = 32'h0000_0000 ,
          INIT_REG_050 = 32'h0000_0000 ;

// Power Management Data registers
parameter INIT_PM_DS_DATA_0 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_1 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_2 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_3 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_4 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_5 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_6 = 10'b00_00000000 ,
          INIT_PM_DS_DATA_7 = 10'b00_00000000 ;

// For MSI capability structure registers
parameter INIT_REG_07C = 32'h0000_0000 ,
          INIT_REG_078 = 32'h0000_0000 ,
          INIT_REG_074 = 32'h0000_0000 ,
          INIT_REG_070 = 32'h0000_0000 ;

// For PCIE capability structure registers
parameter INIT_REG_0A0 = 32'h0000_0000 ,
          INIT_REG_09C = 32'h0000_0000 ,
          INIT_REG_098 = 32'h0000_0000 ,
          INIT_REG_094 = 32'h0000_0000 ,
          INIT_REG_090 = 32'h0000_0000 ;

// Start addr for BAR registers
parameter BAR0_ST_ADR  = 32'h0000_0000;
parameter BAR1_ST_ADR  = 32'h0001_0000;
parameter BAR2_ST_ADR  = 32'h0002_0000;
parameter BAR3_ST_ADR  = 32'h0003_0000;
parameter BAR4_ST_ADR  = 32'h0004_0000;
parameter BAR5_ST_ADR  = 32'h0005_0000;

// For Device serial number registers
parameter INIT_REG_108 = 32'h0000_0000 ,
          INIT_REG_104 = 32'h0000_0000 ,
          INIT_REG_100 = 32'h0000_0000 ;

// For VC capability structure registers
parameter INIT_REG_17C = 32'h0000_0000 ,
          INIT_REG_178 = 32'h0000_0000 ,
          INIT_REG_174 = 32'h0000_0000 ,
          INIT_REG_170 = 32'h0000_0000 ,
          INIT_REG_16C = 32'h0000_0000 ,
          INIT_REG_168 = 32'h0000_0000 ,
          INIT_REG_164 = 32'h0000_0000 ,
          INIT_REG_160 = 32'h0000_0000 ,
          INIT_REG_15C = 32'h0000_0000 ,
          INIT_REG_158 = 32'h0000_0000 ,
          INIT_REG_154 = 32'h0000_0000 ,
          INIT_REG_150 = 32'h0000_0000 ,
          INIT_REG_14C = 32'h0000_0000 ,
          INIT_REG_148 = 32'h0000_0000 ,
          INIT_REG_144 = 32'h0000_0000 ,
          INIT_REG_140 = 32'h0000_0000 ,
          INIT_REG_13C = 32'h0000_0000 ,
          INIT_REG_138 = 32'h0000_0000 ,
          INIT_REG_134 = 32'h0000_0000 ,
          INIT_REG_130 = 32'h0000_0000 ,
          INIT_REG_12C = 32'h0000_0000 ,
          INIT_REG_128 = 32'h0000_0000 ,
          INIT_REG_124 = 32'h0000_0000 ,
          INIT_REG_120 = 32'h0000_0000 ,
          INIT_REG_11C = 32'h0000_0000 ,

          INIT_REG_118 = 32'h0000_0000 ,
          INIT_REG_114 = 32'h0000_0000 ,
          INIT_REG_110 = 32'h0000_0000 ,
          INIT_REG_10C = 32'h8200_0000 ;


// =============================================================================
