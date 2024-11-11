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
   
     
The following will describe the purpose and function of each component :  

## ReLu ( Rectified Linear Unit )
To enable our model to learn more complex relationships within the data, we implemented the Rectified Linear Unit (ReLU) activation function.  
$$ f(x) = \max(0, x) $$
If the input value is less than 0, the output is set to 0. If the input value is greater than or equal to 0, the output equals the input.  
### Methodology
I used the `bnez` instruction to iterate through the input vector and employed `bltz` to check whether each element is less than zero. If so, jump to `set_zero` and set the value to zero.