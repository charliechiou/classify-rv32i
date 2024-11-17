# Assignment 2: Classify
 The project utilizes **RISC-V assembly language** to perform
 inference on a **Artificial Neural Network (ANN)** by using pre-trained weights provided by instructor. To overcame the challenge, there are two part need to complete :

 ### Part A : Mathematical Functions  
Implement essential matrix operations critical for neural network inference, including:  
+ **ReLu ( Rectified Linear Unit )** : Activation function to filter out negative values within the matrix.  

+ **ArgMax** : Find out the index of the maximum value in a matrix.

+ **Dot Product** : Calculate the dot product of two vextors.

+ **Matrix Multiplication** : Calculate the multiplication of two matrixs to support the data flow between two matrices.

 ### Part B : File Operations
 Implement some essential file operation including:  
 + **Read Matrix** : Read matrix data from file for the network.

 + **Write Matrix** : Writes matrix data to file to save the results.  
   
---
#### The following will describe the purpose and function of each component :

## Outline
- [ReLU](#ReLu-(-Rectified-Linear-Unit-))
- [Argmax](#argmax)
- [Dot Product](#dot-product)
- [Matrix Multiplication](#matrix-multiplication)
- [Read Matrix](#read-matrix)
- [Write Matrix](#write-matrix)
- [Classify](#classify)

## ReLu ( Rectified Linear Unit )

### Introduction

To enable our model to learn more complex relationships within the data, we implemented the Rectified Linear Unit (ReLU) activation function.  

```math
f(x) = max(0, x)
```

If the input value is less than 0, the output is set to 0. If the input value is greater than or equal to 0, the output equals the input.  

### Methodology
Using the `bnez` instruction to check whether there are still element need to be handle and employed `bltz` to check whether each element is less than zero.

```
loop_start:
    ...
    bltz t1,set_zero
    ...
store_element:
    addi a0, a0, 4 # move pointer to next element
    addi a1, a1, -1 # decrease the number of remain element
    bnez a1, loop_start
end:
```

If so, jump to `set_zero` and set the value to zero.

```
set_zero:
    li t1, 0 #set element to zero
```
## Argmax

### Introduction
By using the argmax function, we can find the index of the largest value in the output. This index corresponds to the predicted class, allowing us to determine the model's prediction.
### Methodology
Setting the first element as the initial maximum value

```
    lw t1, 0(a0)        # t1 store the initial current max value
    li t2, 0            # t2 store max value index
```

 use the `blt` instruction to loop through the input. 
 
```
loop_start:
    ...
    j next_element
    ...

next_element:
    addi t3, t3, 1 
    blt t3,a1,loop_start
```

 If an element is larger than the current maximum stored in `t2`, the program jumps to the `update_max` label, where the maximum value and its index are updated.

 ```
    blt t1, t4, update_max  #If current max smaller than current element then branch
update_max:
    mv t1, t4  #update current max value
    mv t2, t3  #update current max value index
 ```

## Dot product

### Introduction
The dot product operation requires two input vectors of equal length, multiplying them element by element. In this project, we need to use the `dot` function to perform matrix multiplication.

### Methodology
First, ensure that all inputs are valid (i.e., all are positive).

```
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  
```

The loop runs `a2` times to process each element in the input arrays.

```
loop_start:
    bge a6, a2, loop_end
    ...
    addi a6,a6,1
    j loop_start

loop_end:
```

Each element, based on the current index, is multiplied using bitwise operations.

```
mul:
    li t2,0

mul_loop_start:
    beq t1,x0,mul_loop_end
    andi t3,t1,1
    beq t3,x0,mul_skip
    add t2,t2,t0

mul_skip:
    slli t0,t0,1
    srli t1,t1,1
    j mul_loop_start

mul_loop_end:
```

The result of each multiplication `t2` is accumulated into `a7`.

```
    add a7,a7,t2
```

## Matrix Multiplication

### Introduction
For matric multiplication，it is important to handling the stride.When multiply A and B, we have to dot product the **row** of A and **column** of B to get the element of output C.Therefore, the stride of A will be `1` and the stride of B will be `the column number of B`.

### Methodology
First, ensure that all inputs are valid (i.e., all values are positive).

```
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error
```

This process is similar to the dot product calculation, but with two loops to iterate through each **row of matrix A** and each **column of matrix B**.

```
outer_loop_start:
    li s1, 0 #reset inner loop counter
    ...
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
    beq s1, a5, inner_loop_end
    ...
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    ...
    addi s0,s0,1
    j outer_loop_start       # repeat outer loop

outer_loop_end:
```

The outer loop uses `s0` as a counter to track the current row of A. After confirming that there are rows left to process (i.e., `s0` < `a1`), it proceeds to the inner loop.

In the inner loop, pointers are set to the beginning of the current row of A and the current column of B. The appropriate stride values are configured, and then the dot function is called to calculate and store the resulting element in matrix C.

```
    # prologue
    ...
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    #epilogue
    ...
```

## Read Matrix

### Introduction
To load pretrained MNIST weights, we need to implement a function that reads matrix data from a binary file. This function dynamically allocate memory and retrieve the matrix dimensions from the file header.

### Methodology
Using the `fopen` function in `util.s`, we can obtain the file descriptor of the binary file. 

```
fopen:
    mv a2 a1
    mv a1 a0
    li a0 c_openFile
    ecall
    #FOPEN_RETURN_HOOK
    jr ra
```

To read the file contents, we use the `fread` function. 

```
fread:
    mv a3 a2
    mv a2 a1
    mv a1 a0
    li a0 c_readFile
    ecall
    #FREAD_RETURN_HOOK
    jr ra
```

First, we read the number of rows and columns from the file header, 

```
    lw t1, 28(sp)    # opening to save num rows
    lw t2, 32(sp)    # opening to save num cols

    sw t1, 0(s3)     # saves num rows
    sw t2, 0(s4)     # saves num cols
```

then calculate the matrix size by multiplying these values.

```
mul:
    li s1,0

mul_loop_start:
    beq t2,x0,mul_loop_end
    andi t3,t2,1
    beq t3,x0,mul_skip
    add s1,s1,t1

mul_skip:
    slli t1,t1,1
    srli t2,t2,1
    j mul_loop_start

mul_loop_end:
```

Following that, we use the same approach to read each element of the matrix into memory.

```
    # set up file, buffer and bytes to read
    mv s2, a0        # matrix
    mv a0, s0
    mv a1, s2
    lw a2, 24(sp)

    jal fread
```

## Write Matrix

### Introduction
After calculating the result, we need to write it back to the binary file. The `write_matrix` function first write the matrix dimensions as the header, then allocate memory to store the result, and finally write each matrix element into the file.

### Methodology
Similar to reading the matrix, first open the file to obtain the file descriptor.

```
fopen:
    mv a2 a1
    mv a1 a0
    li a0 c_openFile
    ecall
    #FOPEN_RETURN_HOOK
    jr ra
```

Then, use `fwrite` to write the matrix dimensions as the header. 

```
fwrite:
    mv a4 a3
    mv a3 a2
    mv a2 a1
    mv a1 a0
    li a0 c_writeFile
    ecall
    #FWRITE_RETURN_HOOK
    jr ra
```

By multiplying the rows and columns, we can determine the matrix size. 

```
mul:
    li s4,0

mul_loop_start:
    beq s3,x0,mul_loop_end
    andi t3,s3,1
    beq t3,x0,mul_skip
    add s4,s4,s2

mul_skip:
    slli s2,s2,1
    srli s3,s3,1
    j mul_loop_start

mul_loop_end:
```

Using the same approach of `fwrite`, write each element of the matrix into the file.

+ write the matrix dimension

```
    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite
```

+ write the matrix
```
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite
```
---
## Classify
After completing all components of the program, we need to integrate them together. The first step is to load the pretrained models **m0**, **m1**, and **Input Matrix** using the `Read Matrix` function.

Code for reading m0:
```  
    # prologue
    ...
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    # epilogue
    ...
```
Similarly, the same approach is applied to read **m1** and **Input Matrix**.

Next, we compute the matmul for **m0** and **Input Matrix**.
```
    #prologue
    ...
    
    lw t0, 0(s3)
    lw t1, 0(s8)

    #call custom mul
mul_for_read_matrix:
    li a0,0

mul_loop_start_for_read_matrix:
    beq t1,x0,mul_loop_end_for_read_matrix
    andi t3,t1,1
    beq t3,x0,mul_skip_for_read_matrix
    add a0,a0,t0

mul_skip_for_read_matrix:
    slli t0,t0,1
    srli t1,t1,1
    j mul_loop_start_for_read_matrix

mul_loop_end_for_read_matrix:

    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    #epilogue
    ...
```
After that, apply the ReLU activation function to compute the first layer outputs. ReLU ensures all negative values are set to zero, effectively introducing non-linearity to the layer.

Repeat the process by applying the pretrained model m1 and the ReLU function to the first layer outputs to compute the second layer outputs.  

then write the result by `Write Matrix` function.
```
    #prologue
    ...
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    #epilogue
    ...
```

Finally, implement the `argmax` function on the second layer outputs to determine the correct prediction.
```
   # Compute and return argmax(o)
    #prologue
    ...
    
    mv a0, s10 # load o array into first arg
    lw t0, 0(s3)
    lw t1, 0(s6)
    
    #call custom mul
mul_for_argmax:
    li a1,0

mul_loop_start_for_argmax:
    beq t1,x0,mul_loop_end_for_argmax
    andi t3,t1,1
    beq t3,x0,mul_skip_for_argmax
    add a1,a1,t0

mul_skip_for_argmax:
    slli t0,t0,1
    srli t1,t1,1
    j mul_loop_start_for_argmax

mul_loop_end_for_argmax:
    
    jal argmax
    
    mv t0, a0 # move return value of argmax into t0
    
    # epilogue
    ...
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    # prologue
    ...
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    # epilogue
    ...
```
---
## Appendix A : Customize multiplication
Since my project involves numerous customized multiplication operations, I will explain each function separately here.

The code performs a bitwise multiplication, implementing multiplication using bitwise addition and shift operations. 

```
# Bitwise multiplication for t0 and t1

mul:
    li a0,0 # a0 save the result

mul_loop_start:
    beq t1,x0,mul_loop_end
    andi t3,t1,1
    beq t3,x0,mul_skip
    add a0,a0,t0

mul_skip:
    slli t0,t0,1
    srli t1,t1,1
    j mul_loop_start
```
Let's break down the code step-by-step:
### Initialization
```
    li a0,0 # a0 save the result
```
+ Load the immediate value 0 into `a0`. This register will be used to accumulate the result.

### Check the Loop
```
mul_loop_start:
    beq t1,x0,mul_loop_end
```
+ If t1 is equal to 0, the loop ends.

### Check the Bit
```
    andi t3,t1,1
    beq t3,x0,mul_skip
    add a0,a0,t0
```
+ Extract the LSB of t1
+ If the LSB of `t1` is **0** there is no need to do the addition.
+ If the LSB of `t1` is **1** then add `t0` to the accumulator.

### Shift to next Bit
```
    slli t0,t0,1
    srli t1,t1,1
    j mul_loop_start
```
+ Shift `t0` **left** by one bit, effectively multiplying it by 2. This operation prepares the multiplicand for the next higher bit.
+ Shift `t1` **right** by one bit, effectively removing the processed bit. This operation prepares for the next iteration.

The simple algorithm uses a **bitwise AND operation** to check each bit of the multiplier `t1`.