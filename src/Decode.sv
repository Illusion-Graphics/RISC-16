`include "Defines.svh"
module Decode
(
    input logic [15:0] anInstruction,

    output logic [1:0] anOutInstructionType,
    output logic [7:0] anOutOperand,

    output logic [4:0] anOutOpALU,
    output logic [2:0] anOutA,
    output logic [2:0] anOutB,
    output logic [2:0] anOutC,

    output logic signed anOutImmediateFlag,
    output logic [7:0] anOutImmediate,

    output logic anOutInstructionError
);

assign anOutInstructionType = anInstruction[15:14];
    
always_comb begin
    anOutImmediateFlag = 0;

    case (anOutInstructionType)
        // ---------------------------------
        // System operations
        `OP_SYS: begin
            anOutOperand = anInstruction[7:0];

            case (anOutOperand)
                `INS_NOP, `INS_HLT: begin end

                default: begin
                    anOutInstructionError = 1;
                end
            endcase
        end
        
        // ---------------------------------
        // ALU operations
        `OP_ALU: begin
            anOutImmediateFlag = anInstruction[13];

            // Not immediate mode
            if (!anOutImmediateFlag) begin
                anOutOperand = {4'b0, anInstruction[12:9]};
                anOutOpALU = anInstruction[13:9];
                anOutA = anInstruction[8:6];
                anOutB = anInstruction[5:3];
                anOutC = anInstruction[2:0];

                case (anOutOperand)
                    `INS_MOV, `INS_ADD, `INS_SUB, `INS_AND, `INS_OR,
                    `INS_NOT, `INS_DEC, `INS_INC, `INS_MUL: begin end

                    default: begin
                        anOutInstructionError = 1;
                    end
                endcase
            end
            // Immediate mode
            else begin
                anOutOperand = {6'b0, anInstruction[12:11]};
                anOutOpALU = {anInstruction[13:11], 2'b00};
                anOutA = anInstruction[10:8];
                anOutImmediate = anInstruction[7:0];
                

                case (anOutOperand)
                    `INS_MOVU, `INS_MOVL: begin end

                    default: begin
                        anOutInstructionError = 1;
                    end
                endcase
            end
        end

        // ---------------------------------
        // Flow operations
        `OP_FLO: begin
            anOutOperand = {2'b0, anInstruction[13:8]};

            case (anOutOperand)
                `INS_JMP, `INS_CALL: begin
                    anOutA = anInstruction[2:0];
                end
                `INS_JMPO: begin
                    anOutImmediate = {3'b0, anInstruction[4:0]};
                    anOutImmediateFlag = 1;
                end
                `INS_BNZ, `INS_BZ: begin
                    anOutA = anInstruction[5:3];
                    anOutB = anInstruction[2:0];
                end
                `INS_BNZO, `INS_BZO: begin
                    anOutA = anInstruction[7:5];
                    anOutImmediate = {{4{anInstruction[4]}},anInstruction[3:0]};
                    anOutImmediateFlag = 1;
                end
                `INS_RET: begin end

                default: begin
                    anOutInstructionError = 1;
                end
            endcase
        end

        // ---------------------------------
        // Memory operations
        `OP_MEM: begin
            anOutOperand = {2'b0, anInstruction[13:8]};

            case (anOutOperand)
               `INS_LDR, `INS_STR: begin
                    anOutA = anInstruction[5:3];
                    anOutB = anInstruction[2:0];
                end

                default: begin
                    anOutInstructionError = 1;
                end
            endcase
        end
    endcase
end

endmodule // Decode