
#!/usr/local/bin/wish

set cpu  $tcl_platform(machine)

switch $cpu {
 intel -
 i*86* {
     set cpu ix86
 }
 x86_64 {
     if {$tcl_platform(wordSize) == 4} {
     set cpu ix86
     }
 }
}

switch $tcl_platform(platform) {
    windows {
        set Para(os_platform) windows
   if {$cpu == "amd64"} {
     # Do not check wordSize, win32-x64 is an IL32P64 platform.
     set cpu x86_64
     }
    }
    unix {
        if {$tcl_platform(os) == "Linux"}  {
            set Para(os_platform) linux
        } else  {
            set Para(os_platform) unix
        }
    }
}

if {$cpu == "x86_64"} {
 set NTPATH nt64
 set LINPATH lin64
} else {
 set NTPATH nt
 set LINPATH lin
}

if {$Para(os_platform) == "linux" } {
    set os $LINPATH
    set idxfile [file join $env(HOME) ipsetting_l.lst]
} else {
    set os $NTPATH
    set idxfile [file join c:/lsc_env ipsetting.lst]
}

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

set Para(ProjectPath) [file dirname [info script]]
package forget core_template
package forget LatticeIPCore
package forget IP_Control
package forget Core_Generate
package forget IP_Generate
package forget IP_Templates
set auto_path "$auto_path"
set Para(install_dir) $env(TOOLRTF)
set Para(CoreIndex) "pci_express_endpoint_v5.3"
set Para(CoreRoot) ""
set fid [open $idxfile r]
while {[gets $fid line ]>=0} {
    if [regexp {([^=]*)=(.*)} $line match parameter value] {
        if [regexp {([ |\t]*;)} $parameter match] {continue}
        set parameter [string trim $parameter]
        set value [string trim $value]
        if {$parameter==$Para(CoreIndex)} {
            if [regexp {(.*)[ |\t]*;} $value match temp] {
                set Para(CoreRoot) $temp
            } else {
                set Para(CoreRoot) $value
            }
        }
    }
}
if {[string length $Para(CoreRoot)]==0} {
    puts stderr "Error: IP $Para(CoreIndex) is not found!"
    exit
}

set Para(ModuleName) "pcie"
set Para(lib) "[file join $Para(CoreRoot) $Para(CoreIndex) lib]"
set Para(CoreName) "PCI Express Endpoint Core"
set Para(arch) "ep5c00"
set Para(family) "ep5c00"
set Para(Family) "ep5c00"
set Para(design) "Verilog HDL"
set Para(Bin) "[file join $Para(install_dir) bin $os]"
set Para(SpeedGrade) "8"
set Para(FPGAPath) "[file join $Para(install_dir) ispfpga bin $os]"

lappend auto_path "[file join $Para(CoreRoot) $Para(CoreIndex) gui]"

lappend auto_path "[file join $Para(CoreRoot) $Para(CoreIndex) script]"
package require Core_Generate

lappend auto_path "$Para(install_dir)/tcltk/lib/ipwidgets/ispipbuilder/../runproc"
package require runcmd


set Para(result) [GenerateCore]
