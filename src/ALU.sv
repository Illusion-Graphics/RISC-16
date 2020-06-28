`include "Defines.svh"

module ALU(
    input logic [4:0] anOperand,

    input logic [15:0] aA,
    input logic [15:0] aB,

    output logic [15:0] anOutput,

    output logic anOutFault
);
    
always_comb begin
    case (anOperand)
        `ALU_MOV: begin
            anOutput = aA;
        end
        `ALU_ADD: begin
            anOutput = aA + aB;
        end
        `ALU_SUB: begin
            anOutput = aA - aB;
        end
        `ALU_AND: begin
            anOutput = aA & aB;
        end
        `ALU_OR: begin
            anOutput = aA | aB;
        end
        `ALU_NOT: begin
            anOutput = ~aA;
        end
        `ALU_DEC: begin
            anOutput = aA + 1;
        end
        `ALU_INC: begin
            anOutput = aA - 1;
        end
        `ALU_MUL: begin
            anOutput = aA * aB;
        end
        `ALU_MOVU: begin
            anOutput = (aA & 16'h00FF) | (aB << 8);
        end
        `ALU_MOVL: begin
            anOutput = (aA & 16'hFF00) | aB;
        end
        default: begin
            anOutFault = 1;
        end
    endcase
end

endmodule // ALU