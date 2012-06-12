
module PCSD (
    HDINN0,
    HDINN1,
    HDINN2,
    HDINN3,
    HDINP0,
    HDINP1,
    HDINP2,
    HDINP3,
    REFCLKN,
    REFCLKP,
    CIN0,
    CIN1,
    CIN2,
    CIN3,
    CIN4,
    CIN5,
    CIN6,
    CIN7,
    CIN8,
    CIN9,
    CIN10,
    CIN11,
    CYAWSTN,
    FF_EBRD_CLK_0,
    FF_EBRD_CLK_1,
    FF_EBRD_CLK_2,
    FF_EBRD_CLK_3,
    FF_RXI_CLK_0,
    FF_RXI_CLK_1,
    FF_RXI_CLK_2,
    FF_RXI_CLK_3,
    FF_TX_D_0_0,
    FF_TX_D_0_1,
    FF_TX_D_0_2,
    FF_TX_D_0_3,
    FF_TX_D_0_4,
    FF_TX_D_0_5,
    FF_TX_D_0_6,
    FF_TX_D_0_7,
    FF_TX_D_0_8,
    FF_TX_D_0_9,
    FF_TX_D_0_10,
    FF_TX_D_0_11,
    FF_TX_D_0_12,
    FF_TX_D_0_13,
    FF_TX_D_0_14,
    FF_TX_D_0_15,
    FF_TX_D_0_16,
    FF_TX_D_0_17,
    FF_TX_D_0_18,
    FF_TX_D_0_19,
    FF_TX_D_0_20,
    FF_TX_D_0_21,
    FF_TX_D_0_22,
    FF_TX_D_0_23,
    FF_TX_D_1_0,
    FF_TX_D_1_1,
    FF_TX_D_1_2,
    FF_TX_D_1_3,
    FF_TX_D_1_4,
    FF_TX_D_1_5,
    FF_TX_D_1_6,
    FF_TX_D_1_7,
    FF_TX_D_1_8,
    FF_TX_D_1_9,
    FF_TX_D_1_10,
    FF_TX_D_1_11,
    FF_TX_D_1_12,
    FF_TX_D_1_13,
    FF_TX_D_1_14,
    FF_TX_D_1_15,
    FF_TX_D_1_16,
    FF_TX_D_1_17,
    FF_TX_D_1_18,
    FF_TX_D_1_19,
    FF_TX_D_1_20,
    FF_TX_D_1_21,
    FF_TX_D_1_22,
    FF_TX_D_1_23,
    FF_TX_D_2_0,
    FF_TX_D_2_1,
    FF_TX_D_2_2,
    FF_TX_D_2_3,
    FF_TX_D_2_4,
    FF_TX_D_2_5,
    FF_TX_D_2_6,
    FF_TX_D_2_7,
    FF_TX_D_2_8,
    FF_TX_D_2_9,
    FF_TX_D_2_10,
    FF_TX_D_2_11,
    FF_TX_D_2_12,
    FF_TX_D_2_13,
    FF_TX_D_2_14,
    FF_TX_D_2_15,
    FF_TX_D_2_16,
    FF_TX_D_2_17,
    FF_TX_D_2_18,
    FF_TX_D_2_19,
    FF_TX_D_2_20,
    FF_TX_D_2_21,
    FF_TX_D_2_22,
    FF_TX_D_2_23,
    FF_TX_D_3_0,
    FF_TX_D_3_1,
    FF_TX_D_3_2,
    FF_TX_D_3_3,
    FF_TX_D_3_4,
    FF_TX_D_3_5,
    FF_TX_D_3_6,
    FF_TX_D_3_7,
    FF_TX_D_3_8,
    FF_TX_D_3_9,
    FF_TX_D_3_10,
    FF_TX_D_3_11,
    FF_TX_D_3_12,
    FF_TX_D_3_13,
    FF_TX_D_3_14,
    FF_TX_D_3_15,
    FF_TX_D_3_16,
    FF_TX_D_3_17,
    FF_TX_D_3_18,
    FF_TX_D_3_19,
    FF_TX_D_3_20,
    FF_TX_D_3_21,
    FF_TX_D_3_22,
    FF_TX_D_3_23,
    FF_TXI_CLK_0,
    FF_TXI_CLK_1,
    FF_TXI_CLK_2,
    FF_TXI_CLK_3,
    FFC_CK_CORE_RX_0,
    FFC_CK_CORE_RX_1,
    FFC_CK_CORE_RX_2,
    FFC_CK_CORE_RX_3,
    FFC_CK_CORE_TX,
    FFC_EI_EN_0,
    FFC_EI_EN_1,
    FFC_EI_EN_2,
    FFC_EI_EN_3,
    FFC_ENABLE_CGALIGN_0,
    FFC_ENABLE_CGALIGN_1,
    FFC_ENABLE_CGALIGN_2,
    FFC_ENABLE_CGALIGN_3,
    FFC_FB_LOOPBACK_0,
    FFC_FB_LOOPBACK_1,
    FFC_FB_LOOPBACK_2,
    FFC_FB_LOOPBACK_3,
    FFC_LANE_RX_RST_0,
    FFC_LANE_RX_RST_1,
    FFC_LANE_RX_RST_2,
    FFC_LANE_RX_RST_3,
    FFC_LANE_TX_RST_0,
    FFC_LANE_TX_RST_1,
    FFC_LANE_TX_RST_2,
    FFC_LANE_TX_RST_3,
    FFC_MACRO_RST,
    FFC_PCI_DET_EN_0,
    FFC_PCI_DET_EN_1,
    FFC_PCI_DET_EN_2,
    FFC_PCI_DET_EN_3,
    FFC_PCIE_CT_0,
    FFC_PCIE_CT_1,
    FFC_PCIE_CT_2,
    FFC_PCIE_CT_3,
    FFC_PFIFO_CLR_0,
    FFC_PFIFO_CLR_1,
    FFC_PFIFO_CLR_2,
    FFC_PFIFO_CLR_3,
    FFC_QUAD_RST,
    FFC_RRST_0,
    FFC_RRST_1,
    FFC_RRST_2,
    FFC_RRST_3,
    FFC_RXPWDNB_0,
    FFC_RXPWDNB_1,
    FFC_RXPWDNB_2,
    FFC_RXPWDNB_3,
    FFC_SB_INV_RX_0,
    FFC_SB_INV_RX_1,
    FFC_SB_INV_RX_2,
    FFC_SB_INV_RX_3,
    FFC_SB_PFIFO_LP_0,
    FFC_SB_PFIFO_LP_1,
    FFC_SB_PFIFO_LP_2,
    FFC_SB_PFIFO_LP_3,
    FFC_SIGNAL_DETECT_0,
    FFC_SIGNAL_DETECT_1,
    FFC_SIGNAL_DETECT_2,
    FFC_SIGNAL_DETECT_3,
    FFC_SYNC_TOGGLE,
    FFC_TRST,
    FFC_TXPWDNB_0,
    FFC_TXPWDNB_1,
    FFC_TXPWDNB_2,
    FFC_TXPWDNB_3,
    FFC_RATE_MODE_RX_0,
    FFC_RATE_MODE_RX_1,
    FFC_RATE_MODE_RX_2,
    FFC_RATE_MODE_RX_3,
    FFC_RATE_MODE_TX_0,
    FFC_RATE_MODE_TX_1,
    FFC_RATE_MODE_TX_2,
    FFC_RATE_MODE_TX_3,
    FFC_DIV11_MODE_RX_0,
    FFC_DIV11_MODE_RX_1,
    FFC_DIV11_MODE_RX_2,
    FFC_DIV11_MODE_RX_3,
    FFC_DIV11_MODE_TX_0,
    FFC_DIV11_MODE_TX_1,
    FFC_DIV11_MODE_TX_2,
    FFC_DIV11_MODE_TX_3,
    LDR_CORE2TX_0,
    LDR_CORE2TX_1,
    LDR_CORE2TX_2,
    LDR_CORE2TX_3,
    FFC_LDR_CORE2TX_EN_0,
    FFC_LDR_CORE2TX_EN_1,
    FFC_LDR_CORE2TX_EN_2,
    FFC_LDR_CORE2TX_EN_3,
    PCIE_POWERDOWN_0_0,
    PCIE_POWERDOWN_0_1,
    PCIE_POWERDOWN_1_0,
    PCIE_POWERDOWN_1_1,
    PCIE_POWERDOWN_2_0,
    PCIE_POWERDOWN_2_1,
    PCIE_POWERDOWN_3_0,
    PCIE_POWERDOWN_3_1,
    PCIE_RXPOLARITY_0,
    PCIE_RXPOLARITY_1,
    PCIE_RXPOLARITY_2,
    PCIE_RXPOLARITY_3,
    PCIE_TXCOMPLIANCE_0,
    PCIE_TXCOMPLIANCE_1,
    PCIE_TXCOMPLIANCE_2,
    PCIE_TXCOMPLIANCE_3,
    PCIE_TXDETRX_PR2TLB_0,
    PCIE_TXDETRX_PR2TLB_1,
    PCIE_TXDETRX_PR2TLB_2,
    PCIE_TXDETRX_PR2TLB_3,
    SCIADDR0,
    SCIADDR1,
    SCIADDR2,
    SCIADDR3,
    SCIADDR4,
    SCIADDR5,
    SCIENAUX,
    SCIENCH0,
    SCIENCH1,
    SCIENCH2,
    SCIENCH3,
    SCIRD,
    SCISELAUX,
    SCISELCH0,
    SCISELCH1,
    SCISELCH2,
    SCISELCH3,
    SCIWDATA0,
    SCIWDATA1,
    SCIWDATA2,
    SCIWDATA3,
    SCIWDATA4,
    SCIWDATA5,
    SCIWDATA6,
    SCIWDATA7,
    SCIWSTN,
    HDOUTN0,
    HDOUTN1,
    HDOUTN2,
    HDOUTN3,
    HDOUTP0,
    HDOUTP1,
    HDOUTP2,
    HDOUTP3,
    COUT0,
    COUT1,
    COUT2,
    COUT3,
    COUT4,
    COUT5,
    COUT6,
    COUT7,
    COUT8,
    COUT9,
    COUT10,
    COUT11,
    COUT12,
    COUT13,
    COUT14,
    COUT15,
    COUT16,
    COUT17,
    COUT18,
    COUT19,
    FF_RX_D_0_0,
    FF_RX_D_0_1,
    FF_RX_D_0_2,
    FF_RX_D_0_3,
    FF_RX_D_0_4,
    FF_RX_D_0_5,
    FF_RX_D_0_6,
    FF_RX_D_0_7,
    FF_RX_D_0_8,
    FF_RX_D_0_9,
    FF_RX_D_0_10,
    FF_RX_D_0_11,
    FF_RX_D_0_12,
    FF_RX_D_0_13,
    FF_RX_D_0_14,
    FF_RX_D_0_15,
    FF_RX_D_0_16,
    FF_RX_D_0_17,
    FF_RX_D_0_18,
    FF_RX_D_0_19,
    FF_RX_D_0_20,
    FF_RX_D_0_21,
    FF_RX_D_0_22,
    FF_RX_D_0_23,
    FF_RX_D_1_0,
    FF_RX_D_1_1,
    FF_RX_D_1_2,
    FF_RX_D_1_3,
    FF_RX_D_1_4,
    FF_RX_D_1_5,
    FF_RX_D_1_6,
    FF_RX_D_1_7,
    FF_RX_D_1_8,
    FF_RX_D_1_9,
    FF_RX_D_1_10,
    FF_RX_D_1_11,
    FF_RX_D_1_12,
    FF_RX_D_1_13,
    FF_RX_D_1_14,
    FF_RX_D_1_15,
    FF_RX_D_1_16,
    FF_RX_D_1_17,
    FF_RX_D_1_18,
    FF_RX_D_1_19,
    FF_RX_D_1_20,
    FF_RX_D_1_21,
    FF_RX_D_1_22,
    FF_RX_D_1_23,
    FF_RX_D_2_0,
    FF_RX_D_2_1,
    FF_RX_D_2_2,
    FF_RX_D_2_3,
    FF_RX_D_2_4,
    FF_RX_D_2_5,
    FF_RX_D_2_6,
    FF_RX_D_2_7,
    FF_RX_D_2_8,
    FF_RX_D_2_9,
    FF_RX_D_2_10,
    FF_RX_D_2_11,
    FF_RX_D_2_12,
    FF_RX_D_2_13,
    FF_RX_D_2_14,
    FF_RX_D_2_15,
    FF_RX_D_2_16,
    FF_RX_D_2_17,
    FF_RX_D_2_18,
    FF_RX_D_2_19,
    FF_RX_D_2_20,
    FF_RX_D_2_21,
    FF_RX_D_2_22,
    FF_RX_D_2_23,
    FF_RX_D_3_0,
    FF_RX_D_3_1,
    FF_RX_D_3_2,
    FF_RX_D_3_3,
    FF_RX_D_3_4,
    FF_RX_D_3_5,
    FF_RX_D_3_6,
    FF_RX_D_3_7,
    FF_RX_D_3_8,
    FF_RX_D_3_9,
    FF_RX_D_3_10,
    FF_RX_D_3_11,
    FF_RX_D_3_12,
    FF_RX_D_3_13,
    FF_RX_D_3_14,
    FF_RX_D_3_15,
    FF_RX_D_3_16,
    FF_RX_D_3_17,
    FF_RX_D_3_18,
    FF_RX_D_3_19,
    FF_RX_D_3_20,
    FF_RX_D_3_21,
    FF_RX_D_3_22,
    FF_RX_D_3_23,
    FF_RX_F_CLK_0,
    FF_RX_F_CLK_1,
    FF_RX_F_CLK_2,
    FF_RX_F_CLK_3,
    FF_RX_H_CLK_0,
    FF_RX_H_CLK_1,
    FF_RX_H_CLK_2,
    FF_RX_H_CLK_3,
    FF_TX_F_CLK_0,
    FF_TX_F_CLK_1,
    FF_TX_F_CLK_2,
    FF_TX_F_CLK_3,
    FF_TX_H_CLK_0,
    FF_TX_H_CLK_1,
    FF_TX_H_CLK_2,
    FF_TX_H_CLK_3,

    FFS_CC_OVERRUN_0,
    FFS_CC_OVERRUN_1,
    FFS_CC_OVERRUN_2,
    FFS_CC_OVERRUN_3,
    FFS_CC_UNDERRUN_0,
    FFS_CC_UNDERRUN_1,
    FFS_CC_UNDERRUN_2,
    FFS_CC_UNDERRUN_3,
    FFS_LS_SYNC_STATUS_0,
    FFS_LS_SYNC_STATUS_1,
    FFS_LS_SYNC_STATUS_2,
    FFS_LS_SYNC_STATUS_3,
    FFS_CDR_TRAIN_DONE_0,
    FFS_CDR_TRAIN_DONE_1,
    FFS_CDR_TRAIN_DONE_2,
    FFS_CDR_TRAIN_DONE_3,
    FFS_PCIE_CON_0,
    FFS_PCIE_CON_1,
    FFS_PCIE_CON_2,
    FFS_PCIE_CON_3,
    FFS_PCIE_DONE_0,
    FFS_PCIE_DONE_1,
    FFS_PCIE_DONE_2,
    FFS_PCIE_DONE_3,
    FFS_PLOL,
    FFS_RLOL_0,
    FFS_RLOL_1,
    FFS_RLOL_2,
    FFS_RLOL_3,
    FFS_RLOS_HI_0,
    FFS_RLOS_HI_1,
    FFS_RLOS_HI_2,
    FFS_RLOS_HI_3,
    FFS_RLOS_LO_0,
    FFS_RLOS_LO_1,
    FFS_RLOS_LO_2,
    FFS_RLOS_LO_3,
    FFS_RXFBFIFO_ERROR_0,
    FFS_RXFBFIFO_ERROR_1,
    FFS_RXFBFIFO_ERROR_2,
    FFS_RXFBFIFO_ERROR_3,
    FFS_TXFBFIFO_ERROR_0,
    FFS_TXFBFIFO_ERROR_1,
    FFS_TXFBFIFO_ERROR_2,
    FFS_TXFBFIFO_ERROR_3,
    PCIE_PHYSTATUS_0,
    PCIE_PHYSTATUS_1,
    PCIE_PHYSTATUS_2,
    PCIE_PHYSTATUS_3,
    PCIE_RXVALID_0,
    PCIE_RXVALID_1,
    PCIE_RXVALID_2,
    PCIE_RXVALID_3,
    FFS_SKP_ADDED_0,
    FFS_SKP_ADDED_1,
    FFS_SKP_ADDED_2,
    FFS_SKP_ADDED_3,
    FFS_SKP_DELETED_0,
    FFS_SKP_DELETED_1,
    FFS_SKP_DELETED_2,
    FFS_SKP_DELETED_3,
    LDR_RX2CORE_0,
    LDR_RX2CORE_1,
    LDR_RX2CORE_2,
    LDR_RX2CORE_3,
    REFCK2CORE,
    SCIINT,
    SCIRDATA0,
    SCIRDATA1,
    SCIRDATA2,
    SCIRDATA3,
    SCIRDATA4,
    SCIRDATA5,
    SCIRDATA6,
    SCIRDATA7,
    REFCLK_FROM_NQ,
    REFCLK_TO_NQ
    ) /* synthesis syn_black_box black_box_pad_pin = "HDINP0, HDINN0, HDINP1, HDINN1, HDINP2, HDINN2, HDINP3, HDINN3, HDOUTP0, HDOUTN0, HDOUTP1, HDOUTN1, HDOUTP2, HDOUTN2, HDOUTP3, HDOUTN3, REFCLKP, REFCLKN" */ ;

