# # Итоговое сравнение моделей
#
# **Автор:** Нечаева Кира Андреевна
#
# **Группа:** НКНбд-01-23
#
# Используются уже сохранённые CSV-файлы.
# Повторная симуляция здесь не выполняется.

ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using DataFrames
using CSV
using Plots


# ## Загрузка данных

classic_file =
    datadir(
        "dining_classic.csv"
    )

arbiter_file =
    datadir(
        "dining_arbiter.csv"
    )

if !isfile(classic_file)
    error(
        "Не найден dining_classic.csv"
    )
end

if !isfile(arbiter_file)
    error(
        "Не найден dining_arbiter.csv"
    )
end

df_classic =
    CSV.read(
        classic_file,
        DataFrame
    )

df_arbiter =
    CSV.read(
        arbiter_file,
        DataFrame
    )

N =
    5

eat_cols =
    [
        "Eat_$i"
        for i in 1:N
    ]


# ## Классическая сеть

p1 =
    plot(
        df_classic.time,
        Matrix(
            df_classic[
                :,
                eat_cols
            ]
        );
        label=
            permutedims(
                [
                    "Философ $i"
                    for i in 1:N
                ]
            ),
        xlabel="Время",
        ylabel="Ест",
        title="Классическая сеть",
        ylims=(-0.05, 1.05)
    )


# ## Сеть с арбитром

p2 =
    plot(
        df_arbiter.time,
        Matrix(
            df_arbiter[
                :,
                eat_cols
            ]
        );
        label=
            permutedims(
                [
                    "Философ $i"
                    for i in 1:N
                ]
            ),
        xlabel="Время",
        ylabel="Ест",
        title="Сеть с арбитром",
        ylims=(-0.05, 1.05)
    )


# ## Итоговая фигура

p_final =
    plot(
        p1,
        p2;
        layout=(2, 1),
        size=(900, 700)
    )

savefig(
    p_final,
    plotsdir(
        "final_report.png"
    )
)

println(
    "Отчёт сохранён:"
)

println(
    "plots/final_report.png"
)


# ## Вывод
#
# Продолжительное отсутствие состояний Eat
# у классической модели соответствует блокировке.
# В модели с арбитром доступ к ресурсам продолжается.
