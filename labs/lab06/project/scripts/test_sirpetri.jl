ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using Random

include(
    srcdir(
        "SIRPetri.jl"
    )
)

using .SIRPetri


println(
    "Создание сети Петри SIR..."
)

β =
    0.3

γ =
    0.1

net,
u0,
states =
    build_sir_network(
        β,
        γ
    )

println(
    "Состояния: ",
    states
)

println(
    "Начальная маркировка: ",
    u0
)

println(
    "Начальная численность: ",
    sum(u0)
)


println(
    "\nКороткий детерминированный тест..."
)

df_det =
    simulate_deterministic(
        net,
        u0,
        (
            0.0,
            5.0
        );
        saveat=0.5,
        rates=[
            β,
            γ
        ]
    )

println(
    "Точек: ",
    nrow(df_det)
)


println(
    "\nКороткий стохастический тест..."
)

df_stoch =
    simulate_stochastic(
        net,
        u0,
        (
            0.0,
            5.0
        );
        rates=[
            β,
            γ
        ],
        rng=MersenneTwister(
            123
        )
    )

println(
    "Событий: ",
    nrow(df_stoch) - 1
)

println(
    "Последняя маркировка: ",
    [
        df_stoch.S[end],
        df_stoch.I[end],
        df_stoch.R[end]
    ]
)

println(
    "Сумма фишек: ",
    df_stoch.S[end] +
    df_stoch.I[end] +
    df_stoch.R[end]
)

println(
    "\nЯдро SIR-сети Петри работает."
)
