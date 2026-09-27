# Jumps, LUI/AUIPC, JAL/JALR call & return
    lui   x1, 0x12345      # x1 = 0x12345000
    addi  x1, x1, 0x678    # x1 = 0x12345678
    auipc x2, 0            # x2 = 8 (address of this instr)
    jal   x3, skip         # x3 = 16, jump over the next instr
    addi  x5, x0, 99       # (skipped)
skip:
    addi  x6, x0, 7        # x6 = 7
    jal   x4, func         # call; x4 = return address (28)
    addi  x7, x0, 42       # x7 = 42
done:
    beq   x0, x0, done
func:
    addi  x8, x0, 1        # x8 = 1
    jalr  x0, x4, 0        # return to x4
