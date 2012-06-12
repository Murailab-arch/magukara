
#!/usr/local/bin/wish

set Para(cmd) ""
if ![catch {set temp $argc} result] {
    if {$argc > 0} {
        for {set i 0} {$i < $argc} {incr i 2} {
            set temp [lindex $argv $i]
            set temp [string range $temp 1 end]
            lappend argv_list $temp
            lappend value_list [lindex $argv [expr $i+1]]
        }
        foreach argument $argv_list value $value_list {
            switch $argument {
                "cmd" {set Para(cmd) $value;}
            }
        }
    }
}

set Para(ProjectPath) "D:/project/PCIe_IP/Native_PCIeBasic_SBx1/ispLeverGenCore/ecp3/rcx1"
set Para(ModuleName) "pcierc_test"
set Para(lib) "C:/ispLEVERCore/pci_express_rc_lite_v1.0/lib"
set Para(CoreName) "PCI EXP RCLite"
set Para(family) "latticeecp3"
set Para(Family) "ep5c00"
set Para(design) "Verilog HDL"

lappend auto_path "C:/ispLEVERCore/pci_express_rc_lite_v1.0/gui"

lappend auto_path "C:/ispLEVERCore/pci_express_rc_lite_v1.0/script"
package require Core_Generate

lappend auto_path "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../runproc"
package require runcmd

set Para(install_dir) "C:/ispTOOLS8_1/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../.."

set Para(result) [GenerateCore]
