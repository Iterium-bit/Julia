using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: Hermitian Operators (Observables)")
#
# --- PHYSICS CONCEPTS ---
# 1. Operators as Physical Quantities:
#    Every measurable quantity (Energy, Spin, Momentum) is represented by a 
#    matrix called an "Operator".
#
# 2. The Hermiticity Condition:
#    If we measure something (like energy), the result must be a REAL number.
#    Therefore, the matrix A must equal its conjugate transpose (A = A').
#    This property is called "Hermitian".
#
# 3. Eigenvalues = Measurement Outcomes:
#    If an operator A has eigenvalues {lambda_1, lambda_2}, these are the ONLY
#    possible values you will ever see on your measurement device.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a valid physical observable and an invalid one, then compare their eigenvalues.
#
# Steps:
# 1. Define the Pauli-Y matrix (Sigma_Y). It represents Spin along the Y-axis.
# 2. Check if it is Hermitian (Does Sigma_Y == Sigma_Y' ?).
# 3. Compute its eigenvalues. They should be real numbers (+1 and -1).
# 4. Create a non-Hermitian random matrix.
# 5. Compute its eigenvalues. They will likely be complex (impossible to measure).
# ------------------------

# --- SOLUTION ---
Sigma_Y = [0 -im;im 0]
display(Sigma_Y)
println("Is Sigma_Y a Hermitian matrix? ",ishermitian(Sigma_Y))
eigenvalues = eigen(Sigma_Y).values
println("The possible eigen values are: $eigenvalues")
# Random Non-Hermitian Matrix 
H_nherm = rand(ComplexF64,2,2)
e_val = eigen(H_nherm).values
println("The possible eigen values of the random non hermitian matrix is : $e_val")




## ------------------------------------------------------------------
println("\nPROBLEM 2: The Pauli Matrices (Gates & Commutators)")
#
# --- PHYSICS CONCEPTS ---
# 1. The "Alphabet" of Qubits:
#    The three Pauli matrices are the fundamental building blocks:
#    - Sigma_X (Bit Flip): Swaps |0> and |1>. (Like a Classical NOT).
#    - Sigma_Z (Phase Flip): Leaves |0> alone, changes |1> to -|1>.
#    - Sigma_Y (Bit+Phase): Combines both effects.
#
# 2. Dual Nature:
#    Pauli matrices are unique because they are:
#    - Hermitian (A' = A): They represent measurable Spin (Spin-X, Spin-Z).
#    - Unitary   (A'A = I): They represent reversible Logic Gates.
#
# 3. Commutation (Order Matters):
#    In classical math, a*b = b*a.
#    In Quantum Mechanics, order matters!
#    The "Commutator" measures this failure: [A, B] = A*B - B*A.
#    If [A, B] != 0, you cannot measure both quantities precisely at the same time
#    (Heisenberg Uncertainty Principle).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Define the Pauli matrices and verify their Commutation Relation: [X, Y] = 2iZ.
#
# Steps:
# 1. Define sigma_x, sigma_y, sigma_z manually.
# 2. Verify that Sigma_X is Unitary (X' * X == Identity).
# 3. Compute the Commutator [X, Y] = X*Y - Y*X.
# 4. Verify that this result is exactly equal to 2*im*Sigma_Z.
# ------------------------

# --- SOLUTION ---

