//  datapath.v  --  The datapath
//  Wires together the PC, memories, register file, immediate generator, ALU,
//  branch unit and all the multiplexers. The control unit (a sibling module in
//  riscv_cpu.v) drives the select lines that appear as inputs here.
`include "defines.vh"

module datapath (
    input  wire        clk,
    input  wire        rst,

    // control signals in
    input  wire        reg_write,
    input  wire        mem_write,
    input  wire [1:0]  alu_a_src,
    input  wire        alu_b_src,
    input  wire [1:0]  result_src,
    input  wire        branch,
    input  wire [1:0]  jump,
    input  wire [3:0]  alu_ctrl,

    // to/from the control unit and memories
    output wire [31:0] instr,        // current instruction (decoded by control)
    output wire [31:0] pc,           // current PC (indexes instruction memory)
    input  wire [31:0] instr_in,     // instruction word coming back from I-mem

    output wire [31:0] dmem_addr,    // data-memory address (= ALU result)
    output wire [31:0] dmem_wdata,   // data-memory write data (= rs2)
    input  wire [31:0] dmem_rdata    // data-memory read data
);
    // instruction field extraction
    assign instr = instr_in;
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];
    wire [2:0] funct3 = instr[14:12];

    // program counter
    reg  [31:0] pc_next;
    wire [31:0] pc_q;
    pc u_pc (.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc_q));
    assign pc = pc_q;

    wire [31:0] pc_plus4 = pc_q + 32'd4;

    // immediate
    wire [31:0] imm;
    imm_gen u_imm (.instr(instr), .imm(imm));

    wire [31:0] pc_target = pc_q + imm;      // branch / JAL target

    // register file
    wire [31:0] rd1, rd2;
    reg  [31:0] result;                      // write-back value (mux below)
    regfile u_rf (
        .clk(clk), .we(reg_write),
        .ra1(rs1), .ra2(rs2), .wa(rd), .wd(result),
        .rd1(rd1), .rd2(rd2)
    );

    // ALU operand muxes
    reg [31:0] alu_a;
    always @(*) begin
        case (alu_a_src)
            `A_RS1 : alu_a = rd1;
            `A_PC  : alu_a = pc_q;
            `A_ZERO: alu_a = 32'd0;
            default: alu_a = rd1;
        endcase
    end
    wire [31:0] alu_b = alu_b_src ? imm : rd2;

    // ALU
    wire [31:0] alu_result;
    wire        alu_zero;
    alu u_alu (
        .a(alu_a), .b(alu_b), .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );

    // data memory interface (memory itself lives in riscv_cpu.v)
    assign dmem_addr  = alu_result;
    assign dmem_wdata = rd2;

    // write-back mux
    always @(*) begin
        case (result_src)
            `RES_ALU: result = alu_result;
            `RES_MEM: result = dmem_rdata;
            `RES_PC4: result = pc_plus4;
            default : result = alu_result;
        endcase
    end

    // branch decision
    wire take_branch;
    branch_unit u_br (.funct3(funct3), .rs1(rd1), .rs2(rd2), .take(take_branch));
    wire branch_taken = branch & take_branch;

    // next-PC selection
    wire [31:0] jalr_target = alu_result & ~32'd1;   // clear low bit per spec
    always @(*) begin
        if (jump == `J_JALR)
            pc_next = jalr_target;
        else if (jump == `J_JAL || branch_taken)
            pc_next = pc_target;
        else
            pc_next = pc_plus4;
    end

    // expose mem_write only through the top module (unused here directly)
    wire _unused_mw = mem_write;
endmodule
