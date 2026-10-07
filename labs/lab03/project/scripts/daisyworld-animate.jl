using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using Plots
using CairoMakie

include(srcdir("daisyworld.jl"))

model =
    daisyworld()

daisycolor(a::Daisy) =
    a.breed

plotkwargs = (
    agent_color=daisycolor,
    agent_size=20,
    agent_marker='✿',
    heatarray=:temperature,
    heatkwargs=(
        colorrange=(-20, 60),
    ),
)

println("Создание анимации Daisyworld...")

abmvideo(
    plotsdir("simulation.mp4"),
    model;
    title="Daisy World",
    frames=60,
    plotkwargs...
)

println("Видео сохранено: plots/simulation.mp4")
