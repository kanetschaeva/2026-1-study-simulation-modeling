# # Сканирование коэффициента заразности
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using Plots
using CSV
using Statistics

include(
    srcdir("sir_model.jl")
)

# ## Один эксперимент

function run_experiment(
    beta,
    seed
)

    initial_total = 3000

    model =
        initialize_sir(
            Ns=[1000, 1000, 1000],
            β_und=fill(beta, 3),
            β_det=fill(beta / 10, 3),
            infection_period=14,
            detection_time=7,
            death_rate=0.02,
            reinfection_probability=0.1,
            Is=[0, 0, 1],
            seed=seed
        )

    peak = 0.0

    for _ in 1:100

        sir_manual_step!(
            model
        )

        fraction =
            infected_count(model) /
            initial_total

        peak =
            max(
                peak,
                fraction
            )
    end

    final_inf =
        infected_count(model) /
        initial_total

    final_rec =
        recovered_count(model) /
        initial_total

    deaths =
        initial_total -
        nagents(model)

    return (
        peak=peak,
        final_inf=final_inf,
        final_rec=final_rec,
        deaths=deaths
    )
end


# ## Параметрическое сканирование

beta_range =
    0.1:0.1:1.0

seeds =
    [42, 43, 44]

results =
    NamedTuple[]

println(
    "Запуск сканирования β..."
)

for beta in beta_range

    for seed in seeds

        result =
            run_experiment(
                beta,
                seed
            )

        push!(
            results,
            (
                beta=beta,
                seed=seed,
                peak=result.peak,
                final_inf=result.final_inf,
                final_rec=result.final_rec,
                deaths=result.deaths
            )
        )

        println(
            "β = ",
            beta,
            ", seed = ",
            seed,
            " — готово"
        )
    end
end

# ## Таблица всех экспериментов

df =
    DataFrame(
        results
    )

CSV.write(
    datadir(
        "beta_scan_all.csv"
    ),
    df
)

# ## Усреднение повторов

grouped =
    combine(
        groupby(
            df,
            :beta
        ),

        :peak =>
            mean =>
            :mean_peak,

        :final_inf =>
            mean =>
            :mean_final_inf,

        :final_rec =>
            mean =>
            :mean_final_rec,

        :deaths =>
            mean =>
            :mean_deaths
    )

sort!(
    grouped,
    :beta
)

# ## Наблюдаемый порог

epidemic_rows =
    grouped[
        grouped.mean_peak .> 0.05,
        :
    ]

if nrow(epidemic_rows) > 0

    observed_threshold =
        epidemic_rows.beta[1]

    println(
        "\nМинимальный β с пиком I > 5%: ",
        observed_threshold
    )

else

    println(
        "\nВ исследованном диапазоне порог не найден."
    )
end

# ## Теоретический порог R0 = 1

γ =
    1 / 14

theoretical_beta =
    γ

println(
    "Теоретический порог β при R0 = 1: ",
    round(
        theoretical_beta,
        digits=4
    )
)

# ## Визуализация

p =
    plot(
        grouped.beta,
        grouped.mean_peak;
        label="Пик эпидемии",
        xlabel="Коэффициент заразности β",
        ylabel="Доля начальной популяции",
        marker=:circle,
        linewidth=2
    )

plot!(
    p,
    grouped.beta,
    grouped.mean_final_inf;
    label="Конечная доля I",
    marker=:square
)

plot!(
    p,
    grouped.beta,
    grouped.mean_deaths ./ 3000;
    label="Доля умерших",
    marker=:diamond
)

savefig(
    p,
    plotsdir(
        "beta_scan.png"
    )
)

println("\nСохранено:")
println("data/beta_scan_all.csv")
println("plots/beta_scan.png")

# ## Вывод
#
# Повторные запуски с разными seed
# учитывают случайность агентной модели.
