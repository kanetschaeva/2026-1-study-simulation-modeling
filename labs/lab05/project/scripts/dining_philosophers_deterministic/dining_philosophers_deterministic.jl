ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

include(
    srcdir(
        "DiningPhilosophers.jl"
    )
)

using .DiningPhilosophers

using CSV
using Plots
using DataFrames

N =
    5

tmax =
    50.0

println(
    "Детерминированная классическая сеть..."
)

net_classic,
u0_classic,
_ =
    build_classical_network(
        N
    )

df_classic =
    simulate_ode(
        net_classic,
        u0_classic,
        tmax;
        saveat=0.1
    )

CSV.write(
    datadir(
        "dining_classic_ode.csv"
    ),
    df_classic
)

p_classic =
    plot_marking_evolution(
        df_classic,
        N
    )

savefig(
    p_classic,
    plotsdir(
        "classic_deterministic.png"
    )
)

println(
    "Точек траектории: ",
    nrow(df_classic)
)

println(
    "\nДетерминированная сеть с арбитром..."
)

net_arbiter,
u0_arbiter,
_ =
    build_arbiter_network(
        N
    )

df_arbiter =
    simulate_ode(
        net_arbiter,
        u0_arbiter,
        tmax;
        saveat=0.1
    )

CSV.write(
    datadir(
        "dining_arbiter_ode.csv"
    ),
    df_arbiter
)

p_arbiter =
    plot_marking_evolution(
        df_arbiter,
        N
    )

savefig(
    p_arbiter,
    plotsdir(
        "arbiter_deterministic.png"
    )
)

println(
    "Точек траектории: ",
    nrow(df_arbiter)
)

println(
    "\nСохранено:"
)

println(
    "data/dining_classic_ode.csv"
)

println(
    "data/dining_arbiter_ode.csv"
)

println(
    "plots/classic_deterministic.png"
)

println(
    "plots/arbiter_deterministic.png"
)
