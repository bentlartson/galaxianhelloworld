; ****************************************************************
; * HelloWorld.asm - 'Hello World' program for Galaxian hardware *
; ****************************************************************
;
; Galaxian uses a vertical (i.e. portrait instead of landscape) monitor orientation.  I define the X axis as being the
; axis going left to right in this portait orientation, and the Y axis as being the axis going up and down.
;
; Note that this demo uses the default Galaxian tileset and color palettes.  Tilesets are stored in a separate memory
; space that isn't addressible by the CPU - the same goes for the color palettes.

INCLUDE 'galaxian.h'

; Variables
Temp           = 0x4000
Temp2          = 0x4001
SpriteGlyph    = 0x4002

        org 0x0000

        ; Disable NMI generation for now and jump to main
        LD A, $00
        LD (NMIEnable), A 
        JP Main

; **********************************
; * NON-MASKABLE INTERRUPT HANDLER *
; **********************************
;
; NMIs are generated 60 times per second and are synonymous with vertical blank
; The actual NMI handler always has to be at memory location 0x0066 per the Z80 architecture specification

        org 0x0066
 
        XOR A                              ; XOR A with A (aka clearing A)
        LD (NMIEnable), A                  ; Disable NMI generation for the duration of the handler

        ; Kick the watchdog
        LD A, (Watchdog)

        ; Check the joystick for left/right movement and update our sprite accordingly
        CALL UpdateSpriteRotation

        LD A, $01
        LD (NMIEnable), A                  ; Set NMI generation back on

        RET

; ********
; * MAIN *
; ********

Main

; ******************
; * INITIALIZATION *
; ******************

        ; Set stack to the beginning
        LD SP, $47FF

        ; Clear sound effects
        XOR A
        LD B, 8
        LD HL, SoundControl
ClearSoundsTop
        LD (HL), A
        INC HL
        DJNZ ClearSoundsTop

        ; Set sound frequency to 255 (this seems to actually turn the sound off)
        LD A, 255
        LD (SoundFreq), A

        ; Clear main RAM (256 bytes x 4 times through)
        XOR A
        LD C, 4
        LD HL, RAM
ClearRAMOuterLoopTop
        LD B, 0
ClearRAMLoopTop
        LD (HL), A
        INC HL
        DJNZ ClearRAMLoopTop
        DEC C
        JP NZ, ClearRAMOuterLoopTop

        ; Fill video RAM with the empty character glyph (0x10) (256 bytes x 4 times through)
        LD A, 0x10
        LD C, 4
        LD HL, VideoRAM
ClearVideoRAMOuterLoopTop
        LD B, 0
ClearVideoRAMLoopTop
        LD (HL), A
        INC HL
        DJNZ ClearVideoRAMLoopTop
        DEC C
        JP NZ, ClearVideoRAMOuterLoopTop

        ; Set all tile rows to scroll offset of 0 and palette 3
        LD HL, ScreenAttrRAM
        LD B, 32
ClearScreenAttrRAMLoopTop
        XOR A
        LD (HL), A
        INC HL
        LD A, 3
        LD (HL), A
        INC HL
        DJNZ ClearScreenAttrRAMLoopTop

        ; Clear all sprites
        LD HL, SpriteRAM
        LD, B, 32
        XOR A
ClearSpriteRAMLoopTop
        LD (HL), A
        INC HL
        DJNZ ClearSpriteRAMLoopTop

        ; Clear all bullets
        LD HL, BulletRAM
        LD, B, 32
ClearBulletRAMLoopTop
        LD (HL), A
        INC HL
        DJNZ ClearBulletRAMLoopTop

        ; Set horizontal and vertical flip to 'off' and stars to 'off'
        XOR A
        LD (VerticalFlip), A
        LD (HorizontalFlip), A
        LD (Stars), A

        ; Initialize the demo-specific data
        CALL InitializeDemo

        ; Enable NMI generation
        LD A, $01
        LD (NMIEnable), A

