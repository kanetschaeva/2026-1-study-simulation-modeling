#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "Agents",
    "StatsBase",
    "DataFrames",
    "Plots",
    "CairoMakie",
    "Literate",
    "IJulia",
    "Quarto"
]

println("Установка пакетов лабораторной работы №3...")

Pkg.add(packages)
Pkg.precompile()

println("\nВсе пакеты установлены.")
