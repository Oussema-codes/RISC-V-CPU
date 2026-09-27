//  branch_unit.v  --  Branch Comparator
//  Decides whether a conditional branch is taken, based on funct3 and the two
//  register operands. Kept separate from the ALU so the branch logic is easy
//  to read and test on its own.
module branch_unit (
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    output reg         take          // 1 => condition true => branch taken
);
    always @(*) begin
        case (funct3)
            3'b000 : take = (rs1 == rs2);                       // BEQ
            3'b001 : take = (rs1 != rs2);                       // BNE
            3'b100 : take = ($signed(rs1) <  $signed(rs2));     // BLT
            3'b101 : take = ($signed(rs1) >= $signed(rs2));     // BGE
            3'b110 : take = (rs1 <  rs2);                       // BLTU
            3'b111 : take = (rs1 >= rs2);                       // BGEU
            default: take = 1'b0;
        endcase
    end
endmodule
