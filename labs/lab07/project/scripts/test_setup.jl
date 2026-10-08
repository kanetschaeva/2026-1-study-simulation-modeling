using DrWatson
@quickactivate "project"

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
    "Quarto",
    "Random",
    "Statistics",
    "LinearAlgebra"
]

println(
    "Проверка окружения:\n"
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
            pkg,
            " — ",
            err
        )
    end
end

println(
    "\nОкружение готово."
)
