using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "ResumableFunctions",
    "ConcurrentSim",
    "Distributions",
    "DataFrames",
    "StatsPlots",
    "BenchmarkTools",
    "CSV",
    "Literate",
    "IJulia",
    "Quarto"
]

Pkg.add(packages)

Pkg.precompile()

println("Все пакеты лабораторной работы №8 установлены.")
