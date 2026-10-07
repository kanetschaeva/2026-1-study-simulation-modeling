using DrWatson
@quickactivate "project"

using BlackBoxOptim
using Statistics
using JLD2

include(
    srcdir("sir_model.jl")
)

function evaluate_parameters(
    x;
    replicates=3
)

    beta =
        x[1]

    detection_time =
        clamp(
            round(
                Int,
                x[2]
            ),
            3,
            14
        )

    death_rate =
        x[3]

    peaks =
        Float64[]

    death_fractions =
        Float64[]

    initial_total =
        3000

    for rep in 1:replicates

        model =
            initialize_sir(
                Ns=[1000, 1000, 1000],
                β_und=fill(beta, 3),
                β_det=fill(beta / 10, 3),
                infection_period=14,
                detection_time=detection_time,
                death_rate=death_rate,
                reinfection_probability=0.1,
                Is=[0, 0, 1],
                seed=42 + rep
            )

        peak =
            0.0

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

        push!(
            peaks,
            peak
        )

        push!(
            death_fractions,
            (
                initial_total -
                nagents(model)
            ) /
            initial_total
        )
    end

    return (
        mean(peaks),
        mean(death_fractions)
    )
end

function cost(x)

    peak,
    deaths =
        evaluate_parameters(x)

    penalty =
        peak <= 0.30 ?
        0.0 :
        100.0 * (peak - 0.30)^2 +
        10.0

    return deaths + penalty
end

println(
    "Запуск оптимизации..."
)

println(
    "Максимальное время — 120 секунд."
)

result =
    bboptimize(
        cost;
        SearchRange=[
            (0.1, 1.0),
            (3.0, 14.0),
            (0.01, 0.1)
        ],
        NumDimensions=3,
        MaxTime=120.0,
        TraceMode=:compact
    )

best =
    best_candidate(
        result
    )

best_peak,
best_deaths =
    evaluate_parameters(
        best;
        replicates=5
    )

best_beta =
    best[1]

best_detection =
    clamp(
        round(
            Int,
            best[2]
        ),
        3,
        14
    )

best_death_rate =
    best[3]

println(
    "\nОптимальные параметры:"
)

println(
    "β_und = ",
    round(
        best_beta,
        digits=4
    )
)

println(
    "Время выявления = ",
    best_detection,
    " дней"
)

println(
    "death_rate = ",
    round(
        best_death_rate,
        digits=4
    )
)

println(
    "\nРезультат:"
)

println(
    "Средний пик = ",
    round(
        best_peak,
        digits=4
    )
)

println(
    "Средняя доля умерших = ",
    round(
        best_deaths,
        digits=4
    )
)

println(
    "Ограничение peak ≤ 0.30: ",
    best_peak <= 0.30
)

jldsave(
    datadir(
        "optimization_result.jld2"
    );
    beta=best_beta,
    detection_time=
        best_detection,
    death_rate=
        best_death_rate,
    peak=
        best_peak,
    death_fraction=
        best_deaths
)

println(
    "\nСохранено:"
)

println(
    "data/optimization_result.jld2"
)
