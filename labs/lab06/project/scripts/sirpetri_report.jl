# # Итоговое сравнение SIR
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# Новые симуляции здесь не выполняются.
# Используются ранее сохранённые CSV.

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using CSV
using Plots


# ## Проверка входных данных

det_file =
    datadir(
        "sir_det.csv"
    )

stoch_file =
    datadir(
        "sir_stoch.csv"
    )

scan_file =
    datadir(
        "sir_scan.csv"
    )

for file in [
    det_file,
    stoch_file,
    scan_file
]

    if !isfile(file)

        error(
            "Не найден файл: $file"
        )
    end
end


# ## Загрузка

df_det =
    CSV.read(
        det_file,
        DataFrame
    )

df_stoch =
    CSV.read(
        stoch_file,
        DataFrame
    )

df_scan =
    CSV.read(
        scan_file,
        DataFrame
    )


# ## Сравнение I(t)

p1 =
    plot(
        df_det.time,
        df_det.I;
        label=
            "Deterministic I",
        xlabel="Время",
        ylabel="Инфицированные",
        title=
            "Детерминированная и стохастическая динамика",
        linewidth=2
    )

plot!(
    p1,
    df_stoch.time,
    df_stoch.I;
    label=
        "Stochastic I",
    linewidth=2
)

savefig(
    p1,
    plotsdir(
        "comparison.png"
    )
)


# ## Чувствительность к β

p2 =
    plot(
        df_scan.β,
        df_scan.peak_I;
        marker=:circle,
        xlabel="β",
        ylabel="Peak I",
        title=
            "Чувствительность пика к β",
        linewidth=2,
        label=
            "Peak I"
    )

savefig(
    p2,
    plotsdir(
        "sensitivity.png"
    )
)


println(
    "Итоговые графики сохранены:"
)

println(
    "plots/comparison.png"
)

println(
    "plots/sensitivity.png"
)


# ## Вывод
#
# CSV используются повторно,
# поэтому итоговый анализ отделён
# от дорогостоящего этапа моделирования.
