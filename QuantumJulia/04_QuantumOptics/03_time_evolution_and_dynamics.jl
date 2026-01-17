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
# PROBLEM 22: Spontaneous Emission (The Master Equation)
#
# --- PHYSICS CONCEPTS ---
# 1. Open Quantum Systems:
#    When a system interacts with an environment, it loses energy/information.
#    We cannot use the Schrödinger Equation anymore. We use the Lindblad Master Equation:
#    d/dt rho = -i[H, rho] + sum( gamma * (L*rho*L' - 0.5*{L'*L, rho}) )
#
# 2. Collapse Operators (Jump Operators):
#    'L' describes how the system interacts with the environment.
#    For spontaneous emission, L = sigma_minus (the lowering operator).
#    It forces the atom from |Up> to |Down>.
#
# 3. Decay Rate (Gamma):
#    The probability of finding the atom excited decays exponentially:
#    P_excited(t) = exp(-gamma * t).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate the decay of a qubit initially in |Up>. Assume H = 0 (no driving force),
# so the only dynamics are pure decay.
#
# Steps:
# 1. Define SpinBasis and state |Up>.
# 2. Define H = 0 (Zero operator).
# 3. Define the Collapse Operator J = [sigma_minus].
# 4. Define decay rate gamma = 1.0.
# 5. Use 'timeevolution.master(tspan, psi0, H, J; rates=gamma, fout=measure_z)'.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 22: Spontaneous Emission (Decay) ---")
b = SpinBasis(1//2)
psi_0 = spinup(b)
H = 0*sigmaz(b)
J = [sigmam(b)] 
gamma = [1.0]
tspan = [0.0:0.2:4.0;]
tout, z_vals = timeevolution.master(tspan, psi_0, H, J; rates=gamma, fout=measure_z)
println(tout,z_vals)
println("\nTime  | <Z> Value | Decay Visualization")
for i in 1:length(tspan)
    t = tout[i]
    val = z_vals[i]
    bar_len = Int(round((val +1)*10))
    bar = repeat("#",bar_len)
    if i % 5 == 1
        println("t=$(rpad(t, 4))| $(rpad(round(val, digits=3), 6))    | $bar")
    end
end
println("\nThe atom started Up (+1.0) and decayed to Ground (-1.0).")



## ------------------------------------------------------------------
# PROBLEM 23: Damped Rabi Oscillations (Competition)
#
# --- PHYSICS CONCEPTS ---
# 1. Driving vs. Dissipation:
#    - Hamiltonian H = (pi/2) * sigma_x drives the qubit (Rabi Oscillation).
#    - Jump Operator J = sigma_minus decays the qubit (Spontaneous Emission).
#
# 2. Dynamics:
#    Initially, the driving dominates, and we see oscillations.
#    Over time, the decay removes energy (decoherence).
#    Eventually, the system reaches a "Steady State" (equilibrium) where
#    Driving Rate == Decay Rate.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a qubit starting in |Down> (-1). Drive it with H = (pi/2)*sigma_x.
# Simultaneously apply decay J = sigma_minus with rate 0.5.
#
# Steps:
# 1. Define Basis and state |Down>.
# 2. Define H = (pi/2) * sigmax (Driving).
# 3. Define J = [sigmam] and rates = [0.5] (Decay).
# 4. Solve and visualize.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 23: Damped Rabi Oscillations ---")
b = SpinBasis(1//2)
tspan = [0.0:0.2:4.0;]
psi_0 = spindown(b)
H = (pi/2)*sigmax(b)
J = [sigmam(b)]
gamma = [0.5]
function measure_z(t, psi)
    return real(expect(sigmaz(b), psi))
end
tout,z_vals = timeevolution.master(tspan,psi_0,H,J;rates = gamma, fout = measure_z)
println("Time        |<z> Value   | Damped Oscillator Visualization")
for i in 1:length(tspan)
    time = tout[i]
    value = z_vals[i]
    bar_len = Int(round((value+1)*10))
    bar = repeat("#",bar_len)
    if i%2 == 1
        println("t=$(rpad(time,4))|$(rpad(round(value,digits = 3),6))|$bar")
    end
end
println("\nConclusion: The oscillations die out as the system reaches equilibrium.")



## ------------------------------------------------------------------
# PROBLEM 24: Pure Dephasing (Noise without Energy Loss)
#
# --- PHYSICS CONCEPTS ---
# 1. Dephasing (T2 Noise):
#    - Unlike spontaneous emission (T1), dephasing does not flip |Up> to |Down>.
#    - It scrambles the phase relationship between them.
#    - |+> = (|0> + |1>) becomes a classical mixture.
#
# 2. The Operator:
#    The jump operator is sigma_z.
#    If the system is |Up>, sigma_z|Up> = |Up> (Phase flip unchanged).
#    But for superpositions, it randomizes the relative phase.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Start a qubit in the Superposition state |+x> = (|0> + |1>)/sqrt(2).
# Apply Dephasing noise (J = sigma_z).
# Measure <sigma_x>. It should decay to 0.
# Measure <sigma_z>. It should stay constant (Energy is conserved!).
#
# Steps:
# 1. Define b = SpinBasis(1//2).
# 2. Define Initial State psi_0 = (spinup + spindown)/sqrt(2).
# 3. Define H = 0.
# 4. Define J = [sigmaz(b)] with rate 0.5.
# 5. Measure both X and Z.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 24: Pure Dephasing ---")

b = SpinBasis(1//2)
psi_0 = (spinup(b) + spindown(b)) / sqrt(2)
H = 0 * sigmaz(b)
J = [sigmaz(b)]
gamma = [0.5]
function measure_x(t, rho)
    return real(expect(sigmax(b), rho))
end

function measure_z_static(t, rho)
    return real(expect(sigmaz(b), rho))
end
tspan = [0.0:0.2:5.0;]
times, x_vals = timeevolution.master(tspan, psi_0, H, J; rates=gamma, fout=measure_x)
_, states = timeevolution.master(tspan, psi_0, H, J; rates=gamma)
final_z = real(expect(sigmaz(b), states[end]))
println("\nTime  | <X> Value (Coherence)")
for i in 1:length(times)
    val = x_vals[i]
    bar = repeat("#", Int(round(val * 20))) # Map 0..1 to 0..20
    println("t=$(rpad(times[i], 4))| $(rpad(round(val, digits=3), 6)) | $bar")
end

println("\nFinal <Z> (Energy): $final_z")



## ------------------------------------------------------------------
# PROBLEM 25: The Jaynes-Cummings Model (Atom-Light Interaction)
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
println("\n--- Problem 25: Jaynes-Cummings Model ---")
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



## ------------------------------------------------------------------
# PROBLEM 26: The Steady State (Direct Solver)
#
# --- PHYSICS CONCEPTS ---
# 1. Equilibrium (Steady State):
#    In open systems (Problem 23), the state eventually stops changing.
#    d/dt rho = 0.
#    This is the "Fixed Point" of the Master Equation.
#
# 2. Driven-Dissipative System:
#    - Drive (H) tries to rotate the qubit (Rabi).
#    - Dissipation (J) tries to decay it to Ground.
#    - Result: The qubit settles somewhere in between (e.g., <Z> = -0.5).
#
# 3. Computational Shortcut:
#    Instead of evolving timeevolution.master(0 to 100...), 
#    we solve the linear equation L * rho_ss = 0 directly using
#    'steadystate.master(H, J)'.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Drive a qubit with H = 1.0 * sigmax. Decay it with J = [sigmam] (rate 1.0).
# 1. Simulate dynamics from t=0 to t=10 and record the final <Z>.
# 2. Calculate the Steady State.
# ------------------------

# --- SOLUTION ---
println("\n--- Problem 26: Steady State Solver ---")
b = SpinBasis(1//2)
psi_0 = spinup(b)
Omega = 1.0
Gamma = 1.0
H = Omega*sigmax(b)
J =[sigmam(b)]
rates = [Gamma]
tspan = [0.0:0.5:20.0;]
tout,z_vals = timeevolution.master(tspan,psi_0,H,J;rates = gamma,fout =measure_z)
z_final_dynamics = z_vals[end]
println("Final <Z> (Time Evolution): $z_final_dynamics")
