# Run the simulations with Icarus Verilog.
.DEFAULT_GOAL := test

RTL     ?= rtl
IV       = iverilog -g2012 -I $(RTL)
VVP      = vvp
BUILD    = build
TB       = testbench

CPU_SRCS = $(RTL)/pc.v $(RTL)/instr_mem.v $(RTL)/regfile.v $(RTL)/alu.v \
           $(RTL)/imm_gen.v $(RTL)/branch_unit.v $(RTL)/data_mem.v \
           $(RTL)/alu_decoder.v $(RTL)/control.v $(RTL)/datapath.v $(RTL)/riscv_cpu.v

$(shell mkdir -p $(BUILD))

.PHONY: test-pc test-alu test-regfile test-imm test-branch
test-pc:
	@$(IV) -o $(BUILD)/u_pc $(RTL)/pc.v $(TB)/tb_pc.v && $(VVP) $(BUILD)/u_pc

test-alu:
	@$(IV) -o $(BUILD)/u_alu $(RTL)/alu.v $(TB)/tb_alu.v && $(VVP) $(BUILD)/u_alu

test-regfile:
	@$(IV) -o $(BUILD)/u_rf $(RTL)/regfile.v $(TB)/tb_regfile.v && $(VVP) $(BUILD)/u_rf

test-imm:
	@$(IV) -o $(BUILD)/u_imm $(RTL)/imm_gen.v $(TB)/tb_imm_gen.v && $(VVP) $(BUILD)/u_imm

test-branch:
	@$(IV) -o $(BUILD)/u_br $(RTL)/branch_unit.v $(TB)/tb_branch_unit.v && $(VVP) $(BUILD)/u_br

# full-CPU integration tests
.PHONY: test-cpu
test-cpu:
	@$(IV) -o $(BUILD)/cpu_arith $(CPU_SRCS) $(TB)/tb_cpu_arith.v && $(VVP) $(BUILD)/cpu_arith
	@$(IV) -o $(BUILD)/cpu_loop  $(CPU_SRCS) $(TB)/tb_cpu_loop.v  && $(VVP) $(BUILD)/cpu_loop
	@$(IV) -o $(BUILD)/cpu_jumps $(CPU_SRCS) $(TB)/tb_cpu_jumps.v && $(VVP) $(BUILD)/cpu_jumps

# everything
.PHONY: test test-all
test: test-all

test-all: test-pc test-alu test-regfile test-imm test-branch test-cpu
	@echo "Done. Scan the output above for RESULT lines."

# assemble a program:  make asm SRC=path/to/prog.s -> prog.hex
.PHONY: asm
asm:
	@python3 tools/assemble.py $(SRC) $(SRC:.s=.hex)

.PHONY: clean
clean:
	@rm -rf $(BUILD) *.vcd
	@echo "cleaned."
