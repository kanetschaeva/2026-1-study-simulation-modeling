#!/usr/bin/env julia

# add_packages.jl
# Установка зависимостей лабораторной работы №1

using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "DifferentialEquations",
    "Plots",
    "DataFrames",
    "CSV",
    "JLD2",
    "Literate",
    "IJulia",
    "BenchmarkTools",
    "Quarto"
]

println("Установка базовых пакетов...")

Pkg.add(packages)

println("\nВсе пакеты установлены!")
println("Для проверки: using DrWatson, DifferentialEquations, Plots")
