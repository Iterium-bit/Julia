using LinearAlgebra
## ------------------------------------------------------------------
println("\nPROBLEM 1: The Kronecker Product (Combining States)")
# Objective: Construct a 2-qubit state |0> (x) |1>.
# Math: If u is size M and v is size N, kron(u, v) is size M*N.
#
# Steps:
# 1. Define Qubit 1 in state |0> = [1, 0].
# 2. Define Qubit 2 in state |1> = [0, 1].
# 3. Compute the composite state using 'kron(q1, q2)'.
# 4. Verify the result matches the manual calculation for |01> ([0, 1, 0, 0]).
# 5. Check that the norm is preserved (still 1.0).

# Define Single Qubits
q1 = [1.0+0im,0.0]         # State |0>
q2 = [0.0+0.0im,1.0]       # State |1>

# Tensor Product
psi_composite = kron(q1,q2)
println("composite States |01> :")

# verify
display(psi_composite)
println("Norm: $(norm(psi_composite))")



## ------------------------------------------------------------------
println("\nPROBLEM 2: Matrix Tensor Products")
# Objective: Construct 2-qubit gates from 1-qubit gates.
#
# Steps:
# 1. Define the Pauli X matrix (Quantum NOT gate).
#    X = [0 1; 1 0]
# 2. Define the Identity matrix I2.
# 3. Construct the operator "Flip both qubits": X_all = X (tensor) X.
# 4. Construct the operator "Flip only Qubit 1": X_1 = X (tensor) I.
# 5. Apply these to the state |00> ([1, 0, 0, 0]) and verify the output.

sigma_x = [0.0+0.0im 1.0+0.0im;1.0+0.0im 0.0+0.0im]
I2 = Matrix(1.0*I,2,2)
x_both = kron(sigma_x,sigma_x)

x_first = kron(sigma_x,I2)

psi_00 = kron([1,0],[1,0])               #State |00>
display(psi_00)
psi_flip_both = x_both*psi_00            # Should become |11> -> [0, 0, 0, 1]
display(psi_flip_both)                   
psi__flip_first = x_first*psi_00         # Should become |10> -> [0, 0, 1, 0]
display(psi__flip_first)



## ------------------------------------------------------------------
println("\nPROBLEM 3: Generating Entanglement")
# Objective: Create the Bell State 1/sqrt(2) * (|00> + |11>).
# Circuit: CNOT * (H (x) I) * |00>
#
# Steps:
# 1. Define Hadamard (H) and Identity (I2).
# 2. Construct the "H on Qubit 1" operator: Op1 = kron(H, I2).
# 3. Define the CNOT matrix manually (4x4).
#    (It swaps the amplitudes of |10> and |11>).
# 4. Apply them to |00> ([1, 0, 0, 0]).
# 5. Verify the result is [0.707, 0, 0, 0.707].

H = [1 1;1 -1]                              # Hadamard gate
op = kron(H,Matrix(1*I ,2,2))               # composite Operator
display(op) 

# If control (Q1) is 1, flip target (Q2).
# |00> -> |00>
# |01> -> |01>
# |10> -> |11> (Flip)
# |11> -> |10> (Flip)                       
CNOT = [1 0 0 0;0 1 0 0;0 0 0 1;0 0 1 0]    # Cnot Gate
display(CNOT)
psi_00 = kron([1,0],[1,0])                  # state |00>
display(psi_00)
state = CNOT*op*psi_00                 # Un-Normalised Bell state
bell_state = normalize(state)
println("Final Bell State: ")
display(bell_state)



## ------------------------------------------------------------------
println("\nPROBLEM 4: Schmidt Decomposition (SVD)")
# Objective: Measure entanglement by reshaping the state vector into a matrix.
#
# Steps:
# 1. Take the Bell State from Problem 3 (Entangled).
# 2. Reshape it into a 2x2 Matrix.
#    (Note: Julia reshapes column-major).
# 3. Compute SVD. The singular values are the Schmidt Coefficients.
# 4. Compare with a Product State (Unentangled).


#    Recall bell_state is [0.707, 0, 0, 0.707]
M_entangled = reshape(bell_state, 2, 2)
svd_entangled = svd(M_entangled)

#    Recall psi_00 is [1, 0, 0, 0]
M_product = reshape(psi_00, 2, 2)
svd_product = svd(M_product)

println("\n--- Entanglement Check (Singular Values) ---")
println("Bell State (Entangled): $(svd_entangled.S)")
println("Product State (Separable): $(svd_product.S)")

# Interpretation:
# If you see [0.707, 0.707], it's maximally entangled.
# If you see [1.0, 0.0], it's a product state.


## ------------------------------------------------------------------
println("\nPROBLEM 5: The Partial Trace")
# Objective: "Trace out" Qubit 2 from the Bell State to see what Qubit 1 looks like alone.
#
# Logic: We sum over the hidden qubit's indices.
# - rho_reduced[1,1] = rho[1,1] (00) + rho[2,2] (01)
# - rho_reduced[2,2] = rho[3,3] (10) + rho[4,4] (11)

# Steps:
# 1. Construct the Density Matrix rho = |psi><psi| for the Bell State.
# 2. Implement a manual partial trace loop.
#    Math: rho_A[i,j] = Sum_k ( rho[ik, jk] )
#    (We sum over the index k of the hidden system B).
# 3. Verify that the result is the Maximally Mixed state (0.5 * Identity).
# 1. Construct Full Density Matrix (4x4)
#    Recall bell_state is [0.707, 0, 0, 0.707]
rho_total = bell_state * bell_state' 

# 2. Perform Partial Trace (Tracing out System B)
#    System sizes: A=2 (visible), B=2 (hidden)
dA = 2
dB = 2
rho_A = zeros(ComplexF64, dA, dA)

# We loop over the indices of the system we KEEP (i, j)
for i in 1:dA
    for j in 1:dA
        # We sum over the index of the system we DISCARD (k)
        sum_val = 0.0 + 0im
        for k in 1:dB
            # Convert composite indices (i,k) and (j,k) to global indices 1..4
            # Formula: Global = (SystemA_Index - 1) * DimB + SystemB_Index
            row_global = (i - 1) * dB + k
            col_global = (j - 1) * dB + k
            
            sum_val += rho_total[row_global, col_global]
        end
        rho_A[i, j] = sum_val
    end
end

println("\n--- Partial Trace Results ---")
println("Full System (Pure State): Rank = $(rank(rho_total))")
println("Reduced System (Mixed State):")
display(rho_A)

# Check Purity: tr(rho^2). 
# Pure = 1.0. Mixed < 1.0. Maximally Mixed = 0.5 (for qubit).
purity = real(tr(rho_A^2))
println("Purity of Reduced State: $purity (Expected 0.5)")