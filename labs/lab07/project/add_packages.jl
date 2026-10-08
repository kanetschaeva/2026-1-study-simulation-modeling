#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "StableRNGs",
    "Distributions",
    "ConcurrentSim",
    "ResumableFunctions",
    "DataFrames",
    "CSV",
    "Plots",
    "Literate",
    "IJulia",
    "Quarto"
]

Pkg.add(packages)

Pkg.precompile()

println(
    "Все пакеты лабораторной работы №7 установлены."
)
