using QuantumOptics
using Plots

## ------------------------------------------------------------------
println("\nPROBLEM 1: Damped Jaynes-Cummings Model")
#
# --- PHYSICS CONCEPTS ---
# 1. Composite Hilbert Space:
#    We are simulating an Atom interacting with a Cavity.
#    The total space is the Tensor Product: H_total = H_atom (x) H_cavity.
#
# 2. The Interaction (Jaynes-Cummings):
#    H_int = g * (a_dagger * sigma_minus + a * sigma_plus).
#    This describes the exchange of energy: The atom falls down to create a photon,
#    or absorbs a photon to jump up.
#
# 3. Vacuum Rabi Oscillations:
#    Even with no photons initially, the atom and vacuum fluctuate.
#    Energy sloshes back and forth between the Atom and the Cavity.
#
# 4. Independent Dissipation:
#    - The cavity loses photons at rate 'kappa'.
#    - The atom spontaneously emits at rate 'gamma'.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a resonant Atom-Cavity system (w_atom = w_cavity = 1.0).
# Start with the Atom Excited |e> and Cavity in Vacuum |0>.
# Use coupling g=0.5, cavity decay kappa=0.1, and atom decay gamma=0.1.
# Plot the Atom Population <Z> and Cavity Photon Number <n> to see the exchange.
#
# --- STEPS ---
# 1. Define Atom basis (Spin 1/2) and Cavity basis (Fock N=10).
# 2. Tensor them together: b_comp = tensor(b_atom, b_cavity).
# 3. Lift operators: sz = sz (x) I, a = I (x) a, etc.
# 4. Define H = H_atom + H_cavity + g*(ad*sm + a*sp).
# 5. Define J = [a, sm] with rates [kappa, gamma].
# 6. Measure <sz> and <n>.
# ------------------------

# --- SOLUTION ---

