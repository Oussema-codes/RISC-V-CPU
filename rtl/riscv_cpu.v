//  riscv_cpu.v  --  Top-level single-cycle RV32I core
//  Instantiates the control unit, the datapath, and the two memories, then
//  connects them together. This is the module the CPU testbench drives.
//
//  The instruction memory is loaded by the testbench, e.g.:
//      $readmemh("programs/test.hex", dut.u_imem.mem);
//  The register file and data memory can be inspected the same way, e.g.:
//      dut.u_dp.u_rf.regs[5]
//      dut.u_dmem.mem[0]
`include "defines.vh"

module riscv_cpu #(
    parameter IMEM_DEPTH = 1024,
    parameter DMEM_DEPTH = 1024
) (
    input wire clk,
    input wire rst
);
    // control <-> datapath wires
    wire        reg_write, mem_write, alu_b_src, branch;
    wire [1:0]  alu_a_src, result_src, jump;
    wire [3:0]  alu_ctrl;

    // datapath <-> memory wires
    wire [31:0] instr, pc, imem_instr;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;

    // control unit
    control u_ctrl (
        .instr      (instr),
        .reg_write  (reg_write),
        .mem_write  (mem_write),
        .alu_a_src  (alu_a_src),
        .alu_b_src  (alu_b_src),
        .result_src (result_src),
        .branch     (branch),
        .jump       (jump),
        .alu_ctrl   (alu_ctrl)
    );

    // datapath
    datapath u_dp (
        .clk        (clk),
        .rst        (rst),
        .reg_write  (reg_write),
        .mem_write  (mem_write),
        .alu_a_src  (alu_a_src),
        .alu_b_src  (alu_b_src),
        .result_src (result_src),
        .branch     (branch),
        .jump       (jump),
        .alu_ctrl   (alu_ctrl),
        .instr      (instr),
        .pc         (pc),
        .instr_in   (imem_instr),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata)
    );

    // instruction memory
    instr_mem #(.DEPTH(IMEM_DEPTH)) u_imem (
        .addr  (pc),
        .instr (imem_instr)
    );

    // data memory
    data_mem #(.DEPTH(DMEM_DEPTH)) u_dmem (
        .clk  (clk),
        .we   (mem_write),
        .addr (dmem_addr),
        .wd   (dmem_wdata),
        .rd   (dmem_rdata)
    );
endmodule
