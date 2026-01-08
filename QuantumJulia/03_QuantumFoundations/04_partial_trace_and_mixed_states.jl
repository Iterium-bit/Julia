using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: The Density Matrix (Pure vs. Mixed)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Definition:
#    - Pure State: rho = |psi><psi|
#    - Mixed State: rho = sum( p_i * |psi_i><psi_i| )
#      (where p_i is the classical probability of being in state i).
#
# 2. Purity (The Test):
#    How do you know if a matrix represents a single clean vector or a messy mix?
#    Calculate gamma = Tr(rho^2).
#    - If gamma == 1.0: Pure State.
#    - If gamma < 1.0:  Mixed State.
#    - If gamma = 1/d:  Maximally Mixed (Total Noise).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct a Pure State and a Mixed State, then calculate their Purity.
#
# Steps:
# 1. Define basis |0> and |1>.
# 2. Construct a Pure State rho_pure = |+><+|.
# 3. Construct a Mixed State rho_mixed = 50% |0> and 50% |1>.
#    (This represents total ignorance: it's either 0 or 1, but we don't know).
# 4. Calculate Tr(rho^2) for both.
# ------------------------

# --- SOLUTION ---

psi_0 = [1,0]
psi_1 = [0,1]
psi_plus = [1,1]/sqrt(2)
rho_pure = psi_plus*psi_plus'

println("Pure State Density Matrix:")
display(rho_pure)
rho_mixed = 0.5*psi_0*psi_0'+0.5*psi_1*psi_1'
println("\nMixed State Density Matrix:")
display(rho_mixed)
purity_pure = tr((rho_pure)^2)
purity_mixed = tr((rho_mixed)^2)
println("\nPurity of rho_pure:  $purity_pure (Expected: 1.0)")
println("Purity of rho_mixed: $purity_mixed (Expected: 0.5)")



## ------------------------------------------------------------------
println("\nPROBLEM 2: The Partial Trace (Tracing out B)")
#
# --- PHYSICS CONCEPTS ---
# 1. Reduced Density Matrix:
#    If we have a joint state rho_AB, the state of system A alone is:
#    rho_A = Tr_B( rho_AB )
#
# 2. Algorithm (for 2 Qubits, keeping the First):
#    If rho_AB is a 4x4 matrix, split it into 2x2 blocks:
#    [ M00  M01 ]
#    [ M10  M11 ]
#    Then rho_A = [ Tr(M00)  Tr(M01) ]
#                 [ Tr(M10)  Tr(M11) ]
#
# 3. Physical Meaning:
#    If the system is Entangled, the Partial Trace throws away information.
#    A "Pure" entangled state becomes a "Mixed" local state.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the reduced density matrix for Alice from a Bell State.
#
# Steps:
# 1. Create the Bell State |Phi+> = (|00> + |11>)/sqrt(2).
# 2. Construct the full Density Matrix rho_AB (4x4).
# 3. Implement the Partial Trace logic (Block Tracing).
# 4. Verify that Alice's state is the Maximally Mixed State (Identity/2).
#    (This proves Alice sees random noise, even though the total state is pure).
# ------------------------

# --- SOLUTION ---
psi_0 = [1,0]
psi_1 = [0,1]
phi_plus = normalize((kron(psi_0,psi_0)+kron(psi_1,psi_1)))
rho_AB = phi_plus*phi_plus'
display(rho_AB)
function partial_trace_B(rho_4x4)
    M00 = rho_4x4[1:2,1:2]
    M01 = rho_4x4[1:2,3:4]
    M10 = rho_4x4[3:4,1:2]
    M11 = rho_4x4[3:4,3:4]
    rho_A = [tr(M00) tr(M01);tr(M10) tr(M11)]
    return rho_A
end
rho_Alice = partial_trace_B(rho_AB)
println("\nAlice's Local State rho_A (Trace out Bob):")
display(rho_Alice)
purity_A = real(tr(rho_Alice^2))

println("Purity of Alice's State: $purity_A")
println("Is Alice's state totally random? $(rho_Alice ≈ I/2)")



## ------------------------------------------------------------------
println("\nPROBLEM 3: Proof of No-Signaling")
#
# --- PHYSICS CONCEPTS ---
# 1. The Paradox:
#    If Alice measures |0>, the state collapses. Bob's qubit INSTANTLY becomes |0>.
#    So Bob's state changed from "Random" to "Pure |0>", right?
#
# 2. The Catch (The Ensemble):
#    Bob doesn't know the outcome. He only knows probabilities.
#    Bob's reality is the weighted sum of all possible outcomes:
#    rho_Bob_final = p(0)*rho_Bob(0) + p(1)*rho_Bob(1)
#
# 3. No-Signaling Theorem:
#    rho_Bob_initial == rho_Bob_final
#    The act of measurement (averaging over outcomes) changes nothing for Bob.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Prove that Alice measuring Z does not change Bob's Density Matrix.
#
# Steps:
# 1. Start with Bell State |Phi+>.
# 2. Calculate Bob's initial state (Trace out Alice).
# 3. Simulate Alice measuring Z:
#    - Outcome 0: Project with P0 (x) I. Get collapsed state.
#    - Outcome 1: Project with P1 (x) I. Get collapsed state.
# 4. Construct Bob's "Average Reality":
#    rho_avg = Prob(0)*rho_B_if_0 + Prob(1)*rho_B_if_1.
# 5. Verify rho_avg == rho_initial.
# ------------------------

