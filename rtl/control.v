//  control.v  --  Control Unit (main decoder + ALU decoder)
//  Looks at the instruction and produces every control signal the datapath
//  needs. All signals are pure combinational functions of the instruction.
`include "defines.vh"

module control (
    input  wire [31:0] instr,
    output reg         reg_write,
    output reg         mem_write,
    output reg  [1:0]  alu_a_src,   // A_RS1 / A_PC / A_ZERO
    output reg         alu_b_src,   // 0 = rs2, 1 = immediate
    output reg  [1:0]  result_src,  // RES_ALU / RES_MEM / RES_PC4
    output reg         branch,      // instruction is a conditional branch
    output reg  [1:0]  jump,        // J_NONE / J_JAL / J_JALR
    output wire [3:0]  alu_ctrl
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire       funct7b5 = instr[30];

    reg [1:0] alu_op;

    // Main decoder: one row per opcode
    always @(*) begin
        // safe defaults: do nothing
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        alu_a_src  = `A_RS1;
        alu_b_src  = 1'b0;
        result_src = `RES_ALU;
        branch     = 1'b0;
        jump       = `J_NONE;
        alu_op     = `ALUOP_ADD;

        case (opcode)
            `OP_REG: begin      // ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA...
                reg_write = 1'b1;
                alu_a_src = `A_RS1;
                alu_b_src = 1'b0;          // second operand is rs2
                alu_op    = `ALUOP_FUNC;
            end
            `OP_IMM: begin      // ADDI, ANDI, ORI, SLTI, SLLI, SRLI, SRAI...
                reg_write = 1'b1;
                alu_a_src = `A_RS1;
                alu_b_src = 1'b1;          // second operand is the immediate
                alu_op    = `ALUOP_FUNC;
            end
            `OP_LOAD: begin     // LW
                reg_write  = 1'b1;
                alu_a_src  = `A_RS1;
                alu_b_src  = 1'b1;         // addr = rs1 + imm
                alu_op     = `ALUOP_ADD;
                result_src = `RES_MEM;     // write-back comes from memory
            end
            `OP_STORE: begin    // SW
                mem_write = 1'b1;
                alu_a_src = `A_RS1;
                alu_b_src = 1'b1;          // addr = rs1 + imm
                alu_op    = `ALUOP_ADD;
            end
            `OP_BRANCH: begin   // BEQ, BNE, BLT, BGE, BLTU, BGEU
                branch    = 1'b1;
                alu_op    = `ALUOP_BR;
            end
            `OP_JAL: begin
                reg_write  = 1'b1;
                jump       = `J_JAL;
                result_src = `RES_PC4;     // rd <- PC + 4
            end
            `OP_JALR: begin
                reg_write  = 1'b1;
                jump       = `J_JALR;
                alu_a_src  = `A_RS1;
                alu_b_src  = 1'b1;         // target = rs1 + imm
                alu_op     = `ALUOP_ADD;
                result_src = `RES_PC4;     // rd <- PC + 4
            end
            `OP_LUI: begin
                reg_write = 1'b1;
                alu_a_src = `A_ZERO;       // rd = 0 + imm = imm
                alu_b_src = 1'b1;
                alu_op    = `ALUOP_ADD;
            end
            `OP_AUIPC: begin
                reg_write = 1'b1;
                alu_a_src = `A_PC;         // rd = PC + imm
                alu_b_src = 1'b1;
                alu_op    = `ALUOP_ADD;
            end
            default: ; // keep safe defaults
        endcase
    end

    // ALU decoder
    alu_decoder u_aludec (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7b5 (funct7b5),
        .op_bit5  (opcode[5]),
        .alu_ctrl (alu_ctrl)
    );
endmodule
