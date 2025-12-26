println("=== Julia Types: Foundation ===")

println("\n=== Types: Layer 1 ===")

x = 5
y = 5

println("x == y", x==y)
println("type of x = ", typeof(x))
println("type of y = ", typeof(y))
println("type of x = type of y:  ", typeof(x) == typeof(y))

println("\n-- Same values,different types")
a = 5
b = 5.0
c = 5+0im
println("Type of a: ",typeof(a))
println("Type of b: ",typeof(b))
println("Type of c: ",typeof(c))



println("\n=== Types: Layer 2 ===")

println("Integer <: Number → ", Integer <: Number)
println("Float64 <: Number → ", Float64 <: Number)
println("ComplexF64 <: Number → ", ComplexF64 <: Number)
println("Bool <: Number → ", Bool <: Number)

println("\n--- Supertype Queries ---")
println("supertype(Int64)         --> ",supertype(Int64))
println("supertype(Float64)       --> ", supertype(Float64))
println("supertype(ComplexF64)    --> ", supertype(ComplexF64))

println("\n--- Bool as Number ---")

println(true + true)
println(true * false)
println(3 * true)
println(3 * false)

println("\n=== Layer 3: Type Promotion ===")
println("1+1               --> ",1+1,    " | ",typeof(1+1))
println("1+1.0             --> ",1+1.0,  " | ",typeof(1+1.0))
println("1.0 +1f0          --> ",1 +1f0, " | ",typeof(1+1.1f0))
println("1+true            --> ", 1+true," | ",typeof(1+true))
println("1+(1+0im)         --> ",1+(1+0im)," | ",typeof(1+(1+0im)))


println("\n--- Promotion rules ---")

println(promote_type(Int64, Float64))
println(promote_type(Float32, Float64))
println(promote_type(Int64, ComplexF64))

println("\n=== Layer 4: Containers & Element Types ===")
v1 = [1,2,3]
v2 = [1.0,2.0,3.0]
v3 = [1,2.0,3]

println("v1: ",typeof(v1))
println("v2: ",typeof(v2))
println("v3: ",typeof(v3))

println("\n--- Container vs Element ---")

println("typeof(v3)  → ", typeof(v3))
println("eltype(v3)  → ", eltype(v3))    #eltype = element type

println("\n=== Layer 5: Type Stability ===")

#A function is type-stable if its return type depends only on input types, not on values.
#A function whose output type depends on values rather than types is not a well-defined mapping in the type system.
function unstable(x)
    if x> 0
        return x
    else
        return 0.0
    end
end

println("unstable(2)  --> ", unstable(2),     " | ",typeof(unstable(2)))
println("unstable(-2) --> ", unstable(-2),    " | ",typeof(unstable(2)))

function stable(x)
    if x > 0
        return x
    else
        return 0
    end
end
println("stable(2)    --> ", stable(2),    " | ",typeof(stable(2)))
println("stabel(-2)   --> ", stable(-2),   " | ",typeof(stable(-2)))

println("\n--- Compiler reasoning ---")

@code_warntype unstable(2)
@code_warntype stable(2)


println("\n=== Final 6: typeof vs eltype ===")

A = [1, 2, 3]
B = [1.0, 2.0, 3.0]
C = [1, 2.0, 3]

println("typeof(A) → ", typeof(A))
println("eltype(A) → ", eltype(A))

println("typeof(B) → ", typeof(B))
println("eltype(B) → ", eltype(B))

println("typeof(C) → ", typeof(C))
println("eltype(C) → ", eltype(C))

println("\n=== Final Layer: Parametric Types ===")

struct Box{T}
    vaue::T 
end
b1 = Box(1)
b2 = Box(1.0)
b3 = Box(1+0im)

println("b1 type: ",typeof(b1))
println("b2 type: ",typeof(b2))
println("b3 type: ",typeof(b3))

square(x::T) where T = x^2
println("square of 2: ",square(2))
println("square of 2.0: ",square(2.0))
println("square of 1+1im: ",square(1+1im))

println("\n=== Abstract vs Concrete Types ===")

abstract type QuantumObject end

struct Ket{T} <: QuantumObject
    data::Vector{T}
end

ψ = Ket{ComplexF64}([1+0im, 0+0im])

println(typeof(ψ))
println(supertype(typeof(ψ)))
