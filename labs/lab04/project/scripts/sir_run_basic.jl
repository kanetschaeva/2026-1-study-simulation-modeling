# # Агентная SIR-модель: базовый эксперимент
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# ## Подключение библиотек

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using Plots
using JLD2

include(
    srcdir("sir_model.jl")
)

# ## Параметры эксперимента

params = Dict(
    :Ns =>
        [1000, 1000, 1000],

    :β_und =>
        [0.5, 0.5, 0.5],

    :β_det =>
        [0.05, 0.05, 0.05],

    :infection_period =>
        14,

    :detection_time =>
        7,

    :death_rate =>
        0.02,

    :reinfection_probability =>
        0.1,

    :Is =>
        [0, 0, 1],

    :seed =>
        42,

    :n_steps =>
        100
)

# ## Расчёт R0
#
# Все вычисления выполняются программно.

γ =
    1 /
    params[:infection_period]

R0 =
    params[:β_und][1] /
    γ

println(
    "γ = ",
    round(
        γ,
        digits=4
    )
)

println(
    "R0 = ",
    round(
        R0,
        digits=3
    )
)

# ## Создание модели

model =
    initialize_sir(
        ;
        params...
    )

times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]
total_vals = Int[]

println(
    "\nЗапуск базовой симуляции..."
)

# ## Моделирование

for day in 1:params[:n_steps]

    sir_manual_step!(
        model
    )

    push!(times, day)

    push!(
        S_vals,
        susceptible_count(model)
    )

    push!(
        I_vals,
        infected_count(model)
    )

    push!(
        R_vals,
        recovered_count(model)
    )

    push!(
        total_vals,
        total_count(model)
    )
end

# ## Таблицы результатов

agent_df =
    DataFrame(
        time=times,
        susceptible=S_vals,
        infected=I_vals,
        recovered=R_vals
    )

model_df =
    DataFrame(
        time=times,
        total=total_vals
    )

# ## Автоматический анализ

peak_index =
    argmax(
        I_vals
    )

println(
    "Пик инфицированных: ",
    I_vals[peak_index]
)

println(
    "День пика: ",
    times[peak_index]
)

println(
    "Умерло: ",
    sum(params[:Ns]) -
    total_vals[end]
)

println(
    "Финальное S: ",
    S_vals[end]
)

println(
    "Финальное I: ",
    I_vals[end]
)

println(
    "Финальное R: ",
    R_vals[end]
)

# ## График

p =
    plot(
        agent_df.time,
        agent_df.susceptible;
        label="Восприимчивые",
        xlabel="Дни",
        ylabel="Количество",
        linewidth=2
    )

plot!(
    p,
    agent_df.time,
    agent_df.infected;
    label="Инфицированные",
    linewidth=2
)

plot!(
    p,
    agent_df.time,
    agent_df.recovered;
    label="Выздоровевшие",
    linewidth=2
)

plot!(
    p,
    model_df.time,
    model_df.total;
    label="Всего живых",
    linestyle=:dash,
    linewidth=2
)

savefig(
    p,
    plotsdir(
        "sir_basic_dynamics.png"
    )
)

# ## Сохранение данных

jldsave(
    datadir(
        "sir_basic_agent.jld2"
    );
    agent_df=agent_df
)

jldsave(
    datadir(
        "sir_basic_model.jld2"
    );
    model_df=model_df
)

println("\nСохранено:")
println("plots/sir_basic_dynamics.png")
println("data/sir_basic_agent.jld2")
println("data/sir_basic_model.jld2")

# ## Вывод
#
# Базовый запуск показывает эпидемическую
# динамику агентной системы из трёх городов.
