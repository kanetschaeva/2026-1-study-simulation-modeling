# Расширение модели Росса

**Автор:** Нечаева Кира Андреевна

**Группа:** НКНбд-01-23

Реализуются дополнительные пункты задания:
несколько ремонтников, разные N,
мониторинг очереди и загрузки,
график числа исправных машин
и аналитическое сравнение.

```julia
ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using ResumableFunctions
using ConcurrentSim
using Distributions
using StableRNGs

using DataFrames
using CSV
using Plots
using Statistics
using LinearAlgebra
```

## Параметры из исходной модели

```julia
const RUNS_PARAM =
    5

const S_PARAM =
    3

const LAMBDA_PARAM =
    100.0

const MU_PARAM =
    1.0

const SEED_PARAM =
    150
```

## Мониторинг

```julia
mutable struct RepairMonitor

    times::Vector{Float64}

    healthy::Vector{Int}

    queue::Vector{Int}

    busy::Vector{Int}

    healthy_now::Int

    queue_now::Int

    busy_now::Int
end


function RepairMonitor(
    total_machines::Int
)

    return RepairMonitor(
        [0.0],
        [total_machines],
        [0],
        [0],
        total_machines,
        0,
        0
    )
end


function record!(
    monitor::RepairMonitor,
    env::Environment
)

    push!(
        monitor.times,
        now(env)
    )

    push!(
        monitor.healthy,
        monitor.healthy_now
    )

    push!(
        monitor.queue,
        monitor.queue_now
    )

    push!(
        monitor.busy,
        monitor.busy_now
    )

    return nothing
end
```

## Поведение машины

```julia
@resumable function machine_param(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Process},
    rng,
    F,
    G,
    monitor::RepairMonitor
)

    while true

        try

            @yield timeout(
                env,
                Inf
            )

        catch
        end

        @yield timeout(
            env,
            rand(
                rng,
                F
            )
        )

        monitor.healthy_now -=
            1

        record!(
            monitor,
            env
        )

        get_spare =
            take!(
                spares
            )

        @yield get_spare |
               timeout(env)

        if state(
            get_spare
        ) != ConcurrentSim.idle

            @yield interrupt(
                value(
                    get_spare
                )
            )

        else

            throw(
                StopSimulation(
                    "No more spares!"
                )
            )
        end

        monitor.queue_now +=
            1

        record!(
            monitor,
            env
        )

        @yield request(
            repair_facility
        )

        monitor.queue_now -=
            1

        monitor.busy_now +=
            1

        record!(
            monitor,
            env
        )

        @yield timeout(
            env,
            rand(
                rng,
                G
            )
        )

        @yield unlock(
            repair_facility
        )

        monitor.busy_now -=
            1

        monitor.healthy_now +=
            1

        record!(
            monitor,
            env
        )

        @yield put!(
            spares,
            active_process(
                env
            )
        )
    end
end
```

## Начальное состояние

```julia
@resumable function start_sim_param(
    env::Environment,
    repair_facility::Resource,
    spares::Store{Process},
    N::Int,
    S::Int,
    rng,
    F,
    G,
    monitor::RepairMonitor
)

    for i in 1:N

        proc =
            @process machine_param(
                env,
                repair_facility,
                spares,
                rng,
                F,
                G,
                monitor
            )

        @yield interrupt(
            proc
        )
    end

    for i in 1:S

        proc =
            @process machine_param(
                env,
                repair_facility,
                spares,
                rng,
                F,
                G,
                monitor
            )

        @yield put!(
            spares,
            proc
        )
    end
end
```

## Один параметрический прогон

```julia
function sim_repair_param(
    N::Int,
    S::Int,
    num_repairers::Int,
    seed::Int
)

    rng =
        StableRNG(
            seed
        )

    F =
        Exponential(
            LAMBDA_PARAM
        )

    G =
        Exponential(
            MU_PARAM
        )

    sim =
        Simulation()

    repair_facility =
        Resource(
            sim,
            num_repairers
        )

    spares =
        Store{Process}(
            sim
        )

    monitor =
        RepairMonitor(
            N + S
        )

    @process start_sim_param(
        sim,
        repair_facility,
        spares,
        N,
        S,
        rng,
        F,
        G,
        monitor
    )

    msg =
        run(sim)

    stop_time =
        now(sim)

    return (
        stop_time,
        msg,
        monitor
    )
end
```

## Среднее значение показателя во времени

```julia
function time_average(
    times,
    values,
    stop_time
)

    total =
        0.0

    for i in 1:(
        length(times) - 1
    )

        total +=
            values[i] *
            (
                times[i + 1] -
                times[i]
            )
    end

    if !isempty(times)

        total +=
            values[end] *
            (
                stop_time -
                times[end]
            )
    end

    return total /
           stop_time
end
```

## Аналитическое среднее время до падения

Состояние — число исправных машин.
Переходы соответствуют описанной
в методичке марковской модели.

```julia
function analytic_crash_time(
    N::Int,
    S::Int,
    num_repairers::Int
)

    states =
        collect(
            N:(N + S)
        )

    count_states =
        length(
            states
        )

    Q =
        zeros(
            Float64,
            count_states,
            count_states
        )

    for (
        row,
        healthy
    ) in enumerate(
        states
    )

        failure_rate =
            min(
                N,
                healthy
            ) /
            LAMBDA_PARAM

        broken =
            N +
            S -
            healthy

        repair_rate =
            min(
                num_repairers,
                broken
            ) /
            MU_PARAM

        Q[
            row,
            row
        ] =
            -(
                failure_rate +
                repair_rate
            )

        if healthy > N

            Q[
                row,
                row - 1
            ] =
                failure_rate
        end

        if healthy < N + S

            Q[
                row,
                row + 1
            ] =
                repair_rate
        end
    end

    expected_times =
        -(
            Q \
            ones(
                count_states
            )
        )

    return expected_times[end]
end
```

