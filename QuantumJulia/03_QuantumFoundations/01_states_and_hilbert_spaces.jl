using LinearAlgebra

## ------------------------------------------------------------------
println("\nPROBLEM 1: States in Hilbert Space (Normalization)")
#
# --- PHYSICS CONCEPTS ---
# 1. The Hilbert Space:
#    In Quantum Mechanics, the state of a system is represented by a vector |psi>
#    living in a complex vector space called a Hilbert Space.
#
# 2. The Physical State:
#    Vectors |psi> and c|psi> (where c is a constant) represent the SAME physical state.
#    However, to calculate probabilities correctly, we enforce the "Normalization Condition":
#    <psi|psi> = 1.
#
# 3. Superposition:
#    If |0> and |1> are valid states, then a*|0> + b*|1> is also a valid state.
#    The probability of finding the system in |0> is |a|^2 / (|a|^2 + |b|^2).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Construct a random superposition state and normalize it manually.
#
# Steps:
# 1. Define basis vectors |0> = [1, 0] and |1> = [0, 1].
# 2. Create an un-normalized state |psi> = (3+2i)|0> + (1-4i)|1>.
# 3. Compute its squared norm (total probability if unnormalized).
# 4. Normalize the vector so its total probability is exactly 1.0.
# 5. Verify the new norm.
# ------------------------

# --- SOLUTION ---
psi0 = [1,0] 
psi1 = [0,1]
psi = (3+2im)psi0 + (1-4im)psi1
display(psi)
psi_norm = psi/norm(psi)

println("Normalized State: ")
display(psi_norm)
println("Final Norm: ",norm(psi_norm))



## ------------------------------------------------------------------
println("\nPROBLEM 2: The Born Rule & Inner Products")
#
# --- PHYSICS CONCEPTS ---
# 1. The Bra-Ket Notation (Inner Product):
#    The "overlap" between two states |phi> and |psi> is denoted as <phi|psi>.
#    Mathematically, this is the dot product: sum(phi_i* * psi_i).
#    In Julia, we use the function 'dot(phi, psi)'.
#
# 2. Probability Amplitude:
#    The complex number c = <phi|psi> is called the "Probability Amplitude".
#    It tells you "how much" of state |phi> is inside state |psi>.
#
# 3. The Born Rule:
#    The probability of finding the system in state |phi> upon measurement
#    is the square of the magnitude of the amplitude:
#    Probability = |<phi|psi>|^2
#
# 4. Orthogonality:
#    Two states are "Orthogonal" (mutually exclusive) if their overlap is zero:
#    <0|1> = 0.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Calculate the measurement probabilities for a specific superposition state.
#
# Steps:
# 1. Define the computational basis |0> and |1>.
# 2. Create the normalized state |psi> = 1/sqrt(3)*|0> + i*sqrt(2/3)*|1>.
# 3. Calculate the "Amplitude" to be found in |0> (dot product).
# 4. Calculate the "Amplitude" to be found in |1>.
# 5. Compute the Probabilities (magnitude squared) and verify they sum to 1.0.
# 6. Verify that |0> and |1> are orthogonal.
# ------------------------

# --- SOLUTION ---
psi0 = [1,0]
psi1 = [0,1]
psi = (1/sqrt(3))*psi0 + im*sqrt(2/3)*psi1
display(psi)
amp0 = dot(psi0,psi)
amp1 = dot(psi1,psi)

println("Amplitude <0|psi>: $amp0")
println("Amplitude <1|psi>: $amp1")
prob0 = (abs(amp0))^2
prob1 = (abs(amp1))^2
println("Probability P(0): $prob0")
println("Probability P(1): $prob1")
println("Total Probability: $(prob0+prob1)")
ortho_check = dot(psi0,psi1)
println("Orthogonality <0|1>: $ortho_check")



## ------------------------------------------------------------------
println("/nPROBLEM 3: Change of Basis")
#
# --- PHYSICS CONCEPTS ---
# 1. Basis Independence:
#    A quantum state |psi> is a physical object (an arrow in space). 
#    It exists independently of the coordinate system we use to describe it.
#
# 2. The Hadamard Basis (X-Basis):
#    Instead of |0> and |1> (Z-Basis), we can use:
#    |+> = 1/sqrt(2) * (|0> + |1>)
#    |-> = 1/sqrt(2) * (|0> - |1>)
#
# 3. Projection (Translation):
#    To express a state |psi> in the new basis {|+>, |->}, we project it:
#    |psi> = c_plus * |+> + c_minus * |->
#    where c_plus = <+|psi> and c_minus = <-|psi>.
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Express the state |0> in terms of the Hadamard basis (|+>, |->).
#
# Steps:
# 1. Define |0> and |1>.
# 2. Construct |+> and |-> manually.
# 3. Calculate the coefficients: c_plus = <+|0> and c_minus = <-|0>.
# 4. Reconstruct the state using these new coefficients: psi_reconstructed = c_plus*|+> + c_minus*|->.
# 5. Verify that psi_reconstructed is mathematically identical to the original |0>.
# ------------------------

# --- SOLUTION ---

psi0 = [1,0]
psi1 = [0,1]
psi_plus = [sqrt(1/2),sqrt(1/2)]
display(psi_plus)
psi_minus = [sqrt(1/2),-sqrt(1/2)]
display(psi_minus)
c_plus = dot(psi_plus,psi0)
c_minus = dot(psi_minus,psi0)
psi_reconstructed = c_plus*psi_plus + c_minus*psi_minus
display(psi_reconstructed)
println("Is psi0 = psi_reconstructed? ",psi0 ≈ psi_reconstructed)



