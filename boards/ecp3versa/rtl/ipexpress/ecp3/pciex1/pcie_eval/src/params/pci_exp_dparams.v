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
// Description      : Parameters for all modules of the design.
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        :  
// Mod. Date        : Jan 31, 2006
// Changes Made     : Initial Creation
// =============================================================================
// Common parameters used in many modules.
//==============================================================================


// Generate LANE_WIDTH parameter based on LW definition 
`ifdef LW1
   parameter LANE_WIDTH = 1 ;
`else
   `ifdef LW2
      parameter LANE_WIDTH = 2 ;
   `else
      `ifdef LW4
         parameter LANE_WIDTH = 4 ;
      `else
         parameter LANE_WIDTH = 1 ;
      `endif
   `endif
`endif


// Defines the DATA Bus Width 
parameter D_WIDTH = 64 ;


// K & Special Symbols decodes.
parameter K27_7 = 8'hFB ; 
parameter K28_0 = 8'h1C ; 
parameter K28_2 = 8'h5C ; 
parameter K28_3 = 8'h7C ; 
parameter K28_5 = 8'hBC ; 
parameter K29_7 = 8'hFD ; 
parameter K30_7 = 8'hFE ; 
parameter K23_7 = 8'hF7 ;
parameter K28_1 = 8'h3C ;
parameter D5_2  = 8'h45 ; 
parameter D10_2 = 8'h4A ; 
parameter D21_5 = 8'hB5 ; 
parameter D26_5 = 8'hBA ; 

parameter COM = K28_5 ; 
parameter STP = K27_7 ; 
parameter SDP = K28_2 ; 
parameter END = K29_7 ; 
parameter EDB = K30_7 ; 
parameter SKP = K28_0 ; 
parameter IDL = K28_3 ; 
parameter PAD = K23_7 ; 
parameter FTS = K28_1 ; 

// Ordered Set Types
parameter OS_WIDTH      = 4 ;
parameter OS_T1_LIP_LAP = 4'd0 ;       
parameter OS_T2_LIP_LAP = 4'd1 ;
parameter OS_COMPLI     = 4'd2 ;
parameter OS_T1         = 4'd3 ;
parameter OS_T2         = 4'd4 ;
parameter OS_IDLE       = 4'd5 ;
parameter OS_EIDLE      = 4'd6 ;
parameter OS_NFTS       = 4'd7 ;
parameter OS_BEACON     = 4'd8 ;

//--LTSSM State widths states
parameter DSM_WIDTH    = 2 ;
parameter PSM_WIDTH    = 2 ;
parameter RSM_WIDTH    = 2 ;
parameter L0SM_WIDTH   = 2 ;
parameter L0sTSM_WIDTH = 2 ;
parameter L0sRSM_WIDTH = 2 ;
parameter L1SM_WIDTH   = 1 ;
parameter L2SM_WIDTH   = 1 ;
parameter DISM_WIDTH   = 2 ;
parameter LBSM_WIDTH   = 2 ;
parameter HRSM_WIDTH   = 1 ;
parameter CFGSM_WIDTH  = 2 ;
parameter MSM_WIDTH    = 3 ;

//--LTSSM Module Main State Machine states
parameter DETECT    = 4'd0 ;
parameter POLLING   = 4'd1 ;
parameter CONFIG    = 4'd2 ;
parameter L0        = 4'd3 ;
parameter L0s       = 4'd4 ;
parameter L1        = 4'd5 ;
parameter L2        = 4'd6 ;
parameter RECOVERY  = 4'd7 ;
parameter LOOPBACK  = 4'd8 ;
parameter HOTRST    = 4'd9 ;
parameter DISABLED  = 4'd10 ;


// TXDP-CTRL define
// No of SKIP req in Max Pkt time (8) + No of DLLPs req based on VCs
`ifdef VC1
   parameter FADDR = 3 ;   //8+3+2 reqs - [3:0]
`else 
   `ifdef VC2
      parameter FADDR = 3 ;  //8+6+2 reqs - [3:0]
   `else 
      `ifdef VC3 
         parameter FADDR = 5 ;  //8+9+2 reqs - [5:0]
      `else
         `ifdef VC4
            parameter FADDR = 5 ;  //8+12+2 reqs - [5:0]
         `else
            parameter FADDR = 6 ;  //8+24+2 reqs - [6:0]
         `endif
      `endif
   `endif
`endif

//==============================================================================

