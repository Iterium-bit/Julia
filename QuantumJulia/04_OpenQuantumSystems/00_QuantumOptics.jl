using QuantumOptics
using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: Defining the Basis and States")
#
# --- LIBRARY CONCEPTS ---
# 1. The Basis (The Universe):
#    In QuantumOptics.jl, a state cannot exist without a "Hilbert Space."
#    We must first define the basis.
#    - `SpinBasis(1//2)`: Creates the space for a single qubit (2 dimensions).
#    - Note: We use `1//2` (Rational) instead of `0.5` to keep the math exact.
#
# 2. The Kets (State Vectors):
#    Once the basis exists, we generate states inside it:
#    - `spinup(b)`: Creates the state |0> (Standard Vector: [1; 0]).
#    - `spindown(b)`: Creates the state |1> (Standard Vector: [0; 1]).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Initialize the QuantumOptics environment by defining a qubit basis and creating
# the two fundamental states |Up> and |Down>.
#
# Steps:
# 1. Import the `QuantumOptics` library.
# 2. Define a variable `b` as a `SpinBasis` with spin 1/2.
# 3. Create the state `psi_up` using the `spinup()` function.
# 4. Create the state `psi_down` using the `spindown()` function.
# 5. Print both states to observe how the library formats them (Physics Metadata).
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)            # Define the Hilbert Space
println("Defined Basis: $b") 
psi_up = spinup(b)             # Create Pure States
println("\nState |Up> (|0>):")
display(psi_up)
psi_down =spindown(b)
println("\nState |Down> (|1>):")
display(psi_down)



## ------------------------------------------------------------------
println("\nPROBLEM 2: Operators and Action")
#
# --- PHYSICS CONCEPTS ---
# 1. Operators need a Basis:
#    An operator (Matrix) must match the dimensions of the state (Vector).
#    The library enforces this. You generate operators *from* the basis:
#    - sigmax(b) : The Bit Flip (Pauli X).
#    - sigmaz(b) : The Phase Flip (Pauli Z).
#
# 2. Application:
#    To apply a gate, we simply multiply the Operator by the Ket:
#    |psi_new> = Operator * |psi_old>
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a Pauli-X operator and use it to flip a state from |Up> to |Down>.
#
# Steps:
# 1. Reuse the basis `b` and state `psi_up` from Problem 1.
# 2. Define the operator `sx` using the function `sigmax(b)`.
# 3. Apply the operator: `psi_flipped = sx * psi_up`.
# 4. Verify the result: Check if `psi_flipped` is equal to `psi_down`.
# ------------------------

# --- SOLUTION ---
sx = sigmax(b)     # Define the Operator (Pauli X)
println("Operator sigmax :")
display(sx)
psi_flipped = sx*psi_up
println("\nResult of operating the sisgmax on the psi_up: ")
display(psi_flipped)
println("Was the bit flipped successfully? ",psi_flipped ≈ psi_down)




## ------------------------------------------------------------------
println("\nPROBLEM 3: Superposition and Normalization")
#
# --- PHYSICS CONCEPTS ---
# 1. Linear Combinations:
#    Quantum states are vectors. You can add them together:
#    |psi_raw> = |Up> + |Down>
#    However, the length (norm) of this new vector will be sqrt(1^2 + 1^2) = 1.414.
#    This is physically invalid because total probability > 100%.
#
# 2. Normalization:
#    To fix this, we must divide the vector by its length.
#    The library provides `normalize(state)` to do this automatically.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create the superposition state |+> = |0> + |1> and normalize it.
#
# Steps:
# 1. Create a raw state by adding `psi_up` and `psi_down` (from Problem 1).
# 2. Print its norm (should be approx 1.414).
# 3. Create a valid state `psi_plus` using the `normalize()` function.
# 4. Verify the new norm is exactly 1.0.
# ------------------------

# --- SOLUTION ---
psi_raw = psi_up+psi_down
display(psi_raw)
println("Raw State Norm: $(norm(psi_raw))")
psi_plus = normalize(psi_raw)
println("\nFinal Norm: $(norm(psi_plus))")
println("Coefficients: $(psi_plus.data)")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Bras and Inner Products")
#
# --- PHYSICS CONCEPTS ---
# 1. The Dagger Operation:
#    The "Hermitian Conjugate" (Dagger) turns a Ket into a Bra.
#    - Ket: |psi> (Column Vector)
#    - Bra: <psi| = dagger(|psi>) (Row Vector, Complex Conjugated)
#
# 2. The Inner Product (Bracket):
#    Multiplying a Bra by a Ket gives a single number (Scalar).
#    <phi|psi> calculates the "Overlap" between two states.
#    - If they are the same: <psi|psi> = 1 (Normalization).
#    - If they are orthogonal: <0|1> = 0.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the overlap between |+> and |0>.
#
# Steps:
# 1. Use `psi_plus` (from Prob 3) and `psi_up` (from Prob 1).
# 2. Create the Bra `<Up|` using `dagger(psi_up)`.
# 3. Calculate the inner product: overlap = bra_up * psi_plus.
# 4. Verify that the result is 1/sqrt(2) (approx 0.707).
# ------------------------

