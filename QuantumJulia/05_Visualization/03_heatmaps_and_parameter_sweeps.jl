using QuantumOptics
using Plots


## ------------------------------------------------------------------
println("\n--- Problem 1: Schrödinger Cat Wigner Function ---")
#
# --- PHYSICS CONCEPTS ---
# 1. Phase Space Representation:
#    Unlike classical particles (point at x, p), quantum states are clouds.
#    The Wigner Function W(x,p) maps this probability density.
#
# 2. The Cat State:
#    A superposition of two macroscopic coherent states: |ψ> ~ |α> + |-α>.
#    Classically, the cat is either Alive (α) or Dead (-α).
#
# 3. Quantum Interference (Negativity):
#    - You will see two positive (Red) blobs for the classical states.
#    - In the center, you will see oscillating stripes.
#    - Crucially, these stripes go NEGATIVE (Blue). Classical probability
#      can never be negative. This is the visual proof of quantumness.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a Cat State with alpha = 2.5.
# Calculate its Wigner function on a 100x100 grid (x, p from -6 to 6).
# Plot the 2D Heatmap to visualize the interference "whiskers".
#
# --- STEPS ---
# 1. Define FockBasis (N=30 to contain the energy).
# 2. Construct state: psi = normalize(|α> + |-α>).
# 3. Define grid vectors xvec and pvec.
# 4. Calculate W = wigner(psi, xvec, pvec).
# 5. Plot using heatmap() with a diverging color map (:RdBu).
# ------------------------

# --- SOLUTION ---

N = 20
b=FockBasis(N)
alpha = 0.5
psi_cat = normalize(coherentstate(b,alpha)+coherentstate(b,-alpha))
xvec = range(-6.0,6.0,length=100)
pvec = range(-6.0,6.0,length=100)
## Wigner Function computes the quasiprobability for every pixel in the grid.
W = wigner(psi_cat,xvec,pvec)    #Wigner(state,x,y)
p=contourf(xvec,pvec,W,xlabel="Position (x)",ylabel="Momentum (p)",title="Schrodinger Cat (Wigner Function)",
    color=:RdBu,clims=(-0.20,0.20),levels=100)  # clims = colour range,levels = smoothness
#display(p)



## ------------------------------------------------------------------
println("\n--- Problem 2: Decoherence Visualization ---")
#
# --- PHYSICS CONCEPTS ---
# 1. Decoherence vs. Dissipation:
#    - Dissipation: Energy loss (The blobs move to the center).
#    - Decoherence: Information loss (The interference fringes vanish).
#    Decoherence happens much faster than energy decay.
#
# 2. The Transition:
#    We start with a Quantum Superposition (Fringes visible).
#    The environment "measures" the cat, killing the fringes.
#    We end up with a Classical Statistical Mixture (Two blobs, no fringes).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Take the Cat State from Problem 1.
# Evolve it for time T=2.0 under cavity decay (kappa = 0.5).
# Plot the Wigner function at the end.
# Compare: Are the fringes gone? Are the blobs still there?
#
# --- STEPS ---
# 1. Reuse psi_cat and basis b from Problem 1.
# 2. Define Hamiltonian H = w*a'*a and Dissipation J = [a].
# 3. Evolve for time t=2.0 using timeevolution.master.
# 4. Calculate Wigner function of the *final state*.
# 5. Plot.
# ------------------------

# --- SOLUTION ---
a =create(b)
ad = destroy(b)
n = number(b)
H = 1.0*n
kappa = 0.5
J = [a]
rates = [kappa]
tspan = [0.0,2.0]    # Start and End
tout,state = timeevolution.master(tspan,psi_cat,H,J;rates=rates)
rho_final = state[end]     #    Extract the last state (the final result)
W_dead = wigner(rho_final,xvec,pvec)
p = contourf(xvec,pvec,W_dead,title="Decoherence (Dead Cat)",xlabel="Position (x)"
    ,ylabel="Momentum (P)",color=:RdBu,clims=(-0.2,0.2),levels = 100)

#display(p)



