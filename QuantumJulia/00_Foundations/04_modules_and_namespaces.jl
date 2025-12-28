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
MyPhysics.energy(3)


println("\n=== Piece 3: Creating a Module ===")

module MyPhysics
    # Everything inside this block lives in its OWN namespace
    energy(x) = x^2
end
