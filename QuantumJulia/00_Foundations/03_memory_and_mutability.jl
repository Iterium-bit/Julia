############################################################
# Memory and Mutability
#
# This file explains:
# - mutable vs immutable objects
# - bindings vs values
# - copying vs sharing
# - why Julia performance depends on these ideas
############################################################


println("\n=== Piece 1: immutable Objects ===")
x = 10 
y = x

println("x = ", x)
println("y = ", y)

x= 30 # Rebinding x, not changing the values
println("\n After Rebinding")
println("x = ",x)
println("y =", y)


println("\n=== Piece 2: Mutable Objects ===")
A = [1,2,3]
B = A

println("A =", A)
println("B =", B)

B[1] = 25
println("A =",A)
println("B =",B)

A =  Float64[1,2,3,4]
println("A = ",A)   ## this is how u can convert a list of integers to float64.


println("\n=== Piece 3: Binding vs Object ===")
C = [1,2,3]
D = C

println("Initially:")
println("C =", C)
println("D =", D)
C = [100,200,300,400] # Rebinding C to New Array
println("\nAfter Rebinding C:")
println("C =",C)
println("D =",D)

println("\n=== Piece 4: Copying vs sharing ===")
E = [2,4,6]
F = E
G = E
G = copy(E)

println("Initially:")
println("E =", E)
println("F =", F)
println("G =", G)

E[1] = 5

println("\nAfter Mutating:")
println("E =", E)
println("F =", F)
println("G =", G)