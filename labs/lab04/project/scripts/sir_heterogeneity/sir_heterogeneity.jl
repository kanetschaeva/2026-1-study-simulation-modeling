ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using Plots
using CSV

include(
    srcdir("sir_model.jl")
)

function create_migration_matrix(
    C,
    intensity
)

    M =
        fill(
            intensity / (C - 1),
            C,
            C
        )

    for i in 1:C
        M[i, i] =
            1 - intensity
    end

    return M
end

β_und =
    [0.2, 0.5, 0.8]

β_det =
    β_und ./ 10

println(
    "β по городам: ",
    β_und
)

model =
    initialize_sir(
        Ns=[1000, 1000, 1000],
        β_und=β_und,
        β_det=β_det,
        infection_period=14,
        detection_time=7,
        death_rate=0.02,
        reinfection_probability=0.1,
        Is=[1, 0, 0],
        seed=42,
        migration_rates=
            create_migration_matrix(
                3,
                0.15
            )
    )

times = Int[]
city1 = Int[]
city2 = Int[]
city3 = Int[]

for day in 1:120

    sir_manual_step!(
        model
    )

    push!(times, day)

    push!(
        city1,
        city_status_count(
            model,
            1,
            :I
        )
    )

    push!(
        city2,
        city_status_count(
            model,
            2,
            :I
        )
    )

    push!(
        city3,
        city_status_count(
            model,
            3,
            :I
        )
    )
end

df =
    DataFrame(
        time=times,
        city1=city1,
        city2=city2,
        city3=city3
    )

CSV.write(
    datadir(
        "heterogeneity.csv"
    ),
    df
)

println("\nПики по городам:")

println(
    "Город 1, β = 0.2: ",
    maximum(city1)
)

println(
    "Город 2, β = 0.5: ",
    maximum(city2)
)

println(
    "Город 3, β = 0.8: ",
    maximum(city3)
)

p1 =
    plot(
        times,
        city1;
        title="Город 1",
        label="β = 0.2",
        ylabel="I",
        linewidth=2
    )

p2 =
    plot(
        times,
        city2;
        title="Город 2",
        label="β = 0.5",
        ylabel="I",
        linewidth=2
    )

p3 =
    plot(
        times,
        city3;
        title="Город 3",
        label="β = 0.8",
        xlabel="Дни",
        ylabel="I",
        linewidth=2
    )

p =
    plot(
        p1,
        p2,
        p3;
        layout=(3, 1),
        size=(800, 900)
    )

savefig(
    p,
    plotsdir(
        "heterogeneity_cities.png"
    )
)

println("\nСохранено:")
println("data/heterogeneity.csv")
println("plots/heterogeneity_cities.png")