sigma_x = [0 1;1 0]
sigma_y = [0 -im;im 0]
sigma_z = [1 0;0 -1]
println("sigma_x: ")
display(sigma_x)
println("sigma_y: ")
display(sigma_y)
println("sigma_z: ")
display(sigma_z)
println("Is sigma_x Unitary? ",isapprox(sigma_x*sigma_x ,I'))
comm_xy = sigma_x*sigma_y-sigma_y*sigma_x
display(comm_xy)
println("Does [x,y] = 2z? ",isapprox(comm_xy ,2im*sigma_z))



## ------------------------------------------------------------------
println("\nPROBLEM 3: The Expectation Value (<A>)")
#
# --- PHYSICS CONCEPTS ---
# 1. The "Sandwich" Formula:
#    The average value of an observable A for a system in state |psi> is:
#    <A> = <psi| A |psi>
#
# 2. Physical Meaning:
#    <A> is NOT the result of a single measurement. It is the statistical MEAN
#    of many measurements repeated on identical systems.
#    - Example: If outcomes are +1 and -1 with 50/50 probability, <A> = 0.
#
# 3. Calculation in Linear Algebra:
#    It is the dot product of the vector |psi> with the vector (A * |psi>).
#    In Julia: dot(psi, A * psi).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the expectation values for Spin-Z and Spin-X for different states.
#
# Steps:
# 1. Define operators Sigma_Z and Sigma_X.
# 2. Define two states:
#    - |0> (Spin Up along Z)
#    - |+> (Spin Right along X)
# 3. Calculate <Z> for state |0>. Expectation: +1.0 (100% chance of +1).
# 4. Calculate <X> for state |0>. Expectation: 0.0 (50% +1, 50% -1).
# 5. Calculate <X> for state |+>. Expectation: +1.0.
# ------------------------

# --- SOLUTION ---

# Operators
Sigma_z = [1 0;0 -1]
Sigma_x = [0 1;1 0]
psi_0 = [1,0]
psi_plus = [1,1]/sqrt(2)

# Expectations
expect_z_0 = dot(psi_0,Sigma_z*psi_0)   
println("The <z> for the state |0>: $expect_z_0")
expect_x_0 = dot(psi_0,Sigma_x*psi_0)
println("The <x> fot the state |0>: $expect_x_0")
expect_x_plus = dot(psi_plus,Sigma_x*psi_plus)
println("The <x> for the state |+>: $expect_x_plus")



## ------------------------------------------------------------------
println("\nPROBLEM 4: The Heisenberg Uncertainty Principle")
#
# --- PHYSICS CONCEPTS ---
# 1. Uncertainty (Standard Deviation):
#    In quantum mechanics, "Uncertainty" (Delta A) is the standard deviation
#    of many measurements.
#    Formula: (Delta A)^2 = <A^2> - <A>^2
#
# 2. The Uncertainty Principle:
#    It is impossible to know two incompatible variables perfectly at the same time.
#    If [A, B] != 0, then:
#    (Delta A) * (Delta B) >= 0.5 * |<[A, B]>|
#
# 3. Application to Spin:
#    Since [X, Y] = 2iZ, the uncertainty limit depends on the Z-spin!
#    (Delta X) * (Delta Y) >= |<Z>|
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Numerical verification of the Uncertainty Principle for the state |0>.
#
# Steps:
# 1. Define operators X, Y, Z and state |psi> = |0> = [1, 0].
# 2. Calculate Expectation Values <X> and <Y>.
# 3. Calculate Expectation Values of squares <X^2> and <Y^2>.
#    (Note: For Pauli matrices, A^2 = I, so <A^2> is always 1.0).
# 4. Compute Uncertainties: Delta = sqrt(<A^2> - <A>^2).
# 5. Compute the Theoretical Limit: 0.5 * |<[X, Y]>|.
# 6. Check if Product (Delta X * Delta Y) >= Limit.
# ------------------------

# --- SOLUTION ---

# Operators
sigma_x = [0 1;1 0]
sigma_y = [0 -im;im 0]
sigma_z = [1 0;0 -1]

# state
psi_0 = [1,0]

# Expectations
expect_x = real(dot(psi_0,sigma_x*psi_0))           # make sure to add real() otherwise there maybe a exremelly small complex number with negligible value and that may mess up.
expect_y = real(dot(psi_0,sigma_y*psi_0))
expect_z = real(dot(psi_0,sigma_z*psi_0))
expect_x2 = real(dot(psi_0,sigma_x*sigma_x*psi_0))
expect_y2 = real(dot(psi_0,sigma_y*sigma_y*psi_0))
expect_z2 = real(dot(psi_0,sigma_z*sigma_z*psi_0))

# Deltas
delta_x = sqrt(expect_x2-expect_x^2)
delta_y = sqrt(expect_y2-expect_y^2)
delta_z = sqrt(expect_z2-expect_z^2)

println("Uncertainty Delta X: $delta_x")
println("Uncertainty Delta Y: $delta_y")
println("Product (Delta X * Delta Y): $(delta_x * delta_y)")
commut_expect = real(dot(psi_0,(sigma_x*sigma_y-sigma_y*sigma_x)*psi_0))
limit = 0.5*abs(commut_expect)
println("Theoretical Lower Limit: $limit")
println("Principle Holds? $((delta_x * delta_y) >= limit)")




## ------------------------------------------------------------------
println("\nPROBLEM 5: Measurement using Density Matrices")
#
# --- PHYSICS CONCEPTS ---
# 1. The Density Matrix (rho):
#    Instead of a vector |psi>, we represent the state as a matrix:
#    rho = |psi><psi|
#    Properties:
#    - Hermitian (rho' = rho)
#    - Trace = 1 (Sum of diagonal probabilities = 1)
#    - Positive Semi-definite (Eigenvalues >= 0)
#
# 2. Probability via Trace:
#    The expectation value of any operator A is the Trace of (rho * A).
#    Prob(0) = Tr(rho * P0)
#
# 3. Measurement Update (Collapse):
#    If we measure outcome 'k' (associated with Projector Pk), the state updates to:
#    rho_new = (Pk * rho * Pk) / Tr(rho * Pk)
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate the collapse of the |+> state using the Density Matrix formalism.
#
# Steps:
# 1. Define Basis states |0> and |1>.
# 2. Create the Pure State vector |+>.
# 3. Construct the Density Matrix rho = |+><+|.
# 4. Define the Projector P0 = |0><0|.
# 5. Calculate Probability of measuring 0 using the Trace formula.
# 6. Calculate the new density matrix after measuring 0.
# 7. Verify the new state is Pure State |0><0|.
# ------------------------

# --- SOLUTION ---
# States
psi_0 = [1,0]
psi_1 = [0,1]
psi_plus = [1,1]/sqrt(2)
# Density Matrices
rho_0 = psi_0*psi_0'
rho_1 = psi_1*psi_1'
rho = rho_0 + rho_1

# Expectation
prob_0 = real(tr(rho*rho_0))
println("Probability of outcome 0 (Tr(rho*P0)): $prob_0")
rho_collapsed = (rho_0 * rho * rho_0) / prob_0

println("Density Matrix after measuring '0':")
display(rho_collapsed)
ideal_rho_0 = psi_0 * psi_0'
println("Matches |0><0|? $(isapprox(rho_collapsed, ideal_rho_0))")