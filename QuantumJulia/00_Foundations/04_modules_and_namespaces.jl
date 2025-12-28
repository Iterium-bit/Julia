############################################################
# Modules and Namespaces
#
# This file explains:
# - what a module really is
# - why namespaces matter
# - how Julia avoids name collisions
# - how large scientific code stays sane
############################################################
println("=== Piece 1: Why Namespaces Exist ===")

x = 10

println("x = ", x)

println("\n=== Piece 2: Name Collision ===")
function energy(x)
    return x^2    
end

println("energy(3) = ", energy(3))
# Another definition with the SAME name
function energy(x, y)
    return x + y
end

println("energy(3, 4) = ", energy(3, 4))
println(energy(5))


module MyPhysics
    energy(x) = x^2
end
MyPhysics.energy(6)


println("\n=== Piece 3: Creating a Module ===")

module MyPhysics
    # Everything inside this block lives in its OWN namespace
    energy(x) = x^2
end
println(energy(10))
MyPhysics.energy(3)

module Mechanics
    energy(x) = x^2
end

module Quantum
    energy(x) = x
end

println(Mechanics.energy(3))
println(Quantum.energy(3))

println("\n=== Piece 4: export ===")

module Mechanics
    export energy
    energy(x) =x^2
end
println("Calling exported function:")
println(Mechanics.energy(3))
energy(3)
println("\n=== Piece 5: using ===")

using .Mechanics   # dot means "local module in this file"

println("energy via using:")
println(energy(4))

energy(4)

using Mechanics
using Quantum

println("\n=== Piece 6: import ===")

import .Mechanics

println("energy via import:")
println(Mechanics.energy(5))

println("\n=== Piece 7: Extending a function ===")

import .Mechanics: energy

energy(x::Float64) = x^3

println("Extended energy:")
println(energy(2.0))

