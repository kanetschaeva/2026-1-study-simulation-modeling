using DrWatson
@quickactivate "project"

using Agents
using Statistics

include(srcdir("daisyworld.jl"))

println("Создание модели Daisyworld...")

model = daisyworld()

println("Размер сетки: ", size(model.temperature))
println("Начальное число агентов: ", nagents(model))
println("Солнечная светимость: ", model.solar_luminosity)

step!(model, 5)

println("\nПосле пяти шагов:")
println("Число агентов: ", nagents(model))
println(
    "Средняя температура: ",
    round(mean(model.temperature), digits=2)
)

println("\nБазовая модель работает.")
