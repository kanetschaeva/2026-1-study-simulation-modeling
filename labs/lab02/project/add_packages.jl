#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

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
    "FFTW",
    "CSV",
    "JLD2",
    "Literate",
    "IJulia",
    "Quarto"
]

println("Установка пакетов лабораторной работы №2...")

Pkg.add(packages)
Pkg.precompile()

println("\nВсе пакеты установлены.")
