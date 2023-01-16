# Lab 1: Basics

Welcome to your first Lab in the machine learning course. This is an easy Lab that gives you a brief introduction to Numpy and Matplotlib (both are Python libraries). Make sure that you watch the following videos before starting this Lab:
- Introduction: https://www.youtube.com/watch?v=JEn0ZZwaPqo&list=PLS8J_PRPtGfdnPf9QqT7Itnn2rAHsoWqY&index=1
- Basics: https://www.youtube.com/watch?v=91siCik-b7o&list=PLS8J_PRPtGfdnPf9QqT7Itnn2rAHsoWqY&index=2

## 1. Introduction to Numpy
Numpy is a Python library which has support for large multi-dimensional arrays and matrices, along with a large collection of high-level mathematical functions to operate on these arrays. It is often the starting point of data pre-processing and implementing basic ML algorithms.

Run the following code to import numpy.

# First we import the numpy Library and call it np
import numpy as np

### Creating a Vector
Here we use numpy to create a **1-dimensional array** which represents a row vector. Since this vector contains 3 values, it is a **vector of dimension 3** (i.e. $\in \mathbb{R}^{3}$).

# Create a vector as a row
vector_row = np.array([7, 2, 9])

print(vector_row)
print("The shape of this vector is:", vector_row.shape)

### Creating a Matrix
Here, we create a **2-dimensional array** (i.e. a matrix) with 2 rows and 3 columns.

matrix = np.array([[1, 2, 3], [4, 5, 6]])

print(matrix)
print("The shape is:", matrix.shape)

### Operations on arrays
Using numpy arrays, you can directly perform operations such as vector addition/substration in an easy way. In the code below, you are asked to create two numpy arrays $u$ and $v$ of the same length, then follow the remaining *TODO* comments to perform other kind of operations on these arrays (addition, substraction, elementwise mutiplication etc.)

""" TODO:
Create two numpy array u and v of the same size
"""
u = np.array([0,1,1])
v = np.array([5,6,8])

""" TODO:
Uncomment the following line to see the result of adding the two arrays u and v
"""
print(u + v)

""" TODO:
Substract the two arrays u - v and print the result
"""
print(u - v)

""" TODO:
Multiply each element of the first array u with the corresponding element of the second 
array v, using u * v. Note that this is the elementwise multiplication and  NOT the dot 
product between the two vectors u and v.
"""
print(u * v)

""" TODO:
Multiply each element of the vector u by 2, using 2 * u
"""
print(u * 2)

The same kind of operations also work for matricies represented as numpy arrays. Check and complete the following code for an example.

A = np.array([
    [1, 2, 3], 
    [4, 5, 6],
])

B = np.array([
    [10, 20, 30], 
    [40, 50, 60],
])

print(A + B) # Here matricies A and B should have the same dimensions (number of lines and columns)

""" TODO:
Complete the code to multiply each element of the matrix A by the corresponding 
element of matrix B. Note that this is not the matrix by matrix multiplication, it is a 
simple elementwise multiplication between the elements of the two matrices.
"""
print(A * B)


### Datasets as numpy arrays
In supervised learning, the training dataset consists of the input data $X$ and the corresponding outputs $y$. The data $X \in \mathbb{R}^{n \times d}$ is a matrix of $n$ lines and $d$ columns. Each column corresponds to a feature, and each line corresponds to a data-point which is a vector of dimension $d$. The $y \in \mathbb{R}^n$ consist of a vector of $n$ outputs. The $i^{th}$ output $y^{(i)}$ in $y$ corresponds to the $i^{th}$ data-point $x^{(i)}$ in $X$ (i.e. the $i^{th}$ row).

In Python, we can represent $X$ and $y$ as `numpy` arrays as shown in the code below.

import numpy as np

# This is a list of lists
X = [[0, 2, 3],
     [1, 4, 5],
     [2, 6, 7],
     [3, 8, 9],
     [4, 2, 3],
     [5, 4, 5],
     [6, 6, 7],
     [7, 8, 9],
     [8, 2, 3]]

# X is now a matrix (or a 2-dimensional numpy array)
X = np.array(X)

# y is a numpy array
y = np.array([0, 1, 1, 0, 0, 0, 1, 1, 0])

print("\n----- Input data X and outputs y :")
print(X)
print(y)

print("\n----- Shape of X and y :")
print("Shape of X: ", X.shape) # 9 lines (data-points) and 3 columns (features)
print("Shape of y: ", y.shape) # 9 output values

