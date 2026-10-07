# # Обедающие философы: стохастическая модель
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# Сравниваются классическая сеть Петри
# и сеть с дополнительным арбитром.

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


# ## Параметры

N =
    5

tmax =
    50.0

seed =
    123

println(
    "N = ",
    N
)

println(
    "tmax = ",
    tmax
)


# ## Классическая сеть

println(
    "\n=== Классическая сеть ==="
)

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

CSV.write(
    datadir(
        "dining_classic.csv"
    ),
    df_classic
)

dead_classic =
    detect_deadlock(
        df_classic,
        net_classic
    )

println(
    "Deadlock обнаружен: ",
    dead_classic
)

println(
    "Последнее время: ",
    round(
        df_classic.time[end],
        digits=3
    )
)

plot_classic =
    plot_marking_evolution(
        df_classic,
        N
    )

savefig(
    plot_classic,
    plotsdir(
        "classic_simulation.png"
    )
)


# ## Сеть с арбитром

println(
    "\n=== Сеть с арбитром ==="
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

CSV.write(
    datadir(
        "dining_arbiter.csv"
    ),
    df_arbiter
)

dead_arbiter =
    detect_deadlock(
        df_arbiter,
        net_arbiter
    )

println(
    "Deadlock обнаружен: ",
    dead_arbiter
)

println(
    "Последнее время: ",
    round(
        df_arbiter.time[end],
        digits=3
    )
)

plot_arbiter =
    plot_marking_evolution(
        df_arbiter,
        N
    )

savefig(
    plot_arbiter,
    plotsdir(
        "arbiter_simulation.png"
    )
)


# ## Результаты

println(
    "\nСохранено:"
)

println(
    "data/dining_classic.csv"
)

println(
    "data/dining_arbiter.csv"
)

println(
    "plots/classic_simulation.png"
)

println(
    "plots/arbiter_simulation.png"
)


# ## Вывод
#
# Классическая сеть допускает взаимную блокировку.
# Арбитр ограничивает число философов,
# которые могут одновременно начать захват вилок.
