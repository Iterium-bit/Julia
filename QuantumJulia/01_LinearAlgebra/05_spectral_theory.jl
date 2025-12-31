using LinearAlgebra
## ------------------------------------------------------------------
println("\nPROBLEM 1: Basic Eigen Decomposition")
# Objective: Compute eigenvalues and eigenvectors of a Hermitian matrix.
#
# Steps:
# 1. Define a random 3x3 Hermitian matrix H (ensure H = H').
# 2. Compute the decomposition: F = eigen(H).
#    (F.values gives eigenvalues, F.vectors gives eigenvectors).
# 3. Extract the first eigenvalue (lambda_1) and first eigenvector (v1).
# 4. Verify the equation H*v1 = lambda_1*v1.
#    (Check the norm of the difference vector).
# 5. Verify that lambda_1 is real (imaginary part should be 0).

H = rand(ComplexF64,3,3)
F = eigen(H)
vals = F.values
println("\nEigen Values: $vals")
vecs = F.vectors
println("\nEigen Vectors: $vecs")
lambda_1 = vals[1]
println("\nFirst Eigenvalue: $lambda_1")
v1 = vecs[:,1]
println("\nFirst Eigenvector: $v1")
lhs = H*v1
rhs = lambda_1*v1
error = norm(lhs - rhs)
println("\nEigenvalue equation error: $error")
println("is eigenvalue real? $(imag(lambda_1) ==0)")



## ------------------------------------------------------------------
println("\nPROBLEM 2: Orthogonality and Unitarity")
# Objective: Verify that eigenvectors of a Hermitian matrix form an orthonormal basis.
#
# Steps:
# 1. Use the 'vecs' matrix from Problem 1.
# 2. Extract the first (v1) and second (v2) eigenvectors.
# 3. Compute the inner product dot(v1, v2).
#    (Since eigenvalues are likely distinct, this should be ~0).
# 4. Verify the entire matrix V is unitary by computing V' * V.
# 5. Check the deviation from the Identity matrix I.

