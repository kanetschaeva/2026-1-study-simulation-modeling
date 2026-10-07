using DrWatson
@quickactivate "project"
using DataFrames

include(
    srcdir(
        "DiningPhilosophers.jl"
    )
)

using .DiningPhilosophers


println(
    "Создание классической сети..."
)

net_classic,
u0_classic,
names_classic =
    build_classical_network(
        5
    )

println(
    "Позиции: ",
    net_classic.n_places
)

println(
    "Переходы: ",
    net_classic.n_transitions
)

println(
    "Начальное число фишек: ",
    sum(u0_classic)
)


println(
    "\nСоздание сети с арбитром..."
)

net_arbiter,
u0_arbiter,
names_arbiter =
    build_arbiter_network(
        5
    )

println(
    "Позиции: ",
    net_arbiter.n_places
)

println(
    "Переходы: ",
    net_arbiter.n_transitions
)

println(
    "Фишек арбитра: ",
    u0_arbiter[end]
)


println(
    "\nТестовая стохастическая симуляция..."
)

df =
    simulate_stochastic(
        net_classic,
        u0_classic,
        5.0
    )

println(
    "Получено состояний: ",
    nrow(df)
)

println(
    "\nЯдро сети Петри работает."
)
