// ============================================================================
//  tb_imm_gen.v  --  unit test for imm_gen.v
//  Instruction words below were produced by tools/assemble.py.
// ============================================================================
`timescale 1ns/1ps
module tb_imm_gen;
    reg  [31:0] instr;
    wire [31:0] imm;
    imm_gen dut (.instr(instr), .imm(imm));

    integer errors = 0;
    task chk(input [255:0] name, input [31:0] exp);
        begin
            #1;
            if (imm !== exp) begin
                $display("  FAIL %0s: instr %08h -> %08h (exp %08h)", name, instr, imm, exp);
                errors = errors + 1;
            end else $display("  ok   %0s -> %08h", name, imm);
        end
    endtask

    initial begin
        $display("== tb_imm_gen ==");
        instr = 32'hfff00093; chk("I-type addi -1", 32'hFFFFFFFF); // addi x1,x0,-1
        instr = 32'h00500093; chk("I-type addi 5",  32'd5);        // addi x1,x0,5
        instr = 32'h00c12083; chk("I-type lw 12",   32'd12);       // lw x1,12(x2)
        instr = 32'h00322823; chk("S-type sw 16",   32'd16);       // sw x3,16(x4)
        instr = 32'h00208463; chk("B-type beq +8",  32'd8);        // beq x1,x2,+8
        instr = 32'h123450b7; chk("U-type lui",     32'h12345000); // lui x1,0x12345
        instr = 32'h00001097; chk("U-type auipc",   32'h00001000); // auipc x1,0x1
        instr = 32'h010000ef; chk("J-type jal +16", 32'd16);       // jal x1,16

        if (errors==0) $display("RESULT: PASS (tb_imm_gen)");
        else           $display("RESULT: FAIL (tb_imm_gen) - %0d error(s)", errors);
        $finish;
    end
endmodule
