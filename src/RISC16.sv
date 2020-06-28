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
wire [2:0] decodeA;
wire [2:0] decodeB;
wire [2:0] decodeC;
wire decodeImmediateFlag;
wire [7:0] decodeImmediate;

Decode decode_inst
(
    .anInstruction(myInstruction),
    .anOutInstructionType(decodeInstructionType),
    .anOutOpALU(ALUOperand),
    .anOutA(decodeA),
    .anOutB(decodeB),
    .anOutC(decodeC),
    .anOutImmediateFlag(decodeImmediateFlag),
    .anOutImmediate(decodeImmediate),
    .anInstructionError(mySystemFlags.InstructionError)
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
reg [15:0] myRegisters [0:9];

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
                2'b00: begin
                    if (myInstruction[7:0] == 8'b00000001) begin
                        mySystemFlags.Halt = 1;
                    end
                end

                2'b01: begin
                    if (decodeImmediateFlag) begin
                        ALUA = myRegisters[{1'b0, decodeA}];
                        ALUB = {8'b0, decodeImmediate};
                    end
                    else begin
                        ALUA = myRegisters[{1'b0, decodeB}];
                        ALUB = myRegisters[{1'b0, decodeC}];
                    end
                end
                
                2'b10: begin

                end
                2'b11: begin
                    if (myInstruction[13:8] == 6'b000001) begin
                        anOutAddress <= myRegisters[{1'b0, decodeB}];
                    end
                    else if (myInstruction[13:8] == 6'b000010) begin
                        anOutAddress <= myRegisters[{1'b0, decodeA}];
                        anOutData <= myRegisters[{1'b0, decodeB}];
                        anOutWrite <= 1;
                    end
                end
            endcase
            myNextState <= APPLY;
        end
        APPLY: begin
            case (decodeInstructionType)
                2'b00: begin end

                2'b01: begin
                    myRegisters[{1'b0, decodeA}] <= ALUOutput;
                end
                
                2'b10: begin
                    if (myInstruction[13:8] == 6'b000110) begin
                        if (myRegisters[{1'b0, decodeA}] != 0) begin
                            myRegisters[7] = myRegisters[7] + {{8{decodeImmediate[7]}},decodeImmediate};
                        end
                    end

                end
                2'b11: begin
                    if (myInstruction[13:8] == 6'b000001) begin
                        myRegisters[{1'b0, decodeA}] <= aData;
                    end
                end
            endcase

            // Go to reset state if we have received an halt signal
            myNextState <= haltState ? RESET : FETCHING;
        end
    endcase
end
    
endmodule // RISC16