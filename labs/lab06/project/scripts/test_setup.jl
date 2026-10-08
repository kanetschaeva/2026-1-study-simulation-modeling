#!/usr/bin/env julia

using DrWatson
@quickactivate "project"

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
    "Quarto",
    "Random",
    "Statistics"
]

println(
    "Проверка окружения лабораторной работы №6:\n"
)

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

    catch err

        println(
            " ✗ ",
            pkg
        )

        println(
            "   ",
            err
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
