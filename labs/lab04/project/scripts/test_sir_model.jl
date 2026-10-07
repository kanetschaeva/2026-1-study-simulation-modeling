using DrWatson
@quickactivate "project"

include(
    srcdir("sir_model.jl")
)

println("Создание тестовой агентной SIR-модели...")

model =
    initialize_sir(
        Ns=[100, 100, 100],
        Is=[0, 0, 1],
        seed=42
    )

println(
    "Начальное число агентов: ",
    nagents(model)
)

println(
    "S = ",
    susceptible_count(model)
)

println(
    "I = ",
    infected_count(model)
)

println(
    "R = ",
    recovered_count(model)
)

println("\nПервые пять модельных дней:")

for day in 1:5

    sir_manual_step!(
        model
    )

    println(
        "День ",
        day,
        ": S=",
        susceptible_count(model),
        ", I=",
        infected_count(model),
        ", R=",
        recovered_count(model),
        ", всего=",
        total_count(model)
    )
end

println(
    "\nАгентная SIR-модель работает."
)
