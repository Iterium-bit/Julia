using QuantumOptics
using LinearAlgebra

println("--- MODULE 3: TIME EVOLUTION (PROBLEMS 21-30) ---")

## ------------------------------------------------------------------
# PROBLEM 21: The Schrödinger Equation (Rabi Oscillations)
#
# --- PHYSICS CONCEPTS ---
# 1. The Schrödinger Equation:
#    Describes how a quantum state changes over time:
#    d/dt |psi(t)> = -i * H * |psi(t)>
#    (We set h_bar = 1 for simplicity).
#
# 2. Unitary Evolution:
#    If H is constant, the state evolves as: |psi(t)> = exp(-iHt) * |psi(0)>
#    This preserves the norm (probability stays 1).
#
# 3. Rabi Oscillations:
#    If we apply a field H = Omega * sigma_x to a qubit starting in |Up> (Z),
#    it will rotate around the X-axis. The probability of measuring "Up"
#    will oscillate like cos^2(Omega * t).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Evolve a qubit starting in state |Up> under the Hamiltonian H = (pi/2) * sigma_x.
# Measure <sigma_z> at multiple time points to visualize the oscillation 
# from +1 (Up) to -1 (Down) and back.
#
# Steps:
# 1. Define SpinBasis(1/2) and initial state |psi_0> = |Up>.
# 2. Define Hamiltonian H = (pi/2) * sigmax.
# 3. Define a time list 'tspan' from 0.0 to 4.0.
# 4. Use 'timeevolution.schroedinger(tspan, psi0, H, fout)'.
# 5. Print the <Z> value at each time step.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 21: Rabi Oscillations ---")

b = SpinBasis(1//2)
psi_0 = spinup(b)
println("Initial State: |Up>")
H = (pi/2) * sigmax(b)
tspan = [0.0:0.2:4.0;]
function measure_z(t, psi)
    return real(expect(sigmaz(b), psi))
end
tout, z_vals = timeevolution.schroedinger(tspan, psi_0, H; fout=measure_z)
println("\nTime  | <Z> Value | Visualization")
for i in 1:length(tout)
    t = tout[i]
    val = z_vals[i]
    bar_len = Int(round((val + 1) * 10)) 
    bar = repeat("#", bar_len)
    println("t=$(rpad(t, 4))| $(rpad(round(val, digits=3), 6))    | $bar")
end

println("\nAt t=1.0, <Z> should be -1.0 (Spin Down).")
println("At t=2.0, <Z> should be +1.0 (Spin Up).")

## ------------------------------------------------------------------
# PROBLEM 23: Pure Dephasing (Noise without Energy Loss)
#
# --- PHYSICS CONCEPTS ---
# 1. Dephasing (T2 Process):
#    - Spontaneous Emission (T1) flips |Up> to |Down> (Energy loss).
#    - Dephasing (T2) randomizes the phase phi in |psi> = |0> + e^iphi|1>.
#    - The "Coherence" (off-diagonal terms) vanishes, but "Population" stays.
#
# 2. The Operator:
#    J = sigma_z.
#    Since sigma_z commutes with the energy basis (|0>, |1>), it doesn't cause jumps.
#    It only scrambles the phase.
# ------------------------
println("\n--- Problem 23: Pure Dephasing ---")