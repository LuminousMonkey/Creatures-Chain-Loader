// Working through understanding the second stage loader of CREATURES.


// $2AED Is starting memory location once loaded?

// 924C - Intro code?

* = $c240 "Init"
  sei

  // Initialise expected bank switching.
  lda #36
  sta $01

  // Set up VIC-II interrupts.
  lda #79
  sta $d019
  lda #f0
  sta $d01a

  // Clear off sprites, etc.
  lda #00
  sta $d418                     // Silence SID
  sta $d020                     // Border colour
  sta $d011                     // VIC-II Control register 1
  sta $d015                     // Turn off all sprites

  // SETLFS Call.
  lda #01
  ldx #08
  ldy #00
  jsr $ffba                     // SETLFS - Logical: 1, Device 8, Sec: 00

  // SETNAM
  lda #04                       // Filename length
  ldx #<filename                // Pointer to filename (c396)
  ldy #>filename
  jsr $ffbd                     // SETNAME
  jsr $f3d5                     // Open file on serial bus.

  lda LAST_ACCESSED_SERIAL      // Last accessed serial device.
  jsr $ed09                     // Send TALK command to serial bus.
  lda $b9                       // Current secondary address.
  jsr $edc7                     // Send TALK to secondary address.
  jsr $ee13                     // Read byte from serial bus.

  lda #00
  sta $a4                       // Bit counter for serial bus.

  // This writes the following bytes to the serial bus:
  // "oM-W"
  jsr sub_routine_1

  lda #$57                      // "W"
  jsr $eddd                     // Write to serial bus.

  lda $a4                       // Write bit counter out to serial bus.
  jsr $eddd

// Possibly some disk loading code?
* = $c382 "Unknown routine."
sub_routine_1:
  lda LAST_ACCESSED_SERIAL      // Last accessed serial device.
  jsr $ed0c                     // Listen to serial bus.

  lda #$6f                      // "o"
  jsr $edb9                     // Send LISTEN to secondary address.

  lda #$4d                      // "M"
  jsr $eddd                     // Write byte to serial bus.

  lda #$2d                      // "-"
  jmp $eddd                     // Write to serial bus (returns back to sub_routine_1 jsr call)

* = $c396 "Filename"
filename:
  .text "MENU"

.label LAST_ACCESSED_SERIAL = $ba
