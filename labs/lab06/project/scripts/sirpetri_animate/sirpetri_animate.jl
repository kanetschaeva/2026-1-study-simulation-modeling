ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using Plots

include(
    srcdir(
        "SIRPetri.jl"
    )
)

using .SIRPetri

β =
    0.3

γ =
    0.1

tmax =
    100.0

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
        saveat=0.2,
        rates=[
            β,
            γ
        ]
    )

println(
    "Получено точек: ",
    nrow(df)
)

frame_indices =
    1:5:nrow(df)

anim =
    @animate for index in frame_indices

        values =
            [
                df.S[index],
                df.I[index],
                df.R[index]
            ]

        bar(
            [
                "S",
                "I",
                "R"
            ],
            values;
            legend=false,
            ylim=(
                0,
                1000
            ),
            xlabel="Состояние",
            ylabel="Численность",
            title=
                "SIR, t = " *
                string(
                    round(
                        df.time[index],
                        digits=1
                    )
                ),
            size=(
                800,
                550
            )
        )
    end

gif(
    anim,
    plotsdir(
        "sir_animation.gif"
    );
    fps=10
)

println(
    "\nАнимация сохранена:"
)

println(
    "plots/sir_animation.gif"
)
