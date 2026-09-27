# Arithmetic / logic smoke test
    li   x1, 5
    li   x2, 7
    add  x3, x1, x2      # 12
    sub  x4, x2, x1      # 2
    and  x5, x1, x2      # 5
    or   x6, x1, x2      # 7
    xor  x7, x1, x2      # 2
    slli x8, x1, 2       # 20
    srli x9, x2, 1       # 3
    slt  x10, x1, x2     # 1
    addi x11, x0, -1     # 0xffffffff
    sltu x12, x0, x11    # 1
done:
    beq  x0, x0, done
