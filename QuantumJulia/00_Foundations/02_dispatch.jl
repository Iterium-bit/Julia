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
struct cow <:Animal end

function greet(a::Animal)
    println("Generic animal greetings.")
end
function greet(d::Dog)
    println("Dog Wags tail.")
end
function greet(c::Cat)
    println("Cat says mew.")
end
function greet(c::cow)
    println("Caw says mooo!!!.")
end
greet(Dog())
greet(cow())
greet(Cat())