using LinearAlgebra
## ------------------------------------------------------------------
println("\nPROBLEM 1: The Tensor Product (Kronecker Product)")
#
# --- PHYSICS CONCEPTS ---
# 1. Composite Systems:
#    If Qubit A lives in space H_A and Qubit B lives in space H_B,
#    the combined system lives in the product space H_A (x) H_B.
#
# 2. Dimensions Multiply:
#    If A has size 2 and B has size 2, the total space is 2 * 2 = 4.
#    (State vector has 4 components: |00>, |01>, |10>, |11>).
#
# 3. The Kron Function:
#    In Julia, the tensor product is calculated using `kron(A, B)`.
#    |0> (x) |0> = [1, 0, 0, 0]
#    |1> (x) |1> = [0, 0, 0, 1]
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Manually construct a 2-qubit state |0>|1> using the tensor product.
#
# Steps:
# 1. Define single qubit basis states |0> and |1>.
# 2. Compute the composite state |Psi> = |0> (x) |1> using `kron`.
# 3. Verify the vector length is 4.
# 4. Verify that the result matches the manual vector [0, 1, 0, 0].
#    (Indices correspond to binary: 00, 01, 10, 11).
# ------------------------

# --- SOLUTION ---

psi_0 = [1.0,0.0]
psi_1 = [0.0,1.0]
println("---Tensor Product---")
psi = kron(psi_0 , psi_1)
println("The combined State |01>:")
display(psi)
println("Domention of the comined space: $(length(psi))")
target = [0,1,0,0]
println("Does solution matches the expectation? ",psi == target)



## ------------------------------------------------------------------
println("\nPROBLEM 2: The CNOT Gate (Controlled-NOT)")
#
# --- PHYSICS CONCEPTS ---
# 1. Multi-Qubit Gates:
#    Single qubit gates are 2x2 matrices.
#    Two-qubit gates are 4x4 matrices (acting on vectors of length 4).
#
# 2. The CNOT Logic:
#    - Control Qubit (First one): "If this is |1>..."
#    - Target Qubit (Second one): "...flip the second bit (X-gate)."
#    - If Control is |0>, do nothing (Identity).
#
# 3. Mathematical Construction:
#    We can build the 4x4 matrix using Tensor Products:
#    CNOT = (|0><0| (x) I) + (|1><1| (x) X)
#    This reads: "If 0, do Identity. If 1, do X."
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct the CNOT matrix and verify it flips |10> to |11>.
#
# Steps:
# 1. Define basis states |0>, |1> and operators I, X.
# 2. Construct Projectors P0 = |0><0| and P1 = |1><1|.
# 3. Construct CNOT = (P0 (x) I) + (P1 (x) X).
# 4. Create the input state |psi_in> = |1> (x) |0> (State |10>).
# 5. Apply CNOT: |psi_out> = CNOT * |psi_in>.
# 6. Verify the result matches |1> (x) |1> (State |11>).
# ------------------------

# --- SOLUTION ---
psi_0 = [1,0]
psi_1 = [0,1]
I = [1 0;0 1]     #2x2 Identity matrix  
X = [0 1;1 0]     #2x2 Pauli (x) matrix
P0 = psi_0*psi_0'
P1 = psi_1*psi_1'
CNOT = kron(P0,I) + kron(P1,X)
display(CNOT)
psi_in = kron(psi_1,psi_0)  # State |10>
println("Input State |01>:")
display(psi_in)
psi_out = CNOT*psi_in
println("Output State: ")
display(psi_out)
target = kron(psi_1,psi_1)
println("matches |11>? ",psi_out == target)



