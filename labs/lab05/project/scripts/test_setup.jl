#!/usr/bin/env julia

using DrWatson
@quickactivate "project"

packages = [
    "DrWatson",
    "OrdinaryDiffEq",
    "DataFrames",
    "Plots",
    "CSV",
    "FFMPEG",
    "Literate",
    "IJulia",
    "Quarto",
    "Random",
    "LinearAlgebra",
    "Statistics"
]

println("Проверка пакетов:\n")

for pkg in packages
    try
        eval(
            Meta.parse(
                "using $pkg"
            )
        )

        println(
            " ✓ ",
            pkg
        )

    catch
        println(
            " ✗ ",
            pkg
        )
    end
end

println(
    "\nПроект: ",
    projectdir()
)

println(
    "Каталог данных: ",
    datadir()
)

println(
    "Каталог графиков: ",
    plotsdir()
)
