using QuantumOptics
using PyPlot
using Dates

# --- SMART SAVE FUNCTION ---
function smart_save(plot_name)
    # 1. Create 'plots' folder if missing
    if !isdir("plots")
        mkdir("plots")
    end

    # 2. Generate timestamped filename
    time_tag = Dates.format(now(), "HH-MM-SS")
    filename = "plots/$(plot_name)_$(time_tag).png"

    # 3. Save and Display
    savefig(filename, dpi=300, bbox_inches="tight")
    println("✅ Saved: $filename")
    display(gcf()) 
end
println("Loaded: QuantumOptics, PyPlot, and smart_save()")
