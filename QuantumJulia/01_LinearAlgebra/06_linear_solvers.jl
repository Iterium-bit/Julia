using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: The Direct Solver (A \\ b)")
# Objective: Solve the linear system Ax = b for x.
# Use Case: First-order perturbation theory often requires solving (H0 - E0) * psi1 = -V * psi0.
#
# Steps:
# 1. Define a random 3x3 Complex matrix A and a random vector b.
# 2. Solve for x using 'x = A \ b'.
# 3. Verify the solution by computing the residual error: norm(A*x - b).
#    (The error should be close to machine precision ~1e-15).

A = rand(ComplexF64,3,3)
b = rand(ComplexF64,3,1)
x = A\b
residual_error = norm(A*x-b)

println("residual error: $residual_error")



## ------------------------------------------------------------------
println("\nPROBLEM 2: LU Decomposition (Reusing Factors) PA = LU")
# Objective: Pre-compute matrix factors to solve systems efficiently.
#
# Steps:
# 1. Define a random matrix A and vector b.
# 2. Compute the factorization: F = lu(A).
#    (This stores L, U, and P packed efficiently).
# 3. Solve using the factor object: x = F \ b.
# 4. Verify the reconstruction of A from L and U.
#    (Note: Julia stores them in F.L, F.U, F.p).

A = rand(ComplexF64,3,3)
b = rand(ComplexF64,3,1)

# 1. Factorize (Expensive step, done once)
F = lu(A)

# 2. Solve (Cheap step, repeated)
x = F\b

# 3. Verify Factorization (PA = LU)
# F.p is the permutation vector. We must permute A rows to match L*U.
P_matrix = Matrix(I,3,3)[F.p, :]
reconstruction_error = norm(P_matrix*A-F.L*F.U)

# 4. Verify Solution
solution_error = norm(A*x-b)
println("LU Reconstruction Error: $reconstruction_error")
println("Solution Error: $solution_error")



## ------------------------------------------------------------------
println("\nPROBLEM 3: Cholesky Factorization (Fastest for HPD)")
# Objective: Factorize a Hermitian Positive Definite matrix.
# Constraint: Fails if the matrix has any zero or negative eigenvalues.
#
# Steps:
# 1. Construct a random HPD matrix.
#    (A = M * M' + shift * I guarantees positive eigenvalues).
# 2. Compute factorization: F = cholesky(A).
# 3. Verify reconstruction: A = F.U' * F.U.
#    (Note: Julia often defaults to the Upper factor for Cholesky).
# 4. Solve a system using the factor.

# 1. Construct HPD Matrix
M = rand(ComplexF64, 3, 3)
A = M * M' + 1.0 * I # Add Identity to ensure it's strictly positive

# 2. Factorize
F = cholesky(A)

# 3. Verify (A = U' * U)
# Note: F.U is the Upper triangular factor
recon_error = norm(A - F.U' * F.U)

# 4. Solve
b = rand(ComplexF64, 3)
x = F \ b
sol_error = norm(A*x - b)

println("Cholesky Reconstruction Error: $recon_error")
println("Cholesky Solution Error: $sol_error")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Diagonal Systems")
# Objective: Demonstrate the speed/simplicity of solving diagonal systems.
# Use Case: Time evolution in the energy eigenbasis.
#
# Steps:
# 1. Define a vector of eigenvalues 'vals'.
# 2. Construct a Diagonal matrix D = Diagonal(vals).
# 3. Define a vector b.
# 4. Solve D \ b.
# 5. Verify that the solution is exactly element-wise division (b ./ vals).

# 1. Construct Diagonal Matrix
vals = [2.0, 4.0, 8.0]
D = Diagonal(vals)

# 2. Define RHS
b = [10.0, 20.0, 32.0]

# 3. Solve (Julia detects structure)
x = D \ b

# 4. Verify manual calculation
#    (./ is element-wise division)
manual_x = b ./ vals
error = norm(x - manual_x)

println("Solution x: $x")
println("Difference from manual division: $error")



## ------------------------------------------------------------------
println("\nPROBLEM 5: Least Squares Solver")
# Objective: Find the best fit x for an overdetermined system (rows > cols).
# Use Case: Curve fitting experimental data.
#
# Steps:
# 1. Define a 5x2 matrix A (5 equations, 2 unknowns).
# 2. Define a random target vector b (size 5).
# 3. Solve x = A \ b.
# 4. Verify that the residual vector (b - Ax) is orthogonal to the columns of A.
#    (This is the geometric condition for the optimal least squares solution).

# 1. Tall Matrix (Overdetermined)
A = rand(Float64, 5, 2)
b = rand(Float64, 5)

# 2. Solve (Minimizes ||Ax - b||)
x = A \ b

# 3. Geometric Verification
# The error vector must be perpendicular to the plane spanned by A
residual_vector = b - A*x
ortho_check = norm(A' * residual_vector)

println("Best fit parameters x: $x")
println("Orthogonality Check (should be ~1e-15): $ortho_check")



## ------------------------------------------------------------------
println("\nPROBLEM 6: Explicit Inversion (Why to Avoid It)")
# Objective: Compare the accuracy of 'inv(A)*b' vs 'A \ b' for an ill-conditioned matrix.
#
# Steps:
# 1. Create a Hilbert matrix (notoriously ill-conditioned).
#    (Entries are H_ij = 1 / (i + j - 1)).
# 2. Define a known solution x_exact (all ones).
# 3. Compute b = H * x_exact.
# 4. Solve for x using both methods:
#    a. x_bad = inv(H) * b
#    b. x_good = H \ b
# 5. Compare errors relative to x_exact.

# 1. Create Ill-conditioned Matrix (Hilbert Matrix)
n = 10
H = [1.0 / (i + j - 1) for i in 1:n, j in 1:n]
println(H)

# 2. Setup Problem
x_exact = ones(n)
b = H * x_exact

# 3. Solve (Bad Way)
x_bad = inv(H) * b
err_bad = norm(x_bad - x_exact)

# 4. Solve (Good Way)
x_good = H \ b
err_good = norm(x_good - x_exact)

println("Error using inv(A)*b: $err_bad")
println("Error using A \\ b:     $err_good")