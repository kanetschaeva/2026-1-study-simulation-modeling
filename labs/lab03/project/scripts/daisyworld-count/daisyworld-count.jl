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

model =
    daisyworld(
        solar_luminosity=1.0
    )

println(
    "Запуск модели на 1000 шагов..."
)

agent_df, model_df =
    run!(
        model,
        1000;
        adata=adata
    )

println(
    "Получено наблюдений: ",
    nrow(agent_df)
)

figure =
    Figure(
        size=(600, 400)
    )

ax =
    figure[1, 1] =
    Axis(
        figure,
        xlabel="tick",
        ylabel="daisy count"
    )

blackl =
    lines!(
        ax,
        agent_df[!, :time],
        agent_df[!, :count_black],
        color=:black
    )

whitel =
    lines!(
        ax,
        agent_df[!, :time],
        agent_df[!, :count_white],
        color=:orange
    )

Legend(
    figure[1, 2],
    [blackl, whitel],
    ["black", "white"],
    labelsize=12
)

save(
    plotsdir("daisy_count.png"),
    figure
)

println(
    "График сохранён: plots/daisy_count.png"
)
