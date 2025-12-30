############################################################
# Matrix Operations
#
# PURPOSE:
# Understand how matrices interact in Julia:
# - addition
# - multiplication
# - composition
#
# Focus: correctness first, performance later.
############################################################

using LinearAlgebra

println("=== Piece 1: Matrix Addition ===")

A = [1 2; 3 4]
B = [5 6; 7 8]
println("A = ")
println(A)

println("B = ")
println(B)

println("A + B = ")
println(A + B)

println("\n=== Piece 2: Matrix–Vector Multiplication ===")

A = [1 2; 3 4]        # Operator on ℝ²

x = [1, 1]       # State in ℝ²

println("A = ")
println(A)

println("x = ", x)

println("A * x = ", A * x)

println("\n=== Piece 3: Matrix–Matrix Multiplication ===")

A = [1 2; 3 4]        # ℝ² → ℝ²

B = [2 0; 1 2]        # ℝ² → ℝ²

println("A = ",A)
println("B = ",B)
println("A * B = ",A*B)
println("B * A = ",B*A)


println("\n=== Piece 4: Broadcasting vs Linear Algebra ===")

A = [1 2; 3 4]

B = [10 20; 30 40]

println("A = ",A)
println("B = ",B)
println("\nMatrix multiplication A * B = ",A*B)
println("\nElementwise multiplication A .* B = ",A.*B)
println("\nBroadcasting with scalars: A.*2 = ", A.*2)
println("\nBroadcasting with functions: Sin.(A) = ",sin.(A))

println("\n=== Final Piece: Associativity and Order ===")

A = [1 2; 3 4]
B = [2 0; 1 2]
C = [0 1; 1 0]
println("\n(A * B) * C = ",(A * B) * C)
println("\nA * (B * C) = ",A * (B * C))
