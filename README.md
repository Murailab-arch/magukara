# magukara

FPGA-based open-source network tester

Please check the [MAGUKARA wiki](/Murailab-arch/magukara/wiki) for how to build your own.


  
                          ,----------------------------,
                          |  TIMESTAMP + Ether frame   |
                          '----------------------------'
                                    |        |
                          ,-----------,    ,-----------,
                          |/dev/magu/0|    |/dev/magu/1|
                          +-----------+----+-----------+
                          |             OS             |
                          '---------+---------+--------'
                                    | PCI Bus |
                          ,---------+---------+--------,
                          |       MAGUKARA(FPGA)       |
                          +-----+----------------+-----+
                          |Port0|                |Port1|
                          '-----'                '-----'
        ,-------------,      |                      |      ,-------------,
    ----| Ether frame |------'                      '------| Ether frame |---->
        '-------------'                                    '-------------'
  
