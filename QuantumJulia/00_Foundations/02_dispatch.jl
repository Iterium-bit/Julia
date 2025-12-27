############################################################
#  Multiple Dispatch — Foundations
#
#  This file demonstrates how Julia treats functions as
#  collections of interaction rules (methods), selected
#  based on the types of *all* arguments.
#
#  Key ideas:
#  - Functions = sets of laws
#  - Dispatch = law selection
#  - Abstract types define roles
#  - Ambiguity is a feature, not a bug
############################################################

############################################################
# Layer 1: Multiple Dispatch (Single Argument)
############################################################

println("=== Layer 1: Multiple Dispatch ===")

function describe(x::Int)
    println("This is an Integer.")
end

function describe(x::Float64)
    println("This is a floating-point number.")
end

describe(2)
describe(2.0)

############################################################
# Layer 2: Dispatch on Multiple Arguments
############################################################

println("\n=== Layer 2: Dispatch on Multiple Arguments ===")

function interact(a::Int, b::Int)
    println("This is Integer–Integer interaction.")
end

function interact(a::Int, b::Float64)
    println("This is Integer–Float interaction.")
end

function interact(a::Float64, b::Float64)
    println("This is Float–Float interaction.")
end

interact(1, 4)
interact(2, 3.3)
interact(3.2, 4.3)

############################################################
# Layer 3: Abstract Types + Dispatch
############################################################

println("\n=== Layer 3: Abstract Types + Dispatch ===")

# Abstract type defines a ROLE, not a concrete object
abstract type Animal end

# Concrete realizations of the role
struct Dog <: Animal end
struct Cat <: Animal end
struct Cow <: Animal end

# Generic fallback rule
function greet(a::Animal)
    println("Generic animal greeting.")
end

# More specific rules override generic ones
function greet(d::Dog)
    println("Dog wags tail.")
end

function greet(c::Cat)
    println("Cat says meow.")
end

function greet(c::Cow)
    println("Cow says mooo.")
end

greet(Dog())
greet(Cow())
greet(Cat())

############################################################
# Interaction rules between animals
############################################################

function interact(a::Dog, b::Cat)
    println("Dog chases Cat.")
end

function interact(a::Cat, b::Dog)
    println("Cat escapes to higher ground.")
end

interact(Dog(), Cat())
interact(Cat(), Dog())

# Falls back to numeric interaction rule defined earlier
interact(1, 2.3)

############################################################
# Layer 4: Parametric Dispatch
############################################################

println("\n=== Layer 4: Parametric Dispatch ===")

abstract type Particle end

struct Electron <: Particle end
struct Proton  <: Particle end

# Generic rule: applies to identical particle types
function scatter(a::T, b::T) where T <: Particle
    println("Elastic scattering between identical particles.")
end

# More specific physical interaction
function scatter(a::Electron, b::Proton)
    println("Electron–Proton Coulomb scattering.")
end

scatter(Electron(), Proton())
scatter(Electron(), Electron())
scatter(Proton(), Proton())

# NOTE:
# scatter(Proton(), Electron()) is intentionally undefined
# to demonstrate ordered dispatch and explicit symmetry encoding

############################################################
# Layer 5: Method Tables
############################################################

println("\n=== Layer 5: Method Tables ===")

# Inspect all interaction laws known to Julia
methods(interact)

# Add a more general rule
function interact(a::Dog, b::Animal)
    println("Dog interacting with some animal.")
end

interact(Dog(), Cat())
interact(Dog(), Dog())

############################################################
# Layer 6: @which — Dispatch Inspection
############################################################

println("\n=== Layer 6: @which ===")

# Shows exactly which method Julia selects
@which interact(Dog(), Cat())
@which interact(Dog(), Dog())

############################################################
# Layer 7: Ambiguity Demonstration (INTENTIONAL)
############################################################

# This introduces a competing rule
function interact(a::Animal, b::Cat)
    println("Some animal interacting with a cat.")
end

# The following call will now trigger an ambiguity error
# because two equally specific rules apply:
#
#   interact(::Dog, ::Animal)
#   interact(::Animal, ::Cat)
#
# Uncomment to observe the error intentionally.
#
# interact(Dog(), Cat())

############################################################
# End of file
############################################################
