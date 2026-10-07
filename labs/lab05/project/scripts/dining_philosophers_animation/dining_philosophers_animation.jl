ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

include(
    srcdir(
        "DiningPhilosophers.jl"
    )
)

using .DiningPhilosophers

using Plots
using Random
using DataFrames

N =
    3

tmax =
    30.0

seed =
    123

fps =
    5

net,
u0,
place_names =
    build_classical_network(
        N
    )

df =
    simulate_stochastic(
        net,
        u0,
        tmax;
        rng=MersenneTwister(
            seed
        )
    )

println(
    "Получено состояний: ",
    nrow(df)
)

anim =
    @animate for row in eachrow(df)

        values =
            [
                row[
                    Symbol(name)
                ]
                for name in place_names
            ]

        bar(
            1:length(values),
            values;
            legend=false,
            ylims=(
                0,
                maximum(u0) + 1
            ),
            xlabel="Позиция",
            ylabel="Фишки",
            title=
                "Время = " *
                string(
                    round(
                        row.time,
                        digits=2
                    )
                ),
            xticks=(
                1:length(values),
                string.(
                    place_names
                )
            ),
            xrotation=45,
            size=(900, 600)
        )
    end

gif(
    anim,
    plotsdir(
        "philosophers_simulation.gif"
    );
    fps=fps
)

println(
    "\nАнимация сохранена:"
)

println(
    "plots/philosophers_simulation.gif"
)
