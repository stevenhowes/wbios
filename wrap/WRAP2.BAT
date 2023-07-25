a386 wrap_cfg.8 wrap_cfg.bin
a386 wrap2.8 wrap2.bin
..\tool\biossum wrap2.bin wrap2.abs
..\tool\cat pxe.bin ..\fill32.bin ..\fill32.bin wrap_cfg.bin wrap2.abs > wrap2.rom
