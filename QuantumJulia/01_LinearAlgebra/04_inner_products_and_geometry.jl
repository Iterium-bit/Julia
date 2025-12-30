using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: Order of Conjugation (2D Vectors)")
# 1. Define u = [1, i] and v = [i, 2].
# 2. Compute dot(u, v).
# 3. Compute dot(v, u).


u = [1.0+0.0im, 0.0+1.0im]
v = [0.0+1.0im, 2.0+0.0im]

dot_uv = dot(u,v)
dot_vu = dot(v,u)

println("u: $u")
println("v: $v")
println("<u,v>: $dot_uv")
println("<v,u>: $dot_vu")


## ------------------------------------------------------------------
println("\nPROBLEM 2: Geometry and Normalization")
# 1. Define psi = [3.0, 4.0im].
# 2. Compute n = norm(psi). Expected: 5.0.
# 3. Verify manually: sqrt(real(dot(psi, psi))).
# 4. Normalize: psi_hat = psi / n.
# 5. Verify norm(psi_hat) is 1.0.

psi = [3.0 + 0.0im, 0.0 + 4.0im]

# Built-in Norm
n = norm(psi)

# Manual verification (Sqrt of inner product with self)
# We take r() because dot returns Complex type (e.g. 25.0 + 0.0im)
n_manual = sqrt(real(dot(psi, psi)))

# Normalize
psi_hat = psi / n
n_hat = norm(psi_hat)

println("Original Norm: $n")
println("Manual Match: $n_manual")
println("Normalized Norm: $n_hat")
println("Normalized Vector: $psi_hat")

## ------------------------------------------------------------------
println("\nPROBLEM 3: Cauchy-Schwarz Inequality")
# Objective: computational proof that |<u|v>| <= ||u|| * ||v||
#
# Steps:
# 1. Define two random normalised complex vectors 'u' and 'v' of dimension 5 using rand(ComplexF64, 5).
# 2. Compute the Left Hand Side (LHS): The absolute value of the inner product |<u|v>|.
#    Note: We must use abs() because dot(u, v) is a complex number.
# 3. Compute the Right Hand Side (RHS): The product of their norms ||u|| * ||v||.
# 4. Print both values and the boolean result of the inequality check (LHS <= RHS).

#Solution

u = rand(ComplexF64,5)   # random 5 dimensional complex Vector
v = rand(ComplexF64,5)
u_norm = u/norm(u)
v_norm = v/norm(v)
lhs = abs(dot(u_norm,v_norm))
rhs = norm(u_norm)*norm(v_norm)
println("LHS: $lhs")
println("RHS: $rhs")
println("Inequality Holds: $(lhs<=rhs)")

## ------------------------------------------------------------------
println("\nPROBLEM 4: Angle Between Vectors")
# Objective: Calculate the geometric angle between two vectors using the dot product.
# Formula: cos(θ) = (u ⋅ v) / (||u|| * ||v||)
#
# Steps:
# 1. Define vector v1=[1, 0] (x-axis) and v2=[1, 1] (diagonal 45 deg).
# 2. Compute the cosine term: dot(v1, v2) divided by the product of their norms.
# 3. Calculate the angle in radians using 'acos()'.
# 4. Convert the result to degrees using 'rad2deg()'. Expected result: ~45.0.
# 5. Repeat the logic for orthogonal vectors [1, 0] and [0, 1] to verify it yields 90.0 degrees.
v1 = [1.0,0.0]
v2 = [1.0,1.0]
cos_theta = dot(v1,v2)/(norm(v1)*norm(v2))
theta_deg = rad2deg(acos(cos_theta))
println("Angle between v1 and v2: $theta_deg")
v3 = [0.0,1.0]
cos_phi = dot(v1,v3)/(norm(v1)*norm(v3))
phi_deg = rad2deg(acos(cos_phi))
println("Angle Bettween v1 and v3: $phi_deg")


## ------------------------------------------------------------------
println("\nPROBLEM 5: The Outer Product and Projection Matrix")
# Objective: Construct a projection operator P = |ψ><ψ| and verify its properties.
#
# Steps:
# 1. Define a random complex vector 'psi' and normalize it (psi_hat).
# 2. Compute the Outer Product P = psi_hat * psi_hat' (Column times Row-Conjugate).
#    Note: This creates a matrix.
# 3. Verify P is Idempotent: P * P should equal P.
# 4. Verify P is Hermitian: P' should equal P.
# 5. Apply P to a random vector 'v' and verify it yields the same result 
#    as the projection formula: (<ψ|v>) * |ψ>.

psi = rand(ComplexF64, 4)
psi_hat = normalize(psi)

P = psi_hat * psi_hat'

is_idempotent = P * P ≈ P
is_hermitian = P' ≈ P

v = rand(ComplexF64, 4)
proj_matrix_way = P * v
proj_scalar_way = dot(psi_hat, v) * psi_hat

println("Is P Idempotent (P^2=P)? $is_idempotent")
println("Is P Hermitian (P'=P)? $is_hermitian")
println("Match? $(proj_matrix_way ≈ proj_scalar_way)")


