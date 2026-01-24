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
# PROBLEM 22: The Jaynes-Cummings Model (Atom-Light Interaction)
#
# --- PHYSICS CONCEPTS ---
# 1. The Setup:
#    A Two-Level Atom (Spin) interacts with a Cavity Mode (Harmonic Oscillator).
#    Basis = Atom (x) Field.
#
# 2. The Hamiltonian:
#    H = w_c * a'a + w_a * sz/2 + g * (a' * sm + a * sp)
#    - First two terms: Energies of Field and Atom.
#    - Last term (Interaction): 
#         a' * sm: Creates photon, Destroys atomic excitation (Atom -> Field).
#         a  * sp: Destroys photon, Creates atomic excitation (Field -> Atom).
#
# 3. Vacuum Rabi Oscillations:
#    If we start with (|Excited>, |0 photons>), the atom emits a photon 
#    into the cavity, becomes |Ground>, absorbs it back, and repeats.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a resonant system (w_c = w_a = 0) with coupling strength g = 1.0.
# Initial State: Atom Excited (|Up>), Cavity Empty (|0>).
# Verify that energy swaps perfectly between the Atom and the Cavity.
#
# Steps:
# 1. Define b_atom (Spin 1/2) and b_field (Fock N=5).
# 2. Define Composite Basis.
# 3. Construct Hamiltonian H_JC = g * (a_dag * sm + a * sp).
# 4. Evolve and measure <sigma_z> (Atom) and <n> (Field).
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 22: Jaynes-Cummings Model ---")
b_atom = SpinBasis(1//2)
b_field = FockBasis(5)
b_total = tensor(b_atom,b_field)
#    We use 'embed' to put operators in the correct space.
#    Index 1 = Atom, Index 2 = Field
sm = embed(b_total,1,sigmam(b_atom))       # sigmam(\tensor)I_field
sp = embed(b_total,1,sigmap(b_atom))
sz = embed(b_total,1,sigmaz(b_atom))
a = embed(b_total,2,destroy(b_field))      # I_atom(\tensor)a
at = embed(b_total,2,create(b_field))
n_op = embed(b_total,2,number(b_field))

g = 1.0
H_JC = g * (at * sm + a * sp)
psi_atom = spinup(b_atom)
psi_field = fockstate(b_field, 0)
psi_0 = tensor(psi_atom, psi_field)
println("Initial State: Atom Excited (+1), Cavity Empty (0)")
function measure_jc(t, psi)
    z_val = real(expect(sz, psi))
    n_val = real(expect(n_op, psi))
    return [z_val, n_val]
end
tspan = [0.0:0.1:4.0;]
tout, results = timeevolution.schroedinger(tspan, psi_0, H_JC; fout=measure_jc)
println("\nTime  | Atom <Z> | Field <n> | Swap Visualization")
for i in 1:length(tout)
    t = tout[i]
    z = results[i][1]
    n = results[i][2]
    # Visualization Logic:
    # If Atom is Up (z=1), print "ATOM".
    # If Field has Photon (n=1), print "PHOTON".
    # Since they swap, the text should move back and forth.
    bar_atom  = repeat("A", Int(round((z + 1) * 5))) # 0 to 10 A's
    bar_field = repeat("P", Int(round(n * 10)))      # 0 to 10 P's
    
    if i % 3 == 1
        s_t = rpad(t, 4)
        s_z = rpad(round(z, digits=2), 5)
        s_n = rpad(round(n, digits=2), 5)
        println("t=$s_t| Z=$s_z  | n=$s_n  | $bar_atom$bar_field")
    end
end

println("\nWhen Atom is -1 (Down), Field should be 1.0 (Photon).")
println(" Total Excitation is conserved.")
