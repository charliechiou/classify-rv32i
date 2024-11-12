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

## ReLu ( Rectified Linear Unit )

### Introduction

To enable our model to learn more complex relationships within the data, we implemented the Rectified Linear Unit (ReLU) activation function.  
`f(x) = max(0, x)`
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
The loop runs a2 times to process each element in the input arrays.
Each element, based on the current index, is multiplied using bitwise operations.
The result of each multiplication (t2) is accumulated into a7.

## Matrix Multiplication

### Introduction
For matric multiplication，it is important to handling the stride.When multiply A and B, we have to dot product the **row** of A and **column** of B to get the element of output C.Therefore, the stride of A will be `1` and the stride of B will be `the column number of B`.

### Methodology
First, ensure that all inputs are valid (i.e., all values are positive).
This process is similar to the dot product calculation, but with two loops to iterate through each **row of matrix A** and each **column of matrix B**.

The outer loop uses `s0` as a counter to track the current row of A. After confirming that there are rows left to process (i.e., `s0` < `a1`), it proceeds to the inner loop.

In the inner loop, pointers are set to the beginning of the current row of A and the current column of B. The appropriate stride values are configured, and then the dot function is called to calculate and store the resulting element in matrix C.

## Read Matrix

### Introduction
To load pretrained MNIST weights, we need to implement a function that reads matrix data from a binary file. This function dynamically allocate memory and retrieve the matrix dimensions from the file header.

### Methodology
Using the `fopen` function in `util.s`, we can obtain the file descriptor of the binary file. To read the file contents, we use the `fread` function. First, we read the number of rows and columns from the file header, then calculate the matrix size by multiplying these values. Following that, we use the same approach to read each element of the matrix into memory.

## Write Matrix

### Introduction
After calculating the result, we need to write it back to the binary file. The `write_matrix` function first write the matrix dimensions as the header, then allocate memory to store the result, and finally write each matrix element into the file.

### Methodology
Similar to reading the matrix, first open the file to obtain the file descriptor. Then, use fwrite to write the matrix dimensions as the header. By multiplying the rows and columns, we can determine the matrix size. Using the same approach of `fwrite`, write each element of the matrix into the file.