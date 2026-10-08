#!/usr/bin/env julia

using Pkg

Pkg.activate(".")

packages = [
    "DrWatson",
    "AlgebraicPetri",
    "Catlab",
    "OrdinaryDiffEq",
    "DataFrames",
    "CSV",
    "Plots",
    "FFMPEG",
    "Literate",
    "IJulia",
    "Quarto"
]

println(
    "Установка пакетов лабораторной работы №6..."
)

Pkg.add(
    packages
)

println(
    "Предкомпиляция..."
)

Pkg.precompile()

println(
    "\nВсе пакеты установлены."
)
