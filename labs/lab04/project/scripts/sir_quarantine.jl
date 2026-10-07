# # Карантинные меры
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

include(
    srcdir("sir_model.jl")
)

function create_migration_matrix(
    C,
    intensity
)

    M =
        fill(
            intensity / (C - 1),
            C,
            C
        )

    for i in 1:C
        M[i, i] =
            1 - intensity
    end

    return M
end


# ## Один сценарий

function run_scenario(
    use_quarantine;
    threshold=0.10,
    seed=42
)

    model =
        initialize_sir(
            Ns=[1000, 1000, 1000],
            β_und=[0.5, 0.5, 0.5],
            β_det=[0.05, 0.05, 0.05],
            infection_period=14,
            detection_time=7,
            death_rate=0.02,
            reinfection_probability=0.1,
            Is=[1, 0, 0],
            seed=seed,
            migration_rates=
                create_migration_matrix(
                    3,
                    0.15
                )
        )

    closed =
        falses(3)

    closure_day =
        fill(
            0,
            3
        )

    infected_history =
        Int[]

    total_history =
        Int[]

    for day in 1:150

        if use_quarantine

            for city in 1:3

                population =
                    city_population(
                        model,
                        city
                    )

                infected =
                    city_status_count(
                        model,
                        city,
                        :I
                    )

                fraction =
                    population > 0 ?
                    infected / population :
                    0.0

		if !closed[city] && fraction >= threshold

                    model.migration_rates[
                        city,
                        :
                    ] .= 0.0

                    model.migration_rates[
                        city,
                        city
                    ] = 1.0

                    closed[city] =
                        true

                    closure_day[city] =
                        day

                    println(
                        "День ",
                        day,
                        ": закрыт город ",
                        city
                    )
                end
            end
        end

        sir_manual_step!(
            model
        )

        push!(
            infected_history,
            infected_count(model)
        )

        push!(
            total_history,
            nagents(model)
        )
    end

    return (
        infected=infected_history,
        total=total_history,
        closure_day=closure_day
    )
end


# ## Два сопоставимых сценария

println(
    "Сценарий без карантина..."
)

baseline =
    run_scenario(
        false
    )

println(
    "\nСценарий с карантином..."
)

quarantine =
    run_scenario(
        true
    )

days =
    collect(
        1:150
    )

baseline_peak =
    maximum(
        baseline.infected
    )

quarantine_peak =
    maximum(
        quarantine.infected
    )

baseline_deaths =
    3000 -
    baseline.total[end]

quarantine_deaths =
    3000 -
    quarantine.total[end]

println("\nБез карантина:")
println("Пик I = ", baseline_peak)
println("Умерло = ", baseline_deaths)

println("\nС карантином:")
println("Пик I = ", quarantine_peak)
println("Умерло = ", quarantine_deaths)

println(
    "Дни закрытия городов = ",
    quarantine.closure_day
)

df =
    DataFrame(
        time=days,
        no_quarantine=
            baseline.infected,
        quarantine=
            quarantine.infected
    )

CSV.write(
    datadir(
        "quarantine_effect.csv"
    ),
    df
)

p =
    plot(
        days,
        baseline.infected;
        label="Без карантина",
        xlabel="Дни",
        ylabel="Инфицированные",
        linewidth=2
    )

plot!(
    p,
    days,
    quarantine.infected;
    label="С карантином",
    linewidth=2
)

savefig(
    p,
    plotsdir(
        "quarantine_effect.png"
    )
)

println("\nСохранено:")
println("data/quarantine_effect.csv")
println("plots/quarantine_effect.png")

# ## Вывод
#
# Сценарии запускаются с одинаковым seed,
# поэтому можно сравнить эффект карантина.
