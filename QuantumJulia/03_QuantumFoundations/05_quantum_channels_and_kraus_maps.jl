using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: The Bit Flip Channel (Kraus Representation)")
#
# --- PHYSICS CONCEPTS ---
# 1. The "Sum of Histories":
#    We don't know if the error happened.
#    So, Final State = (State if No Error) + (State if Error).
#
# 2. Kraus Operators define the branches:
#    - Branch 0 (Survival): K0 = sqrt(1-p) * Identity
#    - Branch 1 (Error):    K1 = sqrt(p)   * Pauli_X
#
# 3. Why add them?
#    The Density Matrix represents our "average" knowledge.
#    It is the weighted sum of all possible realities.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Apply a Bit Flip Channel (p=0.3) to a pure state |0> and see it become mixed.
#
# Steps:
# 1. Define p = 0.3.
# 2. Construct K0 (Keep state) and K1 (Flip state).
# 3. Verify that K0'K0 + K1'K1 = Identity (Probability conservation).
# 4. Apply the map: rho_out = K0*rho*K0' + K1*rho*K1'.
# ------------------------

# --- SOLUTION ---
p = 0.3
psi_0 =[1,0]
I2 = [1 0;0 1]
x = [0 1;1 0]
println("Probability of error: $p")
K0 = sqrt(1-p)*I2
K1 = sqrt(p)*x
check = K0'*K0 + K1'*K1
println("Do probabilities sum to 1? $(check ≈ I2)")
rho_in = psi_0*psi_0' # Pure |0><0|
outcome_survival = K0*rho_in*K0
outcome_error = K1*rho_in*K1
rho_out = outcome_survival+outcome_error
println("\nInput State (Pure):")
display(rho_in)
println("Output State (Mixed):")
display(rho_out)
println("\nInterpretation:")
println("Prob of |0> (Top Left): $(real(rho_out[1,1]))  (Should be $(1-p))")
println("Prob of |1> (Bot Right): $(real(rho_out[2,2]))  (Should be $p)")



## ------------------------------------------------------------------
println("\nPROBLEM 2: The Depolarizing Channel")
#
# --- PHYSICS CONCEPTS ---
# 1. The Scenario:
#    The qubit interacts with a chaotic environment.
#    With probability p, an error occurs.
#    Since the environment is isotropic (no preferred direction),
#    the errors X, Y, and Z are equally likely (p/3 each).
#
# 2. Kraus Operators (The Pauli Twirl):
#    To satisfy Completeness (Sum K'K = I), we define:
#    - K0 = sqrt(1 - p) * I    (History: No Error)
#    - K1 = sqrt(p/3) * X      (History: X Error)
#    - K2 = sqrt(p/3) * Y      (History: Y Error)
#    - K3 = sqrt(p/3) * Z      (History: Z Error)
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Apply Depolarizing noise to the state |+> and watch the coherence vanish.
#
# Steps:
# 1. Define Pauli matrices X, Y, Z.
# 2. Define error probability p = 0.5 (50% chance of error).
# 3. Construct the 4 Kraus Operators.
# 4. Verify completeness.
# 5. Apply to |+> state and calculate the remaining "Coherence" (off-diagonal).
# ------------------------

# --- SOLUTION ---
X = [0 1;1 0]
Y = [0 im;-im 0]
Z = [1 0;0 -1]
I = [1 0;0 1]
p_depol = 0.5 # %0% Errir chance
K0_depol = sqrt(1-p_depol)*I
error_apm = sqrt(p_depol/3)
K1_depol = error_apm*x
K2_depol = error_apm*Y
K3_depol = error_apm*Z
Check = K0_depol*K0_depol'+ K1_depol*K1_depol' + K2_depol*K2_depol' + K3_depol*K3_depol'
println("\nCompleteness Check: ",Check ≈I)
rho_plus = [0.5 0.5; 0.5 0.5]

println("\nInput State |+> (Off-diagonal is 0.5):")
display(rho_plus)
rho_out_depol = (K0_depol * rho_plus * K0_depol') + 
                (K1_depol * rho_plus * K1_depol') + 
                (K2_depol * rho_plus * K2_depol') + 
                (K3_depol * rho_plus * K3_depol')
println("\nOutput State (p=$p_depol):")
display(rho_out_depol)
radius_initial = 2 * abs(rho_plus[1,2])
radius_final   = 2 * abs(rho_out_depol[1,2])
println("Radius of Bloch Vector: $radius_initial -> $radius_final")