############################################################
# Matrix Factorizations
#
# PURPOSE:
# Understand why Julia treats factorizations as objects:
# - LU, QR, Cholesky are operators
# - they encode structure
# - they avoid repeated work
############################################################

using LinearAlgebra

println("=== Piece 1: Why Factorizations Exist ===")

A = [4.0 3.0;6.0 3.0]
b = [10.0, 12.0]

println("A = ",A)
println("b = ", b)

println("\n=== Piece 2: LU Factorization ===") # L means lower and U means Upper

F =lu(A) # P = LU not A = Lu

println("\nF =",F)
println("Type of F -> ", typeof(F))
println("\n=== Piece 3: Solving Linear Systems ===")

# Solve Ax = b using the LU factorization
x = F \ b

println("Solution x = ", x)

# Verify the solution
println("A * x = ", A * x)

println("\nSolving for multiple right-hand sides:")

B = [10.0  1.0;
     12.0  0.0]

X = F \ B

println("X = ")
println(X)

println("A * X = ")
println(A * X)

println("\n=== Piece 4: QR Factorization ===")

A = [1.0  1.0;
     1.0 -1.0;
     1.0  0.0]   # Tall matrix (3×2)

println("A = ")
println(A)

Fqr = qr(A)

println("\nType of Fqr -> ", typeof(Fqr))
println(Fqr)

println("\n=== Piece 5: Cholesky Factorization ===")

# Symmetric positive-definite matrix
A = [4.0  2.0;
     2.0  3.0]

println("A = ")
println(A)

Fch = cholesky(A)

println("\nType of Fch -> ", typeof(Fch))
println("\nL = ")
println(Fch.L)

println("\nU = ")
println(Fch.U)

println("\nSolving system using Cholesky")

b = [1.0, 0.0]

x_ch = Fch \ b

println("x_ch = ", x_ch)
println("A * x_ch = ", A * x_ch)

############################################################
# Problem 1: Solving a Linear System
#
# Given the linear system:
#
#     A x = b
#
# where
#
#     A = [ 4   1
#           1   3 ]
#
#     b = [ 1
#           2 ]
#
# Tasks:
# 1. Solve the system analytically.
# 2. Solve it numerically using Julia.
# 3. Verify the solution.
#
# Exact analytical solution:
#     x₁ = 1/11
#     x₂ = 7/11
###########################################################
A = [4.0 1.0; 1.0 3.0]
b = [1.0, 2.0]

println("Matrix A = ",A)
println("Vector b = ",b)

x= A \ b
println("\nComputed Solution x = ",x)

# Verification
println("A * x  = b: ", A * x)