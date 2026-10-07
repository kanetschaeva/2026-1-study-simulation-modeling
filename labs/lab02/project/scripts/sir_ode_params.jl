# # Параметрическое исследование модели SIR
#
# **Автор:** Нечаева Кира Андреевна
#
# Исследуем влияние среднего числа контактов `c`.

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DifferentialEquations
using DataFrames
using Plots
using CSV
using JLD2

script_name =
    splitext(basename(PROGRAM_FILE))[1]

mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# ## Модель

function sir_ode!(du, u, p, t)

    S, I, R = u
    β, c, γ = p

    N = S + I + R

    du[1] = -β * c * I / N * S
    du[2] = β * c * I / N * S - γ * I
    du[3] = γ * I

    nothing
end

# ## Базовые условия

u0 = [990.0, 10.0, 0.0]
tspan = (0.0, 60.0)

β = 0.05
γ = 0.25

c_values =
    [2.0, 4.0, 5.0, 6.0, 10.0]

results = DataFrame(
    c=Float64[],
    R0=Float64[],
    peak_I=Float64[],
    peak_time=Float64[],
    final_R=Float64[]
)

plt = plot(
    xlabel="Время, дни",
    ylabel="Количество инфицированных",
    title="SIR: влияние числа контактов c",
    linewidth=2,
    grid=true,
    size=(900, 500)
)

# ## Серия экспериментов

for c in c_values

    p = [β, c, γ]

    prob =
        ODEProblem(
            sir_ode!,
            u0,
            tspan,
            p
        )

    sol =
        solve(
            prob,
            Tsit5();
            saveat=0.1
        )

    I =
        [u[2] for u in sol.u]

    R =
        [u[3] for u in sol.u]

    idx = argmax(I)

    R0_value =
        c * β / γ

    push!(
        results,
        (
            c,
            R0_value,
            I[idx],
            sol.t[idx],
            R[end]
        )
    )

    plot!(
        plt,
        sol.t,
        I,
        label="c=$c, R0=$(round(R0_value,digits=2))",
        linewidth=2
    )
end

# ## Результаты

println("Параметрическое исследование SIR:\n")
println(results)

savefig(
    plt,
    plotsdir(
        script_name,
        "sir_contact_scan.png"
    )
)

CSV.write(
    datadir(
        script_name,
        "sir_contact_scan.csv"
    ),
    results
)

@save datadir(
    script_name,
    "sir_contact_scan.jld2"
) results

println(
    "\nПараметрическое исследование SIR завершено."
)
