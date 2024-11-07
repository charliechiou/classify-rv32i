.import ./cus_mul.s


.globl dot

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

    li t0,0
    li t1,0
    li t2,0     

    slli a3,a3,2
    slli a4,a4,2

loop_start:
    bge t2, a2, loop_end
    lw t3,0(a0)
    lw t4,0(a1)
    # mul t5,t3,t4

    addi sp,sp,-36
    sw t0,0(sp)
    sw t1,4(sp)
    sw t2,8(sp)
    sw a0,12(sp)
    sw a1,16(sp)
    sw a2,20(sp)
    sw a3,24(sp)
    sw a4,28(sp)
    sw ra,32(sp)

    mv a0, t3
    mv a1, t4
    jal cus_mul
    mv t5,a0

    lw t0,0(sp)
    lw t1,4(sp)
    lw t2,8(sp)
    lw a0,12(sp)
    lw a1,16(sp)
    lw a2,20(sp)
    lw a3,24(sp)
    lw a4,28(sp)
    lw ra,32(sp)
    addi sp,sp,36

    add t0,t0,t5

    add a0,a0,a3
    add a1,a1,a4
    addi t2,t2,1
    j loop_start

loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
