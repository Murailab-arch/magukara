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
//`define      DWN_STRM_LANE  

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
`define      ENDPOINT_COMP    

//==============================================================================
// Define if the CFG REG block is selected 
//`define      CFG_REG        -- Config registers present
//==============================================================================
`define      CFG_REG

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


