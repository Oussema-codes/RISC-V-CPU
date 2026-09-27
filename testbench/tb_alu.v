// ============================================================================
//  tb_alu.v  --  unit test for alu.v
// ============================================================================
`timescale 1ns/1ps
`include "defines.vh"
module tb_alu;
    reg  [31:0] a, b;
    reg  [3:0]  ctrl;
    wire [31:0] result;
    wire        zero;

    alu dut (.a(a), .b(b), .alu_ctrl(ctrl), .result(result), .zero(zero));

    integer errors = 0;
    task chk(input [255:0] name, input [31:0] exp);
        begin
            #1;
            if (result !== exp) begin
                $display("  FAIL %0s: %08h op %08h -> %08h (exp %08h)", name, a, b, result, exp);
                errors = errors + 1;
            end else $display("  ok   %0s -> %08h", name, result);
        end
    endtask

    initial begin
        $display("== tb_alu ==");
        a=5;  b=7;  ctrl=`ALU_ADD;  chk("ADD", 32'd12);
        a=7;  b=5;  ctrl=`ALU_SUB;  chk("SUB", 32'd2);
        a=5;  b=7;  ctrl=`ALU_SUB;  chk("SUB neg", 32'hFFFFFFFE);
        a=32'hF0; b=32'h0F; ctrl=`ALU_AND; chk("AND", 32'h00);
        a=32'hF0; b=32'h0F; ctrl=`ALU_OR;  chk("OR",  32'hFF);
        a=32'hFF; b=32'h0F; ctrl=`ALU_XOR; chk("XOR", 32'hF0);
        a=1;  b=4;  ctrl=`ALU_SLL;  chk("SLL", 32'd16);
        a=32'h80000000; b=4; ctrl=`ALU_SRL; chk("SRL", 32'h08000000);
        a=32'h80000000; b=4; ctrl=`ALU_SRA; chk("SRA", 32'hF8000000);
        a=32'hFFFFFFFF; b=1; ctrl=`ALU_SLT; chk("SLT (-1<1)", 32'd1);
        a=1;  b=32'hFFFFFFFF; ctrl=`ALU_SLT;  chk("SLT (1<-1)", 32'd0);
        a=1;  b=32'hFFFFFFFF; ctrl=`ALU_SLTU; chk("SLTU (1<big)", 32'd1);

        // zero flag
        a=5; b=5; ctrl=`ALU_SUB; #1;
        if (zero !== 1'b1) begin $display("  FAIL zero flag"); errors=errors+1; end
        else $display("  ok   zero flag");

        if (errors==0) $display("RESULT: PASS (tb_alu)");
        else           $display("RESULT: FAIL (tb_alu) - %0d error(s)", errors);
        $finish;
    end
endmodule
