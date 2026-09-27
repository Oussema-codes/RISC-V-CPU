//  alu.v  --  Arithmetic Logic Unit
//  Pure combinational block. Given two 32-bit operands and a 4-bit control
//  code, it produces a 32-bit result and a `zero` flag (result == 0).
`include "defines.vh"

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    // Shift amount is the low 5 bits of b (RV32 shifts by 0..31).
    wire [4:0] shamt = b[4:0];

    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD : result = a + b;
            `ALU_SUB : result = a - b;
            `ALU_AND : result = a & b;
            `ALU_OR  : result = a | b;
            `ALU_XOR : result = a ^ b;
            `ALU_SLL : result = a << shamt;
            `ALU_SRL : result = a >> shamt;                 // logical right
            `ALU_SRA : result = $signed(a) >>> shamt;       // arithmetic right
            `ALU_SLT : result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b)                    ? 32'd1 : 32'd0;
            default  : result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule
