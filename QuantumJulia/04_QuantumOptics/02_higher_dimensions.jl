using LinearAlgebra
using QuantumOptics

## ------------------------------------------------------------------
# PROBLEM 11: The Harmonic Oscillator (Fock Basis)
#
# --- PHYSICS CONCEPTS ---
# 1. The Fock Basis (|n>):
#    - Discrete energy levels: |0> (Ground), |1> (1 Photon), |2>...
#    - Since we cannot simulate infinity, we "truncate" at N_cutoff.
#
# 2. Ladder Operators:
#    - Annihilation (a):  Destroys a photon.  a|n>  = sqrt(n)|n-1>
#    - Creation (a_dag):  Creates a photon.   a'|n> = sqrt(n+1)|n+1>
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
# fundamental commutation relation [a, a_dag] = 1 and the ground state energy.
#
# Steps:
# 1. Define FockBasis with N=20.
# 2. Create operators 'a', 'at' (dagger), and 'n'.
# 3. Calculate Commutator C = a*at - at*a.
# 4. Check expectation value <0|C|0>. It should be 1.0.
# 5. Define H and measure ground state energy.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 11: Harmonic Oscillator Setup ---")
N = 20
b = FockBasis(N)
vac = fockstate(b,0)
a = destroy(b)
a_dag = create(b)
n = number(b)
Comm = a*a_dag - a_dag*a_dag
expect_Comm = real(expect(Comm,vac))
println("The expectation value of <0|[a,a_dag]0|>: $expect_Comm")

H = a+0.5*identityoperator(b)
expect_E = real(expect(H,vac))
println("The expected energy in the vaccum state: $expect_E")



## ------------------------------------------------------------------
# PROBLEM 12: Coherent States (Laser Light)
#
# --- PHYSICS CONCEPTS ---
# 1. Definition:
#    A Coherent State |alpha> is a specific superposition of Fock states.
#    It is defined as the eigenstate of the Annihilation operator:
#    a * |alpha> = alpha * |alpha>
#    (Note: 'a' is not Hermitian, so the eigenvalue 'alpha' can be Complex!)
#
# 2. Physical Meaning:
#    - Describes a laser beam with stable amplitude and phase.
#    - The mean photon number is <n> = |alpha|^2.
#    - It is the "most classical" quantum state because it minimizes uncertainty.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a Coherent state with alpha = 1.5. Verify that it is indeed
# an eigenstate of 'a', and that its energy matches the theory.
#
# Steps:
# 1. Define alpha = 1.5.
# 2. Create the state using 'coherentstate(basis, alpha)'.
# 3. Check the Eigenvalue Equation: Norm of (a|psi> - alpha|psi>) should be ~0.
# 4. Measure the average photon number <n> and compare to |alpha|^2.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 12: Coherent States ---")

alpha = 1.5
psi_coh = coherentstate(b,alpha)
diff_vector = a*psi_coh -alpha*psi_coh           #a|alpha> = alpha|alpha>
error = norm(diff_vector)
println("Eigenstate Error: $(error)")
expect_n = abs2(alpha)
measured_n = real(expect(n,psi_coh))
println("Theory <n>: $expect_n")
println("Measured <n>: $measured_n")
println("Th differece between the Theory and Measured <n>: $(expect_n-measured_n)")



## ------------------------------------------------------------------
# PROBLEM 13: Quadratures and Heisenberg Uncertainty
#
# --- PHYSICS CONCEPTS ---
# 1. Quadratures (Position and Momentum):
#    We define dimensionless position (x) and momentum (p):
#    x = (a + a_dag) / sqrt(2)
#    p = i * (a_dag - a) / sqrt(2)
#
# 2. Heisenberg Uncertainty Principle:
#    It is impossible to know both x and p perfectly.
#    Delta(x) * Delta(p) >= 0.5.
#
# 3. State Behavior:
#    - Coherent States (|alpha>) & Vacuum (|0>): Are "Minimum Uncertainty".
#      They hit the limit exactly: Delta(x)*Delta(p) = 0.5.
#    - Fock States (|n>): Are "Fuzzy". Uncertainty grows with n.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct x and p operators. Calculate the uncertainty product 
# for a Coherent State, a Fock State, and the Vacuum.
#
# Steps:
# 1. Define x and p operators.
# 2. Create a helper function 'check_uncertainty' to calculate
#    Delta = sqrt(variance).
# 3. Test on Coherent State, Fock State |5>, and Vacuum.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 13: Heisenberg Uncertainty Check ---")

x = (a+a_dag)/sqrt(2)
p = im*(a_dag-a)/sqrt(2)
function check_uncertainty(state,state_name)
    var_x = real(variance(x,state))
    var_p = real(variance(p,state))
    dx = sqrt(var_x)
    dp = sqrt(var_p)
    product = dx*dp
    println("State: $state_name")
    println("Uncertainty in X: $dx")
    println("Uncertainty in P: $dp")
    println("Uncertainty product: $product")
end
check_uncertainty(psi_coh,"Coheret |alpha = 1.5>")
psi_fock = fockstate(b,5)
check_uncertainty(psi_fock,"Fock State |n=5>")



## ------------------------------------------------------------------
# PROBLEM 14: Squeezed States (Quantum Noise Reduction)
#
# --- PHYSICS CONCEPTS ---
# 1. Standard Quantum Limit (SQL):
#    For the Vacuum state |0>, the uncertainty in Position (x) and 
#    Momentum (p) is equal: Delta(x) = Delta(p) = 0.707.
#    The product is minimal: Delta(x) * Delta(p) = 0.5.
#
# 2. Squeezing:
#    We can "squeeze" the noise in x below the vacuum limit (Delta(x) < 0.707)
#    if we allow the noise in p to increase (Delta(p) > 0.707).
#    The area of uncertainty is conserved (Product ~ 0.5).
#
# 3. The Squeezing Operator:
#    S(r) = exp( 0.5 * r * (a^2 - (a_dag)^2) )
#    - 'r' is the squeezing parameter.
#    - We construct this manually to ensure stability.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct the Squeezing Operator manually. Create a Squeezed Vacuum state 
# with r=0.5. Verify that the uncertainty in x drops below the vacuum level.
#
# Steps:
# 1. Define r = 0.5.
# 2. Construct S manually: S = exp(dense(0.5 * r * (a^2 - at^2))).
# 3. Apply S to the vacuum to create |psi_sq>.
# 4. Measure Delta(x) and Delta(p). Verify Delta(x) < 0.707.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 14: Squeezed States ---")
r = 0.5
S = exp(dense(0.5*r*(a^2-a_dag^2)))
vac = fockstate(b,0)
psi_squeezed = S*vac
println("The Squeezed vaccum state is:")
display(psi_squeezed)
check_uncertainty(psi_squeezed,"Squeezed vaccum State |r=0.5>")
println("Is the uncertainty in x is less than 0.707? ",sqrt(real(variance(x,psi_squeezed)))<0.707)



## ------------------------------------------------------------------
# PROBLEM 15: Schrödinger's Cat (Interference & Non-Orthogonality)
#
# --- PHYSICS CONCEPTS ---
# 1. Macroscopic Superposition:
#    A "Cat State" is a superposition of two macroscopic coherent states
#    with opposite phases: |Cat> = N * (|alpha> + |-alpha>).
#
# 2. Non-Orthogonality:
#    Unlike qubit basis states, Coherent states are NOT orthogonal.
#    The overlap is: < -alpha | alpha > = exp(-2 * |alpha|^2).
#    This overlap is the mathematical origin of the "quantumness" here.
#
# 3. Quantum Interference (Parity):
#    - "Even Cat" (+): The odd photon numbers cancel out perfectly due 
#       to destructive interference. It contains ONLY even photons (|0>, |2>, |4>...).
#    - "Odd Cat" (-): Contains ONLY odd photons (|1>, |3>, |5>...).
#    - This parity signature proves it is a Quantum Superposition, not a Classical Mixture.
#
# 4. Normalization (N):
#    Due to the overlap, N is not just 1/sqrt(2).
#    N = 1 / sqrt(2 * (1 + exp(-2*|alpha|^2)))
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct an "Even Cat State" with alpha = 2.0. Rigorously calculate the 
# component overlap to verify non-orthogonality. Prove that quantum interference 
# explicitly eliminates the odd photon numbers.
#
# Steps:
# 1. Define alpha = 2.0.
# 2. Calculate the theoretical overlap exp(-2*|alpha|^2) and compare with code.
# 3. Construct |psi_cat> = normalize(|alpha> + |-alpha>).
# 4. Measure Probability of n=1 (Odd) and n=3 (Odd). Must be exactly 0.
# 5. Measure Expectation of Momentum <p>. Must be 0 (Stationary average).
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 15: Schrödinger's Cat (Rigorous) ---")

alpha = 2.0
psi_plus = coherentstate(b,alpha)
psi_minus = coherentstate(b,-alpha)
psi_cat = normalize(psi_plus + psi_minus)
overlap_theory = exp(-2*abs2(alpha))             # Theory: < -alpha | alpha > = exp(-2 * |alpha|^2)
overlap_cal = real(abs(dagger(psi_minus)*psi_plus))     
error = overlap_theory - overlap_cal
println("Component Overlap(Non- Orthogonality):")
println("From Theory: $overlap_theory")                                  # <psi_minus|psi_plus> != 0
println("The differece between the Calculated and Theory: $error")
psi_1 = fockstate(b,1)
psi_2 = fockstate(b,3)
prob_1 = real(abs2(dagger(psi_1)*psi_cat))
prob_2 = real(abs2(dagger(psi_2)*psi_cat))
if (prob_1<1e-10) && (prob_2<1e-10)
    println("Destructive interefer eliminated odd photons.")
else
    println("Odd photons detected")
end
p_exp = real(expect(p,psi_cat))
println("Average Momentum <p>: $p_exp")



## ------------------------------------------------------------------
# PROBLEM 16: Thermal States (Density Matrices & Purity)
#
# --- PHYSICS CONCEPTS ---
# 1. Pure vs. Mixed:
#    - Coherent State: Pure (Purity = 1.0).
#    - Thermal State: Mixed (Purity < 1.0).
#
# 2. Temperature vs Photon Number:
#    The 'thermalstate' function expects Temperature (T).
#    To simulate a specific mean photon number (n_bar), we convert:
#    T = 1 / ln(1 + 1/n_bar)
#
# 3. Purity:
#    Gamma = Tr(rho^2).
#    For Thermal state with n_bar, Gamma = 1 / (2*n_bar + 1).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a Thermal State with <n>=1. Compare Purity with a Coherent State.
#
# Steps:
# 1. Define target n_bar = 1.0.
# 2. Calculate required Temperature T.
# 3. Create Coherent State |alpha> (where |alpha|^2 = n_bar).
# 4. Create Thermal State using 'thermalstate(H, T)'.
# 5. Measure and compare Purity.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 16: Thermal States ---")

n_bar = 1.0
T_eff = 1.0 / log(1.0 + (1.0 / n_bar))   # Bose#    Bose-Einstein Inversion: T = 1 / ln(1 + 1/n)-Einstein Inversion: T = 1 / ln(1 + 1/n)
psi_coh = coherentstate(b,sqrt(n_bar))   # We choose alpha such that |alpha|^2 = n_bar = 1
rho_coh = dm(psi_coh)
rho_ther = thermalstate(n,T_eff)
purity_coh = real(tr(rho_coh*rho_coh))
println("Purity of Coherent State: $purity_coh")
purity_therm = real(tr(rho_ther*rho_ther))
println("Purity of Thermal State:  $purity_therm")
theory_purity = 1.0/(2*n_bar +1)                ## For a thermal state, Purity = 1 / (2*n_bar + 1)
println("Theoretical Thermal Purity: $theory_purity")
if abs(purity_therm - theory_purity) < 1e-5
    println("The Thermal state is correctly 'mixed'.")
else
    println("Purity calculation mismatch.")
end



## ------------------------------------------------------------------
# PROBLEM 17: Von Neumann Entropy
#
# --- PHYSICS CONCEPTS ---
# 1. Entropy (S):
#    Measures the lack of information or the amount of "disorder".
#    S = -Tr(rho * ln(rho))
#    (We usually use log base e, or sometimes base 2 for bits).
#
# 2. Pure States (Laser):
#    We know everything about the state. 
#    S = 0.
#
# 3. Mixed States (Thermal):
#    We have incomplete knowledge (probability distribution).
#    S > 0.
#    In fact, for a fixed energy, the Thermal State has the MAXIMUM possible entropy.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the Von Neumann Entropy for the Coherent and Thermal states 
# created in Problem 16. Verify that the Laser has zero entropy while 
# the Thermal state has positive entropy.
#
# Steps:
# 1. Reuse 'rho_coh' and 'rho_therm' from Problem 16.
# 2. Calculate S using 'entropy_vn(rho)'.
#    (Note: If entropy_vn is missing, we calculate -Tr(rho*log(rho)) manually).
# 3. Compare the values.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 17: Von Neumann Entropy ---")

S_coh = real(entropy_vn(rho_coh))    # QuantumOptics provides 'entropy_vn' (Von Neumann).
S_therm = real(entropy_vn(rho_ther))
println("Entropy of Thermal State:  $S_therm")
S_theory = (n_bar+1)*log(n_bar+1)-n_bar*log(n_bar) # Theory: S = (n+1)ln(n+1) - n*ln(n)
println("Theoretical Thermal Entropy: $S_theory")
if abs(S_therm - S_theory) < 1e-5
    println("Entropy matches Bose-Einstein theory.")
else
    println("Entropy calculation mismatch.")
end



## ------------------------------------------------------------------
# PROBLEM 18: Quantum Fidelity (State Similarity)
#
# --- PHYSICS CONCEPTS ---
# 1. Fidelity (F):
#    A measure of "closeness" between two quantum states.
#    - F = 1.0: The states are identical.
#    - F = 0.0: The states are perfectly distinguishable (orthogonal).
#
# 2. Formula:
#    If one state is Pure (|psi>) and the other is Mixed (rho),
#    the math simplifies to:
#    F = <psi| rho |psi>
#    (This represents the overlap probability).
#
# 3. Application:
#    As a Thermal State gets hotter (higher <n>), it spreads out in phase space.
#    Its overlap (Fidelity) with the cold Vacuum State |0> should drop.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the Fidelity between the Vacuum State |0> and three different 
# Thermal States with increasing temperature (<n> = 0.1, 1.0, 5.0).
# Verify that Fidelity drops as Temperature rises.
#
# Steps:
# 1. Define Vacuum State |0>.
# 2. Define list of target mean photon numbers [0.1, 1.0, 5.0].
# 3. For each <n>:
#    a. Calculate T (using the inverse Bose-Einstein formula).
#    b. Create Thermal State rho_therm.
#    c. Calculate Fidelity F = real(expect(rho_therm, vac)).
# 4. Print results.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 18: Quantum Fidelity Check ---")