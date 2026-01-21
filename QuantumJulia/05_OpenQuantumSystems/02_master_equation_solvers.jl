

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
