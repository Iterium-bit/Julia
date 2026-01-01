using LinearAlgebra
using SparseArrays # Standard library for sparese Matrices


## ------------------------------------------------------------------
println("\nPROBLEM 1: Dense vs. Sparse Memory Usage")
# Objective: Demonstrate the massive memory savings of sparse matrices.
# Use Case: Storing Hamiltonians for systems with N > 12 qubits.
#
# Steps:
# 1. Define a large dimension N = 10,000.
# 2. Create a dense Identity matrix (stores 100,000,000 numbers).
# 3. Create a sparse Identity matrix (stores only 10,000 numbers).
# 4. Compare the memory footprint using 'sizeof()'.

N = 10_000

#    WARNING: Don't print this! It's too big.
I_dense = Matrix(1.0*I,N,N)

#    'spzeros' creates an empty sparse matrix.
#    'sparse(I, N, N)' converts Identity to sparse format.
I_sparse = sparse(1.0*I,N,N)    # It is used to reduce the redundancy of information in Matrices. eg for this case it is using same 0 for all the other matrix elements. so it does not save 0 millions of times for each elements

mem_dense = sizeof(I_dense)/1024^2      # Convert to Megabytes (MB)
mem_sparse = sizeof(I_sparse)/1024^2

println("Dimension N: $N")
println("Dense Memory:  $mem_dense MB")
println("Sparse Memory: $mem_sparse MB")
println("Compression Ratio: $(mem_dense / mem_sparse)")


## ------------------------------------------------------------------
println("\nPROBLEM 2: The Coordinate List Constructor")
# Objective: Build a Tridiagonal Hamiltonian efficiently.
# Use Case: 1D Quantum Chain (Kinetic Energy Matrix).
#
# Matrix Structure:
#  2 -1  0  0
# -1  2 -1  0
#  0 -1  2 -1
#  0  0 -1  2
#
# Steps:
# 1. Define lists for the diagonal terms (value 2.0).
# 2. Define lists for the off-diagonal terms (value -1.0).
# 3. Concatenate them into master lists: rows, cols, vals.
# 4. Create the matrix using 'sparse(rows, cols, vals)'.

n = 1000

#    Value is 2.0 everywhere
rows_d = 1:n            #Creates a list [1, 2, ..., 1000].
cols_d = 1:n            #Creates a list [1, 2, ..., 1000].
vals_d = fill(2.0,n)    #Creates a list of 2.0s matching that length.

#    Value is -1.0. Note: only n-1 entries.
rows_u = 1:n-1                   #Goes from 1 to 999.
cols_u = 2:n                     #Goes from 2 to 1000.
vals_u = fill(-1.0, n-1)         #The first entry is at (1, 2), the last is at (999, 1000).

#    Value is -1.0.
rows_l = 2:n                     #Goes from 2 to 1000.
cols_l = 1:n-1                   #Goes from 1 to 999.
vals_l = fill(-1.0, n-1)         #The first entry is at (2, 1), the last is at (1000, 999).

#vcat: "Vertical Concatenate". It glues the three lists together into one giant master list.
I_idx = vcat(rows_d, rows_u, rows_l)    #Contains ALL row coordinates.
J_idx = vcat(cols_d, cols_u, cols_l)    #Contains ALL column coordinates.
V_val = vcat(vals_d, vals_u, vals_l)    #Contains ALL values

H_sparse = sparse(I_idx, J_idx, V_val)       #It effectively says: "At (I[k], J[k]), place the value V[k]. Everywhere else is 0."

println("Matrix Size: $(size(H_sparse))")
println("Non-zero elements: $(nnz(H_sparse))") # nnz counts stored values



## ------------------------------------------------------------------
println("\nPROBLEM 3: Performance Benchmark (Sparse vs Dense)")
# Objective: Compare the speed of Matrix-Vector multiplication.
#
# Steps:
# 1. Create a random sparse matrix of size N=5000 with 1% density.
#    (Using 'sprand' which generates random sparse matrices).
# 2. Create a dense copy of it.
# 3. Define a random vector b.
# 4. Use '@time' to measure the speed of multiplication.
# 5. Verify the results match.

N = 5000
density = 0.01 # 1% of entries are non-zero

#    sprand(type, rows, cols, density)
A_sparse = sprand(ComplexF64, N, N, density)
A_dense = Matrix(A_sparse) # Convert to dense for comparison

b = rand(ComplexF64, N)

println("Benchmarking Matrix-Vector Multiplication (N=$N):")

println("Sparse Time:")
@time x_sparse = A_sparse * b

println("Dense Time:")
@time x_dense = A_dense * b

err = norm(x_sparse - x_dense)
println("Difference: $err")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Structured Matrices (Tridiagonal)")
# Objective: Use the specialized 'Tridiagonal' type for 1D chains.
# Use Case: Solving the 1D Schrödinger equation or Heat equation.
#
# Steps:
# 1. Define the vectors for the diagonals:
#    - Main diagonal (d): All 2.0
#    - Lower diagonal (dl): All -1.0
#    - Upper diagonal (du): All -1.0
# 2. Construct the matrix T = Tridiagonal(dl, d, du).
# 3. Convert it to a standard dense matrix to verify visual structure.
# 4. Compare storage: Generic Sparse vs. Structured Tridiagonal.



d  = fill(2.0, n)       # Main diagonal (Length n)
dl = fill(-1.0, n - 1)  # Lower diagonal (Length n-1)
du = fill(-1.0, n - 1)  # Upper diagonal (Length n-1)

T_struct = Tridiagonal(dl, d, du)

println("Top-left 4x4 block:")
display(T_struct[1:4, 1:4])

#    Generic Sparse stores: row_index, col_index, value (3 numbers per entry)
#    Tridiagonal stores:    value (1 number per entry, position implied)
mem_sparse = sizeof(Int) * 2 * (3*n - 2) + sizeof(Float64) * (3*n - 2)
mem_struct = sizeof(T_struct)

println("\nMemory Usage (Bytes):")
println("Generic Sparse: $mem_sparse")
println("Tridiagonal:    $mem_struct")



## ------------------------------------------------------------------
println("\nPROBLEM 5: The Graph Laplacian")
# Objective: Construct the operator for a "Quantum Random Walk" on a random graph.
#
# Steps:
# 1. Create a random sparse matrix A representing connections.
# 2. Symmetrize A (Hamiltonians must be Hermitian).
# 3. Compute the Degree vector (sum of connections for each node).
# 4. Construct L = D - A.
# 5. Verify that L * [1,1...] = 0.

n = 100
density = 0.05

#    (We treat non-zero entries as "hopping strengths")
M = sprand(Float64, n, n, density)

A = M + M'

#    sum(A, dims=2) sums across columns for each row.
d_vector = vec(sum(A, dims=2))
D = Diagonal(d_vector)

L = D - A

ones_vec = ones(n)
zero_mode_check = norm(L * ones_vec)

println("Graph Size: $n nodes")
println("Edges: $(nnz(A) ÷ 2)") # Divided by 2 because A_ij = A_ji counts as 1 edge
println("L * |111> error (should be 0): $zero_mode_check")