print("\n----- Length of X and y (i.e. number of data-points) :")
print(len(X)) # the number of data-points (n = 9). Same as X.shape[0]
print(len(y)) # the length of the array y (n = 9).

print("\n The number of features (i.e. columns in X) is", X.shape[1])

### Selecting subsets of arrays
You will find it useful later on to select a subset of the dataset (e.g. some lines and/or some columns). The Python code below gives some examples of this. You can read the code and run it to see the results and get familiar with the syntax.

print("The matrix X is:")
print(X)

print("Example 1. Subset of X between rows 2 to 6 (excluded) :")
print( X[2:6] )

print("\nExample 2. Sub-array of y between index 2 to 6 (excluded) :")
print( y[2:6] )

print("\nExample 3. Subset of X between rows 2 to 6, and columns 0 to 2 :")
print( X[2:6, 0:2] ) # same as X[2:6, :2]

print("\nExample 4. Subset of X between rows 2 to 6, and only column 1 :")
print( X[2:6, 1] )

print("\nExample 5. Subset of X between rows 2 to 6, and only columns 0 and 2 :")
print( X[2:6, [0,2]] )

print("\nExample 6. An array from X consisting of all rows, and only column 0 :")
print( X[:, 0] )

print("\nExample 7. An array from X consisting of all rows, and only the last column (-1) :")
print( X[:, -1] )

print("\nExample 8. An array from X consisting of only row 2, and all columns :")
print( X[2] ) # same as X[2, :]

print("\nExample 9. The scalar value from X at row 2 and column 0 :")
print( X[2, 0] ) # same as X[2][0]

print("\nExample 10. Subset of X consisting of rows 2, 5 and 7  :")
print( X[[2,5,7]] )


## Dot product of two vectors
The dot product of two vectors $u \in \mathbb{R}^d$ and $v \in \mathbb{R}^d$ (of the same dimension $d$) is defined as: $u . v = u^T v = \sum_{j=0}^{d-1} u_j v_j$. In Python, it is easy to compute this without using a loop, with one of the following methods:
- using `np.dot(u, v)`
- or in Python 3 using: `u @ v` which is prefered and more explicit.

u = np.array([1, 2, 10]) # u has shape (3,)
v = np.array([5, 1, 3])  # v has shape (3,)

""" TODO:
Compute here the dot product of u and v using three methods:
- using the np.dot function
- using the @ operator
- using the euqation shown above (with the sum)
You should get the same result with the three methods.
"""
print(np.dot(v,v))
print(u @ v)
print(np.sum([u[i] * v[i] for i in range(len(u))]))

## Product of a matrix and a vector
Computing the product of a matrix $A$ and a vector $v$ requires computing the dot product of each row of $A$ with the vector $v$. This means that the number of columns in the matrix $A$ should be equal to the dimension of the vector $v$. In Python 3, it is easy to compute the product of a matrix $A$ and a vector $v$ simply using `A @ v` (assuming that $A \in \mathbb{R}^{n \times d}$ and $v \in \mathbb{R}^{d}$).

# Matrix A has n=2 lines and d=3 columns
A = np.array([
    [1, 2, 3], 
    [4, 5, 6],
])

# Vector v is of dimension d=3
v = np.array(
    [6,
     5,
     2])

""" TODO:
Compute here the product of A and v. The product 
should be a vector of dimension n=2.
"""
print(A @ v)

## Product of two matricies
Computing the product of two matrices $A$ and $B$ requires computing the dot product between each line of the first matrix, with each column of the second matrix. This means that the number of columns in the first matrix should be equal to the number of lines in the second matrix. In Python 3, it is easy to compute the product of two matricies $A$ and $B$ simply using `A @ B` (assuming that $A \in \mathbb{R}^{n \times d}$ and $B \in \mathbb{R}^{d \times k}$).

# A has n=2 lines and d=3 columns
A = np.array([
    [1, 2, 3], 
    [4, 5, 6],
])

# B has d=3 lines and k=4 columns
B = np.array([
    [2, 8, 4, 9], 
    [4, 1, 3, 2],
    [6, 5, 2, 5],
])

""" TODO:
Compute here the product of A and B. The product 
should be a matrix of n=2 lines and k=4 columns.
"""
print(A @ B)

## Make predictions with a linear machine learning model

