//  data_mem.v  --  Data Memory (RAM)
//  Word-addressed read/write memory used by LW and SW. Reads are combinational
//  (available the same cycle); writes happen on the rising clock edge.
//  This simple core only implements word (32-bit) accesses.
module data_mem #(
    parameter DEPTH = 1024
) (
    input  wire        clk,
    input  wire        we,           // write enable (from SW)
    input  wire [31:0] addr,         // byte address (ALU result)
    input  wire [31:0] wd,           // write data (rs2)
    output wire [31:0] rd            // read data (for LW)
);
    reg [31:0] mem [0:DEPTH-1];

    assign rd = mem[addr[31:2]];

    always @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wd;
    end
endmodule
