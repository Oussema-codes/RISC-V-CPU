// ============================================================================
//  tb_cpu_loop.v  --  runs programs/test_loop.hex (sum 1..10 = 55, then a
//  store/load round-trip through data memory) and checks the results.
// ============================================================================
`timescale 1ns/1ps
module tb_cpu_loop;
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
        $readmemh("testbench/programs/test_loop.hex", dut.u_imem.mem);
        @(negedge clk) rst = 1;
        @(negedge clk) rst = 0;
        repeat (120) @(posedge clk);

        $display("== tb_cpu_loop ==");
        check("x1 (sum)",   dut.u_dp.u_rf.regs[1], 32'd55);
        check("x5 (loaded)", dut.u_dp.u_rf.regs[5], 32'd55);
        check("mem[0]",     dut.u_dmem.mem[0],     32'd55);

        if (errors == 0) $display("RESULT: PASS (tb_cpu_loop)");
        else             $display("RESULT: FAIL (tb_cpu_loop) - %0d error(s)", errors);
        $finish;
    end
endmodule
