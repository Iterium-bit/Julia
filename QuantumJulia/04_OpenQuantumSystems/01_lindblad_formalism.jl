using QuantumOptics

## ------------------------------------------------------------------
println("\nPROBLEM 1: Unitary Time Evolution")
#
# --- PHYSICS CONCEPTS ---
# 1. The Basis:
#    In QuantumOptics.jl, you must define the "Space" your particles live in.
#    We use SpinBasis(1//2) for a qubit.
#
# 2. Operators:
#    Instead of typing [0 1; 1 0], we use built-in functions:
#    sigmax(basis), sigmaz(basis), etc.
#
# 3. The Solver:
#    timeevolution.schroedinger(tspan, psi0, H)
#    This function automatically solves the differential equation
#    d|psi>/dt = -i H |psi> using high-precision adaptive ODE solvers.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a qubit rotating under H = Omega * Sigma_X using the library solver.
#
# Steps:
# 1. Define a Spin Basis.
# 2. Define state |0> (spin down) and Hamiltonian H.
# 3. Use `timeevolution.schroedinger` to solve for 0 to 2pi.
# 4. Extract probabilities and check results.
# ------------------------

# --- SOLUTION ---