## ------------------------------------------------------------------
println("\nPROBLEM 3: The Bell State (Entanglement)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Circuit:
#    To create the Bell State |Phi+>, we apply two gates to |00>:
#    Step A: Hadamard on Qubit 1 (creates superposition).
#            State becomes: (|0> + |1>) (x) |0>  =  |00> + |10>
#    Step B: CNOT (Control=Q1, Target=Q2).
#            - |00> stays |00> (Control is 0).
#            - |10> becomes |11> (Control is 1, so flips Target).
#            Final State: 1/sqrt(2) * (|00> + |11>).
#
# 2. Entanglement:
#    This state cannot be written as (State A) (x) (State B).
#    Measuring Qubit 1 instantly determines Qubit 2.
#    If Q1 is 0, Q2 is 0. If Q1 is 1, Q2 is 1. (Perfect Correlation).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Implement the H -> CNOT circuit to generate the Bell pair.
#
# Steps:
# 1. Define H (Hadamard) and I (Identity).
# 2. Construct the operator for Step A: Op1 = H (x) I.
#    (Apply H to first qubit, do nothing to second).
# 3. Use the CNOT matrix from Problem 2.
# 4. Start with |psi_init> = |00>.
# 5. Evolve: |psi_bell> = CNOT * (Op1 * |psi_init>).
# 6. Verify the vector is [0.707, 0, 0, 0.707].
# ------------------------

# --- SOLUTION ---

H = [1 1;1 -1]/sqrt(2)
I = [1 0;0 1]
Op1 = kron(H,I)
println("\n--- Generating Bell State ---")
ket_0 = [1.0, 0.0]
psi_00 = kron(ket_0, ket_0)
psi_step1 = Op1 * psi_00
println("State after Hadamard: $psi_step1")
P0 = [1 0; 0 0]; P1 = [0 0; 0 1]; X = [0 1; 1 0];
CNOT = kron(P0, I) + kron(P1, X)

psi_bell = CNOT * psi_step1

println("Final Bell State (|00> + |11>):")
display(psi_bell)
prob_00 = abs(psi_bell[1])^2  # Index 1 is 00
prob_01 = abs(psi_bell[2])^2  # Index 2 is 01
prob_10 = abs(psi_bell[3])^2  # Index 3 is 10
prob_11 = abs(psi_bell[4])^2  # Index 4 is 11

println("Prob(00): $prob_00")
println("Prob(11): $prob_11")
println("Prob(01 or 10): $(prob_01 + prob_10)")



## ------------------------------------------------------------------
println("\nPROBLEM 4: The CHSH Inequality Test")
#
# --- PHYSICS CONCEPTS ---
# 1. The Setup:
#    Alice has two possible measurements: A1 (Z-axis) and A2 (X-axis).
#    Bob has two possible measurements: B1 (Z+X) and B2 (Z-X).
#
# 2. The Correlation Function S:
#    We calculate the sum of expectation values:
#    S = <A1, B1> + <A1, B2> + <A2, B1> - <A2, B2>
#
# 3. The Limit:
#    - Classical Hidden Variables: |S| <= 2
#    - Quantum Entanglement:       |S| = 2 * sqrt(2) approx 2.82
#    Violating "2" proves the universe is not locally real.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the CHSH parameter S for the Bell State |Phi+> = (|00>+|11>)/sqrt(2).
#
# Steps:
# 1. Define Alice's Operators: A1=Z, A2=X.
# 2. Define Bob's Operators: B1=(Z+X)/sqrt(2), B2=(Z-X)/sqrt(2).
# 3. Construct the 4 system-wide observables using Kronecker products
#    (e.g., Obs1 = A1 (x) B1).
# 4. Calculate the expectation value for all 4 combinations on the Bell State.
# 5. Compute S and check if it > 2.
# ------------------------

# --- SOLUTION ---

Z = [1 0;0 -1]
X = [0 1;1 0]
psi_0 = [1,0]
psi_1 = [0,1]
A1 = Z
A2 = X
B1 = (Z+X)/sqrt(2)
B2 = (Z-X)/sqrt(2)

println("\n--- CHSH Inequality Test ---")
Obs_A1B1 = kron(A1,B1)
Obs_A1B2 = kron(A1,B2)
Obs_A2B1 = kron(A2,B1)
Obs_A2B2 = kron(A2,B2)
psi_bell = (kron(psi_0,psi_0)+kron(psi_1,psi_1))/sqrt(2)
E_11 = real(dot(psi_bell,Obs_A1B1*psi_bell))
E_12 = real(dot(psi_bell,Obs_A1B2*psi_bell))
E_21 = real(dot(psi_bell,Obs_A2B1*psi_bell))
E_22 = real(dot(psi_bell,Obs_A2B2*psi_bell))

println("Correlations:")
println("<A1 B1>: $E_11")
println("<A1 B2>: $E_12")
println("<A2 B1>: $E_21")
println("<A2 B2>: $E_22")
S_value = E_11 + E_12 + E_21 - E_22
println("---------------------------")
println("CHSH Parameter S: $S_value")
println("Classical Limit:  2.0")
println("Violation?        $(S_value > 2.0)")
println("Matches 2*sqrt(2)? $(isapprox(S_value, 2*sqrt(2)))")