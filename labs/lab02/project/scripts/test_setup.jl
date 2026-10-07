#!/usr/bin/env julia

using DrWatson
@quickactivate "project"

packages = [
    "DrWatson",
    "DifferentialEquations",
    "SimpleDiffEq",
    "Tables",
    "DataFrames",
    "StatsPlots",
    "LaTeXStrings",
    "Plots",
    "BenchmarkTools",
    "Statistics",
    "FFTW",
    "CSV",
    "JLD2",
    "Literate",
    "IJulia",
    "Quarto"
]

println("Проверка пакетов:\n")

for pkg in packages
    try
        eval(Meta.parse("using $pkg"))
        println(" ✓ ", pkg)
    catch e
        println(" ✗ ", pkg)
    end
end

println("\nПроект: ", projectdir())
println("Каталог данных: ", datadir())
println("Каталог графиков: ", plotsdir())
