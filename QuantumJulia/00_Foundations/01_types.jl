############################################################
#  Julia Types: Foundations
#
#  This file builds a deep, conceptual understanding of
#  Julia’s type system — the real reason behind its
#  correctness, predictability, and performance.
#
#  Philosophy:
#  - Types encode mathematical structure
#  - Values live inside that structure
#  - Performance is a consequence, not a goal
############################################################

println("=== Julia Types: Foundation ===")

############################################################
# Layer 1: What is a Type?
# ----------------------------------------------------------
# Values answer: "What is it?"
# Types answer:  "What rules apply to it?"
############################################################

println("\n=== Types: Layer 1 ===")

x = 5
y = 5

# Value comparison
println("x == y               --> ", x == y)

# Type inspection
println("type of x            --> ", typeof(x))
println("type of y            --> ", typeof(y))
println("type of x == type of y --> ", typeof(x) == typeof(y))

############################################################
# Same numerical value, different mathematical structures
############################################################

println("\n-- Same value, different types --")

a = 5           # Integer (exact, discrete)
b = 5.0         # Float64 (approximate, continuous)
c = 5 + 0im     # Complex number (different algebra)

println("Type of a --> ", typeof(a))
println("Type of b --> ", typeof(b))
println("Type of c --> ", typeof(c))

############################################################
# Layer 2: Type Hierarchy
# ----------------------------------------------------------
# Julia types form a mathematical hierarchy, not a flat list.
############################################################

println("\n=== Types: Layer 2 ===")

println("Integer <: Number   --> ", Integer <: Number)
println("Float64 <: Number   --> ", Float64 <: Number)
println("ComplexF64 <: Number --> ", ComplexF64 <: Number)
println("Bool <: Number      --> ", Bool <: Number)

println("\n--- Supertype Queries ---")

println("supertype(Int64)      --> ", supertype(Int64))
println("supertype(Float64)    --> ", supertype(Float64))
println("supertype(ComplexF64) --> ", supertype(ComplexF64))

############################################################
# Bool as a Number
# ----------------------------------------------------------
# Bool behaves numerically (0 or 1) but carries logical meaning.
############################################################

println("\n--- Bool as Number ---")

println("true + true   --> ", true + true)
println("true * false  --> ", true * false)
println("3 * true      --> ", 3 * true)
println("3 * false     --> ", 3 * false)

############################################################
# Layer 3: Type Promotion
# ----------------------------------------------------------
# When two types meet, Julia promotes to a common type
# that preserves all information.
############################################################

println("\n=== Layer 3: Type Promotion ===")

println("1 + 1        --> ", 1 + 1,        " | ", typeof(1 + 1))
println("1 + 1.0      --> ", 1 + 1.0,      " | ", typeof(1 + 1.0))
println("1.0 + 1f0    --> ", 1.0 + 1f0,    " | ", typeof(1.0 + 1f0))
println("1 + true     --> ", 1 + true,     " | ", typeof(1 + true))
println("1 + (1+0im)  --> ", 1 + (1+0im),  " | ", typeof(1 + (1+0im)))

println("\n--- Promotion Rules (Explicit) ---")

println("Int64, Float64   --> ", promote_type(Int64, Float64))
println("Float32, Float64 --> ", promote_type(Float32, Float64))
println("Int64, ComplexF64 --> ", promote_type(Int64, ComplexF64))

############################################################
# Layer 4: Containers & Element Types
# ----------------------------------------------------------
# Containers in Julia are homogeneous: one element type,
# one algebra, one set of rules.
############################################################

println("\n=== Layer 4: Containers & Element Types ===")

v1 = [1, 2, 3]
v2 = [1.0, 2.0, 3.0]
v3 = [1, 2.0, 3]   # promoted at construction

println("v1 type --> ", typeof(v1))
println("v2 type --> ", typeof(v2))
println("v3 type --> ", typeof(v3))

println("\n--- Container vs Element ---")

println("typeof(v3) --> ", typeof(v3))   # structure
println("eltype(v3) --> ", eltype(v3))   # algebra inside

############################################################
# Layer 5: Type Stability
# ----------------------------------------------------------
# A function is type-stable if its return type depends
# only on input types, not on values.
############################################################

println("\n=== Layer 5: Type Stability ===")

# Type-unstable: return type depends on value
function unstable(x)
    if x > 0
        return x
    else
        return 0.0   # introduces Float64
    end
end

println("unstable(2)   --> ", unstable(2),  " | ", typeof(unstable(2)))
println("unstable(-2)  --> ", unstable(-2), " | ", typeof(unstable(-2)))

# Type-stable: return type is predictable
function stable(x)
    if x > 0
        return x
    else
        return zero(x)   # preserves type of x
    end
end

println("stable(2)     --> ", stable(2),   " | ", typeof(stable(2)))
println("stable(-2)    --> ", stable(-2),  " | ", typeof(stable(-2)))

println("\n--- Compiler Reasoning ---")

@code_warntype unstable(2)
@code_warntype stable(2)

############################################################
# typeof vs eltype (Revisited)
############################################################

println("\n=== Final Layer: typeof vs eltype ===")

A = [1, 2, 3]
B = [1.0, 2.0, 3.0]
C = [1, 2.0, 3]

println("typeof(A) --> ", typeof(A))
println("eltype(A) --> ", eltype(A))

println("typeof(B) --> ", typeof(B))
println("eltype(B) --> ", eltype(B))

println("typeof(C) --> ", typeof(C))
println("eltype(C) --> ", eltype(C))

############################################################
# Parametric Types
# ----------------------------------------------------------
# Parametric types move variability to the type level,
# enabling specialization without runtime overhead.
############################################################

println("\n=== Final Layer: Parametric Types ===")

struct Box{T}
    value::T
end

b1 = Box(1)
b2 = Box(1.0)
b3 = Box(1 + 0im)

println("b1 type --> ", typeof(b1))
println("b2 type --> ", typeof(b2))
println("b3 type --> ", typeof(b3))

# Parametric function
square(x::T) where T = x^2

println("square(2)        --> ", square(2))
println("square(2.0)      --> ", square(2.0))
println("square(1 + 1im)  --> ", square(1 + 1im))

############################################################
# Abstract vs Concrete Types
# ----------------------------------------------------------
# Abstract types organize ideas.
# Concrete types store data and determine performance.
############################################################

println("\n=== Abstract vs Concrete Types ===")

abstract type QuantumObject end

struct Ket{T} <: QuantumObject
    data::Vector{T}
end

ψ = Ket{ComplexF64}([1 + 0im, 0 + 0im])

println("ψ type      --> ", typeof(ψ))
println("supertype   --> ", supertype(typeof(ψ)))
