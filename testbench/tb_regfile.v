// ============================================================================
//  tb_regfile.v  --  unit test for regfile.v
// ============================================================================
`timescale 1ns/1ps
module tb_regfile;
    reg         clk = 0;
    reg         we;
    reg  [4:0]  ra1, ra2, wa;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;

    regfile dut (.clk(clk), .we(we), .ra1(ra1), .ra2(ra2), .wa(wa),
                 .wd(wd), .rd1(rd1), .rd2(rd2));

    always #5 clk = ~clk;

    integer errors = 0;
    task chk(input [255:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got !== exp) begin
                $display("  FAIL %0s: got %08h exp %08h", name, got, exp);
                errors = errors + 1;
            end else $display("  ok   %0s = %08h", name, got);
        end
    endtask

    task write(input [4:0] r, input [31:0] v);
        begin wa=r; wd=v; we=1; @(posedge clk); #1 we=0; end
    endtask

    initial begin
        $display("== tb_regfile ==");
        we=0; ra1=0; ra2=0; wa=0; wd=0;
        @(negedge clk);

        write(5, 32'hDEAD_BEEF);
        write(10, 32'h0000_0042);
        ra1=5; ra2=10; #1;
        chk("x5",  rd1, 32'hDEAD_BEEF);
        chk("x10", rd2, 32'h0000_0042);

        // x0 must stay zero even after a write
        write(0, 32'hFFFF_FFFF);
        ra1=0; #1;
        chk("x0 stays 0", rd1, 32'd0);

        // overwrite
        write(5, 32'h1234_5678);
        ra1=5; #1;
        chk("x5 overwrite", rd1, 32'h1234_5678);

        if (errors==0) $display("RESULT: PASS (tb_regfile)");
        else           $display("RESULT: FAIL (tb_regfile) - %0d error(s)", errors);
        $finish;
    end
endmodule
