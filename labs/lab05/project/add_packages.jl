#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "OrdinaryDiffEq",
    "DataFrames",
    "Plots",
    "CSV",
    "FFMPEG",
    "Literate",
    "IJulia",
    "Quarto"
]

println("Установка пакетов лабораторной работы №5...")

Pkg.add(packages)

println("Предкомпиляция...")

Pkg.precompile()

println("\nВсе пакеты установлены.")