b_atom = SpinBasis(1//2)
b_cavity = FockBasis(10)
b_comp = tensor(b_atom,b_cavity)

#    Atom Operators: Op (x) I
sz = tensor(sigmaz(b_atom),one(b_cavity))   # Use one(b) instesd of identity(b) which is used in the qutip.
sp = tensor(sigmap(b_atom),one(b_cavity))
sm = tensor(sigmam(b_atom),one(b_cavity))

#    Cavity Operators: I (x) Op
a = tensor(one(b_atom),destroy(b_cavity))
ad = tensor(one(b_atom),create(b_cavity))
n = tensor(one(b_atom),number(b_cavity))

# Hamiltonian
w_cavity = 1.0
w_atom = 1.0
g = 1.0
H = (w_atom/2)*sz + w_cavity*n + g*(ad*sm+a*sp)
kappa = 0.1
gamma = 0.1
J = [a,sm]
rates = [kappa,gamma]

# Initial State
psi_atom = spinup(b_atom)
psi_cavity = fockstate(b_cavity,0)
psi_0 = tensor(psi_atom,psi_cavity)

function measure_jc(t,rho)
    pop_atom = real(expect(sz,rho))
    pop_cavity = real(expect(n,rho))
    return [pop_atom,pop_cavity]
end
tspan = [0.0:0.1:20.0;]
tout,results = timeevolution.master(tspan,psi_0,H,J;rates = rates,fout = measure_jc)
atom_data = [r[1] for r in results]
cavity_data =[r[2] for r in results]
p = plot(tout,atom_data,label = "Atom Population <z>",xlabel="Time(t)",ylabel="Population/Number",
    title = "Jaynes-Cummings (Damped)",lw =3,color=:black)
plot!(p,tout,cavity_data,label="Cavity Photon <n>",lw=3,color=:grey,linestyle=:dash)
#display(p)



## ------------------------------------------------------------------
# PROBLEM 2: The Quantum Bridge (3-Mode Composite System)
#
# --- PHYSICS CONCEPTS ---
# 1. Tripartite Hilbert Space:
#    We have three distinct systems:
#    - System 1: The Atom (Qubit - The Bridge).
#    - System 2: Cavity A (Source - Fock Basis).
#    - System 3: Cavity B (Target - Fock Basis).
#    Total Space = Spin(1/2) (x) Fock(N) (x) Fock(N).
#
# 2. Dual Interaction Hamiltonian:
#    The atom talks to BOTH cavities simultaneously.
#    H_int = g_a * (a * sigma_plus + h.c.)  <-- Atom absorbs from A
#          + g_b * (b^dagger * sigma_minus + h.c.) <-- Atom emits into B
#
# 3. Energy Flow Dynamics:
#    We expect to see energy flow: Cavity A -> Atom -> Cavity B.
#    The Atom acts as a temporary storage buffer.
# ------------------------
#
# --- PROBLEM ---
println("\nObjective: Simulate a resonant system (w_atom = w_a = w_b = 1.0).")
# Start with 5 Photons in Cavity A, Atom in Ground, Cavity B in Vacuum.
# Use couplings g_a = g_b = 1.0.
# Add decay ONLY to Cavity B (kappa = 0.5) to make it a "Sink".
# Plot <n_A>, <P_atom>, and <n_B>.
#
# --- STEPS ---
# 1. Define b_atom, b_A (N=5), b_B (N=5).
# 2. Tensor them: tensor(b_atom, b_A, b_B).
# 3. Lift operators carefully (Identity matrices in the right slots!).
# 4. Construct H = H_0 + H_int_A + H_int_B.
# 5. Solve and visualize the flow.
# ------------------------

# --- SOLUTION ---

N = 5
b_atom = SpinBasis(1//2)
b_A = FockBasis(N)
b_B = FockBasis(N)
##b_comp = tensor(b_atom,b_A,b_B)

#    Atom: [Op] (x) [I] (x) [I]
sz = tensor(sigmaz(b_atom),one(b_A),one(b_B))
sp = tensor(sigmap(b_atom),one(b_A),one(b_B))
sm = tensor(sigmam(b_atom),one(b_A),one(b_B))

#    Cavity A: [I] (x) [Op] (x) [I]
a = tensor(one(b_atom),destroy(b_A),one(b_B))
ad = tensor(one(b_atom),create(b_A),one(b_B))
na = tensor(one(b_atom),number(b_A),one(b_B))

#    Cavity B: [I] (x) [I] (x) [Op]
b = tensor(one(b_atom),one(b_A),destroy(b_B))
bd = tensor(one(b_atom),one(b_A),create(b_B))
nb = tensor(one(b_atom),one(b_A),number(b_B))

w = 1.0
g = 1.0
H = (w/2)*sz + w*na + w*nb + g*(a*sp + ad*sm) + g*(b*sp+bd*sm)
#    We only let Cavity B leak. This pulls energy through the chain.
kappa = 0.5
J = [b]
rates = [kappa]

# Initial State    
#    Atom: Ground |down>
#    Cavity A: 5 Photons |5>
#    Cavity B: Vacuum |0>
psi_0 = tensor(spindown(b_atom),fockstate(b_A,5),fockstate(b_B,0))
function measure_bridge(t,rho)
    pop_Atom = real(expect(sz,rho))
    pop_A = real(expect(na,rho))
    pop_B = real(expect(nb,rho))
    return [pop_Atom,pop_A,pop_B]
end
tspan = [0.0:0.05:15.0;]
tout,res = timeevolution.master(tspan,psi_0,H,J;rates = rates,fout = measure_bridge)
atom_data = [r[1] for r in res]
A_data = [r[2] for r in res]
B_data = [r[3] for r in res]
p = plot(tout,atom_data,label="Bridege (Atom Z)",xlabel="Time(t)",ylabel="Population/Photons",
    title="3-Mode Quantum Bridge",lw =3,color=:blue)
plot!(p,tout,A_data,label="Source (Cavity A)",lw =3,color=:green)
plot!(p,tout,B_data,label="Target (Cavity B)",lw = 3,color=:red)
#display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 3: The Dark State (Interference in Tavis-Cummings)")
#
# --- PHYSICS CONCEPTS ---
# 1. Tripartite System:
#    Atom 1 (Spin) + Atom 2 (Spin) + Cavity (Fock).
#    They all interact: Atoms exchange energy with the SAME cavity mode.
#
# 2. Collective Interaction:
#    H_int = g * (a_dagger * (sm1 + sm2) + a * (sp1 + sp2)) 
#    The cavity talks to the "Sum" of the atoms.
#
# 3. Interference:
#    - If atoms are "In Phase" (|+>), their couplings add up (Constructive).
#    - If atoms are "Out of Phase" (|->), their couplings CANCEL (Destructive).
#      g - g = 0. The cavity literally cannot see the atoms.
# ------------------------
#
# --- PROBLEM ---
# Objective:
println("\nSimulate 2 Atoms inside 1 Lossy Cavity (kappa = 1.0).")
# Compare two initial states:
#   1. Bright State: (|e,g> + |g,e>) / sqrt(2). (Should decay fast).
#   2. Dark State:   (|e,g> - |g,e>) / sqrt(2). (Should stay excited forever).
# Plot the Total Atomic Energy to prove one is trapped.
#
# --- STEPS ---
# 1. Define b1, b2, b_cav (N=5).
# 2. Lift all operators to the 3-mode space.
# 3. Define Resonant Hamiltonian.
# 4. Define Decay J = [a] (Only cavity leaks).
# 5. Run TWO simulations with different psi_0.
# ------------------------

# --- SOLUTION ---
N = 5
b1 = SpinBasis(1//2)
b2 = SpinBasis(1//2)
b_cav = FockBasis(N)

#    Atom 1: [Op] (x) [I] (x) [I]
sz1 = tensor(sigmaz(b1),one(b2),one(b_cav))
sp1 = tensor(sigmap(b1),one(b2),one(b_cav))
sm1 = tensor(sigmam(b1),one(b2),one(b_cav))

#    Atom 2: [I] (x) [Op] (x) [I]
sz2 = tensor(one(b1),sigmaz(b2),one(b_cav))
sp2 = tensor(one(b1),sigmap(b2),one(b_cav))
sm2 = tensor(one(b1),sigmam(b2),one(b_cav))

#    Cavity: [I] (x) [I] (x) [Op]
a = tensor(one(b1),one(b2),destroy(b_cav))
ad = tensor(one(b1),one(b2),create(b_cav))
n = tensor(one(b1),one(b2),number(b_cav))
w = 1.0
g = 1.0
H_0 = (w/2)*sz1 + (w/2)*sz2 + w*n
H_int = g*(ad*(sm1+sm2)+a*(sp1+sp2))
H = H_0 + H_int
kappa = 1.0
J = [a]
rates = [kappa]
function measure_atoms(t,rho)
    e1 = (real(expect(sz1,rho))+1)/2
    e2 = (real(expect(sz2,rho))+1)/2
    return e1+e2
end
tspan = [0.0:0.05:10.0;]
#    (|up, down> + |down, up>) Symmetric
psi_bright = normalize(tensor(spinup(b1),spindown(b2),fockstate(b_cav,0))+
    tensor(spindown(b1),spinup(b2),fockstate(b_cav,0)))
tout,res_bright = timeevolution.master(tspan,psi_bright,H,J;rates = rates,fout=measure_atoms)

#    (|up, down> - |down, up>) (Antisymmetric)
psi_dark = normalize(tensor(spinup(b1),spindown(b2),fockstate(b_cav,0))-
    tensor(spindown(b1),spinup(b2),fockstate(b_cav,0)))
tout,res_dark = timeevolution.master(tspan,psi_dark,H,J;rates = rates,fout=measure_atoms)

p = plot(tout,res_bright,label="Bright State (+)",xlabel="Time(t)",ylabel="Atomic Energy <z1+z2>",title="Quantum Interference(Dark State)",lw =3,color =:red)
plot!(p,tout,res_dark,label="Dark State(-)",lw=3,color=:blue)
#display(p)



# --- PHYSICS CONCEPTS ---
println("\n--- Problem 4: Dispersive Readout Simulation ---")
# 1. The Dispersive Regime:
#    When detuning Delta = |w_a - w_c| >> g, the interaction changes form.
#    H_eff approx (w_c + chi * sigma_z) * a^dagger * a
#    The cavity frequency SPLITS into two peaks depending on the Qubit State (Z).
#
# 2. Readout Principle:
#    We drive the cavity at frequency w_drive = w_c.
#    - If Qubit = Ground (+1 Z): Cavity is on resonance. Photons enter.
#    - If Qubit = Excited (-1 Z): Cavity is off resonance. Photons bounce off.
#
# 3. Readout Error (T1 Decay):
#    If the qubit decays (|e> -> |g>) DURING the measurement, the cavity
#    suddenly brightens, giving a false signal. This is a major error source.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a Detuned System: w_c=5.0, w_a=6.0 (Delta=1.0), g=0.1.
# Drive the cavity with strength E=0.2.
# Compare two scenarios in one plot:
#   1. Start with Atom in Ground |g>. Measure <n>.
#   2. Start with Atom in Excited |e>. Measure <n>.
# Include Relaxation (Gamma_1 = 0.05) to see the signal degrade.
#
# --- STEPS ---
# 1. Define Basis (N=20 for accuracy).
# 2. Define Full Jaynes-Cummings Hamiltonian (Rotating Frame).
# 3. Add Drive Term: H_drive = E * (a + a').
# 4. Add Dissipation: Cavity (kappa=0.5), Atom (gamma=0.05).
# 5. Run TWICE (once for psi_g, once for psi_e).
# ------------------------

# --- SOLUTION ---
N = 20
b_atom = SpinBasis(1//2)
b_cav = FockBasis(N)

sz = tensor(sigmaz(b_atom), one(b_cav))
sp = tensor(sigmap(b_atom), one(b_cav))
sm = tensor(sigmam(b_atom), one(b_cav))

a  = tensor(one(b_atom), destroy(b_cav))
ad = tensor(one(b_atom), create(b_cav))
n  = tensor(one(b_atom), number(b_cav))

w_c = 0.0          
w_a = 2.0          
g   = 0.5          
E   = 0.15
kappa = 0.1   
gamma = 0.05  
J = [a, sm]
rates = [kappa, gamma]
function measure_readout(t, rho)
    return real(expect(n, rho))
end
H_sys = (w_a / 2) * sz + g * (a * sp + ad * sm)
H_drive = E * (a + ad)
H = H_sys + H_drive
tspan = [0.0:0.1:30.0;]
# --- SCENARIO 1: Qubit is Ground (Should be Bright) ---
psi_g = tensor(spindown(b_atom), fockstate(b_cav, 0))
tout, res_g = timeevolution.master(tspan, psi_g, H, J; rates=rates, fout=measure_readout)

# --- SCENARIO 2: Qubit is Excited (Should be Dark) ---
psi_e = tensor(spinup(b_atom), fockstate(b_cav, 0))
tout, res_e = timeevolution.master(tspan, psi_e, H, J; rates=rates, fout=measure_readout)

p = plot(tout, res_g, 
    label="Qubit Ground (Resonant)", 
    color=:blue, 
    lw=3, 
    xlabel="Time (t)", 
    ylabel="Cavity Photons <n>",
    title="Dispersive Readout (Discrimination)"
)
plot!(p, tout, res_e, 
    label="Qubit Excited (Detuned)", 
    color=:red, 
    lw=3,
    linestyle=:dash
)
display(p)