// ============================================================================
//  tb_cpu_arith.v  --  runs programs/test_arith.hex and checks the register
//  file against the values the program is supposed to produce.
// ============================================================================
`timescale 1ns/1ps
module tb_cpu_arith;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;               // 100 MHz

    riscv_cpu dut (.clk(clk), .rst(rst));

    integer errors = 0;
    task check(input [255:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got !== exp) begin
                $display("  FAIL  %0s: got %08h expected %08h", name, got, exp);
                errors = errors + 1;
            end else begin
                $display("  ok    %0s = %08h", name, got);
            end
        end
    endtask

    integer k;
    initial begin
        for (k=0;k<32;k=k+1)   dut.u_dp.u_rf.regs[k] = 32'd0;
        for (k=0;k<1024;k=k+1) begin dut.u_imem.mem[k]=32'd0; dut.u_dmem.mem[k]=32'd0; end
        $readmemh("testbench/programs/test_arith.hex", dut.u_imem.mem);
        @(negedge clk) rst = 1;         // hold reset one cycle
        @(negedge clk) rst = 0;
        repeat (40) @(posedge clk);     // let the program finish

        $display("== tb_cpu_arith ==");
        check("x1",  dut.u_dp.u_rf.regs[1],  32'd5);
        check("x2",  dut.u_dp.u_rf.regs[2],  32'd7);
        check("x3",  dut.u_dp.u_rf.regs[3],  32'd12);
        check("x4",  dut.u_dp.u_rf.regs[4],  32'd2);
        check("x5",  dut.u_dp.u_rf.regs[5],  32'd5);
        check("x6",  dut.u_dp.u_rf.regs[6],  32'd7);
        check("x7",  dut.u_dp.u_rf.regs[7],  32'd2);
        check("x8",  dut.u_dp.u_rf.regs[8],  32'd20);
        check("x9",  dut.u_dp.u_rf.regs[9],  32'd3);
        check("x10", dut.u_dp.u_rf.regs[10], 32'd1);
        check("x11", dut.u_dp.u_rf.regs[11], 32'hFFFFFFFF);
        check("x12", dut.u_dp.u_rf.regs[12], 32'd1);

        if (errors == 0) $display("RESULT: PASS (tb_cpu_arith)");
        else             $display("RESULT: FAIL (tb_cpu_arith) - %0d error(s)", errors);
        $finish;
    end
endmodule
