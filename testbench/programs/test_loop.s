# Sum 1..10 = 55, then store/load through data memory
    li   x1, 0          # sum
    li   x2, 1          # i
    li   x3, 11         # limit
loop:
    add  x1, x1, x2     # sum += i
    addi x2, x2, 1      # i++
    blt  x2, x3, loop   # while i < 11
    li   x4, 0          # base addr
    sw   x1, 0(x4)      # mem[0] = sum
    lw   x5, 0(x4)      # x5 = mem[0]
done:
    jal  x0, done
