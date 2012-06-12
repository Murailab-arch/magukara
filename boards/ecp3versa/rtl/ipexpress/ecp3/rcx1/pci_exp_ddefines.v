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
// File             : pci_exp_dparams.v
// Title            :
// Dependencies     :
// Description      : defines for all modules of the design.
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        : 
// Mod. Date        : Jan 31, 2006
// Changes Made     : Initial Creation
// =============================================================================

//==============================================================================
// Defines lane width 
// LW1 for X1
// LW2 for X2
// LW4 for X4
//==============================================================================
`define      LW1

//==============================================================================
// Defines if the component has a Down Stream Lane or an Upstream lane 
// When not defined the IP has a Up stream lane
//==============================================================================
`define      DWN_STRM_LANE  

//==============================================================================
// Defines if the component has a Down Stream Port or an Upstream Port 
// When not defined the IP has a Up stream Port
//==============================================================================
//`define      DWN_STRM_PORT 

//==============================================================================
// Defines the Component types. Enable the appropriate component type 
//`define      ROOT_COMP       
//`define      SWITCH_COMP    
//`define      ENDPOINT_COMP    
//==============================================================================
`define      ROOT_COMP       

//==============================================================================
// Define if Polling.Compliance State required 
//==============================================================================
`define      POL_COMP

//==============================================================================
// Number of VC's supported by the design
// VC Supported                Defines
// 1                           `define NUM_VC 1    `define VC1
// 2                           `define NUM_VC 2    `define VC2
// 3                           `define NUM_VC 3    `define VC3
// 4                           `define NUM_VC 4    `define VC4
// 5                           `define NUM_VC 5    `define VC5
// 6                           `define NUM_VC 6    `define VC6
// 7                           `define NUM_VC 7    `define VC7
// 8                           `define NUM_VC 8    `define VC8
//==============================================================================
`define      NUM_VC 1 
`define      VC1


//==============================================================================
// Define the Low Priority Extended VC Count (Port VC Capability Reg1) 
// Allowed Values are  = 3'b000 to  `NUM_VC-1
//==============================================================================
`define LPEVCC    3'b000

//==============================================================================
// Generate the appropriate defines to select the the VC  channel 
// used in TXINTF block to enable VC
// =============================================================================
`ifdef VC1
   `define EN_VC0
`endif
`ifdef VC2
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
`endif
`ifdef VC3
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
`endif
`ifdef VC4
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
   `define EN_VC3
`endif
`ifdef VC5
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
   `define EN_VC3
   `define EN_VC4
`endif
`ifdef VC6
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
   `define EN_VC3
   `define EN_VC4
   `define EN_VC5
`endif
`ifdef VC7
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
   `define EN_VC3
   `define EN_VC4
   `define EN_VC5
   `define EN_VC6
`endif
`ifdef VC8
   `define CFG_VCC
   `define EN_VC0
   `define EN_VC1
   `define EN_VC2
   `define EN_VC3
   `define EN_VC4
   `define EN_VC5
   `define EN_VC6
   `define EN_VC7
`endif

// =============================================================================
// This determines the size of the buffer used as retry buffer and receive 
// TLP buffer in Data link layer. 
//`define      MAX_TLP_4K
//`define      MAX_TLP_2K
//`define      MAX_TLP_1K
//`define      MAX_TLP_512
//==============================================================================
`ifdef MAX_PL_SIZE_128
   `define MAX_TLP_512
`endif
`ifdef MAX_PL_SIZE_256
   `define MAX_TLP_512
`endif
`ifdef MAX_PL_SIZE_512
   `define MAX_TLP_512
`endif
`ifdef MAX_PL_SIZE_1K
   `define MAX_TLP_1K
`endif
`ifdef MAX_PL_SIZE_2K
   `define MAX_TLP_2K
`endif
`ifdef MAX_PL_SIZE_4K
   `define MAX_TLP_4K
`endif
//==============================================================================
// Defines SKP insertion frequency Range 1180/2 = 590 to 1538/2 = 769 
//==============================================================================
`define      SKP_INS_CNT       10'd590  

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
