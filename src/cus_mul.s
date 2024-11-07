.globl cus_mul

.text
cus_mul:
    #prologue
    addi sp,sp,-16
    sw s0,0(sp)
    sw s1,4(sp)
    sw s2,8(sp)
    sw s3,12(sp)

    mv s0,a0
    mv s1,a1

    li s2, 0            # result = 0
loop:
    beq s1, x0, end     # 當 b == 0 時結束
    andi s3, s1, 1     # 檢查 b 的最低位
    beq s3, x0, skip    # 若最低位為 0 則跳過
    add s2, s2, s0    # result += a
skip:
    slli s0, s0, 1     # a 左移 1 位
    srli s1, s1, 1     # b 右移 1 位
    j loop               # 重複迴圈
end:
    mv a0,s2

    lw s0,0(sp)
    lw s1,4(sp)
    lw s2,8(sp)
    lw s3,12(sp)
    addi sp,sp,16

    ret
