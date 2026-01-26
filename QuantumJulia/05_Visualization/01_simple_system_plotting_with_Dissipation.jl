using QuantumOptics
using Plots
println("--- MODULE 5: VISUALIZATION (Basic Plotting) ---")

## ------------------------------------------------------------------
println("\nPROBLEM 1: Visualizing Rabi Oscillations")

## ------------------------------------------------------------------
# 
#
# --- PHYSICS CONCEPTS ---
# 1. The Data:
#    In quantum dynamics, we usually track an "Expectation Value" (like energy or spin)
#    over time. This gives us two arrays:
#    - x-axis: Time (t)
#    - y-axis: Expectation Value (<Z>)
#
# 2. The Plotting Tool (Plots.jl):
#    - plot(x, y): Creates a standard line graph.
#    - label: Names the curve for the legend.
#    - xlabel/ylabel: Labels the axes (CRITICAL for science).
#    - savefig(): Saves the image to your hard drive.
# ------------------------
#
# --- STEPS ---
# 1. Define a Spin-1/2 system (Qubit).
# 2. Apply a Hamiltonian H = (pi/2) * sigma_x (Standard Rabi Drive).
# 3. Solve the Schrödinger equation for t = 0 to 4.
# 4. Extract the <Z> values (Spin Up/Down).
# 5. Plot Time vs <Z> and save the figure.
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
psi_0 = spinup(b)
tspan = [0.0:0.05:5.0;]
H = (pi/2)*sigmax(b)
function measure_z(t,psi)
    return real(expect(sigmaz(b),psi))   
end
tout,z_vals = timeevolution.schroedinger(tspan,psi_0,H;fout=measure_z)
p = plot( tout,z_vals,
    label = "Rabi Oscillations",
    xlabel = "Time(t)",
    ylabel = "Spin_Projection <z>",
    title = "Qubit Dynamics",
    lw = 3,
    colour = :blue,
    legends = :topright
)
hline!([0,0],label ="Superposition", linestyle = :dash,colour =:gray)

display(p)
# output_filename = "05_Visualization/01_problem1_rabi.png"
# savefig(output_filename)




## ------------------------------------------------------------------
println("\nPROBLEM 2: Comparing Driving Strengths")
#
# --- PHYSICS CONCEPTS ---
# 1. Rabi Frequency (Omega):
#    The Hamiltonian is H = Omega * sigma_x.
#    - Higher Omega = Stronger Driving = Faster Oscillations.
#    - We want to visualize this relationship directly.
#
# 2. Plotting Concept: 'plot' vs 'plot!'
#    - plot(...): Creates a NEW graph (erasing the old one).
#    - plot!(...): ADDS a curve to the EXISTING graph (The '!' means "mutate").
# ------------------------
#
# --- STEPS ---
# 1. Initialize an empty plot object.
# 2. Loop through three values of Omega: [0.5, 1.0, 2.0].
# 3. For each Omega:
#    a. Define H = Omega * sigmax.
#    b. Solve Schrödinger equation.
#    c. Use 'plot!' to add the curve to the graph.
# 4. Display the final result.
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
psi_0 = spinup(b)
omegas = [0.5,1.0,1.5,2.0]
function measure_z(psi)
    return real(expect(sigmaz(b),psi))
end
p = plot(title = "Effect of Omega",
    xlabel= "Time(t)",
    ylabel = "Spin <z>",
    legend = :topright,
    lw =2
)

for omega in omegas
    local H = omega*sigmax(b)
    local tout,z_vals = timeevolution.schroedinger(tspan,psi_0,H;fout = measure_z)
    plot!(p,tout,z_vals,label ="Ω = $omega",lw =4)
end
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 3: Parametric Plots (Phase Space Trajectories)")
#
# --- PHYSICS CONCEPTS ---
# 1. Trajectories:
#    Sometimes we don't care about "when" something happens (Time),
#    but "how" the state moves through space.
# 2. Bloch Projection:
#    If we plot <X> vs <Z>, we see the qubit rotating in a circle
#    on the Bloch sphere (projected onto a 2D plane).
# ------------------------
#
# --- STEPS ---
# 1. Simulate Rabi Oscillations (standard H = pi/2 * X).
# 2. Measure TWO things: Expectation of Z and Expectation of Y.
# 3. Plot Y values (x-axis) vs Z values (y-axis).
# ------------------------