# --- SOLUTION ---
bra_up = dagger(psi_up)     # Create the Bra <Up|
overlap = bra_up*psi_plus   # Calculate Overlap <Up | +>
println("The inner product of the <Up|plus>: $overlap")
prob_measurement_0 = abs(overlap^2)
println("The probability of finding |0>: $prob_measurement_0")



## ------------------------------------------------------------------
println("\nPROBLEM 5: Expectation Values")
#
# --- PHYSICS CONCEPTS ---
# 1. The Expectation Value <A>:
#    It represents the statistical mean of the observable A.
#    <A> = <psi| A |psi>
#
# 2. Example: Z-Component of Spin
#    - Operator: sigmaz(b)
#    - State |+>: 50% chance Up (+1), 50% chance Down (-1).
#    - Expected Average: 0.5*(+1) + 0.5*(-1) = 0.
#
# 3. The `expect` Function:
#    Writing `dagger(psi) * op * psi` works, but `expect(op, psi)`
#    is cleaner and optimized for performance.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the expectation value of Pauli-Z for the state |+>.
#
# Steps:
# 1. Define the Pauli Z operator `sz = sigmaz(b)`.
# 2. Use `psi_plus` (from Prob 3).
# 3. Calculate the expectation value using the manual Bra-Ket method.
# 4. Calculate it again using the built-in `expect()` function.
# 5. Verify they are both 0.
# ------------------------

# --- SOLUTION ---
sz = sigmaz(b)
exp_val_mannual = real(dagger(psi_plus)*sz*psi_plus)
exp_val_lib = real(expect(sz,psi_plus))          # expect(operator,state)
println("Does both methods give the same expected values? $(exp_val_lib ≈ exp_val_mannual)")



## ------------------------------------------------------------------
println("\nPROBLEM 6: Composite Systems (Two Qubits)")
#
# --- PHYSICS CONCEPTS ---
# 1. Composite Basis:
#    To describe two particles, we combine their spaces:
#    H_total = H_1 (x) H_2
#    In code: `b_composite = tensor(b, b)` or `b ⊗ b`.
#
# 2. Tensor Product of States:
#    |Psi> = |Alice> (x) |Bob>
#    In code: `psi_AB = tensor(psi_A, psi_B)` or `psi_A ⊗ psi_B`.
#
# 3. Dimensions:
#    The new dimension is dim(A) * dim(B).
#    For two qubits: 2 * 2 = 4.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a two-qubit system in the state |01> (|Up> (x) |Down>).
#
# Steps:
# 1. Define a composite basis `b2` by tensoring `b` with itself.
# 2. Create the combined state `psi_01` by tensoring `psi_up` and `psi_down`.
# 3. Print the state to see the "CompositeKet" structure.
# 4. Verify the total dimension is 4.
# ------------------------

# --- SOLUTION ---
b2 = tensor(b,b)   # Define the Composite Basis (Two Qubits).
println("The composite system of two qubits is:")
display(b2)
psi_01 = tensor(psi_up,psi_down)     # Joint State |01>
println("Joint State |01> :")
display(psi_01)
println("structure: $(psi_01.basis.shape)")
println("Total Dimensions: $(length(psi_01))")



## ------------------------------------------------------------------
println("\nPROBLEM 7: Partial Trace")
#
# --- PHYSICS CONCEPTS ---
# 1. The Partial Trace:
#    The operation of "averaging out" one particle to see the state of the other.
#    If the system is entangled, the result is a Mixed State (Density Matrix).
#
# 2. The Library Function `ptrace()`:
#    `ptrace(state, indices_to_keep)`
#    - arguments: The state you start with, and the index of the system you want to LOOK at.
#    - Example: `ptrace(psi_AB, 1)` keeps Alice (1) and traces out Bob.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create the Bell State |Phi+> = (|00> + |11>)/sqrt(2), then find Alice's local state.
#
# Steps:
# 1. Reuse the composite basis `b2` and basis states from Problem 6.
# 2. Construct the Bell State `psi_bell` manually (tensor up-up + tensor down-down) and normalize.
# 3. Use `ptrace(psi_bell, 1)` to get Alice's Density Matrix.
# 4. Print the result. You should see a diagonal matrix with 0.5s.
# ------------------------

# --- SOLUTION ---
 
