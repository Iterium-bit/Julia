println("===  Layer 1: Multiple Dispatch===")
function describe(X::Int)
    return println("This is an Integer.")
end
function describe(x::Float64)
    return println("This is a floating-point number.")
end
describe(2)
describe(2.0)

println("\n=== Layer 2: Dispatch on Multiple Arguments ===")
function interact(a::Int , b::Int)
    return println("This is Integer-Integer interaction.")
end
function interact(a::Int , b::Float64 )
    return println("This is Integer-Float interaction.")
end
function interact(a::Float64 , b::Float64)
    return println("This is Float-Float interaction.")
end
interact(1,4)
interact(2,3.3)
interact(3.2,4.3)

println("\n=== Layer 3: Abstract Type + Dispatch")
abstract type Animal end
struct Dog <:Animal end
struct Cat <:Animal end
struct Cow <:Animal end

function greet(a::Animal)
    println("Generic animal greetings.")
end
function greet(d::Dog)
    println("Dog Wags tail.")
end
function greet(c::Cat)
    println("Cat says mew.")
end
function greet(C::cow)
    println("Caw says mooo!!!.")
end
greet(Dog())
greet(Cow())
greet(Cat())

function interact(a::Dog, b::Cat)
    println("Dog chases Cat.")
end
function interact(a::Cat, b::Dog)
    println("Cat escapes to higher ground.")
end
interact(Dog(),Cat())
interact(Cat(),Dog())
interact(1,2.3)


println("\n=== Layer 4:Parametric Dispatch ===")
abstract type Particle end
struct Electron<: Particle end
struct Proton <:Particle end
function scatter(a::T,b::T) where T <: Particle
    println("Elastic scattering between identical particles.")
end
function scatter(a::Electron , b::Proton)
    println("Electron-Proton Coulomb scattering.")
end
scatter(Electron(),Proton())
#scatter(Proton(),Electron())
scatter(Electron(),Electron())
scatter(Proton(),Proton())

println("\n=== Layer 5: Method Tables ===")

methods(interact)

function interact(a::Dog, b::Animal)
    println("Dog interacting with some animal")
end

interact(Dog(), Cat())
interact(Dog(), Dog())

println("\n=== Layer 6: @which ===")

@which interact(Dog(), Cat())
@which interact(Dog(), Dog())
function interact(a::Animal, b::Cat)
    println("Some animal interacting with cat")
end

interact(Dog(), Cat())
