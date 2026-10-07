#!/usr/bin/env julia

using DrWatson
@quickactivate "project"

packages = [
    "DrWatson",
    "Agents",
    "Graphs",
    "StatsBase",
    "Distributions",
    "DataFrames",
    "Plots",
    "CSV",
    "JLD2",
    "BlackBoxOptim",
    "Literate",
    "IJulia",
    "Quarto"
]

println("Проверка пакетов:\n")

for pkg in packages
    try
        eval(Meta.parse("using $pkg"))
        println(" ✓ ", pkg)
    catch
        println(" ✗ ", pkg)
    end
end

println("\nПроект: ", projectdir())
println("Каталог данных: ", datadir())
println("Каталог графиков: ", plotsdir())