A = rand(ComplexF64,3,3)
H = A + A'
println("\nIs H Hermitian? $(ishermitian(H))")
F = eigen(H)
vecs = F.vectors
vals = F.values
v1 = vecs[:,1]
v2 = vecs[:,2]
ortho_check = dot(v1,v2)
V = vecs
unitary_check = norm(V'*V-I)
println("\nInner product v1.v2 (Should be ~0.0): $ortho_check")
println("\nUnitary Error (Should be ~1e-15): $unitary_check")



## ------------------------------------------------------------------
println("\nPROBLEM 3: Commutators and Shared Bases")
# Objective: Verify that matrices with the same eigenvectors commute.
#
# Steps:
# 1. Generate a random unitary matrix V (using eigenvectors of a random Hermitian matrix).
# 2. Define two distinct sets of eigenvalues (d1 and d2).
# 3. Construct matrix A = V * Diagonal(d1) * V'.
# 4. Construct matrix B = V * Diagonal(d2) * V'.
# 5. Compute the Commutator: C = A*B - B*A.
# 6. Verify that norm(C) is approximately zero.


# 1. Create a shared basis V
H_temp = (H = rand(ComplexF64,3,3))+H'
V = eigen(H_temp).vectors
println("\nEigenvectors: $V")

# 2. Define Eigenvalues
d1 = [1.0,2.0,3.0]
d2 = [4.0,5.0,6.0]
A = V*Diagonal(d1)*V'
B = V*Diagonal(d2)*V'
Commutator = A*B - B*A
Commutator_error = norm(Commutator)

println("Commutator Error (should be ~0.0): $Commutator_error")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Matrix Exponentials")
# Objective: Compute the matrix exponential e^(iH) and verify it is Unitary.
# Use Case: Simulating Quantum Time Evolution (Schrodinger Equation).
#
# Steps:
# 1. Define a random Hermitian matrix H (Hamiltonian).
# 2. Compute U = exp(1im * H) using the built-in matrix exponential function 'exp()'.
#    Note: In Julia, 'exp(Matrix)' computes the matrix exponential.
#          'exp.(Matrix)' (with dot) would be element-wise (INCORRECT here).
# 3. Verify that U is Unitary: U' * U should be Identity.
# 4. Print the Unitary Error (norm of U'U - I).


# 1. Random Hamiltonian
H_herm = (H =rand(ComplexF64,3,3))+H'

# 2. Compute Time Evolution Operator
# exp(M) uses scaling and squaring or spectral methods automatically
U = exp(1im*H_herm)
# 3. Verify Unitary Property (Preservation of Probability)
unitary_error = norm(U'*U-I)

println("\nUnitary Error (should be ~1e-15): $unitary_error")



## ------------------------------------------------------------------
println("\nPROBLEM 5: Eigenvalues of a Unitary Operator")
# Objective: Verify that eigenvalues of U lie on the complex unit circle (|λ|=1).
#
# Steps:
# 1. Reuse the Unitary matrix 'U' from Problem 4.
#    (If U is not in memory, regenerate it using U = exp(1im * H)).
# 2. Compute the eigenvalues of U.
# 3. Compute the absolute value (magnitude) of these eigenvalues.
# 4. Verify that the magnitudes are all effectively 1.0.
#    (Compute the norm of the difference vector: |vals| - [1,1,1]).


# 1. Decompose U
e_values = eigen(U).values

# 2. Check magnitudes
magnitudes = abs.(e_values)
deviation = norm.(magnitudes.-1.0)     #magnitudes.-1.0 subtracts 1.0 from each elements
println("Eigenvalues of U: ")
display(e_values)
println("\nDeviation from Unit Circle (should be ~1e-15): $deviation")


## ------------------------------------------------------------------
println("\nPROBLEM 6: Invariants (Trace and Determinant)")
# Objective: Verify that Trace = sum(eigenvalues) and Det = product(eigenvalues).
#
# Steps:
# 1. Define a random 3x3 matrix A (can be general complex, doesn't need to be Hermitian).
# 2. Compute the eigenvalues using 'eigen(A).values'.
# 3. Compute the Trace Error: abs( tr(A) - sum(vals) ).
# 4. Compute the Determinant Error: abs( det(A) - prod(vals) ).
# 5. Print both errors.

A =rand(ComplexF64,3,3)
e_values = eigen(A).values

# Check Trace
Trace_error = abs(tr(A)-sum(e_values))

# Check Determinant
# prod() computes the product of all elements in a vector
Determinant_error = abs(det(A)-prod(e_values))

println("Trace Error: $Trace_error")
println("Determinant Error: $Determinant_error")



## ------------------------------------------------------------------
println("\nPROBLEM 7: Heisenberg Uncertainty Principle")
# Objective: Verify sigma_A * sigma_B >= 0.5 * |<[A,B]>| for random observables.
#
# Steps:
# 1. Define two random Hermitian matrices A and B.
# 2. Define a random normalized state 'psi'.
# 3. Calculate Variance: <A^2> - <A>^2.
#    (Note: We use a small helper function 'expect' for cleaner code).
# 4. Calculate the Commutator C = AB - BA.
# 5. Compute the RHS limit: 0.5 * |<psi|C|psi>|.
# 6. Check if LHS (product of sigmas) >= RHS.

# Helper: Compute expectation value <psi|Op|psi>
expect(Op, s) = real(dot(s, Op * s))

# 1. Observables
A = (M1 = rand(ComplexF64,3,3)) + M1'
B = (M2 = rand(ComplexF64,3,3)) + M2'

# 2. State
psi = normalize(rand(ComplexF64,3))
Var_A = expect(A*A,psi)-(expect(A,psi)^2)
Var_B = expect(B*B,psi)-(expect(B,psi)^2)
std_A = sqrt(Var_A)
std_B = sqrt(Var_B)
LHS = std_A*std_B

# 3. Commutator Bound
Commu = A*B-B*A
RHS_lim = 0.5(abs(expect(Commu,psi)))
println(RHS_lim)
println("Uncertainty Product: $LHS")
println("Heisenberg Limit:    $RHS_lim")
println("Satisfied? $(LHS >= RHS_lim - 1e-14)")



## ------------------------------------------------------------------
println("\nPROBLEM 8: Normal Matrices")
# Objective: Verify that a general Normal matrix (complex eigenvalues)
#            still possesses orthogonal eigenvectors.
#
# Steps:
# 1. Construct a Normal matrix 'N' manually using the Spectral Theorem.
#    (N = V * D * V', where V is unitary and D is random complex).
#    Note: Generating a random matrix directly is almost never Normal.
# 2. Verify the Normal condition: comm_error = norm(N*N' - N'*N).
# 3. Compute eigenvectors of N.
# 4. Verify orthogonality: dot(v1, v2) should be ~0.
#
# Use Case: Non-Hermitian Quantum Mechanics (open systems, decay).


H_temp = rand(ComplexF64, 3, 3); H_temp += H_temp'
V = eigen(H_temp).vectors

#    b) Create random complex eigenvalues
vals_complex = rand(ComplexF64, 3)

#    c) Build N
N = V * Diagonal(vals_complex) * V'

# 2. Check Normality Condition [N, N'] = 0
normality_check = norm(N*N' - N'*N)

# 3. Decompose
F_N = eigen(N)
vecs_N = F_N.vectors

# 4. Verify Orthogonality (v1 ⊥ v2)
v1 = vecs_N[:, 1]
v2 = vecs_N[:, 2]
ortho_check = abs(dot(v1, v2))

println("Is N Hermitian? $(ishermitian(N))") # Should be False
println("Normality Error: $normality_check")
println("Orthogonality of Eigenvectors: $ortho_check")




## ------------------------------------------------------------------
println("\nPROBLEM 9: Spectral Decomposition")
# Objective: Reconstruct H as a sum of projectors: H = sum( lambda_i * P_i ).
#
# Steps:
# 1. Define a random Hermitian matrix H.
# 2. Compute eigenvalues (vals) and eigenvectors (vecs).
# 3. Initialize a zero matrix 'H_sum' of the same size as H.
# 4. Loop through each index 'i' (from 1 to 3):
#    a. Extract eigenvector v = vecs[:, i].
#    b. Form Projector P = v * v'.
#    c. Add weighted projector to sum: H_sum += vals[i] * P.
# 5. Verify reconstruction: norm(H - H_sum) should be ~1e-15.


# 1. Define Matrix
H = (A = rand(ComplexF64,3,3))+A'

# 2. Decompose
e_vals = eigen(H).values
e_vectors = eigen(H).vectors

# 3. Sum of Projectors
n = size(H,1)
println(n)
H_sum = zeros(ComplexF64,3,3)

for i in 1:n
    v = e_vectors[:,i]
    p = v*v'
    H_sum .+= e_vals[i]*p
end

# 4. Verify
error = norm(H - H_sum)

println("Spectral Sum Error: $error")



## ------------------------------------------------------------------
println("\nPROBLEM 10: The Finite Dimension Paradox")
# Objective: Demonstrate that no finite matrices can satisfy [A, B] = i*Identity.
#
# Steps:
# 1. Define two random complex matrices A and B (Size 4x4).
# 2. Compute the Commutator C = A*B - B*A.
# 3. Compute the Trace of C. (Must be 0 due to cyclic property).
# 4. Compute the Trace of the Identity matrix scaled by 'im' (im * I).
# 5. Show that tr(C) is NOT equal to tr(im * I).
#
# Insight: This proves why Quantum Mechanics requires infinite-dimensional
#          Hilbert spaces for continuous variables like position/momentum.

A = rand(ComplexF64,4,4)
B = rand(ComplexF64,4,4)

# LHS of Canonical Commutation Relation
Commu =A*B-B*A
trace_LHS = tr(Commu)
println("\nTrace of Commutation A*B-B*A: $trace_LHS")

# RHS of Canonical Commutation Relation (if [A,B] = i*I)
trace_RHS = tr(1im*rand(ComplexF64,4,4))

println("\nTrace(i*im): $trace_RHS ")

println("Can finite matrices represent x and p? $(trace_LHS ≈ trace_RHS)")