input           HDINN0;
input           HDINN1;
input           HDINN2;
input           HDINN3;
input           HDINP0;
input           HDINP1;
input           HDINP2;
input           HDINP3;
input           REFCLKN;
input           REFCLKP;
input           CIN0;
input           CIN1;
input           CIN2;
input           CIN3;
input           CIN4;
input           CIN5;
input           CIN6;
input           CIN7;
input           CIN8;
input           CIN9;
input           CIN10;
input           CIN11;
input           CYAWSTN;
input           FF_EBRD_CLK_0;
input           FF_EBRD_CLK_1;
input           FF_EBRD_CLK_2;
input           FF_EBRD_CLK_3;
input           FF_RXI_CLK_0;
input           FF_RXI_CLK_1;
input           FF_RXI_CLK_2;
input           FF_RXI_CLK_3;
input           FF_TX_D_0_0;
input           FF_TX_D_0_1;
input           FF_TX_D_0_2;
input           FF_TX_D_0_3;
input           FF_TX_D_0_4;
input           FF_TX_D_0_5;
input           FF_TX_D_0_6;
input           FF_TX_D_0_7;
input           FF_TX_D_0_8;
input           FF_TX_D_0_9;
input           FF_TX_D_0_10;
input           FF_TX_D_0_11;
input           FF_TX_D_0_12;
input           FF_TX_D_0_13;
input           FF_TX_D_0_14;
input           FF_TX_D_0_15;
input           FF_TX_D_0_16;
input           FF_TX_D_0_17;
input           FF_TX_D_0_18;
input           FF_TX_D_0_19;
input           FF_TX_D_0_20;
input           FF_TX_D_0_21;
input           FF_TX_D_0_22;
input           FF_TX_D_0_23;
input           FF_TX_D_1_0;
input           FF_TX_D_1_1;
input           FF_TX_D_1_2;
input           FF_TX_D_1_3;
input           FF_TX_D_1_4;
input           FF_TX_D_1_5;
input           FF_TX_D_1_6;
input           FF_TX_D_1_7;
input           FF_TX_D_1_8;
input           FF_TX_D_1_9;
input           FF_TX_D_1_10;
input           FF_TX_D_1_11;
input           FF_TX_D_1_12;
input           FF_TX_D_1_13;
input           FF_TX_D_1_14;
input           FF_TX_D_1_15;
input           FF_TX_D_1_16;
input           FF_TX_D_1_17;
input           FF_TX_D_1_18;
input           FF_TX_D_1_19;
input           FF_TX_D_1_20;
input           FF_TX_D_1_21;
input           FF_TX_D_1_22;
input           FF_TX_D_1_23;
input           FF_TX_D_2_0;
input           FF_TX_D_2_1;
input           FF_TX_D_2_2;
input           FF_TX_D_2_3;
input           FF_TX_D_2_4;
input           FF_TX_D_2_5;
input           FF_TX_D_2_6;
input           FF_TX_D_2_7;
input           FF_TX_D_2_8;
input           FF_TX_D_2_9;
input           FF_TX_D_2_10;
input           FF_TX_D_2_11;
input           FF_TX_D_2_12;
input           FF_TX_D_2_13;
input           FF_TX_D_2_14;
input           FF_TX_D_2_15;
input           FF_TX_D_2_16;
input           FF_TX_D_2_17;
input           FF_TX_D_2_18;
input           FF_TX_D_2_19;
input           FF_TX_D_2_20;
input           FF_TX_D_2_21;
input           FF_TX_D_2_22;
input           FF_TX_D_2_23;
input           FF_TX_D_3_0;
input           FF_TX_D_3_1;
input           FF_TX_D_3_2;
input           FF_TX_D_3_3;
input           FF_TX_D_3_4;
input           FF_TX_D_3_5;
input           FF_TX_D_3_6;
input           FF_TX_D_3_7;
input           FF_TX_D_3_8;
input           FF_TX_D_3_9;
input           FF_TX_D_3_10;
input           FF_TX_D_3_11;
input           FF_TX_D_3_12;
input           FF_TX_D_3_13;
input           FF_TX_D_3_14;
input           FF_TX_D_3_15;
input           FF_TX_D_3_16;
input           FF_TX_D_3_17;
input           FF_TX_D_3_18;
input           FF_TX_D_3_19;
input           FF_TX_D_3_20;
input           FF_TX_D_3_21;
input           FF_TX_D_3_22;
input           FF_TX_D_3_23;
input           FF_TXI_CLK_0;
input           FF_TXI_CLK_1;
input           FF_TXI_CLK_2;
input           FF_TXI_CLK_3;
input           FFC_CK_CORE_RX_0;
input           FFC_CK_CORE_RX_1;
input           FFC_CK_CORE_RX_2;
input           FFC_CK_CORE_RX_3;
input           FFC_CK_CORE_TX;
input           FFC_EI_EN_0;
input           FFC_EI_EN_1;
input           FFC_EI_EN_2;
input           FFC_EI_EN_3;
input           FFC_ENABLE_CGALIGN_0;
input           FFC_ENABLE_CGALIGN_1;
input           FFC_ENABLE_CGALIGN_2;
input           FFC_ENABLE_CGALIGN_3;
input           FFC_FB_LOOPBACK_0;
input           FFC_FB_LOOPBACK_1;
input           FFC_FB_LOOPBACK_2;
input           FFC_FB_LOOPBACK_3;
input           FFC_LANE_RX_RST_0;
input           FFC_LANE_RX_RST_1;
input           FFC_LANE_RX_RST_2;
input           FFC_LANE_RX_RST_3;
input           FFC_LANE_TX_RST_0;
input           FFC_LANE_TX_RST_1;
input           FFC_LANE_TX_RST_2;
input           FFC_LANE_TX_RST_3;
input           FFC_MACRO_RST;
input           FFC_PCI_DET_EN_0;
input           FFC_PCI_DET_EN_1;
input           FFC_PCI_DET_EN_2;
input           FFC_PCI_DET_EN_3;
input           FFC_PCIE_CT_0;
input           FFC_PCIE_CT_1;
input           FFC_PCIE_CT_2;
input           FFC_PCIE_CT_3;
input           FFC_PFIFO_CLR_0;
input           FFC_PFIFO_CLR_1;
input           FFC_PFIFO_CLR_2;
input           FFC_PFIFO_CLR_3;
input           FFC_QUAD_RST;
input           FFC_RRST_0;
input           FFC_RRST_1;
input           FFC_RRST_2;
input           FFC_RRST_3;
input           FFC_RXPWDNB_0;
input           FFC_RXPWDNB_1;
input           FFC_RXPWDNB_2;
input           FFC_RXPWDNB_3;
input           FFC_SB_INV_RX_0;
input           FFC_SB_INV_RX_1;
input           FFC_SB_INV_RX_2;
input           FFC_SB_INV_RX_3;
input           FFC_SB_PFIFO_LP_0;
input           FFC_SB_PFIFO_LP_1;
input           FFC_SB_PFIFO_LP_2;
input           FFC_SB_PFIFO_LP_3;
input           FFC_SIGNAL_DETECT_0;
input           FFC_SIGNAL_DETECT_1;
input           FFC_SIGNAL_DETECT_2;
input           FFC_SIGNAL_DETECT_3;
input           FFC_SYNC_TOGGLE;
input           FFC_TRST;
input           FFC_TXPWDNB_0;
input           FFC_TXPWDNB_1;
input           FFC_TXPWDNB_2;
input           FFC_TXPWDNB_3;
input           FFC_RATE_MODE_RX_0;
input           FFC_RATE_MODE_RX_1;
input           FFC_RATE_MODE_RX_2;
input           FFC_RATE_MODE_RX_3;
input           FFC_RATE_MODE_TX_0;
input           FFC_RATE_MODE_TX_1;
input           FFC_RATE_MODE_TX_2;
input           FFC_RATE_MODE_TX_3;
input           FFC_DIV11_MODE_RX_0;
input           FFC_DIV11_MODE_RX_1;
input           FFC_DIV11_MODE_RX_2;
input           FFC_DIV11_MODE_RX_3;
input           FFC_DIV11_MODE_TX_0;
input           FFC_DIV11_MODE_TX_1;
input           FFC_DIV11_MODE_TX_2;
input           FFC_DIV11_MODE_TX_3;
input           LDR_CORE2TX_0;
input           LDR_CORE2TX_1;
input           LDR_CORE2TX_2;
input           LDR_CORE2TX_3;
input           FFC_LDR_CORE2TX_EN_0;
input           FFC_LDR_CORE2TX_EN_1;
input           FFC_LDR_CORE2TX_EN_2;
input           FFC_LDR_CORE2TX_EN_3;
input           PCIE_POWERDOWN_0_0;
input           PCIE_POWERDOWN_0_1;
input           PCIE_POWERDOWN_1_0;
input           PCIE_POWERDOWN_1_1;
input           PCIE_POWERDOWN_2_0;
input           PCIE_POWERDOWN_2_1;
input           PCIE_POWERDOWN_3_0;
input           PCIE_POWERDOWN_3_1;
input           PCIE_RXPOLARITY_0;
input           PCIE_RXPOLARITY_1;
input           PCIE_RXPOLARITY_2;
input           PCIE_RXPOLARITY_3;
input           PCIE_TXCOMPLIANCE_0;
input           PCIE_TXCOMPLIANCE_1;
input           PCIE_TXCOMPLIANCE_2;
input           PCIE_TXCOMPLIANCE_3;
input           PCIE_TXDETRX_PR2TLB_0;
input           PCIE_TXDETRX_PR2TLB_1;
input           PCIE_TXDETRX_PR2TLB_2;
input           PCIE_TXDETRX_PR2TLB_3;
input           SCIADDR0;
input           SCIADDR1;
input           SCIADDR2;
input           SCIADDR3;
input           SCIADDR4;
input           SCIADDR5;
input           SCIENAUX;
input           SCIENCH0;
input           SCIENCH1;
input           SCIENCH2;
input           SCIENCH3;
input           SCIRD;
input           SCISELAUX;
input           SCISELCH0;
input           SCISELCH1;
input           SCISELCH2;
input           SCISELCH3;
input           SCIWDATA0;
input           SCIWDATA1;
input           SCIWDATA2;
input           SCIWDATA3;
input           SCIWDATA4;
input           SCIWDATA5;
input           SCIWDATA6;
input           SCIWDATA7;
input           SCIWSTN;
input           REFCLK_FROM_NQ;

