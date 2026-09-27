//  alu_decoder.v  --  ALU Control Decoder
//  Translates the coarse ALUOp (from the main decoder) plus funct3/funct7 into
//  the 4-bit alu_ctrl code the ALU understands.
//    ALUOP_ADD  -> always ADD  (address math, LUI, AUIPC, JAL/JALR target)
//    ALUOP_BR   -> ADD         (branches compare in the branch_unit)
//    ALUOP_FUNC -> decode the exact op from funct3 (+ funct7 for SUB/SRA)
`include "defines.vh"

module alu_decoder (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,     // instr[30] : distinguishes ADD/SUB, SRL/SRA
    input  wire       op_bit5,      // instr[5]  : 1 = R-type (OP), 0 = OP-IMM
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            `ALUOP_ADD : alu_ctrl = `ALU_ADD;
            `ALUOP_BR  : alu_ctrl = `ALU_ADD;   // ALU unused for the compare
            default    : begin                  // ALUOP_FUNC
                case (funct3)
                    3'b000 : // ADD / SUB (SUB only for R-type with funct7[5]=1)
                        alu_ctrl = (op_bit5 & funct7b5) ? `ALU_SUB : `ALU_ADD;
                    3'b001 : alu_ctrl = `ALU_SLL;
                    3'b010 : alu_ctrl = `ALU_SLT;
                    3'b011 : alu_ctrl = `ALU_SLTU;
                    3'b100 : alu_ctrl = `ALU_XOR;
                    3'b101 : // SRL / SRA
                        alu_ctrl = funct7b5 ? `ALU_SRA : `ALU_SRL;
                    3'b110 : alu_ctrl = `ALU_OR;
                    3'b111 : alu_ctrl = `ALU_AND;
                    default: alu_ctrl = `ALU_ADD;
                endcase
            end
        endcase
    end
endmodule