; *************
; * MAIN LOOP *
; *************
;
; Just a busy wait loop - the logic is all in the NMI handler above

MainLoopTop

        JP MainLoopTop

; *************************************
; * UPDATE SPRITE ROTATION SUBROUTINE *
; *************************************

UpdateSpriteRotation

        ; Check to see if the joystick is being presed right
        LD A, (Input0)
        BIT 3, A 
        JP Z, NoJoystickRight

        ; Load sprite index into B, rotation direction into C, and base glyph into D
        XOR A
        LD B, A
        LD A, 1
        LD C, A
        LD A, (SpriteGlyph)
        LD D, A

        ; Rotate the sprite left
        CALL RotateSprite

NoJoystickRight

        ; Check to see if the joystick is being presed left
        LD A, (Input0)
        BIT 2, A 
        JP Z, NoJoystickLeft

        ; Load sprite index into B, rotation direction into C, and base glyph into D
        XOR A
        LD B, A
        LD C, A
        LD A, (SpriteGlyph)
        LD D, A

        ; Rotate the sprite right
        CALL RotateSprite      

NoJoystickLeft

        RET

; ******************************
; * INITIALIZE DEMO SUBROUTINE *
; ******************************

InitializeDemo

        ; Place an 'H' tile
        LD B, 24
        LD C, 8
        LD D, 15
        CALL PlaceTile

        ; Place an 'E' tile
        LD B, 21
        LD C, 9
        CALL PlaceTile

        ; Place two 'L' tiles
        LD B, 28
        LD C, 10
        CALL PlaceTile
        LD C, 11
        CALL PlaceTile

        ; Place an 'O' tile
        LD B, 31
        LD C, 12
        CALL PlaceTile

        ; Place a 'W' tile
        LD B, 39
        LD C, 14
        CALL PlaceTile

        ; Place an 'O' tile
        LD B, 31
        LD C, 15
        CALL PlaceTile

        ; Place an 'R' tile
        LD B, 34
        LD C, 16
        CALL PlaceTile

        ; Place an 'L' tile
        LD B, 28
        LD C, 17
        CALL PlaceTile

        ; Place a 'D' tile
        LD B, 20
        LD C, 18
        CALL PlaceTile

        ; Save the initial sprite glyph
        LD HL, SpriteGlyph
        LD (HL), 41

        ; Place a test sprite
        LD B, 0
        LD A, (SpriteGlyph)
        LD C, A
        LD D, 101
        LD E, 92
        LD A, 2
        LD I, A
        CALL PlaceSprite

        ; Place a test bullet
        LD B, 0
        LD C, 50
        LD D, 129
        CALL PlaceBullet

        ; Place another test bullet
        LD B, 1
        LD C, 200
        LD D, 129
        CALL PlaceBullet

        RET

; ***************************
; * PLACE BULLET SUBROUTINE *
; ***************************
;
; Input parameters:
;
; * B = Index of the bullet to place (0-7)
; * C = X location
; * D = Y location

PlaceBullet

       ; Save D in Temp since we need to overwite D later
        LD A, D
        LD (Temp), A

         ; Calculate the memory offset
        LD A, B
        RLA
        RLA                                ; Multiply the bullet index by 4 since each bullet is 4 bytes
        LD D, 0
        LD E, A                            ; Transfer the result from A to DE
        LD HL, BulletRAM+1
        ADD HL, DE                         ; Add the result to the BulletRAM+1 base address and store the final result in HL

        ; Restore D
        LD A, (Temp)
        LD D, A

        ; Write the bullet X/Y data
        LD (HL), C
        INC HL
        INC HL
        LD (HL), D
        
        RET

; ***************************
; * PLACE SPRITE SUBROUTINE *
; ***************************
;
; Input parameters:
;
; * B = Index of the sprite to place (0-7)
; * C = Sprite glyph
; * D = X location
; * E = Y location
; * I = Palette to use

