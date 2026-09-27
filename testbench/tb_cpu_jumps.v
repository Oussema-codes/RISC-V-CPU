// ============================================================================
//  tb_cpu_jumps.v  --  runs programs/test_jumps.hex, exercising LUI, AUIPC,
//  JAL and JALR (a function call and return).
// ============================================================================
`timescale 1ns/1ps
module tb_cpu_jumps;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    riscv_cpu dut (.clk(clk), .rst(rst));

    integer errors = 0;
    task check(input [255:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got !== exp) begin
                $display("  FAIL  %0s: got %08h expected %08h", name, got, exp);
                errors = errors + 1;
            end else $display("  ok    %0s = %08h", name, got);
        end
    endtask

    integer k;
    initial begin
        for (k=0;k<32;k=k+1)   dut.u_dp.u_rf.regs[k] = 32'd0;
        for (k=0;k<1024;k=k+1) begin dut.u_imem.mem[k]=32'd0; dut.u_dmem.mem[k]=32'd0; end
        $readmemh("testbench/programs/test_jumps.hex", dut.u_imem.mem);
        @(negedge clk) rst = 1;
        @(negedge clk) rst = 0;
        repeat (40) @(posedge clk);

        $display("== tb_cpu_jumps ==");
        check("x1 (lui+addi)", dut.u_dp.u_rf.regs[1], 32'h12345678);
        check("x2 (auipc)",    dut.u_dp.u_rf.regs[2], 32'd8);
        check("x3 (jal link)", dut.u_dp.u_rf.regs[3], 32'd16);
        check("x5 (skipped)",  dut.u_dp.u_rf.regs[5], 32'd0);
        check("x6",            dut.u_dp.u_rf.regs[6], 32'd7);
        check("x4 (call link)",dut.u_dp.u_rf.regs[4], 32'd28);
        check("x7 (after ret)",dut.u_dp.u_rf.regs[7], 32'd42);
        check("x8 (in func)",  dut.u_dp.u_rf.regs[8], 32'd1);

        if (errors == 0) $display("RESULT: PASS (tb_cpu_jumps)");
        else             $display("RESULT: FAIL (tb_cpu_jumps) - %0d error(s)", errors);
        $finish;
    end
endmodule