## Набор параметров

```julia
N_values =
    [
        5,
        10,
        15
    ]

repairer_values =
    [
        1,
        2
    ]

results =
    NamedTuple[]

representative_monitor =
    nothing

representative_stop_time =
    0.0
```

## Серия экспериментов

```julia
for N in N_values

    for num_repairers in repairer_values

        crash_times =
            Float64[]

        queues =
            Float64[]

        utilizations =
            Float64[]

        for run_id in 1:RUNS_PARAM

            seed =
                SEED_PARAM +
                100 * N +
                10 * num_repairers +
                run_id

            stop_time,
            msg,
            monitor =
                sim_repair_param(
                    N,
                    S_PARAM,
                    num_repairers,
                    seed
                )

            avg_queue =
                time_average(
                    monitor.times,
                    monitor.queue,
                    stop_time
                )

            avg_busy =
                time_average(
                    monitor.times,
                    monitor.busy,
                    stop_time
                )

            utilization =
                avg_busy /
                num_repairers

            push!(
                crash_times,
                stop_time
            )

            push!(
                queues,
                avg_queue
            )

            push!(
                utilizations,
                utilization
            )

	    if N == 10 &&
               num_repairers == 2 &&
               run_id == 1

                global representative_monitor =
                    monitor

                global representative_stop_time =
                    stop_time
	    end
        end

        analytic_time =
            analytic_crash_time(
                N,
                S_PARAM,
                num_repairers
            )

        simulated_time =
            mean(
                crash_times
            )

        push!(
            results,
            (
                N=N,
                S=S_PARAM,
                repairers=
                    num_repairers,
                mean_crash_time=
                    simulated_time,
                analytic_crash_time=
                    analytic_time,
                relative_error=
                    abs(
                        simulated_time -
                        analytic_time
                    ) /
                    analytic_time,
                average_queue=
                    mean(
                        queues
                    ),
                repair_utilization=
                    mean(
                        utilizations
                    )
            )
        )

        println(
            "N=",
            N,
            ", repairers=",
            num_repairers,
            " | simulation=",
            round(
                simulated_time,
                digits=3
            ),
            " | analytic=",
            round(
                analytic_time,
                digits=3
            ),
            " | queue=",
            round(
                mean(
                    queues
                ),
                digits=4
            ),
            " | utilization=",
            round(
                mean(
                    utilizations
                ),
                digits=4
            )
        )
    end
end
```

## Таблица результатов

```julia
df_summary =
    DataFrame(
        results
    )

CSV.write(
    datadir(
        "ross_parameter_summary.csv"
    ),
    df_summary
)

println(
    "\nСводная таблица:"
)

show(
    df_summary;
    allrows=true,
    allcols=true
)

println()
```

## График числа исправных машин

```julia
p_healthy =
    plot(
        representative_monitor.times,
        representative_monitor.healthy;
        xlabel="Время",
        ylabel="Исправные машины",
        title=
            "Число исправных машин во времени",
        label="Healthy",
        linewidth=2
    )

savefig(
    p_healthy,
    plotsdir(
        "ross_healthy.png"
    )
)
```

## График очереди на ремонт

```julia
p_queue =
    plot(
        representative_monitor.times,
        representative_monitor.queue;
        xlabel="Время",
        ylabel="Длина очереди",
        title=
            "Очередь на ремонт",
        label="Queue",
        linewidth=2
    )

savefig(
    p_queue,
    plotsdir(
        "ross_queue.png"
    )
)
```

## Загрузка ремонтников

```julia
p_utilization =
    plot(
        xlabel="N",
        ylabel="Utilization",
        title=
            "Загрузка ремонтников"
    )

for repairers in repairer_values

    part =
        filter(
            :repairers =>
                value ->
                    value == repairers,
            df_summary
        )

    plot!(
        p_utilization,
        part.N,
        part.repair_utilization;
        marker=:circle,
        linewidth=2,
        label=
            "$repairers repairer(s)"
    )
end

savefig(
    p_utilization,
    plotsdir(
        "ross_utilization.png"
    )
)
```

## Имитационное и аналитическое время падения

```julia
p_crash =
    plot(
        xlabel="N",
        ylabel="Среднее время до падения",
        title=
            "Имитационное и аналитическое решение"
    )

for repairers in repairer_values

    part =
        filter(
            :repairers =>
                value ->
                    value == repairers,
            df_summary
        )

    plot!(
        p_crash,
        part.N,
        part.mean_crash_time;
        marker=:circle,
        linewidth=2,
        label=
            "Simulation, r=$repairers"
    )

    plot!(
        p_crash,
        part.N,
        part.analytic_crash_time;
        marker=:square,
        linewidth=2,
        linestyle=:dash,
        label=
            "Analytic, r=$repairers"
    )
end

savefig(
    p_crash,
    plotsdir(
        "ross_crash_time.png"
    )
)


println(
    "\nСохранено:"
)

println(
    "data/ross_parameter_summary.csv"
)

println(
    "plots/ross_healthy.png"
)

println(
    "plots/ross_queue.png"
)

println(
    "plots/ross_utilization.png"
)

println(
    "plots/ross_crash_time.png"
)
```