PlaceSprite

       ; Save D and E since we need to overwite them
        PUSH DE

         ; Calculate the memory offset
        LD A, B
        RLA
        RLA                                ; Multiply the sprite index by 4 since each sprite is 4 bytes
        LD D, 0
        LD E, A                            ; Transfer the result from A to DE
        LD HL, SpriteRAM
        ADD HL, DE                         ; Add the result to the SpriteRAM base address and store the final result in HL

        ; Restore D and E
        POP DE

        ; Write the sprite data
        LD A, D
        ADD 16                             ; location = 16 actually corresponds to the far left edge of the screen
        LD (HL), A
        INC HL
        LD (HL), C
        INC HL
        LD A, I
        LD (HL), A
        INC HL
        LD (HL), E

        RET
 
; ****************************
; * ROTATE SPRITE SUBROUTINE *
; ****************************
;
; This 'rotates' a sprite which is defined by 7 consecutive adjacent sprite glyphs representing 90 degrees of rotation
;
; Input parameters:
;
; * B = Index of the sprite to rotate (0-7)
; * C = Direction to rotate (0 = 'left', 1 = 'right')
; * D = Sprite base (i.e. lowest value) glyph
;
; Additional registers/memory used:
;
; * A    = Temp storage
; * E    = Temp storage
; * H    = Temp storage
; * L    = Temp storage
; * Temp = Temp storage

RotateSprite

       ; Save D in Temp since we need to overwite D later
        LD A, D
        LD (Temp), A

        ; Calculate the memory offset
        LD A, B
        RLA
        RLA                                ; Multiply the sprite index by 4 since each sprite is 4 bytes
        INC A                              ; ...and add 1 since the sprite glyph is the second of the 4 bytes
        LD D, 0
        LD E, A                            ; Transfer the result from A to DE
        LD HL, SpriteRAM
        ADD HL, DE                         ; Add the result to the SpriteRAM base address and store the final result in HL

        ; Restore D
        LD A, (Temp)
        LD D, A
        
        BIT 0, C
        JP Z, NoRotateRight

        ; Flip the sprite vertically if needed
        LD A, (HL)
        SUB D
        SUB 6                              ; Is the sprite glyph currently equal to base value + 6?
        JP NZ, SpriteNotFacingLeft
        LD A, D
        ADD A, 6+64                        ; If so, then set the Y flip bit (base value + 6 plus bit 6 set)
        LD (HL), A
SpriteNotFacingLeft

        ; Flip the sprite horizontally if needed
        LD A, (HL)
        SUB D
        SUB 64                             ; Is the sprite glyph currently equal to base value plus bit 6 set?
        JP NZ, SpriteNotFacingUp
        LD A, D
        ADD A, 192                         ; If so, then set the X flip bit (base value plus bit 6 & 7 set)
        LD (HL), A
SpriteNotFacingUp

        ; Unflip the sprite vertically if needed
        LD A, (HL)
        SUB D
        SUB 6+192                          ; Is the sprite glyph currently equal to base value plus bit 6 & 7 set?
        JP NZ, SpriteNotFacingRight
        LD A, D
        ADD A, 6+128                       ; If so, then unset the X flip bit (base value + 6 plus bit 7 set)
        LD (HL), A
SpriteNotFacingRight

        ; Unflip the sprite horizontally if needed
        LD A, (HL)
        SUB D
        SUB 128                            ; Is the sprite glyph currently equal to bas value plus bit 7 set?
        JP NZ, SpriteNotFacingDown
        LD A, D                            ; If so, then unset the Y flip bit
        LD (HL), A
SpriteNotFacingDown

        ; Update the sprite glyph as needed
        LD A, (HL)
        AND 192
        JP Z, IncrementGlyph               ; Increment the sprite glyph if both bit flip flags are off
        SUB 192
        JP Z, IncrementGlyph               ; Also increment the sprite glyph if both bit flip flags are on
        LD A, (HL)
        DEC A                              ; Otherwise, decrement the sprite glyph
        JP IncrementDecrementGlyphEndIf
IncrementGlyph
        LD A, (HL)
        INC A
