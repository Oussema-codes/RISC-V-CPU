// ============================================================================
//  tb_branch_unit.v  --  unit test for branch_unit.v
// ============================================================================
`timescale 1ns/1ps
module tb_branch_unit;
    reg  [2:0]  funct3;
    reg  [31:0] rs1, rs2;
    wire        take;
    branch_unit dut (.funct3(funct3), .rs1(rs1), .rs2(rs2), .take(take));

    integer errors = 0;
    task chk(input [255:0] name, input exp);
        begin
            #1;
            if (take !== exp) begin
                $display("  FAIL %0s: take=%b exp=%b", name, take, exp);
                errors = errors + 1;
            end else $display("  ok   %0s (take=%b)", name, take);
        end
    endtask

    initial begin
        $display("== tb_branch_unit ==");
        rs1=5; rs2=5; funct3=3'b000; chk("BEQ  5==5", 1);
        rs1=5; rs2=6; funct3=3'b000; chk("BEQ  5==6", 0);
        rs1=5; rs2=6; funct3=3'b001; chk("BNE  5!=6", 1);
        rs1=32'hFFFFFFFF; rs2=1; funct3=3'b100; chk("BLT  -1<1 (s)", 1);
        rs1=1; rs2=32'hFFFFFFFF; funct3=3'b100; chk("BLT  1<-1 (s)", 0);
        rs1=1; rs2=1;            funct3=3'b101; chk("BGE  1>=1 (s)", 1);
        rs1=1; rs2=32'hFFFFFFFF; funct3=3'b110; chk("BLTU 1<big",   1);
        rs1=32'hFFFFFFFF; rs2=1; funct3=3'b111; chk("BGEU big>=1",  1);

        if (errors==0) $display("RESULT: PASS (tb_branch_unit)");
        else           $display("RESULT: FAIL (tb_branch_unit) - %0d error(s)", errors);
        $finish;
    end
endmodule