# --- SOLUTION ---
b= SpinBasis(1//2)
psi_0 = spinup(b)
H = (pi/2)*sigmax(b)
tspan = [0.0:0.05:5;]
function Measeure_bloch(time,psi)
    y = real(expect(sigmaz(b),psi))
    z = real(expect(sigmay(b),psi))
    return [y,z]
end
tout,results = timeevolution.schroedinger(tspan,psi_0,H,fout = Measeure_bloch)
y_vals = [r[1] for r in results]
z_vals = [r[2] for r in results]
p = plot(y_vals,z_vals,Label = "Bloch Trajectory",xlabel = "Expectation <x>",ylabel = "Expectation <z>",title = "Qubit Rotation",lw =3,arrow = true,aspect_rati0=1)
display(p)




## ------------------------------------------------------------------
println("\nPROBLEM 4: Subplots (Correlated Dynamics)")
#
# --- PHYSICS CONCEPTS ---
# 1. Correlated Observables:
#    In quantum mechanics, variables are often linked. For example, as a qubit
#    rotates, when Population (<Z>) is maximum, Coherence (<Y>) is zero.
#    To prove this, we must view them simultaneously.
#
# 2. Visualization Strategy (Subplots):
#    Instead of cramping lines onto one graph, we stack them vertically.
#    - Panel A: Population Dynamics.
#    - Panel B: Coherence Dynamics.
#    This allows for clear, direct comparison of time-aligned events.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate Rabi oscillations (H = pi/2 * X).
# Generate a single figure with two panels:
#   1. Top Panel: Expectation of Sigma_Z (Population).
#   2. Bottom Panel: Expectation of Sigma_Y (Coherence).
#
# --- STEPS ---
# 1. Define the system (Spin Basis, Initial State, Hamiltonian).
# 2. Define a measurement function that returns a vector [z, y].
# 3. Solve the Schrödinger equation.
# 4. Extract Z and Y data into separate arrays.
# 5. Create two separate plot objects (p_pop and p_coh).
# 6. Combine them using 'plot(p1, p2, layout=(2,1))'.
# ------------------------

# --- SOLUTION ---

b = SpinBasis(1//2)
psi_0 = spinup(b)
H = (pi/2)*sigmax(b)
tspan = [0.0:0.05:5.0;]
function measeure_panels(t,psi)
    z = real(expect(sigmaz(b),psi))
    y = real(expect(sigmay(b),psi))
    return [z,y]    
end
tout,results = timeevolution.schroedinger(tspan,psi_0,H;fout = measeure_panels)
z_data = [r[1] for r in results]
y_data = [r[2] for r in results]
p_pop = plot(tout,z_data,label = "<z>",color =:blue,ylabel = "Population",lw = 2,title = "Correlated Dynamics")
p_coh = plot(tout,y_data,label = "<y>",color =:red,ylabel = "Coherence",lw = 2)
p = plot(p_pop,p_coh,layout = (2,1),size = (600,600),xlabel = "Time")
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 5: Error Bars (Simulating Real Data)")
#
# --- PHYSICS CONCEPTS ---
# 1. Experimental Noise:
#    Real quantum computers are "noisy." If you run the same experiment 100 times,
#    you won't get the exact same number every time. You get a distribution.
#
# 2. Visualizing Uncertainty:
#    We represent this noise using "Error Bars" (whiskers on the data points).
#    - Central Dot: The average value.
#    - Bars: The standard deviation (how much it wiggles).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Take the smooth 'z_data' from Problem 4.
# 1. Add random noise to it to create 'z_noisy'.
# 2. Plot 'z_noisy' as discrete dots with error bars.
# 3. Overlay the clean 'z_data' as a solid line (Theory).
# ------------------------

# --- SOLUTION ---
noise = 0.15
z_noisy = z_data +noise*(rand(length(z_data)).-0.5)
errors = fill(noise,length(z_data))
p = plot(tout,z_noisy,yerror = errors,seriestype =:scatter,label = "Exp.Data",
    color =:black,ms = 4 ,# ms = marker sixe
    title = "Theory vs Experiment",
    xlabel = "Time",
    ylabel = "Population <Z>"
    )
plot!(p, tout, z_data, 
    label="Theory", 
    color=:red, 
    lw=3
)
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 6: Spontaneous Emission (Simple Decay)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Lindblad Master Equation:
#    Allows us to simulate "Jump Operators" (J).
#    These represent the environment measuring or stealing energy from the qubit.
#
# 2. Spontaneous Emission (J = sigma_minus):
#    The qubit falls from |Up> to |Down> and emits a photon.
#    This is an irreversible process.
#
# 3. Expected Result:
#    Exponential decay: <Z>(t) should go from +1 (Up) to -1 (Down).
# ------------------------
#
# --- STEPS ---
# 1. Define Jump Operator J = [sigmam(b)] (Sigma Minus).
# 2. Define Rate = [1.0] (Fast decay).
# 3. Use 'timeevolution.master' instead of 'schroedinger'.
# 4. Plot the decay.
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
psi_0 = spinup(b)
H = 0*sigmax(b)
J = [sigmam(b)]    # Lowers the state (|1> -> |0>)
rates = [1.0]
function measure_z(t,rho)
    return real(expect(sigmaz(b),rho))     # Note: The solver now gives us a Density Matrix (rho), not a Ket (psi)!
end
tspan = [0.0:0.05:5.00;]
tout,z_decay = timeevolution.master(tspan,psi_0,H,J;rates = rates,fout = measure_z)   # fout = Function OUTput
p = plot(tout,z_decay,label = "Spontaneous Emission",
    xlabel = "Time (t)",ylabel = "Population<Z>",
    title = "Energy relaxation",lw = 3,color =:black)
hline!(p,[-1.0],label ="Ground State",linestyle =:dash,color =:grey)  # [-1.0] here tells where to draw the dashed line
display(p)




## ------------------------------------------------------------------
println("\nPROBLEM 7: Damped Rabi Oscillations")
#
# --- PHYSICS CONCEPTS ---
# 1. Competition:
#    - Hamiltonian H (Drive) tries to rotate the state forever.
#    - Dissipator J (Decay) tries to stop it and pull it to -1.
#
# 2. Result:
#    The system will oscillate, but the amplitude will shrink over time.
#    Eventually, it settles into a "Steady State" where Drive = Decay.
# ------------------------
#
# --- STEPS ---
# 1. Define H = (pi/2) * sigmax (The Drive).
# 2. Define J = [sigmam] with rate 0.5 (The Decay).
# 3. Solve with Master Equation.
# 4. Plot the "Dying Oscillation".
# ------------------------

# --- SOLUTION ---
 b = SpinBasis(1//2)
 psi_0 = spinup(b)
 H = (pi/2)*sigmax(b)
 J = [sigmam(b)]
 rates = [1.0]
 tspan = [0.0:0.05:5.0;]
 function measeure_z(t,rho)
    return real(expect(sigmaz(b),rho))
 end
 tout,results = timeevolution.master(tspan,psi_0,H,J;rates = rates, fout = measeure_z)
 p = plot(tout,results,label = "Damped Rabi",
    xlabel = "Time(t)",ylabel = "Population <Z>",
    title = "Drive vs. Decay",lw = 3,color=:black)
hline!(p,[0.0],label ="Steady State",linestyle=:dot,color=:grey)
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 8: Pure Dephasing (T2) - The Phase Killer")
#
# --- PHYSICS CONCEPTS ---
# 1. The Operator:
#    - Relaxation (T1) uses J = sigma_minus (Energy loss).
#    - Dephasing (T2) uses J = sigma_z.
#      This means the environment "measures" the qubit (Z) but doesn't flip it.
#
# 2. The Setup:
#    - We start in a Superposition state |+> (on the Equator).
#    - We turn OFF the Hamiltonian (H=0).
#    - Result: <X> (Coherence) should decay to 0.
#    - Result: <Z> (Population) should stay constant (Energy conserved).
# ------------------------
#
# --- STEPS ---
# 1. Start in state |+> = (|0> + |1>) / sqrt(2).
# 2. Set H = 0 (No drive).
# 3. Set J = [sigmaz(b)] with rate 0.5.
# 4. Measure <X> (to see decay) and <Z> (to see conservation).
# 5. Plot both on one graph.
# ------------------------

# --- SOLUTION ---
b = SpinBasis(1//2)
psi_0 = normalize((spinup(b)+spindown(b)))
H = 0*sigmax(b)
J = [sigmaz(b)]
rates = [0.5]
function measure_dephasing(t, rho)
    x = real(expect(sigmax(b), rho)) # Coherence (Should die)
    z = real(expect(sigmaz(b), rho)) # Population (Should survive)
    return [x, z]
end
tspan = [0.0:0.05:10.0;]
tout, res = timeevolution.master(tspan, psi_0, H, J; rates=rates, fout=measure_dephasing)
x_data = [r[1] for r in res]
z_data = [r[2] for r in res]
p = plot(tout,x_data,label = "Coherence <X>",color=:red,lw = 3,
    ylabel= "Expectation Value",xlabel ="Time(t)",title = "Pure Dephasing")
plot!(p, tout,z_data,label = "Population<z>",color =:blue,linestyle =:dash,lw =3)
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 9: The Quantum Harmonic Oscillator")
#
# --- PHYSICS CONCEPTS ---
# 1. The Fock Basis:
#    Unlike spins (which have 2 levels: Up/Down), oscillators have infinite levels
#    (0, 1, 2... photons). We must truncate this at a cutoff 'N'.
#
# 2. The Hamiltonian:
#    H = omega * a^dagger * a
#    This represents a particle trapped in a parabolic potential (like a spring).
#    Energy levels are equally spaced: E_n = hbar * omega * n.
#
# 3. Coherent States (|alpha>):
#    These are the "most classical" states. They are eigenstates of the annihilation
#    operator 'a'. They oscillate back and forth without changing shape (if H is harmonic).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Simulate a Coherent State with alpha = 2.0 evolving under a Harmonic Hamiltonian.
# Measure the Position Operator X = (a + a^dagger).
# We expect to see a perfect sinusoidal oscillation (Classical Motion).
#
# --- STEPS ---
# 1. Define FockBasis with cutoff N=20.
# 2. Initialize state |psi_0> = coherentstate(alpha=2.0).
# 3. Define H = 1.0 * number(b).
# 4. Measure Position <X> = <a + a^dagger>.
# ------------------------

# --- SOLUTION ---
N = 20
b = FockBasis(N)
alpha = 2.0
psi_0 = coherentstate(b,alpha)  #(coherentstate(basis,mean_number)), alpha = mean for coherent states
omega = 1.0
H = omega*number(b)
x_op = (destroy(b) + create(b))
function measure_position(t,psi)
    return real(expect(x_op,psi))
end
tspan = [0.00:0.1:20.0;]
tout, result = timeevolution.schroedinger(tspan,psi_0,H;fout = measure_position)
p = plot(tout,result,label = "Position <x>",xlabel = "Time(t)",ylabel = "Position",
    title = "Harmonic Oscillator (Coherent State)",lw =3,color=:black)
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 10: Photon Loss (Damped Oscillator)")
#
# --- PHYSICS CONCEPTS ---
# 1. Optical Decay:
#    In a cavity, photons leak out. The Jump Operator is simply 'a' (destroy).
#    J = [destroy(b)].
#
# 2. Effect on Coherent States:
#    A coherent state remains a coherent state during decay, but its amplitude |alpha|
#    decreases exponentially.
#    The oscillation amplitude should shrink, spiraling to 0 (Vacuum).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Take the system from Problem 9 and add dissipation (Photon Loss).
# Use a decay rate of kappa = 0.1.
# Plot the Position <X> to see the damped oscillation.
#
# --- STEPS ---
# 1. Reuse H and psi_0 from Problem 9.
# 2. Define J = [destroy(b)] with rate [0.1].
# 3. Solve using Master Equation.
# 4. Plot Position <X> vs Time.
# ------------------------

# --- SOLUTION ---
b = FockBasis(20)
psi_0 = coherentstate(b,2.0)  
H = 1.0*number(b)
j = [destroy(b)]
rates = [0.1]
x_op = create(b)+destroy(b)
function measeure_dampedpos(t,rho)
    return real(expect(x_op,rho))
end
tspan = [0.0:0.1:30.0;]
tout,x_damped = timeevolution.master(tspan,psi_0,H,j;rates = rates,fout = measeure_dampedpos)
p = plot(tout,x_damped,label = "Damped Position",ylabel="Position <x>",xlabel = "Time(t)",
    title="Photon Loss(Damped Oscillator)",lw =3,color =:black)
hline!(p,[0.0],label = "Vacuum Level",linestyle =:dash,color =:grey)
display(p)



## ------------------------------------------------------------------
println("\nPROBLEM 11: Finite Temperature Oscillator (Heating & Cooling)")
#
# --- PHYSICS CONCEPTS ---
# 1. Thermal Bath:
#    A real environment pushes the system toward a "Thermal State", not just Vacuum.
#    It involves two competing processes:
#    - Decay (losing photons): J = destroy(b)
#    - Heating (gaining photons): J = create(b)
#
# 2. The Steady State:
#    The system will settle into a balance where Rate_in = Rate_out.
#    The final average photon number <n> depends on the ratio of Heating/Cooling.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Start the oscillator in the Vacuum state |0>.
# Apply Cooling (rate=1.0) and Heating (rate=0.5).
# Measure the Photon Number <n> = a^dagger * a.
# We expect <n> to rise from 0 and settle at a finite thermal value.
#
# --- STEPS ---
# 1. Define FockBasis(N=20).
# 2. Start in Vacuum: psi_0 = fockstate(b, 0).
# 3. Define J = [destroy(b), create(b)].
# 4. Define rates = [1.0, 0.5].
# 5. Measure <n>.
# ------------------------

# --- SOLUTION ---
N = 20
b = FockBasis(N)
psi_0 = fockstate(b,0)  # fockstate(Basis,state)
H = 0*number(b)
#    Channel 1: Decay (Standard loss)
#    Channel 2: Heating (Thermal pump)
J = [destroy(b),create(b)]
rates = [1.0,0.5]
n_op = number(b)
function measeure_n(t,rho)
    real(expect(n_op,rho))    
end
tspan = [0.0:0.1:10.0;]
tout,results = timeevolution.master(tspan,psi_0,H,J;rates = rates,fout = measeure_n)
p = plot(tout,results,label = "Photon Number <n>",xlabel = "Time(t)",ylabel="Average Photons",
    title = "Heating vs Cooling",lw =3,color=:black)
hline!(p,[0.0],label="Thermal Equilibrium",linestyle =:dash,color=:grey)
display(p)




## ------------------------------------------------------------------
println("\nPROBLEM 12: Phase Noise (Elastic Scattering)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Operator:
#    For Phase Noise, the environment "measures" the photon number without destroying photons.
#    J = [number(b)]  (which is a^dagger * a).
#
# 2. The Effect:
#    - Population <n> (Energy) stays CONSTANT.
#    - Position <X> (Coherence) DECAYS to 0.
#    The state turns from a "Coherent State" (Laser) into a "Thermal State" ring.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Start with a Coherent State (alpha = 2.0).
# Apply Phase Noise (rate = 0.5).
# Measure <X> (should die) and <n> (should survive).
#
# --- STEPS ---
# 1. Define FockBasis(N=20).
# 2. State |psi_0> = coherentstate(alpha=2.0).
# 3. Define J = [number(b)].
# 4. Measure <X> and <n>.
# ------------------------

# --- SOLUTION ---
N = 20
b =FockBasis(N)
H = 0*number(b)
psi_0 = coherentstate(b,2.0)
J = [number(b)]
rates = [0.5]
x_op = create(b)+destroy(b)
n_op = number(b)
tspan = [0.0:0.05:10.0;]
function measure_phase_noise(t,rho)
    x = real(expect(x_op,rho))
    n = real(expect(n_op,rho))
    return [x,n]
end
tout,res = timeevolution.master(tspan,psi_0,H,J;rates = rates,fout = measure_phase_noise)
x_data = [r[1] for r in res]
n_data = [r[2] for r in res]
p = plot(tout,x_data,label = "Coherence <x>",xlabel="Time(t)",ylabel="Expectation Value",
    lw = 4,color=:black)
plot!(p,tout,n_data,label="Photon Number <n>",linestyle=:dash,lw =4,color=:grey)
display(p)




