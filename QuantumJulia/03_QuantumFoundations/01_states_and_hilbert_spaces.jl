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

