# magukara

FPGA-based open-source network tester

## Directory Structure

    /cores/              -- Cores library, with Verilog sources, test benches and documentation.
    /cores/coregen       -- libraries for Xilinx
    /cores/ipexpress     -- libraries for Lattice
    /boards/             -- Difrrent boards supported
    /boards/netfpga      -- NetFPGA 1G board
    /boards/ecp3versa    -- Lattice ECP3 Versa Development Kit
    /doc/                -- Documentation.
    /src/viewer/         -- Web frontend using node.js

## Quickstart

### NetFPGA-1G

    $ linux32 bash  # if you are running on 64bit kernel
    # connect JTAG cables
    $ cd boards/netfpga/synthesis
    $ mkdir build
    $ make load

## Building tools

### NetFPGA-1G

* [Xilinx ISE 10.1 sp3](http://www.xilinx.com/support/download/index.htm)

### Lattice ECP3 Verse

* [Lattice Diamond](http://www.latticesemi.com/products/designsoftware/diamond/downloads.cfm)

### Verilog-HDL simulation

* [Icarus Verilog](http://www.icarus.com/eda/verilog/) -- `brew install icarus-verilog` on mac
* [GPL Cver](http://www.pragmatic-c.com/gpl-cver/) -- `brew install gplcver` on mac

### Wave viewer

* [GTKWave](http://gtkwave.sourceforge.net/) -- `brew install gtkwave` on mac

## How to build

### NetFPGA-1G
    $ cd boards/netfpga/synthesis
    $ make

## How to simulation 

### NetFPGA-1G

    $ cd boards/netfpga/test/
    $ make
    $ gtkwave test.vcd

    