### 1) Predicting one output with one model using a dot product
Let $x = \begin{bmatrix} 1 \\ x_1 \\ x_2 \\ \vdots \\ x_d \end{bmatrix}$ be a new input data-point, and $\theta = \begin{bmatrix} \theta_0 \\ \theta_1 \\ \theta_2 \\ \vdots \\ \theta_d \end{bmatrix}$ be the parameters vector of a linear machine learning model. 

To predict the output corresponding to $x$ using a **linear model** $h_\theta$, we need to compute the dot product between $x$ and $\theta$. So our predicted output is $h_\theta(x) = \theta^T x = \theta_0 + \theta_1 x_1 + \dots + \theta_d x_d$. Note that the vector $x$ has an additional first value $x_0 = 1$, so that the dot product $\theta^T x$ can be computed (i.e. $x$ and $\theta$ should be of the same dimension).

### 2) Predicting multiple outputs with one model using a matrix-vector product
Assume now that several data-points are stacked as rows in a matrix $X$ (i.e. each row corresponds to one data-point). To predict the outputs of all data-points in a dataset $X$ using the linear model $h_\theta$, we can simply multiply the dataset matrix by the vector of parameters $\theta$. So our predicted outputs will be a vector $X \theta$, as illustrated in the following figure. Note that the first column of $X$ is set to all ones (i.e. each data-point in $X$ starts with 1).
<img src="imgs/matrixProdLab1.png" width="600px" />

### 3) Predicting multiple outputs with multiple models using a matrix-matrix product
To predict the outputs of all data-points in a dataset $X$ using multiple linear models $h^{(1)}_\theta, h^{(2)}_\theta, h^{(3)}_\theta, \dots$, we can simply multiply the dataset matrix by another matrix $H$. Each column of the matrix $H$ corresponds to the parameters vector of one model. So our predicted outputs will be a matrix $X H$, as illustrated in the following figure.
<img src="imgs/matrix2ProdLab1.png" width="600px" />

Complete the *TODO*s in the following Python code to make predictions using the provided model parameters. Note that, here, all the model parameters are provided to you. We will see later in the course how to learn or estimate the values of such parameters.

# The parameters vectors corresponding to three linear models
theta_model_1 = np.array([4, 3, 7, 2]) # parameters vector of model_1
theta_model_2 = np.array([8, 2, -4, 8]) # parameters vector of model_2
theta_model_3 = np.array([5, -1, 3, 6]) # parameters vector of model_3

# Dataset represented as a matrix X
X = np.array([[1, 5, 9, 2],
              [1, 7, 3, 5],
              [1, 5, 2, 8],
              [1, 2, 1, 3],
              [1, 3, 2, 1]])

# New data-point x represented as a vector
x = np.array([1, 3, 7, 4])

""" TODO:
Predict the output corresponding to the new data-point x using model_1 
(i.e. using the parameters vector theta_model_1).
The result should be a scalar value (just one output value)
"""
print(x @ theta_model_1)

""" TODO:
Predict the outputs corresponding to all data-points in the dataset X 
using model_1 (i.e. using the parameters vector theta_model_1).
The result should be a vector of len(X) outputs.
"""

print(X @ theta_model_1)
""" TODO:
Predict the outputs corresponding to all data-points in the dataset X 
using model_1, model_2, and model_3.
The result should be a matrix of len(X) lines and 3 columns (as we have 3 models)
"""
Theta = np.c_[theta_model_1, theta_model_2, theta_model_3]
XTheta = X @ Theta
print(XTheta)
""" TODO:
For each data-point, compute the average predicted output of the three models.
Use the matrix of predicted outputs that you computed above. The result should 
be a vector of len(X) outputs.
For example: based on the figure shown above, the average predictions would be:
[ (70 + 223 + 27) / 3,
  (25 + 212 + 4) / 3,
  ...,
  (31.7 + 214.7 + 14.8) / 3 ]

"""
print(([np.mean(r) for r in XTheta]))


## 2. Plotting with Matplotlib
Matplotlib is a Python library that allows you to visualize data. First, let's load a simple dataset $X \in \mathbb{R}^{300 \times 2}$ with $n=300$ data-points and $d=2$ features:

from scipy.io import loadmat

mat = loadmat("datasets/simpleDataset.mat")
X = mat["X"]
print("X.shape:", X.shape)

""" TODO:
print a small subset of X (e.g. the 10 first rows) to see what it looks like.
"""
print(X[:10])

Next, run the following cell to import the matplotlib library.

