using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: Forward Euler Integration (Stability Check)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Schrödinger Equation:
#    The fundamental equation of motion for a quantum state |psi(t)> is:
#    d/dt |psi> = -i * H * |psi>
#    where H is the Hamiltonian (Energy operator).
#
# 2. Unitarity (Conservation of Probability):
#    A closed quantum system must preserve total probability.
#    Mathematically, the norm <psi|psi> must remain 1.0 at all times.
#    The operator evolving the state (U) must be Unitary (U'U = I).
#
# 3. The Numerical Instability of Euler:
#    The "Forward Euler" method approximates the derivative as a straight line:
#    |psi(t+dt)> ≈ |psi(t)> + dt * (-iH |psi(t)>)
#                = (1 - iH*dt) * |psi(t)>
#    
#    The "amplification factor" is the term (1 - iH*dt).
#    Its magnitude is sqrt(1^2 + (H*dt)^2), which is always > 1.
#    Therefore, this method continuously pumps artificial energy into the system,
#    causing the probability to explode (violate Unitarity).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Attempt to solve the time evolution of a single qubit using the Forward Euler 
# method and mathematically demonstrate why it fails.
#
# Steps:
# 1. Define the Hamiltonian H as the Pauli-Z matrix (qubit in a magnetic field).
# 2. Define the initial state |psi> as |+> = 1/sqrt(2) (|0> + |1>).
# 3. Set a time step dt = 0.01 and evolve the system for 100 steps.
#    Use the update rule: psi_new = psi - (i * dt * H * psi).
# 4. Compute the final norm of the state.
# 5. Verify that the norm has grown larger than 1.0, proving instability.
# ------------------------

# --- SOLUTION ---

H = [1 0;0 -1]                       # Pauli Z Hamiltonian
state = [1,0]+[0,1]                  # initial State |+> superposition
psi = state/norm(state)
dt = 0.01                            # Time Steps
steps = 100                          # Number of iterations

println("--- Euler Method Stability Check ---")
println("Initial Norm: $(norm(psi))")

for t in 1:steps
    global psi = psi-(im*dt)*(H*psi)
end
final_norm = norm(psi)
println(final_norm)

println("Final Norm (100 steps): $final_norm")
println("Error: The norm grew by $((final_norm - 1.0)*100)%")
println("Conclusion: Euler's method violates Unitarity.")



