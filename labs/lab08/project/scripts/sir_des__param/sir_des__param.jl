using DrWatson
@quickactivate "project"

include(
    srcdir(
        "sir_model.jl"
    )
)

using Random, StatsPlots, BenchmarkTools

tmax =
    40.0

u0 =
    [
        990,
        10,
        0
    ]

Random.seed!(
    1234
)

betas =
    [
        0.03,
        0.05,
        0.07
    ]

for β in betas

    p =
        [
            β,
            10.0,
            0.25
        ]

    m =
        MakeSIRModel(
            u0,
            p
        )

    activate(
        m
    )

    sir_run(
        m,
        tmax
    )

    data =
        out(
            m
        )

    @df data plot(
        :t,
        [
            :S :I :R
        ],
        labels=[
            "S" "I" "R"
        ],
        xlab="Время",
        ylab="Численность",
        title=
            "Дискретно-событийная SIR модель",
    )

    savefig(
        plotsdir(
            "sir_des_beta_$(β).png"
        )
    )
end