%matplotlib notebook
import matplotlib.pyplot as plt

The first thing to do next is to create a figure `fig` with one subplot `ax` as follows:
```python
fig, ax = plt.subplots()
```

A scatter plot allows us to show each feature-vector $x^{(i)}$ (i.e. a row from $X$) as a point on a two dimensional plot. To produce a scatter plot of all our data we use:
```python
ax.scatter(values_at_feature_0, values_at_feature_1)
```
The `values_at_feature_0` correspond to the values of feature 0: `X[:, 0]` (i.e. all values at column 0 of $X$),
The `values_at_feature_1` correspond to the values of feature 1: `X[:, 1]` (i.e. all values at column 1 of $X$).

Then, we display our plot using:
```python
fig.show()
```

Read the following code and run the cell to see the plot:

fig, ax = plt.subplots()     # create a figure with one subplot
ax.scatter(X[:, 0], X[:, 1]) # scatter plot of all the data
fig.show()                   # display our figure

To make our scatter plot more meaningful, we can:
1. Add a title to our figure.
 - We can add a title using `fig.suptitle("Your Title Here")`


2. Add a text that describes the x-axis (Feature 0) and y-axis (Feature 1).
 - We can add a text to describe the first dimension using `ax.set_xlabel("...")`, and a text to describe the second dimension using `ax.set_ylabel("...")`.


3. Use a personalized color and a personalized marker for our data-points.
 - When calling the `ax.scatter(...)` function, can specify a color (e.g. `"red"`) and a marker (e.g. `"x"`) as follows: `ax.scatter(values_at_feature_0, values_at_feature_1, color="red", marker="x")`. There are several possible markers, some of them are: `"x"`, `"o"`, `"."`, `"+"`, `">"` ... etc. You can also use any predefined letter as a marker, for example, to use the letter R, your marker should be: `"$R$"`.


4. Use a legend text to describe something about your data-points.
 - To do so, when calling the `ax.scatter(...)` function we can specify a label (i.e. some text) as follows: `ax.scatter(values_at_feature_0, values_at_feature_1, color="red", marker="x", label="All My Points")`. Then, we need to call `ax.legend()` to make the legend text appear.
 
Based on this description, complete the following code to produce a more mearningful scatter plot that looks like the following:
<img src="imgs/simpleScatter1.png" width="500px" />


fig, ax = plt.subplots()  # creating a figure with one subplot

""" TODO:
Complete the code to produce a plot similar to the above picture
"""
# Add a title to your figure:
fig.suptitle('Simple dataset with 3 clusters')

# Add a text that describes the two dimensions of your scatter plot:
ax.set_xlabel('Feature 0')
ax.set_ylabel('Feature 1')

# Do a scattr plot with a personalized color and marker and legend:
ax.scatter(X[:,0], X[:,1], color='r', marker='x')
ax.legend(['All My Points'])

fig.show()  # displaying our figure

Finally, the 300 data-points of our dataset $X$ are divided into three clusters (groups of points) :
- The first cluster of points (shown in blue on the next figure) consists of rows between 0 and 100 (i.e. the subset `X[:100]`)
- The second cluster of points (shown in red) consists of rows between 100 and 200 (i.e. the subset `X[100:200]`)
- The third cluster of points (shown in green) consists of rows between 200 and 300 (i.e. the subset `X[200:300]`, or `X[200:]`).

You are asked to complete the following code in order to produce a scatter plot that looks like the following:
<img src="imgs/simpleScatter2.png" width="500px" />


fig, ax = plt.subplots()

""" TODO:
Complete the code to produce a plot similar to the above picture
"""
# Add a title for the figure
fig.suptitle('Simple Dataset with 3 Clusters')
# Set the x-axis label to "Feature 0" and the y-axis label to "Feature 1"
ax.set_xlabel('Feature 0')
ax.set_ylabel('Feature 1')
# Scatter plot for the points of the first cluster: ax.scatter(...)
ax.scatter(X[:100,0], X[:100,1], color='b', marker='$A$')
# Scatter plot for the points of the second cluster: ax.scatter(...)
ax.scatter(X[100:200,0], X[100:200,1], color='r', marker='$B$')
# Scatter plot for the points of the third cluster: ax.scatter(...)
ax.scatter(X[200:300,0], X[200:300,1], color='g', marker='$C$')
ax.legend(['First Cluster','Second Cluster','Third Cluster'])

fig.show()