## ------------------------------------------------------------------
println("\n--- Problem 3: Rabi Chevron Heatmap ---")
#
# --- PHYSICS CONCEPTS ---
# 1. 2D Parameter Sweep:
#    We vary Time (t) AND Detuning (Delta) simultaneously.
#    This creates a 2D map of the system's response.
#
# 2. Generalized Rabi Frequency:
#    Omega_eff = sqrt(Omega^2 + Delta^2).
#    - As Detuning (Delta) increases, the oscillation frequency INCREASES.
#    - However, the Amplitude DECREASES (Population < 1.0).
#
# 3. The Chevron Pattern:
#    The interference between drive and detuning creates a "V" or ">" shape.
#    This is the signature of a driven two-level system.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a Driven Qubit.
# Scan Detuning (Delta) from -5.0 to 5.0.
# Scan Time (t) from 0.0 to 5.0.
# Calculate Excited State Population <e|rho|e> for every (t, Delta) pixel.
# Plot the Heatmap.
#
# --- STEPS ---
# 1. Define Spin Basis.
# 2. Define Operators (sz, sx).
# 3. Create a Grid of Detuning values and Time values.
# 4. Loop over Detuning:
#    - Define H = Delta/2 * sz + Omega * sx.
#    - Solve Master Equation.
#    - Store the population row.
# 5. Plot Heatmap (Time vs Delta).
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
sz = sigmaz(b)
sx = sigmax(b)
sp = sigmap(b)
sm = sigmam(b)
Omega = 1.0          # Drive Strength (Rabi Frequency)
gamma = 0.2          # Decay rate (to make it realistic)
J = [sm]
rates = [gamma]
delta_list=range(-5.0,5.0,length=100)
t_list = range(0.0,10.0,length=100)
data_matrix = zeros(length(delta_list),length(t_list))  # creates the grid of zero values of length(delta_list)xlength(t_list)
for (i,delta) in enumerate(delta_list)
    H = 0.5*delta*sz + Omega*sx
    psi_0 = spindown(b)
    tout,pop_e = timeevolution.master(t_list,psi_0,H,J;rates=rates,fout = (t,rho)-> real(expect(0.5*(sz+one(b)), rho)))
    data_matrix[i,:] = pop_e
end
p3 = heatmap(t_list, delta_list, data_matrix,
    xlabel = "Time (t)",
    ylabel = "Detuning (Delta)",
    title = "Rabi Chevron (Interference Pattern)",
    color = :viridis, # Classic science colormap
    clims = (0.0, 1.0) # Population is between 0 and 1
)

#display(p3)


## ------------------------------------------------------------------
println("\n--- Problem 4: Jaynes-Cummings Heatmap (Hybrid System) ---")
#
# --- PHYSICS CONCEPTS ---
# 1. The Tensor Product:
#    We combine two Hilbert spaces: b_total = b_cavity ⊗ b_atom.
#    Operators must be "lifted": a_total = a ⊗ I_atom.
#
# 2. Vacuum Rabi Oscillations:
#    Energy exchanges between the Atom and the Cavity.
#    |e, 0> <--> |g, 1>
#    The rate of this exchange is the Vacuum Rabi Frequency: 2g.
#
# 3. Avoided Crossing (The Heatmap):
#    At Resonance (Delta=0), the exchange is perfect (Red to Blue).
#    As we detune, the atom refuses to give up its photon (Stays Red).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a Jaynes-Cummings system.
# Sweep Detuning (Delta) from -10g to 10g.
# Plot Atom Excitation Probability over Time.
#
# --- STEPS ---
# 1. Define FockBasis(N=5) and SpinBasis(1/2).
# 2. Create Composite Basis: b = b_cav ⊗ b_spin.
# 3. Define Operators:
#    - a = destroy(b_cav) ⊗ I_spin
#    - sm = I_cav ⊗ sigmam(b_spin)
# 4. Define Hamiltonian: H = Delta * sz + g * (a'sm + a sm').
# 5. Evolve starting from |0, e> (Empty cavity, Excited atom).
# ------------------------

# --- SOLUTION ---
N_cav = 5
b_cav = FockBasis(N_cav)
b_atom = SpinBasis(1//2)
b = tensor(b_cav,b_atom)
a = tensor(destroy(b_cav),one(b_atom))
a_dag = tensor(create(b_cav),one(b_atom))
sz = tensor(one(b_cav),sigmaz(b_atom))
sp = tensor(one(b_cav),sigmap(b_atom))
sm = tensor(one(b_cav),sigmam(b_atom))
g = 1.0
kappa = 0.05
gamma = 0.05
J = [sqrt(kappa)*a,sqrt(gamma)*sm]
detuning_list = range(-5.0,5.0,length=50)
t_list = range(0.0,10.0,length=200)
jc_data = zeros(length(detuning_list),length(t_list))
psi_0 = tensor(fockstate(b_cav,0),spinup(b_atom))
for i in 1:length(detuning_list)
    delta = detuning_list[i]
    H = 0.5*delta*sz + g*(a_dag*sm+a*sp)
    function save_expect(t,rho)
        return real(expect(0.5(sz+one(b)),rho))        
    end
    tout,results = timeevolution.master(t_list,psi_0,H,J;fout = save_expect)
    jc_data[i,:] = results
end
p4 = heatmap(t_list,detuning_list,jc_data,xlabel="Time(t)",ylabel="Detuning (Δ)",Title="Jaynes-Cumming",color=:seismic,clims=(0,1))
display(p4)


