############################################################
# Matrix Types
#
# This file builds the correct mental model for matrices
# in Julia: as typed linear-algebraic objects.
############################################################

using LinearAlgebra

println("=== Piece 1: A Matrix Is a Typed Object ===")
A = [1 2 3;
     4 5 6;
     7 8 9;
     10 11 12]

println("A =")
println(A)
println(typeof(A))
println(size(A))
println(eltype(A))

println("\n=== Piece 2: Same Matrix, Different Algebra ===")