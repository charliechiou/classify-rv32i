.globl cus_mul

.text
cus_mul:
    li t0, 0            # result = 0
loop:
    beq a1, x0, end     # 當 b == 0 時結束
    andi t1, a1, 1     # 檢查 b 的最低位
    beq t1, x0, skip    # 若最低位為 0 則跳過
    add t0, t0, a0    # result += a
skip:
    slli a0, a0, 1     # a 左移 1 位
    srli a1, a1, 1     # b 右移 1 位
    j loop               # 重複迴圈
end:
    mv a0,t0

    ret
