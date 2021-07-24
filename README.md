# galaxianhelloworld
Hello World Program for Galaxian arcade hardware

## Overview

Galaxian was an arcade game by Namco released in 1979.  It proved to be immensely successful in the arcades upon it's release.  It's hardware was later used as the basis for many other arcade games released in the late 70s and early 80s.  (Scroll to the bottom of the Galaxian MAME driver file here to see a mostly complete list: https://github.com/mamedev/mame/blob/master/src/mame/drivers/galaxian.cpp)

This project is a simple 'Hello World' program for said hardware that also allows you to rotate a sprite graphic using the joystick.  It demonstrates some of the features of the graphics hardware such as tiles (the actual 'Hello World' text), sprites (including how horizontal and vertical flipping works), and bullets.

## Building

Since it's written in Z80 assembly, to build this, you will need a Z80 cross-assembler.  I used RASM, which can be found at https://github.com/EdouardBERGE/rasm.  If you use a different cross-assembler, you may need to modify the source code slightly to support the nuances of that assembler.

## Running

Note that this project will only assemble an executable ROM - it does not contain any source code to assemble any tile ROMs, and in fact assumes the use of the default Galaxian tile ROMs.  To run it, simply assemble the program, and copy the 2K output binary over the first ROM image you would find in a standard Galaxian 5 ROM set. In the case of the MAME 'galaxian' ROMSET, this would be the file 'galmidw.u'.

## Other

This program has been tested and verified to work on original Galaxian hardware.