## ------------------------------------------------------------------
println("\nPROBLEM 2: The Exact Solver (Matrix Exponential)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Exact Solution:
#    For a time-independent Hamiltonian H, the Schrödinger equation
#    dy/dt = -iHy has the analytical solution:
#    |psi(t)> = exp(-i * H * t) * |psi(0)>
#
# 2. The Propagator U(t):
#    The operator U(t) = exp(-iHt) is called the Propagator.
#    It is a Unitary matrix (U'U = I), which guarantees that the
#    total probability is conserved (Norm = 1.0) forever.
#
# 3. Matrix Exponentiation vs. Element-wise:
#    In Linear Algebra, exp(A) is NOT calculated by exponentiating
#    each number in the grid. It is the infinite Taylor series:
#    exp(A) = I + A + A^2/2! + A^3/3! + ...
#    Julia's 'exp()' function computes this series efficiently.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Solve the single-qubit evolution using the exact matrix exponential
# and prove that it preserves probability (Unitarity).
#
# Steps:
# 1. Define the Hamiltonian H (Pauli Z) and initial state |+>.
# 2. Define the total evolution time T = 10.0.
# 3. Compute the unitary propagator U = exp(-im * H * T).
# 4. Apply the propagator: psi_final = U * psi_initial.
# 5. Verify that the final norm is exactly 1.0.
# ------------------------

# --- SOLUTION ---

H = [1 0;0 -1]
psi_initial = [1,1]/sqrt(2)
T = 10.0
U = exp(-im*H*T)

# We jump straight to the final time T in one matrix multiplication.
psi_final = U*psi_initial
final_norm = norm(psi_final)
println("Final Norm: $final_norm")
println("Is Unitarity Preserved? ",final_norm ≈ 1)




## ------------------------------------------------------------------
println("\nPROBLEM 3: Runge-Kutta 4th Order (RK4)")
#
# --- PHYSICS CONCEPTS ---
# 1. Taylor Expansion of Evolution:
#    The exact propagator is U = exp(-iHt) = I - iHt - (H^2 t^2)/2 + ...
#    - Euler Method captures only the first term (Linear). Error ~ dt^2.
#    - RK4 captures the first FOUR terms (Quartic). Error ~ dt^5.
#
# 2. Why RK4?
#    Calculating the full Matrix Exponential is impossible for large systems
#    (e.g., N > 10,000). RK4 only requires matrix-vector multiplication (H*psi),
#    which is fast and cheap, while being accurate enough for most simulations.
#
# 3. The Algorithm:
#    Instead of one step, we take a weighted average of 4 slopes:
#    k1 = Slope at start
#    k2 = Slope at midpoint (using k1)
#    k3 = Slope at midpoint (using k2)
#    k4 = Slope at end (using k3)
#    psi_new = psi + (dt/6) * (k1 + 2k2 + 2k3 + k4)
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Solve the qubit evolution using RK4 and compare stability with Euler.
#
# Steps:
# 1. Define the derivative function: f(psi) = -i * H * psi.
# 2. Implement the RK4 update step manually.
# 3. Evolve for 100 steps with dt = 0.01.
# 4. Check the norm. It will be MUCH closer to 1.0 than Euler.
# ------------------------

# --- SOLUTION ---

f(y) = -im*H*y
psi_RK4 = [1,1]/sqrt(2)
dt = 0.01
steps = 100

println("\n--- Runge-Kutta (RK4) Method ---")
for t in 1:steps
    k1 = f(psi_RK4)
    k2 = f(psi_RK4+(dt/2)*k1)
    k3 = f(psi_RK4+(dt/2)*k2)
    k4 = f(psi_RK4+dt*k3)
    # The 'global' keyword is needed to update the variable in the loop
    global psi_RK4 = psi_RK4+(dt/6)*(k1+2*k2+2*k3+k4)
end
norm_RK4 = norm(psi_RK4)
err_RK4 = abs(norm_RK4-1.0)
println("Final Norm: $norm_RK4")
println("Error in Normalisation: $err_RK4")
println("Improvement over Euler: Euler was ~0.005 error, RK4 is ~1e-13!")



## ------------------------------------------------------------------
println("\nPROBLEM 4: Crank-Nicolson Method (Implicit Unitary Solver)")
# --- PHYSICS CONCEPTS ---
# 1. Implicit Methods vs Explicit Methods:
#    - Euler/RK4 are "Explicit": You calculate the next state directly from the current one.
#    - Crank-Nicolson is "Implicit": It calculates the slope using an average of 
#      the current time AND the future time.
#
# 2. The Cayley Transform (Preserving Probability):
#    We want an operator U such that psi(t+dt) = U * psi(t).
#    Crank-Nicolson approximates the exponential exp(-iH*dt) as:
#    
#    U ≈ (I - i*H*dt/2) * (I + i*H*dt/2)^-1
#
#    This looks complex, but it has a magical property: The numerator is the 
#    complex conjugate of the denominator. Therefore, the magnitude is EXACTLY 1.
#    This method NEVER loses or gains probability. It is perfectly stable.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Solve the same Rabi Oscillation (Pi-pulse) using the Crank-Nicolson method.
#
# Steps:
# 1. Define the Hamiltonian H (same as before).
# 2. Construct the "Forward" matrix A = (I - i*H*dt/2).
# 3. Construct the "Backward" matrix B = (I + i*H*dt/2).
# 4. Instead of multiplying, we solve the linear system: B * psi_new = A * psi_old.
#    (This is equivalent to psi_new = inv(B) * A * psi_old).
# 5. Evolve and verify that the probability remains exactly 1.0 (machine precision).
# ------------------------

# --- SOLUTION ---
Omega = 1.0
psi0 = [1.0,0.0]
display(psi0)
T = pi/Omega
steps = 50
dt = T/steps
H_rabi = [0.0 Omega/2.0;Omega/2.0 0.0]
println("\n--- Crank-Nicolson Method ---")
I2 = Matrix{ComplexF64}(I,2,2)
Matrix_Forward = I2-(im*dt/2)*H_rabi
Matrix_Backward = I2+(im*dt/2)*H_rabi
for t in 1:steps
    rhs = Matrix_Forward*psi0
    global psi0 = Matrix_Backward\rhs
end

prob_0 = abs(psi0[1])^2
prob_1 = abs(psi0[2])^2
norm_cn = norm(psi0)
println("Final State: $psi0")
println("Probability |1>: $prob_1")
println("Norm: $norm_cn (Strictly Preserved)")