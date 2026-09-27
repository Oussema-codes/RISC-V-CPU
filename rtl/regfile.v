//  regfile.v  --  32 x 32-bit Register File
//  Two asynchronous read ports (rd1, rd2) and one synchronous write port.
//  Register x0 is hard-wired to zero: reads of x0 return 0 and writes to x0
//  are ignored, exactly as the RISC-V specification requires.
module regfile (
    input  wire        clk,
    input  wire        we,           // write enable
    input  wire [4:0]  ra1,          // read address 1  (rs1)
    input  wire [4:0]  ra2,          // read address 2  (rs2)
    input  wire [4:0]  wa,           // write address   (rd)
    input  wire [31:0] wd,           // write data
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [0:31];

    // Asynchronous (combinational) reads, with x0 forced to zero.
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : regs[ra2];

    // Synchronous write; never write to x0.
    always @(posedge clk) begin
        if (we && (wa != 5'd0))
            regs[wa] <= wd;
    end
endmodule
