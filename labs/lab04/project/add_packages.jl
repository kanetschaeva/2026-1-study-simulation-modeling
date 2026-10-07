#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

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

println("Установка пакетов лабораторной работы №4...")

Pkg.add(packages)

println("Предкомпиляция...")
Pkg.precompile()

println("\nВсе пакеты установлены.")
