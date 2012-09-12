# magukara

FPGA-based open-source network tester

## Supported FPGA board

* [Lattice ECP3 Versa Development Kit](http://www.latticesemi.com/products/developmenthardware/developmentkits/ecp3versadevelopmentkit/index.cfm)
* NetFPGA-1G (don't use NetFPGA framework)

## Directory Structure

    /cores/              -- Cores library, with Verilog sources, test benches and documentation.
    /cores/coregen       -- libraries for Xilinx
    /cores/ipexpress     -- libraries for Lattice
    /boards/             -- Difrrent boards supported
    /boards/netfpga      -- NetFPGA 1G board
    /boards/ecp3versa    -- Lattice ECP3 Versa Development Kit
    /doc/                -- Documentation.
    /software/monitor/   -- Web frontend using node.js

## Quickstart (build and FPGA configuration)

### LatticeECP3

    # connect USB cables
    $ cd boards/ecp3versa/synthesis
    $ make load

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

### LatticeECP3

    $ cd boards/ecp3versa/synthesis
    $ make

### NetFPGA-1G

    $ cd boards/netfpga/synthesis
    $ make

## How to simulation 

### NetFPGA-1G

    $ cd boards/netfpga/test/
    $ make
    $ gtkwave test.vcd

## Reference

* [RFC2544](http://tools.ietf.org/html/rfc2544) - Benchmarking Methodology for Network Interconnect Devices
* [RFC5180](http://tools.ietf.org/html/rfc5180) - IPv6 Benchmarking Methodology for Network Interconnect Devices
* [RFC6201](http://tools.ietf.org/html/rfc6201) - Device Reset Characterization
