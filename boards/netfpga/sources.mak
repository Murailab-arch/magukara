BOARD_SRC=$(wildcard $(BOARD_DIR)/*.v)

#ASFIFO_SRC_SRC=$(wildcard $(CORES_DIR)/asfifo/rtl/*.v)
#FIFO9TOGMII_SRC=$(wildcard $(CORES_DIR)/fifo9togmii/rtl/*.v)
GMII2FIFO9_SRC=$(wildcard $(CORES_DIR)/gmii2fifo9/rtl/*.v)
RGMII2GMII_SRC=$(wildcard $(CORES_DIR)/rgmii2gmii/rtl/*.v)
CRC_SRC=$(wildcard $(CORES_DIR)/crc/rtl/*.v)
COREGEN_SRC=$(wildcard $(CORES_DIR)/coregen/*.v)
MEASURE_SRC=$(wildcard $(CORES_DIR)/measure/rtl/*.v)

CORES_SRC=$(ASFIFO_SRC) $(FIFO9TOGMII_SRC) $(GMII2FIFO9_SRC) $(RGMII2GMII_SRC) $(CRC_SRC) $(COREGEN_SRC) $(MEASURE_SRC)