IncrementDecrementGlyphEndIf
        LD (HL), A                         ; Save the sprite glyph value back into memory
        JP RotateEndIf

NoRotateRight

        ; Flip the sprite horizontally if needed
        LD A, (HL)
        SUB D                              ; Is the sprite glyph currently equal to base value?
        JP NZ, SpriteNotFacingDown2
        LD A, D
        ADD A, 128                         ; If so, then set the X flip bit (base value plus bit 7 set)
        LD (HL), A
SpriteNotFacingDown2

        ; Flip the sprite vertically if needed
        LD A, (HL)
        SUB D
        SUB 6+128                          ; Is the sprite glyph currently equal to base value + 6 plus bit 7 set?
        JP NZ, SpriteNotFacingRight2
        LD A, D
        ADD A, 6+192                       ; If so, then set the Y flip bit (base value + 6 plus bit 6 & 7 set)
        LD (HL), A
SpriteNotFacingRight2

        ; Unflip the sprite horizontally if needed
        LD A, (HL)
        SUB D
        SUB 192                            ; Is the sprite glyph currently equal to base value plus bit 6 & 7 set?
        JP NZ, SpriteNotFacingUp2
        LD A, D
        ADD A, 64                          ; If so, then unset the Y flip bit
        LD (HL), A
SpriteNotFacingUp2

        ; Unflip the sprite vertically if needed
        LD A, (HL)
        SUB D
        SUB 6+64                           ; Is the sprite glyph currently equal to base value + 6 plus bit 6 set?
        JP NZ, SpriteNotFacingLeft2
        LD A, D
        ADD A, 6                           ; If so, then unset the X flip bit
        LD (HL), A
SpriteNotFacingLeft2

        ; Update the sprite glyph as needed
        LD A, (HL)
        AND 192
        JP Z, DecrementGlyph2              ; Decrement the sprite glyph if both bit flip flags are off
        SUB 192
        JP Z, DecrementGlyph2              ; Also decrement the sprite glyph if both bit flip flags are on
        LD A, (HL)
        INC A                              ; Otherwise, increment the sprite glyph
        JP IncrementDecrementGlyphEndIf2
DecrementGlyph2
        LD A, (HL)
        DEC A
IncrementDecrementGlyphEndIf2
        LD (HL), A                         ; Save the sprite glyph value back into memory

RotateEndIf

        RET

; *************************
; * PLACE TILE SUBROUTINE *
; *************************
;
; Input parameters:
;
; * B = Index of the tile to place (0-255)
; * C = X position of the tile, where 0 is the left side of the screen and 27 is the right
; * D = Y position of the tile, where 0 is the top of the screen and 31 is the bottom
;
; Additional registers/memory used:
;
; * A    = Temp storage
; * E    = Temp storage
; * H    = Temp storage
; * L    = Temp storage
; * Temp = Temp storage

PlaceTile
 
       ; Save D in Temp since we need to overwite D later
        LD A, D
        LD (Temp), A

        ; The proper memory offset = (27 - X) * 32 + Y + 64
        LD A, 27                           ; Load 27 into A
        SUB C                              ; Subtract X
        LD H, 0
        LD L, A                            ; Load the result into HL
        LD E, 5
XTimes32Top
        SLA L
        RL H                               ; Rotate HL left 5 times in order to multiply by 32
        DEC E
        JP NZ, XTimes32Top
        LD A, D                            ; Now load the Y value into A
        ADD A, 64                          ; Add 64
        LD D, 0
        LD E, A                            ; Transfer the result from A to DE
        ADD HL, DE                         ; Now add it all together and put the result in HL

        ; Load the actual tile
        LD DE, VideoRAM                    ; Load the video RAM base address into DE
        ADD HL, DE                         ; Now add the tile offset we calculated and store the result in HL
        LD (HL), B                         ; Store the tile value at the mem location given by HL

        ; Restore D
        LD A, (Temp)
        LD D, A

        RET

        org 0x07ff
        defb 0xff
        org 0x0800
