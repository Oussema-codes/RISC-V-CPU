//  pc.v  --  Program Counter
//  Holds the address of the instruction currently being executed.
//  On every rising clock edge it latches pc_next. Reset forces it to 0.
module pc (
    input  wire        clk,
    input  wire        rst,       // active-high, synchronous reset
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk) begin
        if (rst)
            pc <= 32'h0000_0000;
        else
            pc <= pc_next;
    end
endmodule
