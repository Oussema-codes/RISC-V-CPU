// ============================================================================
//  tb_pc.v  --  unit test for pc.v
// ============================================================================
`timescale 1ns/1ps
module tb_pc;
    reg         clk = 0, rst;
    reg  [31:0] pc_next;
    wire [31:0] pc;
    pc dut (.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc));
    always #5 clk = ~clk;

    integer errors = 0;
    task chk(input [255:0] name, input [31:0] exp);
        begin
            if (pc !== exp) begin
                $display("  FAIL %0s: pc=%08h exp=%08h", name, pc, exp);
                errors = errors + 1;
            end else $display("  ok   %0s pc=%08h", name, pc);
        end
    endtask

    initial begin
        $display("== tb_pc ==");
        rst=1; pc_next=32'hDEAD_BEEF; @(posedge clk); #1;
        chk("reset -> 0", 32'd0);

        rst=0; pc_next=32'd4;  @(posedge clk); #1; chk("load 4",  32'd4);
        pc_next=32'd8;         @(posedge clk); #1; chk("load 8",  32'd8);
        pc_next=32'h1000;      @(posedge clk); #1; chk("load jump",32'h1000);
        rst=1; pc_next=32'd99; @(posedge clk); #1; chk("reset again",32'd0);

        if (errors==0) $display("RESULT: PASS (tb_pc)");
        else           $display("RESULT: FAIL (tb_pc) - %0d error(s)", errors);
        $finish;
    end
endmodule
