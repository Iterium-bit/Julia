############################################################
# Memory and Mutability
#
# PURPOSE:
# This file builds a final, unambiguous mental model of
# how Julia handles memory, objects, and variables.
#
# CORE IDEAS (CHEAT CODES):
# - Variables bind to objects
# - Mutation changes objects
# - Assignment (=) changes bindings
# - Sharing is explicit
# - Copying is explicit
# - Immutability is the default
#
# If you understand this file, you will NOT make
# silent memory bugs in serious Julia code.
############################################################


############################################################
# Piece 1: Immutable Objects (Numbers)
############################################################

println("\n=== Piece 1: Immutable Objects ===")

x = 10
y = x   # y binds to the SAME value object as x

println("x = ", x)
println("y = ", y)

# IMPORTANT:
# Integers are IMMUTABLE.
# You cannot change the value 10 itself.

x = 30   # This does NOT change 10 → it REBINDS x to a new value

println("\nAfter Rebinding x:")
println("x = ", x)
println("y = ", y)

# CHEAT CODE:
# x = 30  → changes the LABEL x
# not the VALUE 10


############################################################
# Piece 2: Mutable Objects (Arrays)
############################################################

println("\n=== Piece 2: Mutable Objects ===")

A = [1, 2, 3]
B = A   # Explicit SHARING of the same array

println("A = ", A)
println("B = ", B)

# Mutation: change the OBJECT, not the variable
B[1] = 25

println("\nAfter mutating B:")
println("A = ", A)
println("B = ", B)

# CHEAT CODE:
# A[1] = ...  → mutation (object changes)
# A = ...     → rebinding (name changes)

# Arrays have a FIXED element type.
# You cannot mix Int and Float in the same array.

A = Float64[1, 2, 3, 4]
println("\nA converted explicitly to Float64:")
println("A = ", A)

# CHEAT CODE:
# Julia never changes container types silently.
# If you want Float64 → you must say it.


############################################################
# Piece 3: Binding vs Object
############################################################

println("\n=== Piece 3: Binding vs Object ===")

C = [1, 2, 3]
D = C   # C and D bind to the SAME object

println("Initially:")
println("C = ", C)
println("D = ", D)

# This creates a NEW array and rebinds C
C = [100, 200, 300, 400]

println("\nAfter rebinding C:")
println("C = ", C)
println("D = ", D)

# CHEAT CODE:
# Mutation → affects all names pointing to object
# Rebinding → affects ONLY that name


############################################################
# Piece 4: Copying vs Sharing
############################################################

println("\n=== Piece 4: Copying vs Sharing ===")

E = [2, 4, 6]
F = E          # shared object
G = copy(E)    # independent object

println("Initially:")
println("E = ", E)
println("F = ", F)
println("G = ", G)

# Mutate original array
E[1] = 5

println("\nAfter mutating E:")
println("E = ", E)
println("F = ", F)   # changes (shared)
println("G = ", G)   # unchanged (copied)

# CHEAT CODE:
# =        → share
# copy()  → duplicate
#
# Julia NEVER copies unless you ask.


############################################################
# Piece 5: Immutable vs Mutable Structs
############################################################

println("\n=== Piece 5: Immutable vs Mutable Structs ===")

# Immutable struct (DEFAULT in Julia)
struct PointImmutable
    x::Float64
    y::Float64
end

# Mutable struct (must be explicitly requested)
mutable struct PointMutable
    x::Float64
    y::Float64
end

p_1 = PointImmutable(1.0, 5.0)
p_2 = PointMutable(1.0, 3.0)

println("Initial values:")
println("p_1 = ", p_1)
println("p_2 = ", p_2)

# p_1.x = 10.0   #  NOT allowed (immutable)
p_2.x = 10.0     #  allowed (mutable)

println("\nAfter attempting mutation:")
println("p_1 = ", p_1)
println("p_2 = ", p_2)

# CHEAT CODE:
# - struct        → immutable (safe, fast, predictable)
# - mutable struct → mutable (use only when needed)
#
# BEST PRACTICE:
# Immutable values inside mutable containers