output          HDOUTN0;
output          HDOUTN1;
output          HDOUTN2;
output          HDOUTN3;
output          HDOUTP0;
output          HDOUTP1;
output          HDOUTP2;
output          HDOUTP3;
output          COUT0;
output          COUT1;
output          COUT2;
output          COUT3;
output          COUT4;
output          COUT5;
output          COUT6;
output          COUT7;
output          COUT8;
output          COUT9;
output          COUT10;
output          COUT11;
output          COUT12;
output          COUT13;
output          COUT14;
output          COUT15;
output          COUT16;
output          COUT17;
output          COUT18;
output          COUT19;
output          FF_RX_D_0_0;
output          FF_RX_D_0_1;
output          FF_RX_D_0_2;
output          FF_RX_D_0_3;
output          FF_RX_D_0_4;
output          FF_RX_D_0_5;
output          FF_RX_D_0_6;
output          FF_RX_D_0_7;
output          FF_RX_D_0_8;
output          FF_RX_D_0_9;
output          FF_RX_D_0_10;
output          FF_RX_D_0_11;
output          FF_RX_D_0_12;
output          FF_RX_D_0_13;
output          FF_RX_D_0_14;
output          FF_RX_D_0_15;
output          FF_RX_D_0_16;
output          FF_RX_D_0_17;
output          FF_RX_D_0_18;
output          FF_RX_D_0_19;
output          FF_RX_D_0_20;
output          FF_RX_D_0_21;
output          FF_RX_D_0_22;
output          FF_RX_D_0_23;
output          FF_RX_D_1_0;
output          FF_RX_D_1_1;
output          FF_RX_D_1_2;
output          FF_RX_D_1_3;
output          FF_RX_D_1_4;
output          FF_RX_D_1_5;
output          FF_RX_D_1_6;
output          FF_RX_D_1_7;
output          FF_RX_D_1_8;
output          FF_RX_D_1_9;
output          FF_RX_D_1_10;
output          FF_RX_D_1_11;
output          FF_RX_D_1_12;
output          FF_RX_D_1_13;
output          FF_RX_D_1_14;
output          FF_RX_D_1_15;
output          FF_RX_D_1_16;
output          FF_RX_D_1_17;
output          FF_RX_D_1_18;
output          FF_RX_D_1_19;
output          FF_RX_D_1_20;
output          FF_RX_D_1_21;
output          FF_RX_D_1_22;
output          FF_RX_D_1_23;
output          FF_RX_D_2_0;
output          FF_RX_D_2_1;
output          FF_RX_D_2_2;
output          FF_RX_D_2_3;
output          FF_RX_D_2_4;
output          FF_RX_D_2_5;
output          FF_RX_D_2_6;
output          FF_RX_D_2_7;
output          FF_RX_D_2_8;
output          FF_RX_D_2_9;
output          FF_RX_D_2_10;
output          FF_RX_D_2_11;
output          FF_RX_D_2_12;
output          FF_RX_D_2_13;
output          FF_RX_D_2_14;
output          FF_RX_D_2_15;
output          FF_RX_D_2_16;
output          FF_RX_D_2_17;
output          FF_RX_D_2_18;
output          FF_RX_D_2_19;
output          FF_RX_D_2_20;
output          FF_RX_D_2_21;
output          FF_RX_D_2_22;
output          FF_RX_D_2_23;
output          FF_RX_D_3_0;
output          FF_RX_D_3_1;
output          FF_RX_D_3_2;
output          FF_RX_D_3_3;
output          FF_RX_D_3_4;
output          FF_RX_D_3_5;
output          FF_RX_D_3_6;
output          FF_RX_D_3_7;
output          FF_RX_D_3_8;
output          FF_RX_D_3_9;
output          FF_RX_D_3_10;
output          FF_RX_D_3_11;
output          FF_RX_D_3_12;
output          FF_RX_D_3_13;
output          FF_RX_D_3_14;
output          FF_RX_D_3_15;
output          FF_RX_D_3_16;
output          FF_RX_D_3_17;
output          FF_RX_D_3_18;
output          FF_RX_D_3_19;
output          FF_RX_D_3_20;
output          FF_RX_D_3_21;
output          FF_RX_D_3_22;
output          FF_RX_D_3_23;
output          FF_RX_F_CLK_0;
output          FF_RX_F_CLK_1;
output          FF_RX_F_CLK_2;
output          FF_RX_F_CLK_3;
output          FF_RX_H_CLK_0;
output          FF_RX_H_CLK_1;
output          FF_RX_H_CLK_2;
output          FF_RX_H_CLK_3;
output          FF_TX_F_CLK_0;
output          FF_TX_F_CLK_1;
output          FF_TX_F_CLK_2;
output          FF_TX_F_CLK_3;
output          FF_TX_H_CLK_0;
output          FF_TX_H_CLK_1;
output          FF_TX_H_CLK_2;
output          FF_TX_H_CLK_3;
output          FFS_CC_OVERRUN_0;
output          FFS_CC_OVERRUN_1;
output          FFS_CC_OVERRUN_2;
output          FFS_CC_OVERRUN_3;
output          FFS_CC_UNDERRUN_0;
output          FFS_CC_UNDERRUN_1;
output          FFS_CC_UNDERRUN_2;
output          FFS_CC_UNDERRUN_3;
output          FFS_LS_SYNC_STATUS_0;
output          FFS_LS_SYNC_STATUS_1;
output          FFS_LS_SYNC_STATUS_2;
output          FFS_LS_SYNC_STATUS_3;
output          FFS_CDR_TRAIN_DONE_0;
output          FFS_CDR_TRAIN_DONE_1;
output          FFS_CDR_TRAIN_DONE_2;
output          FFS_CDR_TRAIN_DONE_3;
output          FFS_PCIE_CON_0;
output          FFS_PCIE_CON_1;
output          FFS_PCIE_CON_2;
output          FFS_PCIE_CON_3;
output          FFS_PCIE_DONE_0;
output          FFS_PCIE_DONE_1;
output          FFS_PCIE_DONE_2;
output          FFS_PCIE_DONE_3;
output          FFS_PLOL;
output          FFS_RLOL_0;
output          FFS_RLOL_1;
output          FFS_RLOL_2;
output          FFS_RLOL_3;
output          FFS_RLOS_HI_0;
output          FFS_RLOS_HI_1;
output          FFS_RLOS_HI_2;
output          FFS_RLOS_HI_3;
output          FFS_RLOS_LO_0;
output          FFS_RLOS_LO_1;
output          FFS_RLOS_LO_2;
output          FFS_RLOS_LO_3;
output          FFS_RXFBFIFO_ERROR_0;
output          FFS_RXFBFIFO_ERROR_1;
output          FFS_RXFBFIFO_ERROR_2;
output          FFS_RXFBFIFO_ERROR_3;
output          FFS_TXFBFIFO_ERROR_0;
output          FFS_TXFBFIFO_ERROR_1;
output          FFS_TXFBFIFO_ERROR_2;
output          FFS_TXFBFIFO_ERROR_3;
output          PCIE_PHYSTATUS_0;
output          PCIE_PHYSTATUS_1;
output          PCIE_PHYSTATUS_2;
output          PCIE_PHYSTATUS_3;
output          PCIE_RXVALID_0;
output          PCIE_RXVALID_1;
output          PCIE_RXVALID_2;
output          PCIE_RXVALID_3;
output          FFS_SKP_ADDED_0;
output          FFS_SKP_ADDED_1;
output          FFS_SKP_ADDED_2;
output          FFS_SKP_ADDED_3;
output          FFS_SKP_DELETED_0;
output          FFS_SKP_DELETED_1;
output          FFS_SKP_DELETED_2;
output          FFS_SKP_DELETED_3;
output          LDR_RX2CORE_0;
output          LDR_RX2CORE_1;
output          LDR_RX2CORE_2;
output          LDR_RX2CORE_3;
output          REFCK2CORE;
output          SCIINT;
output          SCIRDATA0;
output          SCIRDATA1;
output          SCIRDATA2;
output          SCIRDATA3;
output          SCIRDATA4;
output          SCIRDATA5;
output          SCIRDATA6;
output          SCIRDATA7;
output          REFCLK_TO_NQ;

