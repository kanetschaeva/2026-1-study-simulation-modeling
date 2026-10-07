ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

include(
    srcdir(
        "DiningPhilosophers.jl"
    )
)

using .DiningPhilosophers

using DataFrames
using CSV
using Plots
using Random
using Statistics

N_values =
    [3, 5, 7]

seeds =
    [
        101,
        202,
        303,
        404,
        505
    ]

tmax =
    50.0

results =
    NamedTuple[]

println(
    "Параметрическое исследование..."
)

for N in N_values

    for seed in seeds

        net_classic,
        u0_classic,
        _ =
            build_classical_network(
                N
            )

        df_classic =
            simulate_stochastic(
                net_classic,
                u0_classic,
                tmax;
                rng=MersenneTwister(
                    seed
                )
            )

        dead_classic =
            detect_deadlock(
                df_classic,
                net_classic
            )

        net_arbiter,
        u0_arbiter,
        _ =
            build_arbiter_network(
                N
            )

        df_arbiter =
            simulate_stochastic(
                net_arbiter,
                u0_arbiter,
                tmax;
                rng=MersenneTwister(
                    seed
                )
            )

        dead_arbiter =
            detect_deadlock(
                df_arbiter,
                net_arbiter
            )

        push!(
            results,
            (
                N=N,
                seed=seed,
                classic_deadlock=
                    dead_classic,
                arbiter_deadlock=
                    dead_arbiter,
                classic_last_time=
                    df_classic.time[end],
                arbiter_last_time=
                    df_arbiter.time[end]
            )
        )

        println(
            "N=",
            N,
            ", seed=",
            seed,
            ", classic=",
            dead_classic,
            ", arbiter=",
            dead_arbiter
        )
    end
end

df =
    DataFrame(
        results
    )

CSV.write(
    datadir(
        "deadlock_parameters.csv"
    ),
    df
)

summary =
    combine(
        groupby(
            df,
            :N
        ),
        :classic_deadlock =>
            (
                x ->
                    mean(
                        Float64.(
                            x
                        )
                    )
            ) =>
            :classic_deadlock_rate,

        :arbiter_deadlock =>
            (
                x ->
                    mean(
                        Float64.(
                            x
                        )
                    )
            ) =>
            :arbiter_deadlock_rate
    )

CSV.write(
    datadir(
        "deadlock_parameters_summary.csv"
    ),
    summary
)

println(
    "\nСводная таблица:"
)

show(
    summary;
    allrows=true,
    allcols=true
)

println()

p =
    plot(
        summary.N,
        summary.classic_deadlock_rate;
        marker=:circle,
        linewidth=2,
        xlabel="Количество философов N",
        ylabel="Доля прогонов с deadlock",
        label="Классическая сеть",
        ylim=(-0.05, 1.05)
    )

plot!(
    p,
    summary.N,
    summary.arbiter_deadlock_rate;
    marker=:square,
    linewidth=2,
    label="С арбитром"
)

savefig(
    p,
    plotsdir(
        "deadlock_frequency_params.png"
    )
)

println(
    "\nСохранено:"
)

println(
    "data/deadlock_parameters.csv"
)

println(
    "data/deadlock_parameters_summary.csv"
)

println(
    "plots/deadlock_frequency_params.png"
)
