# # Модель SIR
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# В программе исследуется трёхпараметрическая модель SIR.
#
# ## Инициализация

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DifferentialEquations
using SimpleDiffEq
using Tables
using DataFrames
using StatsPlots
using LaTeXStrings
using Plots
using BenchmarkTools
using Statistics

script_name = splitext(basename(PROGRAM_FILE))[1]

mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# ## Определение модели

function sir_ode!(du, u, p, t)

    S, I, R = u
    β, c, γ = p

    N = S + I + R

    @inbounds begin
        du[1] = -β * c * I / N * S
        du[2] =  β * c * I / N * S - γ * I
        du[3] =  γ * I
    end

    nothing
end

# ## Параметры и начальные условия

# Параметры

δt = 0.1
tmax = 40.0
tspan = (0.0, tmax)

u0 = [990.0, 10.0, 0.0]

p = [
    0.05,   # β
    10.0,   # c
    0.25    # γ
]

# Базовое репродуктивное число

R0 = (p[2] * p[1]) / p[3]

# ## Численное решение

# Решение системы

prob_ode = ODEProblem(
    sir_ode!,
    u0,
    tspan,
    p
)

sol_ode = solve(
    prob_ode;
    dt=δt
)

# Таблица результатов

df_ode = DataFrame(
    t=sol_ode.t,
    S=[u[1] for u in sol_ode.u],
    I=[u[2] for u in sol_ode.u],
    R=[u[3] for u in sol_ode.u]
)

df_ode[!, :N] =
    df_ode.S +
    df_ode.I +
    df_ode.R

println("Параметры модели SIR:")
println("β = ", p[1])
println("c = ", p[2])
println("γ = ", p[3])
println("R0 = ", round(R0, digits=3))
println(
    "Средняя продолжительность болезни = ",
    round(1 / p[3], digits=2),
    " дней"
)

println(
    "Начальные условия: S0 = ",
    u0[1],
    ", I0 = ",
    u0[2],
    ", R0 = ",
    u0[3]
)

# ## Визуализация

# Основной график

sir_matrix =
    hcat(
        df_ode.S,
        df_ode.I,
        df_ode.R
    )

plt1 = plot(
    df_ode.t,
    sir_matrix,
    label=[L"S(t)" L"I(t)" L"R(t)"],
    xlabel="Время, дни",
    ylabel="Количество людей",
    title="Модель SIR: динамика эпидемии",
    linewidth=2,
    legend=:right,
    grid=true,
    size=(800, 500)
)

annotate!(
    plt1,
    maximum(df_ode.t) * 0.7,
    maximum(df_ode.N) * 0.8,
    text(
        "β=$(p[1])\nc=$(p[2])\nγ=$(p[3])\nR0=$(round(R0,digits=2))",
        8,
        :left
    )
)

# График заражённых

plt2 = plot(
    df_ode.t,
    df_ode.I,
    label=L"I(t)",
    xlabel="Время, дни",
    ylabel="Количество инфицированных",
    title="Динамика числа заражённых",
    color=:red,
    linewidth=2,
    fill=(0, 0.3, :red),
    grid=true,
    size=(800, 400)
)

peak_idx = argmax(df_ode.I)
peak_time = df_ode.t[peak_idx]
peak_value = df_ode.I[peak_idx]

vline!(
    plt2,
    [peak_time],
    color=:black,
    linestyle=:dash,
    label=false
)

annotate!(
    plt2,
    peak_time,
    peak_value * 1.05,
    text(
        "Пик: $(round(peak_value,digits=1))\n$(round(peak_time,digits=1)) день",
        8
    )
)

# Логарифмический масштаб

plt3 = plot(
    df_ode.t,
    df_ode.I,
    label=L"I(t)",
    xlabel="Время, дни",
    ylabel="Количество инфицированных",
    title="Инфицированные: логарифмический масштаб",
    yscale=:log10,
    color=:red,
    linewidth=2,
    grid=true,
    size=(800, 400)
)

# Доли популяции

percentages =
    hcat(
        df_ode.S,
        df_ode.I,
        df_ode.R
    ) ./ df_ode.N .* 100

plt4 = plot(
    df_ode.t,
    percentages,
    label=[
        L"S(t)/N"
        L"I(t)/N"
        L"R(t)/N"
    ],
    xlabel="Время, дни",
    ylabel="Доля популяции, %",
    title="Динамика эпидемии в процентах",
    linewidth=2,
    legend=:right,
    grid=true,
    size=(800, 500)
)

