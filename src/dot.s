.globl dot
.import ./cus_mul.s

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li a5,0
    li a6,0    #計算迴圈次數
    li a7,0    #儲存數值

    slli a3,a3,2
    slli a4,a4,2

loop_start:
    bge a6, a2, loop_end
    lw t0,0(a0)
    lw t1,0(a1)
    # mul t2,t0,t1

    addi sp,sp,-36
    sw a0,0(sp)
    sw a1,4(sp)
    sw a2,8(sp)
    sw a3,12(sp)
    sw a4,16(sp)
    sw a5,20(sp)
    sw a6,24(sp)
    sw a7,28(sp)
    sw ra,32(sp)

    mv a0, t0
    mv a1, t1
    jal cus_mul
    mv t2,a0

    lw a0,0(sp)
    lw a1,4(sp)
    lw a2,8(sp)
    lw a3,12(sp)
    lw a4,16(sp)
    lw a5,20(sp)
    lw a6,24(sp)
    lw a7,28(sp)
    lw ra,32(sp)
    addi sp,sp,36

    add a7,a7,t2

    add a0,a0,a3
    add a1,a1,a4
    addi a6,a6,1
    j loop_start

loop_end:
    mv a0, a7
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
