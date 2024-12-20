.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t1, 0(a0)        # t1 store the initial current max value
    li t2, 0            # t2 store max value index
    li t3, 0            # t3 loop counter


loop_start:
    lw t4, 0(a0)
    blt t1, t4, update_max  #If current max smaller than current element then branch
    j next_element

update_max:
    mv t1, t4
    mv t2, t3

next_element:
    addi t3, t3, 1
    addi a0, a0, 4
    blt t3,a1,loop_start

    mv a0,t2
    ret

handle_error:
    li a0, 36
    j exit