//synopsys translate_off

parameter CONFIG_FILE = "configfile.txt";
parameter QUAD_MODE = "SINGLE";
parameter PLL_SRC = "REFCLK_EXT";
parameter CH0_CDR_SRC = "REFCLK_EXT";
parameter CH1_CDR_SRC = "REFCLK_EXT";
parameter CH2_CDR_SRC = "REFCLK_EXT";
parameter CH3_CDR_SRC = "REFCLK_EXT";

  defparam PCSD_sim_inst.CONFIG_FILE = CONFIG_FILE;
  defparam PCSD_sim_inst.QUAD_MODE = QUAD_MODE;
  defparam PCSD_sim_inst.PLL_SRC = PLL_SRC;
  defparam PCSD_sim_inst.CH0_CDR_SRC = CH0_CDR_SRC;
  defparam PCSD_sim_inst.CH1_CDR_SRC = CH1_CDR_SRC;
  defparam PCSD_sim_inst.CH2_CDR_SRC = CH2_CDR_SRC;
  defparam PCSD_sim_inst.CH3_CDR_SRC = CH3_CDR_SRC;

 PCSD_sim PCSD_sim_inst (
   .HDINN0(HDINN0),
   .HDINN1(HDINN1),
   .HDINN2(HDINN2),
   .HDINN3(HDINN3),
   .HDINP0(HDINP0),
   .HDINP1(HDINP1),
   .HDINP2(HDINP2),
   .HDINP3(HDINP3),
   .REFCLKN(REFCLKN),
   .REFCLKP(REFCLKP),
   .CIN11(CIN11),
   .CIN10(CIN10),
   .CIN9(CIN9),
   .CIN8(CIN8),
   .CIN7(CIN7),
   .CIN6(CIN6),
   .CIN5(CIN5),
   .CIN4(CIN4),
   .CIN3(CIN3),
   .CIN2(CIN2),
   .CIN1(CIN1),
   .CIN0(CIN0),
   .CYAWSTN(CYAWSTN),
   .FF_EBRD_CLK_3(FF_EBRD_CLK_3),
   .FF_EBRD_CLK_2(FF_EBRD_CLK_2),
   .FF_EBRD_CLK_1(FF_EBRD_CLK_1),
   .FF_EBRD_CLK_0(FF_EBRD_CLK_0),
   .FF_RXI_CLK_3(FF_RXI_CLK_3),
   .FF_RXI_CLK_2(FF_RXI_CLK_2),
   .FF_RXI_CLK_1(FF_RXI_CLK_1),
   .FF_RXI_CLK_0(FF_RXI_CLK_0),
   .FF_TX_D_0_0(FF_TX_D_0_0),
   .FF_TX_D_0_1(FF_TX_D_0_1),
   .FF_TX_D_0_2(FF_TX_D_0_2),
   .FF_TX_D_0_3(FF_TX_D_0_3),
   .FF_TX_D_0_4(FF_TX_D_0_4),
   .FF_TX_D_0_5(FF_TX_D_0_5),
   .FF_TX_D_0_6(FF_TX_D_0_6),
   .FF_TX_D_0_7(FF_TX_D_0_7),
   .FF_TX_D_0_8(FF_TX_D_0_8),
   .FF_TX_D_0_9(FF_TX_D_0_9),
   .FF_TX_D_0_10(FF_TX_D_0_10),
   .FF_TX_D_0_11(FF_TX_D_0_11),
   .FF_TX_D_0_12(FF_TX_D_0_12),
   .FF_TX_D_0_13(FF_TX_D_0_13),
   .FF_TX_D_0_14(FF_TX_D_0_14),
   .FF_TX_D_0_15(FF_TX_D_0_15),
   .FF_TX_D_0_16(FF_TX_D_0_16),
   .FF_TX_D_0_17(FF_TX_D_0_17),
   .FF_TX_D_0_18(FF_TX_D_0_18),
   .FF_TX_D_0_19(FF_TX_D_0_19),
   .FF_TX_D_0_20(FF_TX_D_0_20),
   .FF_TX_D_0_21(FF_TX_D_0_21),
   .FF_TX_D_0_22(FF_TX_D_0_22),
   .FF_TX_D_0_23(FF_TX_D_0_23),
   .FF_TX_D_1_0(FF_TX_D_1_0),
   .FF_TX_D_1_1(FF_TX_D_1_1),
   .FF_TX_D_1_2(FF_TX_D_1_2),
   .FF_TX_D_1_3(FF_TX_D_1_3),
   .FF_TX_D_1_4(FF_TX_D_1_4),
   .FF_TX_D_1_5(FF_TX_D_1_5),
   .FF_TX_D_1_6(FF_TX_D_1_6),
   .FF_TX_D_1_7(FF_TX_D_1_7),
   .FF_TX_D_1_8(FF_TX_D_1_8),
   .FF_TX_D_1_9(FF_TX_D_1_9),
   .FF_TX_D_1_10(FF_TX_D_1_10),
   .FF_TX_D_1_11(FF_TX_D_1_11),
   .FF_TX_D_1_12(FF_TX_D_1_12),
   .FF_TX_D_1_13(FF_TX_D_1_13),
   .FF_TX_D_1_14(FF_TX_D_1_14),
   .FF_TX_D_1_15(FF_TX_D_1_15),
   .FF_TX_D_1_16(FF_TX_D_1_16),
   .FF_TX_D_1_17(FF_TX_D_1_17),
   .FF_TX_D_1_18(FF_TX_D_1_18),
   .FF_TX_D_1_19(FF_TX_D_1_19),
   .FF_TX_D_1_20(FF_TX_D_1_20),
   .FF_TX_D_1_21(FF_TX_D_1_21),
   .FF_TX_D_1_22(FF_TX_D_1_22),
   .FF_TX_D_1_23(FF_TX_D_1_23),
   .FF_TX_D_2_0(FF_TX_D_2_0),
   .FF_TX_D_2_1(FF_TX_D_2_1),
   .FF_TX_D_2_2(FF_TX_D_2_2),
   .FF_TX_D_2_3(FF_TX_D_2_3),
   .FF_TX_D_2_4(FF_TX_D_2_4),
   .FF_TX_D_2_5(FF_TX_D_2_5),
   .FF_TX_D_2_6(FF_TX_D_2_6),
   .FF_TX_D_2_7(FF_TX_D_2_7),
   .FF_TX_D_2_8(FF_TX_D_2_8),
   .FF_TX_D_2_9(FF_TX_D_2_9),
   .FF_TX_D_2_10(FF_TX_D_2_10),
   .FF_TX_D_2_11(FF_TX_D_2_11),
   .FF_TX_D_2_12(FF_TX_D_2_12),
   .FF_TX_D_2_13(FF_TX_D_2_13),
   .FF_TX_D_2_14(FF_TX_D_2_14),
   .FF_TX_D_2_15(FF_TX_D_2_15),
   .FF_TX_D_2_16(FF_TX_D_2_16),
   .FF_TX_D_2_17(FF_TX_D_2_17),
   .FF_TX_D_2_18(FF_TX_D_2_18),
   .FF_TX_D_2_19(FF_TX_D_2_19),
   .FF_TX_D_2_20(FF_TX_D_2_20),
   .FF_TX_D_2_21(FF_TX_D_2_21),
   .FF_TX_D_2_22(FF_TX_D_2_22),
   .FF_TX_D_2_23(FF_TX_D_2_23),
   .FF_TX_D_3_0(FF_TX_D_3_0),
   .FF_TX_D_3_1(FF_TX_D_3_1),
   .FF_TX_D_3_2(FF_TX_D_3_2),
   .FF_TX_D_3_3(FF_TX_D_3_3),
   .FF_TX_D_3_4(FF_TX_D_3_4),
   .FF_TX_D_3_5(FF_TX_D_3_5),
   .FF_TX_D_3_6(FF_TX_D_3_6),
   .FF_TX_D_3_7(FF_TX_D_3_7),
   .FF_TX_D_3_8(FF_TX_D_3_8),
   .FF_TX_D_3_9(FF_TX_D_3_9),
   .FF_TX_D_3_10(FF_TX_D_3_10),
   .FF_TX_D_3_11(FF_TX_D_3_11),
   .FF_TX_D_3_12(FF_TX_D_3_12),
   .FF_TX_D_3_13(FF_TX_D_3_13),
   .FF_TX_D_3_14(FF_TX_D_3_14),
   .FF_TX_D_3_15(FF_TX_D_3_15),
   .FF_TX_D_3_16(FF_TX_D_3_16),
   .FF_TX_D_3_17(FF_TX_D_3_17),
   .FF_TX_D_3_18(FF_TX_D_3_18),
   .FF_TX_D_3_19(FF_TX_D_3_19),
   .FF_TX_D_3_20(FF_TX_D_3_20),
   .FF_TX_D_3_21(FF_TX_D_3_21),
   .FF_TX_D_3_22(FF_TX_D_3_22),
   .FF_TX_D_3_23(FF_TX_D_3_23),
   .FF_TXI_CLK_0(FF_TXI_CLK_0),
   .FF_TXI_CLK_1(FF_TXI_CLK_1),
   .FF_TXI_CLK_2(FF_TXI_CLK_2),
   .FF_TXI_CLK_3(FF_TXI_CLK_3),
   .FFC_CK_CORE_RX_0(FFC_CK_CORE_RX_0),
   .FFC_CK_CORE_RX_1(FFC_CK_CORE_RX_1),
   .FFC_CK_CORE_RX_2(FFC_CK_CORE_RX_2),
   .FFC_CK_CORE_RX_3(FFC_CK_CORE_RX_3),
   .FFC_CK_CORE_TX(FFC_CK_CORE_TX),
   .FFC_EI_EN_0(FFC_EI_EN_0),
   .FFC_EI_EN_1(FFC_EI_EN_1),
   .FFC_EI_EN_2(FFC_EI_EN_2),
   .FFC_EI_EN_3(FFC_EI_EN_3),
   .FFC_ENABLE_CGALIGN_0(FFC_ENABLE_CGALIGN_0),
   .FFC_ENABLE_CGALIGN_1(FFC_ENABLE_CGALIGN_1),
   .FFC_ENABLE_CGALIGN_2(FFC_ENABLE_CGALIGN_2),
   .FFC_ENABLE_CGALIGN_3(FFC_ENABLE_CGALIGN_3),
   .FFC_FB_LOOPBACK_0(FFC_FB_LOOPBACK_0),
   .FFC_FB_LOOPBACK_1(FFC_FB_LOOPBACK_1),
   .FFC_FB_LOOPBACK_2(FFC_FB_LOOPBACK_2),
   .FFC_FB_LOOPBACK_3(FFC_FB_LOOPBACK_3),
   .FFC_LANE_RX_RST_0(FFC_LANE_RX_RST_0),
   .FFC_LANE_RX_RST_1(FFC_LANE_RX_RST_1),
   .FFC_LANE_RX_RST_2(FFC_LANE_RX_RST_2),
   .FFC_LANE_RX_RST_3(FFC_LANE_RX_RST_3),
   .FFC_LANE_TX_RST_0(FFC_LANE_TX_RST_0),
   .FFC_LANE_TX_RST_1(FFC_LANE_TX_RST_1),
   .FFC_LANE_TX_RST_2(FFC_LANE_TX_RST_2),
   .FFC_LANE_TX_RST_3(FFC_LANE_TX_RST_3),
   .FFC_MACRO_RST(FFC_MACRO_RST),
   .FFC_PCI_DET_EN_0(FFC_PCI_DET_EN_0),
   .FFC_PCI_DET_EN_1(FFC_PCI_DET_EN_1),
   .FFC_PCI_DET_EN_2(FFC_PCI_DET_EN_2),
   .FFC_PCI_DET_EN_3(FFC_PCI_DET_EN_3),
   .FFC_PCIE_CT_0(FFC_PCIE_CT_0),
   .FFC_PCIE_CT_1(FFC_PCIE_CT_1),
   .FFC_PCIE_CT_2(FFC_PCIE_CT_2),
   .FFC_PCIE_CT_3(FFC_PCIE_CT_3),
   .FFC_PFIFO_CLR_0(FFC_PFIFO_CLR_0),
   .FFC_PFIFO_CLR_1(FFC_PFIFO_CLR_1),
   .FFC_PFIFO_CLR_2(FFC_PFIFO_CLR_2),
   .FFC_PFIFO_CLR_3(FFC_PFIFO_CLR_3),
   .FFC_QUAD_RST(FFC_QUAD_RST),
   .FFC_RRST_0(FFC_RRST_0),
   .FFC_RRST_1(FFC_RRST_1),
   .FFC_RRST_2(FFC_RRST_2),
   .FFC_RRST_3(FFC_RRST_3),
   .FFC_RXPWDNB_0(FFC_RXPWDNB_0),
   .FFC_RXPWDNB_1(FFC_RXPWDNB_1),
   .FFC_RXPWDNB_2(FFC_RXPWDNB_2),
   .FFC_RXPWDNB_3(FFC_RXPWDNB_3),
   .FFC_SB_INV_RX_0(FFC_SB_INV_RX_0),
   .FFC_SB_INV_RX_1(FFC_SB_INV_RX_1),
   .FFC_SB_INV_RX_2(FFC_SB_INV_RX_2),
   .FFC_SB_INV_RX_3(FFC_SB_INV_RX_3),
   .FFC_SB_PFIFO_LP_0(FFC_SB_PFIFO_LP_0),
   .FFC_SB_PFIFO_LP_1(FFC_SB_PFIFO_LP_1),
   .FFC_SB_PFIFO_LP_2(FFC_SB_PFIFO_LP_2),
   .FFC_SB_PFIFO_LP_3(FFC_SB_PFIFO_LP_3),
   .FFC_SIGNAL_DETECT_0(FFC_SIGNAL_DETECT_0),
   .FFC_SIGNAL_DETECT_1(FFC_SIGNAL_DETECT_1),
   .FFC_SIGNAL_DETECT_2(FFC_SIGNAL_DETECT_2),
   .FFC_SIGNAL_DETECT_3(FFC_SIGNAL_DETECT_3),
   .FFC_SYNC_TOGGLE(FFC_SYNC_TOGGLE),
   .FFC_TRST(FFC_TRST),
   .FFC_TXPWDNB_0(FFC_TXPWDNB_0),
   .FFC_TXPWDNB_1(FFC_TXPWDNB_1),
   .FFC_TXPWDNB_2(FFC_TXPWDNB_2),
   .FFC_TXPWDNB_3(FFC_TXPWDNB_3),
   .FFC_RATE_MODE_RX_0(FFC_RATE_MODE_RX_0),
   .FFC_RATE_MODE_RX_1(FFC_RATE_MODE_RX_1),
   .FFC_RATE_MODE_RX_2(FFC_RATE_MODE_RX_2),
   .FFC_RATE_MODE_RX_3(FFC_RATE_MODE_RX_3),
   .FFC_RATE_MODE_TX_0(FFC_RATE_MODE_TX_0),
   .FFC_RATE_MODE_TX_1(FFC_RATE_MODE_TX_1),
   .FFC_RATE_MODE_TX_2(FFC_RATE_MODE_TX_2),
   .FFC_RATE_MODE_TX_3(FFC_RATE_MODE_TX_3),
   .FFC_DIV11_MODE_RX_0(FFC_DIV11_MODE_RX_0),
   .FFC_DIV11_MODE_RX_1(FFC_DIV11_MODE_RX_1),
   .FFC_DIV11_MODE_RX_2(FFC_DIV11_MODE_RX_2),
   .FFC_DIV11_MODE_RX_3(FFC_DIV11_MODE_RX_3),
   .FFC_DIV11_MODE_TX_0(FFC_DIV11_MODE_TX_0),
   .FFC_DIV11_MODE_TX_1(FFC_DIV11_MODE_TX_1),
   .FFC_DIV11_MODE_TX_2(FFC_DIV11_MODE_TX_2),
   .FFC_DIV11_MODE_TX_3(FFC_DIV11_MODE_TX_3),
   .LDR_CORE2TX_0(LDR_CORE2TX_0),
   .LDR_CORE2TX_1(LDR_CORE2TX_1),
   .LDR_CORE2TX_2(LDR_CORE2TX_2),
   .LDR_CORE2TX_3(LDR_CORE2TX_3),
   .FFC_LDR_CORE2TX_EN_0(FFC_LDR_CORE2TX_EN_0),
   .FFC_LDR_CORE2TX_EN_1(FFC_LDR_CORE2TX_EN_1),
   .FFC_LDR_CORE2TX_EN_2(FFC_LDR_CORE2TX_EN_2),
   .FFC_LDR_CORE2TX_EN_3(FFC_LDR_CORE2TX_EN_3),
   .PCIE_POWERDOWN_0_0(PCIE_POWERDOWN_0_0),
   .PCIE_POWERDOWN_0_1(PCIE_POWERDOWN_0_1),
   .PCIE_POWERDOWN_1_0(PCIE_POWERDOWN_1_0),
   .PCIE_POWERDOWN_1_1(PCIE_POWERDOWN_1_1),
   .PCIE_POWERDOWN_2_0(PCIE_POWERDOWN_2_0),
   .PCIE_POWERDOWN_2_1(PCIE_POWERDOWN_2_1),
   .PCIE_POWERDOWN_3_0(PCIE_POWERDOWN_3_0),
   .PCIE_POWERDOWN_3_1(PCIE_POWERDOWN_3_1),
   .PCIE_RXPOLARITY_0(PCIE_RXPOLARITY_0),
   .PCIE_RXPOLARITY_1(PCIE_RXPOLARITY_1),
   .PCIE_RXPOLARITY_2(PCIE_RXPOLARITY_2),
   .PCIE_RXPOLARITY_3(PCIE_RXPOLARITY_3),
   .PCIE_TXCOMPLIANCE_0(PCIE_TXCOMPLIANCE_0),
   .PCIE_TXCOMPLIANCE_1(PCIE_TXCOMPLIANCE_1),
   .PCIE_TXCOMPLIANCE_2(PCIE_TXCOMPLIANCE_2),
   .PCIE_TXCOMPLIANCE_3(PCIE_TXCOMPLIANCE_3),
   .PCIE_TXDETRX_PR2TLB_0(PCIE_TXDETRX_PR2TLB_0),
   .PCIE_TXDETRX_PR2TLB_1(PCIE_TXDETRX_PR2TLB_1),
   .PCIE_TXDETRX_PR2TLB_2(PCIE_TXDETRX_PR2TLB_2),
   .PCIE_TXDETRX_PR2TLB_3(PCIE_TXDETRX_PR2TLB_3),
   .SCIADDR0(SCIADDR0),
   .SCIADDR1(SCIADDR1),
   .SCIADDR2(SCIADDR2),
   .SCIADDR3(SCIADDR3),
   .SCIADDR4(SCIADDR4),
   .SCIADDR5(SCIADDR5),
   .SCIENAUX(SCIENAUX),
   .SCIENCH0(SCIENCH0),
   .SCIENCH1(SCIENCH1),
   .SCIENCH2(SCIENCH2),
   .SCIENCH3(SCIENCH3),
   .SCIRD(SCIRD),
   .SCISELAUX(SCISELAUX),
   .SCISELCH0(SCISELCH0),
   .SCISELCH1(SCISELCH1),
   .SCISELCH2(SCISELCH2),
   .SCISELCH3(SCISELCH3),
   .SCIWDATA0(SCIWDATA0),
   .SCIWDATA1(SCIWDATA1),
   .SCIWDATA2(SCIWDATA2),
   .SCIWDATA3(SCIWDATA3),
   .SCIWDATA4(SCIWDATA4),
   .SCIWDATA5(SCIWDATA5),
   .SCIWDATA6(SCIWDATA6),
   .SCIWDATA7(SCIWDATA7),
   .SCIWSTN(SCIWSTN),
   .HDOUTN0(HDOUTN0),
   .HDOUTN1(HDOUTN1),
   .HDOUTN2(HDOUTN2),
   .HDOUTN3(HDOUTN3),
   .HDOUTP0(HDOUTP0),
   .HDOUTP1(HDOUTP1),
   .HDOUTP2(HDOUTP2),
   .HDOUTP3(HDOUTP3),
   .COUT19(COUT19),
   .COUT18(COUT18),
   .COUT17(COUT17),
   .COUT16(COUT16),
   .COUT15(COUT15),
   .COUT14(COUT14),
   .COUT13(COUT13),
   .COUT12(COUT12),
   .COUT11(COUT11),
   .COUT10(COUT10),
   .COUT9(COUT9),
   .COUT8(COUT8),
   .COUT7(COUT7),
   .COUT6(COUT6),
   .COUT5(COUT5),
   .COUT4(COUT4),
   .COUT3(COUT3),
   .COUT2(COUT2),
   .COUT1(COUT1),
   .COUT0(COUT0),
   .FF_RX_D_0_0(FF_RX_D_0_0),
   .FF_RX_D_0_1(FF_RX_D_0_1),
   .FF_RX_D_0_2(FF_RX_D_0_2),
   .FF_RX_D_0_3(FF_RX_D_0_3),
   .FF_RX_D_0_4(FF_RX_D_0_4),
   .FF_RX_D_0_5(FF_RX_D_0_5),
   .FF_RX_D_0_6(FF_RX_D_0_6),
   .FF_RX_D_0_7(FF_RX_D_0_7),
   .FF_RX_D_0_8(FF_RX_D_0_8),
   .FF_RX_D_0_9(FF_RX_D_0_9),
   .FF_RX_D_0_10(FF_RX_D_0_10),
   .FF_RX_D_0_11(FF_RX_D_0_11),
   .FF_RX_D_0_12(FF_RX_D_0_12),
   .FF_RX_D_0_13(FF_RX_D_0_13),
   .FF_RX_D_0_14(FF_RX_D_0_14),
   .FF_RX_D_0_15(FF_RX_D_0_15),
   .FF_RX_D_0_16(FF_RX_D_0_16),
   .FF_RX_D_0_17(FF_RX_D_0_17),
   .FF_RX_D_0_18(FF_RX_D_0_18),
   .FF_RX_D_0_19(FF_RX_D_0_19),
   .FF_RX_D_0_20(FF_RX_D_0_20),
   .FF_RX_D_0_21(FF_RX_D_0_21),
   .FF_RX_D_0_22(FF_RX_D_0_22),
   .FF_RX_D_0_23(FF_RX_D_0_23),
   .FF_RX_D_1_0(FF_RX_D_1_0),
   .FF_RX_D_1_1(FF_RX_D_1_1),
   .FF_RX_D_1_2(FF_RX_D_1_2),
   .FF_RX_D_1_3(FF_RX_D_1_3),
   .FF_RX_D_1_4(FF_RX_D_1_4),
   .FF_RX_D_1_5(FF_RX_D_1_5),
   .FF_RX_D_1_6(FF_RX_D_1_6),
   .FF_RX_D_1_7(FF_RX_D_1_7),
   .FF_RX_D_1_8(FF_RX_D_1_8),
   .FF_RX_D_1_9(FF_RX_D_1_9),
   .FF_RX_D_1_10(FF_RX_D_1_10),
   .FF_RX_D_1_11(FF_RX_D_1_11),
   .FF_RX_D_1_12(FF_RX_D_1_12),
   .FF_RX_D_1_13(FF_RX_D_1_13),
   .FF_RX_D_1_14(FF_RX_D_1_14),
   .FF_RX_D_1_15(FF_RX_D_1_15),
   .FF_RX_D_1_16(FF_RX_D_1_16),
   .FF_RX_D_1_17(FF_RX_D_1_17),
   .FF_RX_D_1_18(FF_RX_D_1_18),
   .FF_RX_D_1_19(FF_RX_D_1_19),
   .FF_RX_D_1_20(FF_RX_D_1_20),
   .FF_RX_D_1_21(FF_RX_D_1_21),
   .FF_RX_D_1_22(FF_RX_D_1_22),
   .FF_RX_D_1_23(FF_RX_D_1_23),
   .FF_RX_D_2_0(FF_RX_D_2_0),
   .FF_RX_D_2_1(FF_RX_D_2_1),
   .FF_RX_D_2_2(FF_RX_D_2_2),
   .FF_RX_D_2_3(FF_RX_D_2_3),
   .FF_RX_D_2_4(FF_RX_D_2_4),
   .FF_RX_D_2_5(FF_RX_D_2_5),
   .FF_RX_D_2_6(FF_RX_D_2_6),
   .FF_RX_D_2_7(FF_RX_D_2_7),
   .FF_RX_D_2_8(FF_RX_D_2_8),
   .FF_RX_D_2_9(FF_RX_D_2_9),
   .FF_RX_D_2_10(FF_RX_D_2_10),
   .FF_RX_D_2_11(FF_RX_D_2_11),
   .FF_RX_D_2_12(FF_RX_D_2_12),
   .FF_RX_D_2_13(FF_RX_D_2_13),
   .FF_RX_D_2_14(FF_RX_D_2_14),
   .FF_RX_D_2_15(FF_RX_D_2_15),
   .FF_RX_D_2_16(FF_RX_D_2_16),
   .FF_RX_D_2_17(FF_RX_D_2_17),
   .FF_RX_D_2_18(FF_RX_D_2_18),
   .FF_RX_D_2_19(FF_RX_D_2_19),
   .FF_RX_D_2_20(FF_RX_D_2_20),
   .FF_RX_D_2_21(FF_RX_D_2_21),
   .FF_RX_D_2_22(FF_RX_D_2_22),
   .FF_RX_D_2_23(FF_RX_D_2_23),
   .FF_RX_D_3_0(FF_RX_D_3_0),
   .FF_RX_D_3_1(FF_RX_D_3_1),
   .FF_RX_D_3_2(FF_RX_D_3_2),
   .FF_RX_D_3_3(FF_RX_D_3_3),
   .FF_RX_D_3_4(FF_RX_D_3_4),
   .FF_RX_D_3_5(FF_RX_D_3_5),
   .FF_RX_D_3_6(FF_RX_D_3_6),
   .FF_RX_D_3_7(FF_RX_D_3_7),
   .FF_RX_D_3_8(FF_RX_D_3_8),
   .FF_RX_D_3_9(FF_RX_D_3_9),
   .FF_RX_D_3_10(FF_RX_D_3_10),
   .FF_RX_D_3_11(FF_RX_D_3_11),
   .FF_RX_D_3_12(FF_RX_D_3_12),
   .FF_RX_D_3_13(FF_RX_D_3_13),
   .FF_RX_D_3_14(FF_RX_D_3_14),
   .FF_RX_D_3_15(FF_RX_D_3_15),
   .FF_RX_D_3_16(FF_RX_D_3_16),
   .FF_RX_D_3_17(FF_RX_D_3_17),
   .FF_RX_D_3_18(FF_RX_D_3_18),
   .FF_RX_D_3_19(FF_RX_D_3_19),
   .FF_RX_D_3_20(FF_RX_D_3_20),
   .FF_RX_D_3_21(FF_RX_D_3_21),
   .FF_RX_D_3_22(FF_RX_D_3_22),
   .FF_RX_D_3_23(FF_RX_D_3_23),
   .FF_RX_F_CLK_0(FF_RX_F_CLK_0),
   .FF_RX_F_CLK_1(FF_RX_F_CLK_1),
   .FF_RX_F_CLK_2(FF_RX_F_CLK_2),
   .FF_RX_F_CLK_3(FF_RX_F_CLK_3),
   .FF_RX_H_CLK_0(FF_RX_H_CLK_0),
   .FF_RX_H_CLK_1(FF_RX_H_CLK_1),
   .FF_RX_H_CLK_2(FF_RX_H_CLK_2),
   .FF_RX_H_CLK_3(FF_RX_H_CLK_3),
   .FF_TX_F_CLK_0(FF_TX_F_CLK_0),
   .FF_TX_F_CLK_1(FF_TX_F_CLK_1),
   .FF_TX_F_CLK_2(FF_TX_F_CLK_2),
   .FF_TX_F_CLK_3(FF_TX_F_CLK_3),
   .FF_TX_H_CLK_0(FF_TX_H_CLK_0),
   .FF_TX_H_CLK_1(FF_TX_H_CLK_1),
   .FF_TX_H_CLK_2(FF_TX_H_CLK_2),
   .FF_TX_H_CLK_3(FF_TX_H_CLK_3),
   .FFS_CC_OVERRUN_0(FFS_CC_OVERRUN_0),
   .FFS_CC_OVERRUN_1(FFS_CC_OVERRUN_1),
   .FFS_CC_OVERRUN_2(FFS_CC_OVERRUN_2),
   .FFS_CC_OVERRUN_3(FFS_CC_OVERRUN_3),
   .FFS_CC_UNDERRUN_0(FFS_CC_UNDERRUN_0),
   .FFS_CC_UNDERRUN_1(FFS_CC_UNDERRUN_1),
   .FFS_CC_UNDERRUN_2(FFS_CC_UNDERRUN_2),
   .FFS_CC_UNDERRUN_3(FFS_CC_UNDERRUN_3),
   .FFS_LS_SYNC_STATUS_0(FFS_LS_SYNC_STATUS_0),
   .FFS_LS_SYNC_STATUS_1(FFS_LS_SYNC_STATUS_1),
   .FFS_LS_SYNC_STATUS_2(FFS_LS_SYNC_STATUS_2),
   .FFS_LS_SYNC_STATUS_3(FFS_LS_SYNC_STATUS_3),
   .FFS_CDR_TRAIN_DONE_0(FFS_CDR_TRAIN_DONE_0),
   .FFS_CDR_TRAIN_DONE_1(FFS_CDR_TRAIN_DONE_1),
   .FFS_CDR_TRAIN_DONE_2(FFS_CDR_TRAIN_DONE_2),
   .FFS_CDR_TRAIN_DONE_3(FFS_CDR_TRAIN_DONE_3),
   .FFS_PCIE_CON_0(FFS_PCIE_CON_0),
   .FFS_PCIE_CON_1(FFS_PCIE_CON_1),
   .FFS_PCIE_CON_2(FFS_PCIE_CON_2),
   .FFS_PCIE_CON_3(FFS_PCIE_CON_3),
   .FFS_PCIE_DONE_0(FFS_PCIE_DONE_0),
   .FFS_PCIE_DONE_1(FFS_PCIE_DONE_1),
   .FFS_PCIE_DONE_2(FFS_PCIE_DONE_2),
   .FFS_PCIE_DONE_3(FFS_PCIE_DONE_3),
   .FFS_PLOL(FFS_PLOL),
   .FFS_RLOL_0(FFS_RLOL_0),
   .FFS_RLOL_1(FFS_RLOL_1),
   .FFS_RLOL_2(FFS_RLOL_2),
   .FFS_RLOL_3(FFS_RLOL_3),
   .FFS_RLOS_HI_0(FFS_RLOS_HI_0),
   .FFS_RLOS_HI_1(FFS_RLOS_HI_1),
   .FFS_RLOS_HI_2(FFS_RLOS_HI_2),
   .FFS_RLOS_HI_3(FFS_RLOS_HI_3),
   .FFS_RLOS_LO_0(FFS_RLOS_LO_0),
   .FFS_RLOS_LO_1(FFS_RLOS_LO_1),
   .FFS_RLOS_LO_2(FFS_RLOS_LO_2),
   .FFS_RLOS_LO_3(FFS_RLOS_LO_3),
   .FFS_RXFBFIFO_ERROR_0(FFS_RXFBFIFO_ERROR_0),
   .FFS_RXFBFIFO_ERROR_1(FFS_RXFBFIFO_ERROR_1),
   .FFS_RXFBFIFO_ERROR_2(FFS_RXFBFIFO_ERROR_2),
   .FFS_RXFBFIFO_ERROR_3(FFS_RXFBFIFO_ERROR_3),
   .FFS_TXFBFIFO_ERROR_0(FFS_TXFBFIFO_ERROR_0),
   .FFS_TXFBFIFO_ERROR_1(FFS_TXFBFIFO_ERROR_1),
   .FFS_TXFBFIFO_ERROR_2(FFS_TXFBFIFO_ERROR_2),
   .FFS_TXFBFIFO_ERROR_3(FFS_TXFBFIFO_ERROR_3),
   .PCIE_PHYSTATUS_0(PCIE_PHYSTATUS_0),
   .PCIE_PHYSTATUS_1(PCIE_PHYSTATUS_1),
   .PCIE_PHYSTATUS_2(PCIE_PHYSTATUS_2),
   .PCIE_PHYSTATUS_3(PCIE_PHYSTATUS_3),
   .PCIE_RXVALID_0(PCIE_RXVALID_0),
   .PCIE_RXVALID_1(PCIE_RXVALID_1),
   .PCIE_RXVALID_2(PCIE_RXVALID_2),
   .PCIE_RXVALID_3(PCIE_RXVALID_3),
   .FFS_SKP_ADDED_0(FFS_SKP_ADDED_0),
   .FFS_SKP_ADDED_1(FFS_SKP_ADDED_1),
   .FFS_SKP_ADDED_2(FFS_SKP_ADDED_2),
   .FFS_SKP_ADDED_3(FFS_SKP_ADDED_3),
   .FFS_SKP_DELETED_0(FFS_SKP_DELETED_0),
   .FFS_SKP_DELETED_1(FFS_SKP_DELETED_1),
   .FFS_SKP_DELETED_2(FFS_SKP_DELETED_2),
   .FFS_SKP_DELETED_3(FFS_SKP_DELETED_3),
   .LDR_RX2CORE_0(LDR_RX2CORE_0),
   .LDR_RX2CORE_1(LDR_RX2CORE_1),
   .LDR_RX2CORE_2(LDR_RX2CORE_2),
   .LDR_RX2CORE_3(LDR_RX2CORE_3),
   .REFCK2CORE(REFCK2CORE),
   .SCIINT(SCIINT),
   .SCIRDATA0(SCIRDATA0),
   .SCIRDATA1(SCIRDATA1),
   .SCIRDATA2(SCIRDATA2),
   .SCIRDATA3(SCIRDATA3),
   .SCIRDATA4(SCIRDATA4),
   .SCIRDATA5(SCIRDATA5),
   .SCIRDATA6(SCIRDATA6),
   .SCIRDATA7(SCIRDATA7),
   .REFCLK_FROM_NQ(REFCLK_FROM_NQ),
   .REFCLK_TO_NQ(REFCLK_TO_NQ)
    );

//synopsys translate_on
endmodule

