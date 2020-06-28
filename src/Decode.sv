module Decode
(
    input logic [15:0] anInstruction,

    output logic [1:0] anOutInstructionType,

    output logic [4:0] anOutOpALU,
    output logic [2:0] anOutA,
    output logic [2:0] anOutB,
    output logic [2:0] anOutC,

    output logic signed anOutImmediateFlag,
    output logic [7:0] anOutImmediate,

    output logic anInstructionError
);

assign anOutInstructionType = anInstruction[15:14];
    
always_comb begin
    anOutImmediateFlag = 0;

    case (anInstruction[15:14])
        // ---------------------------------
        // System operations
        2'b00: begin
            case (anInstruction)
                // NOP
                16'h0000: begin end

                // HLT
                16'h0001: begin
                end
            endcase
        end
        
        // ---------------------------------
        // ALU operations
        2'b01: begin
            // Not immediate mode
            if (!anInstruction[13]) begin
                anOutOpALU = anInstruction[13:9];
                anOutA = anInstruction[8:6];
                anOutB = anInstruction[5:3];
                anOutC = anInstruction[2:0];
            end
            // Immediate mode
            else begin
                anOutImmediateFlag = 1;
                anOutOpALU = {anInstruction[13:11], 2'b00};
                anOutA = anInstruction[10:8];
                anOutImmediate = anInstruction[7:0];
            end
        end

        // ---------------------------------
        // Flow operations
        2'b10: begin
            case (anInstruction[13:8])
                // JMP
                6'b000001,
                // CALL
                6'b000011: begin
                    anOutA = anInstruction[2:0];
                end
                // JMPO
                6'b000010: begin
                    anOutImmediate = {3'b0, anInstruction[4:0]};
                    anOutImmediateFlag = 1;
                end
                // BNZ
                6'b000101,
                // BZ
                6'b000111: begin
                    anOutA = anInstruction[5:3];
                    anOutB = anInstruction[2:0];
                end
                // BNZO
                6'b000110,
                // BZO
                6'b001000: begin
                    anOutA = anInstruction[7:5];
                    anOutImmediate = {{4{anInstruction[4]}},anInstruction[3:0]};
                    anOutImmediateFlag = 1;
                end
                // RET
                6'b000100: begin end

                default: begin
                    anInstructionError = 1;
                end
            endcase
        end

        // ---------------------------------
        // Memory operations
        2'b11: begin
            case (anInstruction[13:8])
                // LDR
                6'b000001,
                // STR
                6'b000010: begin
                    anOutA = anInstruction[5:3];
                    anOutB = anInstruction[2:0];
                end

                default: begin
                    anInstructionError = 1;
                end
            endcase
        end

        default: begin
            anInstructionError = 1;
        end
    endcase
end

endmodule