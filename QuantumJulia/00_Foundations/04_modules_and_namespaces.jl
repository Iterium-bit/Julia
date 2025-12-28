############################################################
# Modules and Namespaces
#
# PURPOSE:
# This file explains how Julia:
# - separates meaning using namespaces
# - avoids name collisions
# - structures large scientific codebases
#
# CORE IDEAS (CHEAT CODES):
# - Names live in namespaces
# - Modules create namespaces
# - Same name ≠ same meaning
# - export controls visibility
# - using vs import controls convenience vs control
# - relative imports (.) describe location, not behavior
############################################################


############################################################
# Piece 1: Why Namespaces Exist
############################################################

println("=== Piece 1: Why Namespaces Exist ===")

x = 10
println("x = ", x)

# At this point everything lives in the GLOBAL namespace (Main).
# This is fine for small scripts, but dangerous for large systems.


############################################################
# Piece 2: Name Collision (the real problem)
############################################################

println("\n=== Piece 2: Name Collision ===")

function energy(x)
    x^2
end

println("energy(3) = ", energy(3))

# Same name, different meaning
function energy(x, y)
    x + y
end

println("energy(3, 4) = ", energy(3, 4))
println("energy(5) = ", energy(5))

# CHEAT CODE:
# Dispatch resolves *which rule runs*
# Namespaces resolve *what the name means*


############################################################
# Piece 3: Modules create separate universes
############################################################

println("\n=== Piece 3: Creating Modules ===")

module Mechanics
    energy(x) = x^2
end

module Quantum
    energy(x) = x
end

println("Mechanics.energy(3) = ", Mechanics.energy(3))
println("Quantum.energy(3)   = ", Quantum.energy(3))

# Same name "energy", completely different meanings.
# No collision because namespaces are separate.


############################################################
# Piece 4: export — controlling visibility
############################################################

println("\n=== Piece 4: export ===")

module Thermodynamics
    export energy

    # Public API
    energy(x) = 2x

    # Internal detail (not exported)
    internal_constant = 42
end

println("Thermodynamics.energy(3) = ",
        Thermodynamics.energy(3))

# NOTE:
# energy(3) does NOT work yet.
# export does NOT inject names automatically.


############################################################
# Piece 5: using — convenience
############################################################

println("\n=== Piece 5: using ===")

using .Thermodynamics

println("energy via using = ", energy(4))

# CHEAT CODE:
# using brings EXPORTED names into scope
# Convenient, but can cause collisions in large codebases


############################################################
# Piece 6: import — control
############################################################

println("\n=== Piece 6: import ===")

import .Mechanics

println("energy via import (qualified) = ",
        Mechanics.energy(5))

# No names leaked into global scope.
# Everything stays explicit.


############################################################
# Piece 7: Extending a function (requires import)
############################################################

println("\n=== Piece 7: Extending a function ===")

import .Mechanics: energy

energy(x::Float64) = x^3

println("Extended Mechanics.energy(2.0) = ",
        energy(2.0))

# CHEAT CODE:
# You MUST import a function before extending it.
# Julia forbids silent modification of external behavior.


############################################################
# Final Piece: Relative imports (module hierarchy)
############################################################

println("\n=== Final Piece: Relative Imports ===")

module Physics

    export speed_of_light

    speed_of_light() = 3.0e8

    module Quantum

        export photon_energy

        # Access parent module explicitly
        using ..Physics

        photon_energy(frequency) = 6.626e-34 * frequency

        function info()
            println("c = ", speed_of_light())
        end
    end
end

println("Calling from nested modules:")
Physics.Quantum.info()

println("Photon energy example = ",
        Physics.Quantum.photon_energy(5.0e14))


############################################################
# FINAL CHEAT SHEET
############################################################
# module        → creates a namespace
# export        → marks public names
# using         → brings exported names into scope
# import        → loads module without leaking names
# import M: f   → allows extending function f
# .             → current module
# ..            → parent module
#
# Namespaces control MEANING
# Dispatch controls BEHAVIOR
############################################################
