//  instr_mem.v  --  Instruction Memory (read-only)
//  A word-addressed ROM. The PC is a *byte* address, but every instruction is
//  4 bytes wide, so we index the memory array with addr[.. :2] (addr / 4).
//  The program is loaded by the testbench with $readmemh into `mem`.
module instr_mem #(
    parameter DEPTH = 1024            // number of 32-bit words
) (
    input  wire [31:0] addr,          // byte address from the PC
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH-1];

    // Combinational read: the instruction appears the same cycle we ask for it.
    assign instr = mem[addr[31:2]];
endmodule
