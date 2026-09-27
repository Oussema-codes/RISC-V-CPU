//  defines.vh  --  Shared constants for the single-cycle RV32I core
//  Include this in any module that needs the named encodings.
`ifndef RV_DEFINES_VH
`define RV_DEFINES_VH

// RV32I opcodes (instruction bits [6:0])
`define OP_LUI     7'b0110111
`define OP_AUIPC   7'b0010111
`define OP_JAL     7'b1101111
`define OP_JALR    7'b1100111
`define OP_BRANCH  7'b1100011
`define OP_LOAD    7'b0000011
`define OP_STORE   7'b0100011
`define OP_IMM     7'b0010011   // ADDI, SLTI, ... (register-immediate ALU)
`define OP_REG     7'b0110011   // ADD, SUB, ...   (register-register ALU)

// ALU operation codes (our own 4-bit encoding)
`define ALU_ADD    4'b0000
`define ALU_SUB    4'b0001
`define ALU_AND    4'b0010
`define ALU_OR     4'b0011
`define ALU_XOR    4'b0100
`define ALU_SLL    4'b0101
`define ALU_SRL    4'b0110
`define ALU_SRA    4'b0111
`define ALU_SLT    4'b1000   // set-less-than, signed
`define ALU_SLTU   4'b1001   // set-less-than, unsigned

// ALUOp given by the main decoder to the ALU decoder
`define ALUOP_ADD  2'b00   // force ADD (loads/stores/lui/auipc/jal target)
`define ALUOP_BR   2'b01   // branch (compare handled by branch unit; ALU=ADD)
`define ALUOP_FUNC 2'b10   // decode from funct3/funct7 (R- and I-type ALU)

// alu_a_src select
`define A_RS1      2'b00
`define A_PC       2'b01
`define A_ZERO     2'b10   // used by LUI so that rd = 0 + imm = imm

// result_src (write-back mux)
`define RES_ALU    2'b00
`define RES_MEM    2'b01
`define RES_PC4    2'b10   // PC+4, for JAL/JALR link register

// jump encoding
`define J_NONE     2'b00
`define J_JAL      2'b01
`define J_JALR     2'b10

`endif
