# # Daisyworld: базовая визуализация
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# В модели чёрные и белые маргаритки взаимодействуют
# с температурой поверхности.
#
# ## Инициализация

using DrWatson
@quickactivate "project"

using Agents
using DataFrames
using Plots
using CairoMakie

include(srcdir("daisyworld.jl"))

# ## Создание модели

model = daisyworld()

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

# ## Начальное состояние

plt1, _ =
    abmplot(
        model;
        plotkwargs...
    )

# ## Пятый модельный шаг

step!(model, 5)

plt2, _ =
    abmplot(
        model;
        heatarray=model.temperature,
        plotkwargs...
    )

# ## Сороковой модельный шаг

step!(model, 40)

plt3, _ =
    abmplot(
        model;
        heatarray=model.temperature,
        plotkwargs...
    )

# ## Сохранение результатов

save(
    plotsdir("daisy_step001.png"),
    plt1
)

save(
    plotsdir("daisy_step005.png"),
    plt2
)

save(
    plotsdir("daisy_step040.png"),
    plt3
)

println("Базовая визуализация Daisyworld завершена.")
println("Сохранены:")
println(" - daisy_step001.png")
println(" - daisy_step005.png")
println(" - daisy_step040.png")

# ## Вывод
#
# Сохранённые изображения позволяют сравнить
# распределение агентов и температуры поверхности
# в разные моменты модельного времени.
