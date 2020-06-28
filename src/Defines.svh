`ifndef __DEFINES_SVH
`define __DEFINES_SVH

// Instruction operands
// - System operations
`define     INS_NOP     8'b00000000
`define     INS_HLT     8'b00000001
// - ALU operations
`define     INS_MOV     8'b00000000
`define     INS_ADD     8'b00000001
`define     INS_SUB     8'b00000010
`define     INS_AND     8'b00000011
`define     INS_OR      8'b00000100
`define     INS_NOT     8'b00000101
`define     INS_DEC     8'b00000110
`define     INS_INC     8'b00000111
`define     INS_MUL     8'b00001000
`define     INS_MOVU    8'b00000000
`define     INS_MOVL    8'b00000001
// - Flow operations
`define     INS_JMP     8'b00000001
`define     INS_JMPO    8'b00000010
`define     INS_CALL    8'b00000011
`define     INS_RET     8'b00000100
`define     INS_BNZ     8'b00000101
`define     INS_BNZO    8'b00000110
`define     INS_BZ      8'b00000111
`define     INS_BZO     8'b00001000
// - Memory operations
`define     INS_LDR     8'b00000001
`define     INS_STR    8'b00000010


// ALU operands
`define     ALU_MOV     5'b00000
`define     ALU_ADD     5'b00001
`define     ALU_SUB     5'b00010
`define     ALU_AND     5'b00011
`define     ALU_OR      5'b00100
`define     ALU_NOT     5'b00101
`define     ALU_DEC     5'b00110
`define     ALU_INC     5'b00111
`define     ALU_MUL     5'b01000
`define     ALU_MOVU    5'b10000
`define     ALU_MOVL    5'b10100

`endif // __DEFINES_SVH