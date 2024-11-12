.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     

loop_start:
    lw t1, 0(a0) #Load element address
    bltz t1,set_zero
    j store_element

set_zero:
    li t1, 0 #set element to zero

store_element:
    sw t1,0(a0)
    addi a0, a0, 4 #move pointer to next element
    addi a1, a1, -1 #decrease the number of remain element
    bnez a1, loop_start
    
end:
    ret

error:
    li a0, 36          
    j exit          
