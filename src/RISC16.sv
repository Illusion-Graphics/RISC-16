`include "Defines.svh"

module RISC16(
    input   bit             aClock,
    input   bit             aReset,

    output  logic   [15:0]  anOutAddress,
    input   logic   [15:0]  aData,
    output  logic   [15:0]  anOutData,
    output  logic           anOutWrite
);

reg [15:0] myInstruction;

// Decode unit
wire [1:0] decodeInstructionType;
wire [7:0] decodeOperand;
wire [2:0] decodeA;
wire [2:0] decodeB;
wire [2:0] decodeC;
wire decodeImmediateFlag;
wire [7:0] decodeImmediate;

Decode decode_inst
(
    .anInstruction(myInstruction),
    .anOutInstructionType(decodeInstructionType),
    .anOutOperand(decodeOperand),
    .anOutOpALU(ALUOperand),
    .anOutA(decodeA),
    .anOutB(decodeB),
    .anOutC(decodeC),
    .anOutImmediateFlag(decodeImmediateFlag),
    .anOutImmediate(decodeImmediate),
    .anOutInstructionError(mySystemFlags.InstructionError)
);

// ALU
wire [4:0] ALUOperand;
wire [15:0] ALUA;
wire [15:0] ALUB;
wire [15:0] ALUOutput;
ALU alu_inst
(
    .anOperand(ALUOperand),
    .aA(ALUA),
    .aB(ALUB),
    .anOutput(ALUOutput),
    .anOutFault()
);


// Internal registers
//  - r0: Special purpose zero register
//  - r1-r7: General purpose registers
//  - r8: Instruction pointer
//  - r9: Return address pointer
//  - r10: Stack pointer
reg [15:0] myRegisters [0:10];

// Flags
typedef struct packed {
    bit InstructionError;
    bit Halt;
} SystemFlags;
SystemFlags mySystemFlags;

// State machine
typedef enum {RESET, FETCHING, DECODE, EXECUTE, APPLY} State;
State myState;
State myNextState; 

// Halt state will finish the current execution and switch to reset
wire haltState = mySystemFlags.Halt;

// Error state will instantly terminate and put the CPU in fault
wire errorState = mySystemFlags.InstructionError || aReset;

// Output logic
always_ff @(posedge aClock) begin
    myState = errorState ? RESET : myNextState;

    case (myState)
        RESET: begin
            if (haltState || aReset)
                myNextState <= RESET;
            else
                myNextState <= FETCHING;
            anOutWrite <= 0;

            // Reset all registers
            for (int i = 0; i < $size(myRegisters); i ++) begin
                myRegisters[i] <= 0;
            end
            myRegisters[7] <= 16'h0400;
            myRegisters[10] <= 16'h0200;
        end
        FETCHING: begin
            myNextState <= DECODE;

            anOutWrite <= 0;

            anOutAddress <= myRegisters[7];
            myRegisters[7]++;
        end
        DECODE: begin
            myInstruction = aData;
            myNextState <= EXECUTE;
        end
        EXECUTE: begin
            case (decodeInstructionType)
                `OP_SYS: begin
                    if (decodeOperand == `INS_HLT)
                        mySystemFlags.Halt = 1;
                end

                `OP_ALU: begin
                    if (decodeImmediateFlag) begin
                        ALUA = myRegisters[{1'b0, decodeA}];
                        ALUB = {8'b0, decodeImmediate};
                    end
                    else begin
                        ALUA = myRegisters[{1'b0, decodeB}];
                        ALUB = myRegisters[{1'b0, decodeC}];
                    end
                end
                
                `OP_FLO: begin

                end

                `OP_MEM: begin
                    case (decodeOperand)
                        `INS_LDR: begin
                            anOutAddress <= myRegisters[{1'b0, decodeB}];
                        end
                        `INS_STR: begin
                            anOutAddress <= myRegisters[{1'b0, decodeA}];
                            anOutData <= myRegisters[{1'b0, decodeB}];
                            anOutWrite <= 1;
                        end
                        `INS_PUSH: begin
                            anOutAddress <= myRegisters[10];
                            anOutData <= myRegisters[{1'b0, decodeA}];
                            anOutWrite <= 1;
                        end
                        `INS_POP: begin
                            anOutAddress <= myRegisters[10] - 1;
                        end
                        default: begin end
                    endcase
                end
            endcase
            myNextState <= APPLY;
        end
        APPLY: begin
            case (decodeInstructionType)
                `OP_SYS: begin end

                `OP_ALU: begin
                    myRegisters[{1'b0, decodeA}] <= ALUOutput;
                end
                
                `OP_FLO: begin
                    case (decodeOperand)
                        `INS_JMP: begin
                            myRegisters[7] = myRegisters[{1'b0, decodeA}];
                        end
                        `INS_JMPO: begin
                            myRegisters[7] = myRegisters[7] + {{8{decodeImmediate[7]}},decodeImmediate};
                        end
                        `INS_CALL: begin
                            myRegisters[8] = myRegisters[7];
                            myRegisters[7] = myRegisters[{1'b0, decodeA}];
                        end
                        `INS_RET: begin
                            myRegisters[7] = myRegisters[8];
                        end
                        `INS_BNZ: begin
                            if (myRegisters[{1'b0, decodeA}] != 0)
                                myRegisters[7] = myRegisters[{1'b0, decodeB}];
                        end
                        `INS_BNZO: begin
                            if (myRegisters[{1'b0, decodeA}] != 0)
                                myRegisters[7] = myRegisters[7] + {{8{decodeImmediate[7]}},decodeImmediate};
                        end
                        `INS_BZ: begin
                            if (myRegisters[{1'b0, decodeA}] == 0)
                                myRegisters[7] = myRegisters[{1'b0, decodeB}];
                        end
                        `INS_BZO: begin
                            if (myRegisters[{1'b0, decodeA}] == 0)
                                myRegisters[7] = myRegisters[7] + {{8{decodeImmediate[7]}},decodeImmediate};
                        end
                        default: begin end
                    endcase
                end

                `OP_MEM: begin
                    case (decodeOperand)
                        `INS_LDR: begin
                            myRegisters[{1'b0, decodeA}] <= aData;
                        end
                        `INS_PUSH: begin
                            myRegisters[10]++;
                        end
                        `INS_POP: begin
                            myRegisters[{1'b0, decodeA}] <= aData;
                            myRegisters[10]--;
                        end
                        default: begin end
                    endcase
                end
            endcase

            // Go to reset state if we have received an halt signal
            myNextState <= haltState ? RESET : FETCHING;
        end
    endcase
end
    
endmodule // RISC16