## ------------------------------------------------------------------
println("\nPROBLEM 6: Gram-Schmidt Orthogonalization (Manual Implementation)")
# Objective: Convert a set of non-orthogonal vectors into an Orthonormal Basis.
# Algorithm:
# 1. First basis vector (e1) is the normalized first input vector (v1).
# 2. To find the second basis vector (e2), take v2 and subtract the component 
#    parallel to e1 (the projection).
#    Formula: u2 = v2 - <e1|v2> * e1
# 3. Normalize the resulting vector u2 to get e2.
# 4. Verify Orthogonality: The dot product of e1 and e2 must be effectively zero.
#
# Steps:
# 1. Define non-orthogonal vectors v1=[1.0, 1.0] and v2=[1.0, 0.0].
# 2. Compute e1 by normalizing v1.
# 3. Compute the projection scalar: proj_coeff = dot(e1, v2).
# 4. Compute the orthogonal residual: u2 = v2 - (proj_coeff * e1).
# 5. Compute e2 by normalizing u2.
# 6. Verify result: Print e1, e2, and the absolute value of dot(e1, e2).

v1 = [1.0, 1.0]
v2 = [1.0, 0.0]

e1 = normalize(v1)

coeff = dot(e1, v2)
u2 = v2 - (coeff * e1)

e2 = normalize(u2)

ortho_error = abs(dot(e1, e2))

println("Basis e1: $e1")
println("Basis e2: $e2")
println("Orthogonality Error: $ortho_error")


## ------------------------------------------------------------------
println("\nPROBLEM 7: The Trace (Sum of Diagonal Elements)")
# Objective: Calculate the Trace of a matrix, which is invariant under unitary transformations.
# Use Case: In Quantum Mechanics, the trace of a Density Matrix must be 1.
#
# Steps:
# 1. Define a random 3x3 complex matrix A.
# 2. Compute the trace using the built-in function 'tr(A)'.
# 3. Verify manually by summing the diagonal elements: A[1,1] + A[2,2] + A[3,3].
# 4. Check the "Cyclic Property" of the trace: tr(A*B) should equal tr(B*A).
#    (Define a second random matrix B for this).
# 5. Print the error between tr(A*B) and tr(B*A).

A = rand(ComplexF64,3,3)
B = rand(ComplexF64,3,3)

# Built-in Trace
tr_val = tr(A)

# Manual Trace
manual_trace = A[1,1]+A[2,2]+A[3,3]

tr_AB = tr(A*B)
tr_BA = tr(B*A)

cyclic_error = abs(tr_AB-tr_BA)
println("Trace match:$(tr_val ≈ manual_trace)")
println("cyclic_error:$cyclic_error")


## ------------------------------------------------------------------
println("\nPROBLEM 8: Expectation Value of an Observable")
# Objective: Compute <H> = <psi|H|psi> and verify it is a real number.
# Use Case: Calculating average energy of a quantum state.
#
# Steps:
# 1. Define a random 3x3 complex matrix A.
# 2. Construct a Hermitian observable H = A + A'.
#    (Hermitian matrices guarantee real expectation values).
# 3. Define a random complex vector 'psi' and normalize it.
# 4. Compute the expectation value: E_avg = dot(psi, H * psi).
# 5. Verify that the imaginary part of E_avg is effectively zero (approx 0.0).
# 6. Print the real part of E_avg.

A = rand(ComplexF64,3,3)
H = A + A'
psi = normalize(rand(ComplexF64,3))
E_avg = dot(psi,H*psi)
is_real = abs(imag(E_avg))<1e-15
println("Expectation Value: $(real(E_avg))")
println("Is purely real? $is_real")


## ------------------------------------------------------------------
println("\nPROBLEM 9: The Parallelogram Law")
# Objective: Verify the geometric identity 2(||u||^2 + ||v||^2) = ||u+v||^2 + ||u-v||^2.
#
# Steps:
# 1. Define two random complex vectors 'u' and 'v' (dimension 4).
# 2. Compute the LHS: 2 * (norm(u)^2 + norm(v)^2).
# 3. Compute the RHS: norm(u + v)^2 + norm(u - v)^2.
# 4. Print the difference (residual) between LHS and RHS.
#    (It should be effectively zero, ~1e-14).

u = rand(ComplexF64,4)
v = rand(ComplexF64,4)
LHS = 2*(norm(u)^2+norm(v)^2)
RHS = norm(u+v)^2 + norm(u-v)^2
residual = abs(LHS-RHS)
println("The difference between the LHS and RHS: $residual")

## ------------------------------------------------------------------
println("\nPROBLEM 10: Matrix Elements and Transition Probabilities")
# Objective: Calculate the transition amplitude <phi|H|psi> and the associated probability.
#
# Steps:
# 1. Define a 3x3 Hermitian Hamiltonian H (Energy operator).
# 2. Define an initial state 'psi' and a final state 'phi' (both normalized).
# 3. Compute the complex amplitude: M = dot(phi, H * psi).
#    (Note: This is equivalent to <phi| (H|psi>) ).
# 4. Compute the Transition Probability: P = |M|^2.
# 5. Print the amplitude and the probability.

A = rand(ComplexF64, 3, 3)
H = A + A'
psi = normalize(rand(ComplexF64,3))
phi = normalize(rand(ComplexF64,3))

M = dot(phi,H*psi)
T_Prob = abs2(M)

println("Transition Amplitude :$M")
println("Transition Probability :$T_Prob")