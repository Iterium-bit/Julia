############################################################
# Matrix Types
#
# PURPOSE:
# Build the correct mental model for matrices in Julia:
#
# - A matrix is a typed linear operator
# - Element type defines the algebra (ℤ, ℝ, ℂ, ...)
# - Shape defines domain → codomain
# - Constructors express intent, literals express content
#
# This file is about WHAT matrices are,
# not what we do with them.
############################################################

using LinearAlgebra


############################################################
# Piece 1: A Matrix Is a Typed Object
############################################################

println("=== Piece 1: A Matrix Is a Typed Object ===")

# Matrix literal syntax:
# - spaces separate columns
# - semicolons separate rows
# - line breaks are OPTIONAL (only for readability)

# All of the following are equivalent in Julia:
#
# [a b;
#  c d]
#
# [a b; c d]

A = [1  2  3;
     4  5  6;
     7  8  9;
     10 11 12]

println("A =")
println(A)

println("typeof(A)  -> ", typeof(A))
println("size(A)    -> ", size(A))
println("eltype(A)  -> ", eltype(A))


############################################################
# Piece 2: Same Matrix, Different Algebra
############################################################

println("\n=== Piece 2: Same Matrix, Different Algebra ===")

A_int = [2 4;
         6 8]                 # lives in ℤ

A_float = [2.0 4.0;
           6.0 8.0]           # lives in ℝ

A_complex = [1+1im  2+2im;
             3+3im  4+4im]    # lives in ℂ

println("A_int type     -> ", typeof(A_int))
println("A_float type   -> ", typeof(A_float))
println("A_complex type -> ", typeof(A_complex))

println("A_int eltype     -> ", eltype(A_int))
println("A_float eltype   -> ", eltype(A_float))
println("A_complex eltype -> ", eltype(A_complex))

# Promotion to richer algebra (no information loss)
println("\nA_int + A_float = ")
println(A_int + A_float)


############################################################
# Piece 3: Vectors vs Matrices
############################################################

println("\n=== Piece 3: Vectors vs Matrices ===")

v   = [1, 2, 3]     # Vector (1D object)
row = [1 2 3]       # 1×3 Matrix (row)
col = [1; 2; 3]     # 3×1 Matrix (column)

println("v   -> ", typeof(v),   " | size = ", size(v))
println("row -> ", typeof(row), " | size = ", size(row))
println("col -> ", typeof(col), " | size = ", size(col))

w = [4, 5, 6]
println("v + w = ", v + w)

println("\n--- Multiplication behavior ---")

println("row * col = ", row * col)   # inner product (1×1 matrix)
println("col * row = ")
println(col * row)                  # outer product

println("typeof(col * row) -> ", typeof(col * row))
println("size(col * row)   -> ", size(col * row))


############################################################
# Piece 4: Transpose vs Adjoint
############################################################

println("\n=== Piece 4: Transpose vs Adjoint ===")

v = [1, 2, 3]

A = [1 2;
     3 4]

C = [1+1im  2+2im;
     3+3im  4+4im]

println("v = ", v)
println("v' = ", v')                       # adjoint (bra)
println("transpose(v) = ", transpose(v))  # transpose only

println("\nReal matrix A:")
println(A)
println("A' = ")
println(A')                               # same as transpose (real case)

println("\nComplex matrix C:")
println(C)
println("C' = ")
println(C')                               # conjugate transpose

println("\n--- Inner products ---")
println("v' * v = ", v' * v)
println("transpose(v) * v = ", transpose(v) * v)


############################################################
# Piece 5: Square vs Rectangular Matrices
############################################################

println("\n=== Piece 5: Square vs Rectangular Matrices ===")

A = [1 2;
     3 4]        # 2×2 operator: ℝ² → ℝ²

B = [1 2 3;
     4 5 6]      # 2×3 map: ℝ³ → ℝ²

x = [1, 2]
y = [1, 2, 3]

println("A * x = ", A * x)
println("B * y = ", B * y)


############################################################
# Piece 6: Identity, Zeros, and Constructors
############################################################

println("\n=== Piece 6: Identity, Zeros, and Constructors ===")

# IMPORTANT:
# `I` is the identity OPERATOR, not a matrix.
# It has no size and no element type.
#
# Matrix{T}(I, m, n) means:
# "Materialize the identity operator as an m×n dense matrix
#  with element type T."
#
# For rectangular cases:
# - Ones appear on the diagonal up to min(m, n)
# - All other entries are zero
#
# Only when m == n does this represent a true identity operator.

I2  = Matrix{Int}(I, 2, 2)
I2f = Matrix{Float64}(I, 2, 2)

println("I2 = ")
println(I2)
println("eltype(I2) = ", eltype(I2))

println("\nI2f = ")
println(I2f)
println("eltype(I2f) = ", eltype(I2f))

println("\nRectangular identity-like matrix (4×2):")
println(Matrix{Int}(I, 4, 2))

Z = zeros(2, 3)
O = ones(3, 3)

println("\nZeros matrix Z (2×3) = ")
println(Z)

println("\nOnes matrix O (3×3) = ")
println(O)
