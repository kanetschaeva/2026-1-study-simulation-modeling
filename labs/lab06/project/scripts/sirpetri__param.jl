# # Параметрическое исследование SIR
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# Исследуются комбинации двух параметров:
# коэффициента заражения β
# и коэффициента выздоровления γ.

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using CSV
using Plots

include(
    srcdir(
        "SIRPetri.jl"
    )
)

using .SIRPetri


# ## Наборы параметров

β_values =
    [
        0.1,
        0.3,
        0.5,
        0.8
    ]

γ_values =
    [
        0.05,
        0.10,
        0.20
    ]

tmax =
    100.0

results =
    NamedTuple[]

println(
    "Параметрическое исследование β × γ"
)


# ## Серия расчётов

for γ in γ_values

    for β in β_values

        net,
        u0,
        _ =
            build_sir_network(
                β,
                γ
            )

        df =
            simulate_deterministic(
                net,
                u0,
                (
                    0.0,
                    tmax
                );
                saveat=0.5,
                rates=[
                    β,
                    γ
                ]
            )

        peak_index =
            argmax(
                df.I
            )

        peak_I =
            df.I[
                peak_index
            ]

        peak_time =
            df.time[
                peak_index
            ]

        final_R =
            df.R[end]

        push!(
            results,
            (
                β=β,
                γ=γ,
                peak_I=peak_I,
                peak_time=peak_time,
                final_R=final_R
            )
        )

        println(
            "β=",
            β,
            ", γ=",
            γ,
            " -> peak I=",
            round(
                peak_I,
                digits=3
            ),
            ", t_peak=",
            round(
                peak_time,
                digits=3
            )
        )
    end
end


# ## Таблица

df_params =
    DataFrame(
        results
    )

CSV.write(
    datadir(
        "sir_parameter_grid.csv"
    ),
    df_params
)

println(
    "\nКомбинаций рассчитано: ",
    nrow(df_params)
)


# ## График

p =
    plot(
        xlabel="β",
        ylabel="Peak I",
        title=
            "Пик инфекции для разных β и γ"
    )

for γ in γ_values

    part =
        filter(
            :γ =>
                value ->
                    value == γ,
            df_params
        )

    plot!(
        p,
        part.β,
        part.peak_I;
        marker=:circle,
        linewidth=2,
        label=
            "γ = $γ"
    )
end

savefig(
    p,
    plotsdir(
        "sir_parameter_grid.png"
    )
)

println(
    "Сохранено:"
)

println(
    "data/sir_parameter_grid.csv"
)

println(
    "plots/sir_parameter_grid.png"
)


# ## Вывод
#
# Использование сетки параметров позволяет
# сравнивать совместное влияние скорости
# заражения и скорости выздоровления.