## ------------------------------------------------------------------
println("\nPROBLEM 4: Global vs. Relative Phase")
#
# --- PHYSICS CONCEPTS ---
# 1. Global Phase (Invisible):
#    If we multiply the WHOLE state vector by a phase factor e^(i*theta),
#    the physical state is identical.
#    |psi'> = e^(i*theta) * |psi>
#    Prob = |<x|psi'>|^2 = |e^(i*theta)|^2 * |<x|psi>|^2 = 1 * Prob_old.
#
# 2. Relative Phase (Visible):
#    If we multiply ONLY ONE coefficient, we change the state.
#    |psi_new> = alpha*|0> + (e^(i*theta) * beta)*|1>
#    This changes how the terms interfere (constructive vs destructive).
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Prove that Global Phase doesn't matter, but Relative Phase does.
#
# Steps:
# 1. Define state |+> = [1, 1]/sqrt(2).
# 2. Create |psi_global> by multiplying |+> by 'im' (90 degree rotation).
# 3. Create |psi_relative> by multiplying ONLY the second component by 'im'.
# 4. Measure all three states in the X-Basis (|+> and |->).
# 5. Observe:
#    - |+> and |psi_global> give IDENTICAL probabilities.
#    - |psi_relative> gives DIFFERENT probabilities.
# ------------------------

# --- SOLUTION ---

psi_plus = [1,1]/sqrt(2)
psi_global = im*psi_plus
psi_relative = [psi_plus[1],im*psi_plus[2]]
println("\nPhase Ambiguity")
println("original State: ")
display(psi_plus)
println("Global Phase changed State: ")
display(psi_global)
println("Relative Phase State: ")
display(psi_relative)

# Verification: Measure in X-Basis
ket_plus = [1,1]/sqrt(2)
prob_origin = (abs(dot(ket_plus,psi_plus)))^2
prob_global = (abs(dot(ket_plus,psi_global)))^2
prob_relative = (abs(dot(ket_plus,psi_relative)))^2
println("Original Probability: $prob_origin")
println("Global Probability: $prob_global")
println("Relative Probability: $prob_relative")
println("Is probability same for both Original and Global: ",prob_origin ≈ prob_global)
println("Is probability same for both Original and Relative: ",prob_origin ≈ prob_relative)



## ------------------------------------------------------------------
println("\nPROBLEM 5: The Bloch Sphere Representation")
#
# --- PHYSICS CONCEPTS ---
# 1. The General Qubit State:
#    Every normalized pure state can be written (ignoring global phase) as:
#    |psi> = cos(theta/2)|0> + e^(i*phi) * sin(theta/2)|1>
#    
#    - Theta (0 to pi): Controls the probability mix of |0> vs |1>.
#      (Theta=0 is |0>, Theta=pi is |1>, Theta=pi/2 is a superposition).
#    - Phi (0 to 2pi): Controls the Relative Phase (rotation around Z-axis).
#
# 2. Bloch Coordinates (x, y, z):
#    We can map this vector to 3D Cartesian coordinates:
#    x = sin(theta) * cos(phi)
#    y = sin(theta) * sin(phi)
#    z = cos(theta)
# ------------------------
#
# --- PROBLEM ---
# Objective:
# Create a function that generates a quantum state from angles (theta, phi)
# and verifies that its coefficients match the Bloch coordinates.
#
# Steps:
# 1. Define a function `bloch_state(theta, phi)`.
# 2. Generate the state for Theta = pi/2, Phi = pi/2.
#    (Geometrically, this is the +Y axis).
# 3. Calculate the expectation values (coordinates) manually from the state vector:
#    x_exp = 2 * Real( alpha' * beta )
#    y_exp = 2 * Imag( alpha' * beta )
#    z_exp = |alpha|^2 - |beta|^2
# 4. Verify these match the geometric formulas.
# ------------------------

# --- SOLUTION ---
function bloch_state(theta,phi)
    alpha = cos(theta/2)
    beta = exp(im*phi)*sin(theta/2)
    return [alpha,beta]
end
println("\nBloch Sphere Mapping")
println("State with θ = π/2 and ϕ = π/2 is :")
display(bloch_state(pi/2,pi/2))
alpha = bloch_state(pi/2,pi/2)[1]
beta = bloch_state(pi/2,pi/2)[2]

# Formulas derived from Pauli matrices (we will learn these next file)
x_cal = 2*real(conj(alpha)*beta)
y_cal = 2*imag(conj(alpha)*beta)
z_cal = abs(alpha^2-beta^2)
println("Calculated Coordinates from State:")
println("X: $x_cal")
println("Y: $y_cal")
println("Z: $z_cal")

# Verify with Geometry
x_geo = sin(pi/2)*cos(pi/2)  # θ = π/2 and ϕ = π/2
y_geo = sin(pi/2)*sin(pi/2)  # θ = π/2 and ϕ = π/2
z_geo = cos(pi/2)            # θ = π/2
println("\nGeometric Expected Coordinates:")
println("X: $x_geo")
println("Y: $y_geo")
println("Z: $z_geo")

println("Match? $(isapprox(y_cal, y_geo))")
