; ********************************************
; * Galaxian.h - Galaxian hardware constants *
; ********************************************

; Memory

RAM            = 0x4000 ; Main memory address space is 2KB long, but it's really 1KB of physical memory that's
                        ; accessible starting at either 0x4000 or 0x4400
VideoRAM       = 0x5000 ; Video RAM address space is 2KB long, but it's really 1KB of physical memory that's
                        ; accessible starting at either 0x5000 or 0x5400
ScreenAttrRAM  = 0x5800
SpriteRAM      = 0x5840
BulletRAM      = 0x5860

; Memory-mapped I/O ports.  Note that some share the same address but one will be read-only and one will be write-only

Input0         = 0x6000 ; Read-only
Input1         = 0x6800 ; Read-only
SoundControl   = 0x6800 ; Sound control ports go from 0x6800-0x6807.  Write-only
Input2         = 0x7000 ; Read-only
NMIEnable      = 0x7001 ; Write-only
Stars          = 0x7004 ; Write-only
VerticalFlip   = 0x7006 ; Write-only
HorizontalFlip = 0x7007 ; Write-only
Watchdog       = 0x7800 ; Read-only
SoundFreq      = 0x7800 ; Write-only