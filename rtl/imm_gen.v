//  imm_gen.v  --  Immediate Generator
//  RISC-V scatters the immediate's bits across the instruction differently for
//  each instruction format. This block reassembles them and sign-extends the
//  result to 32 bits, choosing the format from the opcode.
`include "defines.vh"

module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: loads, JALR, and register-immediate ALU ops
            `OP_LOAD, `OP_JALR, `OP_IMM:
                imm = {{20{instr[31]}}, instr[31:20]};

            // S-type: stores
            `OP_STORE:
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: branches (note the implicit 0 in bit 0)
            `OP_BRANCH:
                imm = {{19{instr[31]}}, instr[31], instr[7],
                       instr[30:25], instr[11:8], 1'b0};

            // U-type: LUI, AUIPC (immediate lives in the upper 20 bits)
            `OP_LUI, `OP_AUIPC:
                imm = {instr[31:12], 12'b0};

            // J-type: JAL
            `OP_JAL:
                imm = {{11{instr[31]}}, instr[31], instr[19:12],
                       instr[20], instr[30:21], 1'b0};

            default:
                imm = 32'd0;
        endcase
    end
endmodule