if R0 > 1

    herd_immunity_threshold =
        (1 - 1/R0) * 100

    hline!(
        plt4,
        [herd_immunity_threshold],
        color=:purple,
        linestyle=:dash,
        label="Порог коллективного иммунитета",
        linewidth=1.5
    )
end

# Фазовый портрет

plt5 = plot(
    df_ode.S,
    df_ode.I,
    label="Фазовая траектория",
    xlabel=L"S(t)",
    ylabel=L"I(t)",
    title="Фазовый портрет SIR",
    color=:blue,
    linewidth=2,
    grid=true,
    size=(800, 500)
)

# Эффективное репродуктивное число

df_ode[!, :Re] =
    R0 .* df_ode.S ./ df_ode.N

plt6 = plot(
    df_ode.t,
    df_ode.Re,
    label=L"R_e(t)",
    xlabel="Время, дни",
    ylabel=L"R_e",
    title="Эффективное репродуктивное число",
    color=:green,
    linewidth=2,
    grid=true,
    size=(800, 400)
)

hline!(
    plt6,
    [1.0],
    color=:red,
    linestyle=:dash,
    label="Порог эпидемии Re=1"
)

cross_idx =
    findfirst(
        x -> x < 1,
        df_ode.Re
    )

if !isnothing(cross_idx) && cross_idx > 1

    cross_time =
        df_ode.t[cross_idx]

    vline!(
        plt6,
        [cross_time],
        color=:black,
        linestyle=:dash,
        label=false
    )
end

# Общая панель

plt7 = plot(
    layout=(2, 3),
    size=(1200, 800)
)

plot!(
    plt7[1],
    df_ode.t,
    df_ode.S,
    label=L"S(t)",
    title="Восприимчивые"
)

plot!(
    plt7[2],
    df_ode.t,
    df_ode.I,
    label=L"I(t)",
    title="Инфицированные"
)

plot!(
    plt7[3],
    df_ode.t,
    df_ode.R,
    label=L"R(t)",
    title="Выздоровевшие"
)

plot!(
    plt7[4],
    df_ode.t,
    df_ode.I,
    yscale=:log10,
    label=L"I(t)",
    title="Лог. масштаб"
)

plot!(
    plt7[5],
    df_ode.S,
    df_ode.I,
    label=false,
    title="Фазовый портрет"
)

plot!(
    plt7[6],
    df_ode.t,
    df_ode.Re,
    label=L"R_e(t)",
    title=L"R_e(t)"
)

hline!(
    plt7[6],
    [1.0],
    linestyle=:dash,
    color=:red,
    label=false
)

# Сохранение

savefig(
    plt1,
    plotsdir(script_name, "sir_main.png")
)

savefig(
    plt2,
    plotsdir(script_name, "sir_infected.png")
)

savefig(
    plt3,
    plotsdir(script_name, "sir_log_scale.png")
)

savefig(
    plt4,
    plotsdir(script_name, "sir_percentages.png")
)

savefig(
    plt5,
    plotsdir(script_name, "sir_phase_portrait.png")
)

savefig(
    plt6,
    plotsdir(script_name, "sir_effective_R.png")
)

savefig(
    plt7,
    plotsdir(script_name, "sir_panel.png")
)

# ## Производительность и анализ результатов

# Бенчмарк

bench = @benchmark solve($prob_ode; dt=$δt) samples=100 evals=1

println("\n=== АНАЛИЗ РЕЗУЛЬТАТОВ ===")

println(
    "Общая численность: ",
    round(df_ode.N[1], digits=1)
)

println(
    "Пиковое число заражённых: ",
    round(peak_value, digits=1)
)

println(
    "Время пика: ",
    round(peak_time, digits=1),
    " дней"
)

println(
    "Итоговое число переболевших: ",
    round(df_ode.R[end], digits=1)
)

println(
    "Медианное время решения: ",
    round(median(bench).time / 1e6, digits=3),
    " мс"
)

println("\nМоделирование SIR завершено успешно.")

# ## Вывод
#
# Модель позволяет определить динамику эпидемии, положение пика
# и момент снижения эффективного репродуктивного числа ниже единицы.
