using LinearAlgebra
using QuantumOptics


## ------------------------------------------------------------------
println("\nPROBLEM 11: The Harmonic Oscillator & Ladder Operators")
#
# --- PHYSICS CONCEPTS ---
# 1. The Fock Basis (|n>):
#    - Discrete energy levels: |0> (Ground), |1> (1 Photon), |2>...
#    - Since we cannot simulate infinity, we "truncate" at N_cutoff.
#
# 2. Ladder Operators:
#    - Annihilation (a):  Destroys a photon.  a|n>  = sqrt(n)|n-1>
#    - Creation (a^dag):  Creates a photon.   a'|n> = sqrt(n+1)|n+1>
#    - Number Op (n):     Counts photons.     n = a' * a
#
# 3. The Hamiltonian:
#    H = h_bar * omega * (n + 1/2)
#    (We usually set h_bar * omega = 1 for simplicity).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Define a Harmonic Oscillator with a cutoff of N=20. Verify the 
# fundamental commutation relation [a, a'] = 1 and the ground state energy.
#
# Steps:
# 1. Define FockBasis with N=20.
# 2. Create operators 'a', 'at' (dagger), and 'n'.
# 3. Calculate Commutator C = a*at - at*a.
# 4. Check expectation value <0|C|0>. It should be 1.0.
# 5. Define H and measure ground state energy.
# ------------------------

# --- SOLUTION ---
N_cutoff = 20              # Define Baiss (Truncated at N = 20)
b = FockBasis(N_cutoff)    # This creates 21 levels: 0 to 20.
a = destroy(b)             # Annihilation Operator of dimension 21.
a_dag = create(b)          # Creation Operator of dimension 21
n_operator = number(b)     # Number operator of dimension 21
comm = a*a_dag-a_dag*a     # Check Commutation: [a, a^dag] = 1
vac = fockstate(b,0)
comm_val = real(expect(comm,vac))
println("Commutation of <0|[a,a_dag]|0>: $comm_val")
println("Theory Matches? $(comm_val ≈ 1)")

H = n_operator + 0.5*identityoperator(b)    # Hamiltonian
E_0 = real(expect(H,vac))                   # Ground State Energy
println("Ground State Energy: $E_0")



## ------------------------------------------------------------------
println("\nPROBLEM 12: Coherent States (Laser Light)")
#
# --- PHYSICS CONCEPTS ---
# 1. Definition:
#    A Coherent State |alpha> is a specific superposition of Fock states.
#    It is defined as the eigenstate of the Annihilation operator:
#    a * |alpha> = alpha * |alpha>
#    (Note: 'a' is not Hermitian, so the eigenvalue 'alpha' can be Complex!)
#
# 2. Physical Meaning:
#    - Represents a laser field with amplitude |alpha|.
#    - The mean photon number is <n> = |alpha|^2.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a Coherent state with alpha = 1.5. Verify that it is indeed
# an eigenstate of 'a', and that its energy matches the theory.
#
# Steps:
# 1. Define alpha = 1.5 (Real number for simplicity, can be complex).
# 2. Create the state using 'coherentstate(basis, alpha)'.
# 3. Check the Eigenvalue Equation: Norm of (a|psi> - alpha|psi>) should be ~0.
# 4. Measure the average photon number <n>.
# ------------------------

# --- SOLUTION ---

alpha = 0.5                # Parameter
psi_coh = coherentstate(b,alpha)  # Coherent Bais  of Dimension 21
n_op = number(b)
# Verify Eigenstate Property: a|alpha> = alpha|alpha>
diff_vector = a*psi_coh - psi_coh*alpha
Error = LinearAlgebra.norm(diff_vector)
println("Eigenstate Error: $Error")

# Verify Mean Photon Number
#    Theory says <n> = |alpha|^2
expected_n = abs2(alpha)
measured_n = real(expect(n_op,psi_coh))
println("Theory <n>:   $expected_n")
println("Measured <n>: $measured_n")
println("Match?      $((measured_n ≈ expected_n))")




## ------------------------------------------------------------------
println("\nPROBLEM 13: Quadratures and Heisenberg Uncertainty")
#
# --- PHYSICS CONCEPTS ---
# 1. Quadratures (Position and Momentum):
#    In the Harmonic Oscillator, we define dimensionless position (x)
#    and momentum (p) using the ladder operators:
#    x = (a + a_dag) / sqrt(2)
#    p = i * (a_dag - a) / sqrt(2)
#
# 2. Heisenberg Uncertainty Principle:
#    It is impossible to know both x and p perfectly simultaneously.
#    The product of their uncertainties (standard deviations) has a lower limit:
#    Delta(x) * Delta(p) >= 0.5
#
# 3. State Behavior:
#    - Coherent States (|alpha>) and Vacuum (|0>): Are "Minimum Uncertainty States".
#      They hit the limit exactly: Delta(x)*Delta(p) = 0.5.
#    - Fock States (|n>): Are "Fuzzy". As 'n' increases, the uncertainty
#      grows significantly.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct the x and p operators. Calculate the uncertainty product 
# for a Coherent State, a Fock State, and the Vacuum to verify the limit.
#
# Steps:
# 1. Define x and p operators using 'a' and 'at'.
# 2. Create a helper function 'check_uncertainty' that:
#    - Calculates variance <O^2> - <O>^2 using 'variance()'.
#    - Computes standard deviation Delta = sqrt(variance).
#    - Returns the product Delta(x) * Delta(p).
# 3. Test on Coherent State (from Prob 12), Fock State |5>, and Vacuum.
# ------------------------

# --- SOLUTION ---
x_op = (a+a_dag)/sqrt(2)
p_op = im*(a_dag-a)/sqrt(2)
function Uncertainty_check(state,state_name)
    var_x = real(variance(x_op,state))            # variance can be used to calculate the variance
    var_p = real(variance(p_op,state))
    delta_x = sqrt(var_x)
    delta_p =  sqrt(var_p)
    product = delta_p*delta_x
    println("State: $state_name")
    println("Delta X: $delta_x")
    println("Delta P: $delta_p")
    println("Uncertainty product: $product")    
end
Uncertainty_check(psi_coh, "Coherent |alpha=1.5>")
psi_fock = fockstate(b, 5)
Uncertainty_check(psi_fock, "Fock State |n=5>")
Uncertainty_check(vac, "Vacuum |0>")