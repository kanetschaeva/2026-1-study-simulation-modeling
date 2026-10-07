# # Daisyworld: динамика модели
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# В эксперименте анализируются число агентов,
# температура и солнечная светимость.
#
# ## Инициализация

using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using Plots
using CairoMakie

include(srcdir("daisyworld.jl"))

black(a) =
    a.breed == :black

white(a) =
    a.breed == :white

adata = [
    (black, count),
    (white, count)
]

# ## Модель со сценарием изменения светимости

model =
    daisyworld(
        solar_luminosity=1.0,
        scenario=:ramp
    )

temperature(model) =
    StatsBase.mean(
        model.temperature
    )

mdata = [
    temperature,
    :solar_luminosity
]

println(
    "Запуск динамического сценария..."
)

agent_df, model_df =
    run!(
        model,
        1000;
        adata=adata,
        mdata=mdata
    )

# ## Построение комплексного графика

figure =
    CairoMakie.Figure(
        size=(600, 600)
    )

ax1 =
    figure[1, 1] =
    Axis(
        figure,
        ylabel="daisy count"
    )

blackl =
    lines!(
        ax1,
        agent_df[!, :time],
        agent_df[!, :count_black],
        color=:red
    )

whitel =
    lines!(
        ax1,
        agent_df[!, :time],
        agent_df[!, :count_white],
        color=:blue
    )

figure[1, 2] =
    Legend(
        figure,
        [blackl, whitel],
        ["black", "white"]
    )

ax2 =
    figure[2, 1] =
    Axis(
        figure,
        ylabel="temperature"
    )

ax3 =
    figure[3, 1] =
    Axis(
        figure,
        xlabel="tick",
        ylabel="luminosity"
    )

lines!(
    ax2,
    model_df[!, :time],
    model_df[!, :temperature],
    color=:red
)

lines!(
    ax3,
    model_df[!, :time],
    model_df[!, :solar_luminosity],
    color=:red
)

for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

# ## Сохранение

save(
    plotsdir("daisy_luminosity.png"),
    figure
)

println(
    "График сохранён: plots/daisy_luminosity.png"
)

# ## Вывод
#
# Эксперимент позволяет одновременно сравнивать
# изменение популяций, температуры и внешней светимости.