psi_00 = tensor(psi_up,psi_up)      #|00>
psi_11 = tensor(psi_down,psi_down)  #|11>
psi_bell = normalize(psi_00+psi_11)    # Normalised Plus Bell state
println("The Plus Bell State is: ")
display(psi_bell)
rho_Alice = ptrace(psi_bell,1)             # Keep System 1, Trace out System 2.
println("\nAlice's Reduced State (Density Matrix):")
display(rho_Alice)
purity = real(tr(rho_Alice^2))
println("The Purity of the Alice state is: $purity")



## ------------------------------------------------------------------
println("\nPROBLEM 8: Unitary Gates (Hadamard & Interference)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Hadamard Gate (H):
#    - Turns |0> into |+> (Superposition).
#    - Turns |1> into |-> (Phase Superposition).
#    - Formula: H = (X + Z) / sqrt(2) (normalized differently in some contexts,
#      standard matrix is [[1, 1], [1, -1]] / sqrt(2)).
#
# 2. Reversibility (H^2 = I):
#    In classical probability, mixing usually destroys information.
#    In quantum, if you mix (H) and then mix again (H), the interference
#    cancels out the "wrong" paths and perfectly restores the original state.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Apply H to |Up>, measure randomness. Apply H again, observe determinism.
#
# Steps:
# 1. Define basis `b` (Spin 1/2).
# 2. Create the Hadamard Operator `hadamard(b)`.
# 3. Apply H to `psi_up` -> `psi_super`. Check if it looks like |+>.
# 4. Apply H to `psi_super` -> `psi_final`.
# 5. Verify `psi_final` is exactly `psi_up` (Interference restored the state).
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
psi_start = spinup(b)
H_op = (sigmax(b)+sigmaz(b))/sqrt(2)
println("Hadamard Operator defined:")
display(H_op)
psi_super = H_op*psi_start
println("When Hadamard Operator act on state |0>:")
display(psi_super)
psi_final = H_op*psi_super
println("When the Hadamard Operator acts on state |+> it gives:")
display(psi_final)
println("Did the state returned to the initial state? $(psi_final ≈ psi_start)")


## ------------------------------------------------------------------
println("\nPROBLEM 9: The CHSH Inequality (Bell Test)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Setup:
#    - Alice and Bob share a Bell State |Phi+> = (|00> + |11>)/sqrt(2).
#    - They measure along different angles.
#
# 2. The CHSH Quantity S:
#    S = <A1*B1> + <A1*B2> + <A2*B1> - <A2*B2>
#    - Classical Limit: S <= 2
#    - Quantum Limit:   S = 2*sqrt(2) ≈ 2.828
#
# 3. The Operators:
#    - Alice measures Z (A1) and X (A2).
#    - Bob measures diagonal angles (Z+X and Z-X).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct the Bell State and the 4 CHSH operators to verify S > 2.
#
# Steps:
# 1. Create Bell State |Phi+>.
# 2. Define Alice's operators: A1=Z, A2=X.
# 3. Define Bob's operators: B1=(Z+X)/sqrt(2), B2=(Z-X)/sqrt(2).
# 4. Construct the joint CHSH operator:
#    Op = (A1⊗B1) + (A1⊗B2) + (A2⊗B1) - (A2⊗B2).
# 5. Calculate expectation value <Phi+ | Op | Phi+>.
# ------------------------


println("\n--- DEBUGGING CHSH PROBLEM (ISOLATED) ---")

# 1. Define Basis
b = SpinBasis(1//2)

# 2. Define Alice (Standard)
Az = sigmaz(b)
Ax = sigmax(b)

# 3. Define Bob (Explicit Matrices)
#    We use standard ComplexF64 matrices to be 100% safe.
mat_Bz = [1.0+0im  1.0+0im;  1.0+0im -1.0+0im] / sqrt(2)
mat_Bx = [1.0+0im -1.0+0im; -1.0+0im -1.0+0im] / sqrt(2)

Bz = DenseOperator(b, mat_Bz)
Bx = DenseOperator(b, mat_Bx)

# 4. CHECK TYPES (Crucial Step)
println("Type check:")
println("  Az: $(typeof(Az))") # Expect Operator
println("  Bz: $(typeof(Bz))") # Expect Operator

# 5. Build Terms Individually
t1 = tensor(Az, Bz)
t2 = tensor(Az, Bx) 
t3 = tensor(Ax, Bz)
t4 = tensor(Ax, Bx)

println("  Term 1 (Tensor): $(typeof(t1))") # Expect Operator

# 6. Sum them up CAREFULLY
# The issue is that t1 + t2 + t3 - t4 might collapse to a scalar
# Let's build it step by step:
op = t1 + t2
println("  After adding t1+t2: $(typeof(op))")

op = op + t3
println("  After adding t3: $(typeof(op))")

# Create negative t4 properly
neg_t4 = -1 * t4  # Use scalar multiplication to create negative operator
println("  Negative t4: $(typeof(neg_t4))")

op = op + neg_t4  # Now add the negative operator
println("  Total Op after adding -t4: $(typeof(op))")