# --- SOLUTION ---
psi_0 = [1,0]
psi_1 = [0,1]
phi_plus = normalize((kron(psi_0,psi_0)+kron(psi_1,psi_1)))
rho_total = phi_plus*phi_plus'
display(rho_total)
function Partial_trace_A(rho)
    b00 = rho[1,1] + rho[3,3]   # Bob 00: Alice(0,0) + Alice(1,1) -> Indices 1,1 and 3,3
    b01 = rho[1,2] + rho[3,4]   # Bob 01: Alice(0,0) + Alice(1,1) for off-diagonal -> Indices 1,2 and 3,4
    b10 = rho[2,1] + rho[4,3]   # Bob 10: Conjugate of 01
    b11 = rho[2,2] + rho[4,4]   # Bob 11: Alice(0,0) + Alice(1,1) -> Indices 2,2 and 4,4
    return [b00 b01;b10 b11]
end
rho_B_initial = Partial_trace_A(rho_total)
println("Bob's Initial State:")
display(rho_B_initial)
P0_A = [1 0; 0 0]; P1_A = [0 0; 0 1]; I2 = [1 0; 0 1];   #    Projectors for Alice
Proj_0 = kron(P0_A, I2)
Proj_1 = kron(P1_A, I2)

#    Scenario A: Alice gets 0
prob_0 = real(tr(rho_total * Proj_0))
rho_after_0 = (Proj_0 * rho_total * Proj_0) / prob_0
rho_B_if_0 = Partial_trace_A(rho_after_0) # Bob's state if outcome is 0

#    Scenario B: Alice gets 1
prob_1 = real(tr(rho_total * Proj_1))
rho_after_1 = (Proj_1 * rho_total * Proj_1) / prob_1
rho_B_if_1 = Partial_trace_A(rho_after_1) # Bob's state if outcome is 1

rho_B_final = (prob_0 * rho_B_if_0) + (prob_1 * rho_B_if_1)

println("\nBob's State AFTER Alice Measures (Averaged):")
display(rho_B_final)
match = isapprox(rho_B_initial, rho_B_final)
println("\nDid Bob's state change? $(!match)")
println("No-Signaling Theorem Holds? $match")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Decoherence via Environment Interaction")
#
# --- PHYSICS CONCEPTS ---
# 1. The Setup:
#    - System (S): Starts in pure state |+> (Superposition).
#    - Environment (E): Starts in |0> (Cold/Empty).
#
# 2. The Interaction:
#    - They interact via a CNOT gate (System controls Environment).
#    - State becomes: (|0>_S|0>_E + |1>_S|1>_E) / sqrt(2).
#
# 3. The Loss (Tracing out E):
#    - We cannot control the environment, so we Trace out E.
#    - Result: The System S loses its off-diagonal terms (Coherence).
#    - It goes from Pure Superposition |+> to Random Mixture.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Show that interacting with an environment destroys quantum superposition.
#
# Steps:
# 1. Define System |+> and Environment |0>.
# 2. Form the joint state |Psi> = |+> (x) |0>.
# 3. Apply CNOT (System is Control, Env is Target).
# 4. Calculate Purity of System BEFORE and AFTER tracing out the Environment.
psi_plus = [1,1]/sqrt(2)
psi_env = [1,0]
psi_joint_initial = kron(psi_plus,psi_env)
rho_joint_initial = psi_joint_initial*psi_joint_initial'
rho_S_inital = partial_trace_B(rho_joint_initial)
Initial_purity = real(tr(rho_S_inital^2))
println("Initial System Purity: $Initial_purity")
CNOT = [1 0 0 0;0 1 0 0;0 0 0 1;0 0 1 0]
psi_joint_final = CNOT*psi_joint_initial
rho_joint_final = psi_joint_final*psi_joint_final'
rho_S_final = partial_trace_B(rho_joint_final)
Final_purity = real(tr(rho_S_final^2))
println("Final System Purity: $Final_purity")
println("Final System State:")
display(rho_S_final)



## ------------------------------------------------------------------
println("\nPROBLEM 5: Purification (Reverse Engineering)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Idea:
#    Any Mixed State rho_A can be written as the partial trace of a
#    Pure State |Psi_AB> from a larger Hilbert Space.
#    |Psi_AB> is called the "Purification" of rho_A.
#
# 2. Why it matters:
#    It implies that "Classical Randomness" might just be "Quantum Entanglement"
#    with something we can't see.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Given a mixed state rho = 0.5|0><0| + 0.5|1><1|, find a Pure State that creates it.
#
# Steps:
# 1. Define the Mixed State rho_mixed (Identity/2).
# 2. Construct the Bell State |Phi+>.
# 3. Trace out the second qubit.
# 4. Show that the result matches rho_mixed exactly.
# ------------------------

# --- SOLUTION ---
rho_target = [0.5 0.0; 0.0 0.5]

println("Target Mixed State:")
display(rho_target)
psi_hidden = normalize(kron([1.0, 0], [1.0, 0]) + kron([0, 1.0], [0, 1.0]))
rho_hidden = psi_hidden * psi_hidden'
rho_derived = partial_trace_B(rho_hidden)
println("Derived State from Hidden Universe:")
display(rho_derived)
println("Match? $(rho_derived ≈ rho_target)")