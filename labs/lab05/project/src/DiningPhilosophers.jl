module DiningPhilosophers

using OrdinaryDiffEq
using Plots
using DataFrames
using Random
using LinearAlgebra


export PetriNet
export build_classical_network
export build_arbiter_network
export simulate_ode
export simulate_stochastic
export detect_deadlock
export plot_marking_evolution


# -------------------------------------------------
# Структура сети Петри
# -------------------------------------------------

struct PetriNet

    n_places::Int

    n_transitions::Int

    incidence::Matrix{Int}

    place_names::Vector{Symbol}

    transition_names::Vector{Symbol}
end


function PetriNet(
    n_places::Int,
    n_transitions::Int;
    place_names=Symbol[],
    transition_names=Symbol[]
)

    incidence =
        zeros(
            Int,
            n_places,
            n_transitions
        )

    if isempty(place_names)

        place_names =
            [
                Symbol("p$i")
                for i in 1:n_places
            ]
    end

    if isempty(transition_names)

        transition_names =
            [
                Symbol("t$i")
                for i in 1:n_transitions
            ]
    end

    return PetriNet(
        n_places,
        n_transitions,
        incidence,
        place_names,
        transition_names
    )
end


function add_arc!(
    net::PetriNet,
    place::Int,
    transition::Int,
    sign::Int
)

    net.incidence[
        place,
        transition
    ] += sign

    return nothing
end


# -------------------------------------------------
# Классическая сеть
# -------------------------------------------------

function build_classical_network(
    N::Int
)

    n_places =
        4 * N

    n_transitions =
        3 * N

    net =
        PetriNet(
            n_places,
            n_transitions
        )

    for i in 1:N

        net.place_names[i] =
            Symbol("Think_$i")

        net.place_names[N+i] =
            Symbol("Hungry_$i")

        net.place_names[2N+i] =
            Symbol("Eat_$i")

        net.place_names[3N+i] =
            Symbol("Fork_$i")
    end

    for i in 1:N

        net.transition_names[i] =
            Symbol("GetLeft_$i")

        net.transition_names[N+i] =
            Symbol("GetRight_$i")

        net.transition_names[2N+i] =
            Symbol("PutForks_$i")
    end

    for i in 1:N

        think =
            i

        hungry =
            N + i

        eat =
            2N + i

        left_fork =
            3N + i

        right_fork =
            3N + (i % N + 1)

        get_left =
            i

        get_right =
            N + i

        put_forks =
            2N + i

        add_arc!(
            net,
            think,
            get_left,
            -1
        )

        add_arc!(
            net,
            left_fork,
            get_left,
            -1
        )

        add_arc!(
            net,
            hungry,
            get_left,
            +1
        )

        add_arc!(
            net,
            hungry,
            get_right,
            -1
        )

        add_arc!(
            net,
            right_fork,
            get_right,
            -1
        )

        add_arc!(
            net,
            eat,
            get_right,
            +1
        )

        add_arc!(
            net,
            eat,
            put_forks,
            -1
        )

        add_arc!(
            net,
            think,
            put_forks,
            +1
        )

        add_arc!(
            net,
            left_fork,
            put_forks,
            +1
        )

        add_arc!(
            net,
            right_fork,
            put_forks,
            +1
        )
    end

    u0 =
        zeros(
            Float64,
            n_places
        )

    for i in 1:N

        u0[i] =
            1.0

        u0[3N+i] =
            1.0
    end

    return (
        net,
        u0,
        net.place_names
    )
end


# -------------------------------------------------
# Сеть с арбитром
# -------------------------------------------------

function build_arbiter_network(
    N::Int
)

    n_places =
        4 * N + 1

    n_transitions =
        3 * N

    net =
        PetriNet(
            n_places,
            n_transitions
        )

    for i in 1:N

        net.place_names[i] =
            Symbol("Think_$i")

        net.place_names[N+i] =
            Symbol("Hungry_$i")

        net.place_names[2N+i] =
            Symbol("Eat_$i")

        net.place_names[3N+i] =
            Symbol("Fork_$i")
    end

    arbiter_idx =
        4N + 1

    net.place_names[
        arbiter_idx
    ] = :Arbiter

    for i in 1:N

        net.transition_names[i] =
            Symbol("GetLeft_$i")

        net.transition_names[N+i] =
            Symbol("GetRight_$i")

        net.transition_names[2N+i] =
            Symbol("PutForks_$i")
    end

    for i in 1:N

        think =
            i

        hungry =
            N + i

        eat =
            2N + i

        left_fork =
            3N + i

        right_fork =
            3N + (i % N + 1)

        get_left =
            i

        get_right =
            N + i

        put_forks =
            2N + i

        add_arc!(
            net,
            think,
            get_left,
            -1
        )

        add_arc!(
            net,
            left_fork,
            get_left,
            -1
        )

        add_arc!(
            net,
            arbiter_idx,
            get_left,
            -1
        )

        add_arc!(
            net,
            hungry,
            get_left,
            +1
        )

        add_arc!(
            net,
            hungry,
            get_right,
            -1
        )

        add_arc!(
            net,
            right_fork,
            get_right,
            -1
        )

        add_arc!(
            net,
            eat,
            get_right,
            +1
        )

        add_arc!(
            net,
            eat,
            put_forks,
            -1
        )

        add_arc!(
            net,
            think,
            put_forks,
            +1
        )

        add_arc!(
            net,
            left_fork,
            put_forks,
            +1
        )

        add_arc!(
            net,
            right_fork,
            put_forks,
            +1
        )

        add_arc!(
            net,
            arbiter_idx,
            put_forks,
            +1
        )
    end

    u0 =
        zeros(
            Float64,
            n_places
        )

    for i in 1:N

        u0[i] =
            1.0

        u0[3N+i] =
            1.0
    end

    u0[
        arbiter_idx
    ] = N - 1

    return (
        net,
        u0,
        net.place_names
    )
end


# -------------------------------------------------
# Детерминированная модель
# -------------------------------------------------

function vectorfield(
    net::PetriNet,
    rates=
        ones(
            net.n_transitions
        )
)

    function f!(
        du,
        u,
        params,
        t
    )

        activity =
            zeros(
                net.n_transitions
            )

        for j in 1:net.n_transitions

            value =
                rates[j]

            for i in 1:net.n_places

                if net.incidence[i, j] < 0

                    value *=
                        max(
                            u[i],
                            0.0
                        ) ^
                        (-net.incidence[i, j])
                end
            end

            activity[j] =
                value
        end

        du .=
            net.incidence *
            activity

        return nothing
    end

    return f!
end


function simulate_ode(
    net::PetriNet,
    u0::Vector{Float64},
    tmax::Float64;
    saveat=0.1
)

    f =
        vectorfield(net)

    prob =
        ODEProblem(
            f,
            u0,
            (
                0.0,
                tmax
            )
        )

    sol =
        solve(
            prob,
            Tsit5();
            saveat=saveat
        )

    df =
        DataFrame(
            time=sol.t
        )

    for i in 1:net.n_places

        df[
            !,
            String(
                net.place_names[i]
            )
        ] =
            sol[i, :]
    end

    return df
end


# -------------------------------------------------
# Стохастическая модель — алгоритм Гиллеспи
# -------------------------------------------------

function simulate_stochastic(
    net::PetriNet,
    u0::Vector{Float64},
    tmax::Float64;
    rates=
        ones(
            net.n_transitions
        ),
    rng=
        Random.GLOBAL_RNG
)

    u =
        copy(u0)

    t =
        0.0

    times =
        [t]

    states =
        [copy(u)]

    while t < tmax

        activity =
            zeros(
                net.n_transitions
            )

        for j in 1:net.n_transitions

            value =
                rates[j]

            for i in 1:net.n_places

                if net.incidence[i, j] < 0

                    value *=
                        u[i] ^
                        (-net.incidence[i, j])
                end
            end

            activity[j] =
                value
        end

        total_activity =
            sum(activity)

        if total_activity <= 0
            break
        end

        dt =
            -log(
                rand(rng)
            ) /
            total_activity

        threshold =
            rand(rng) *
            total_activity

        cumulative =
            0.0

        chosen =
            1

        for j in 1:net.n_transitions

            cumulative +=
                activity[j]

            if threshold <= cumulative

                chosen =
                    j

                break
            end
        end

        for i in 1:net.n_places

            u[i] +=
                net.incidence[
                    i,
                    chosen
                ]
        end

        t += dt

        if t <= tmax

            push!(
                times,
                t
            )

            push!(
                states,
                copy(u)
            )
        end
    end

    df =
        DataFrame(
            time=times
        )

    for i in 1:net.n_places

        df[
            !,
            String(
                net.place_names[i]
            )
        ] =
            [
                state[i]
                for state in states
            ]
    end

    return df
end


# -------------------------------------------------
# Проверка deadlock
# -------------------------------------------------

function detect_deadlock(
    df::DataFrame,
    net::PetriNet;
    tol=1e-6
)

    last_state =
        [
            df[
                end,
                String(
                    net.place_names[i]
                )
            ]
            for i in 1:net.n_places
        ]

    for j in 1:net.n_transitions

        can_fire =
            true

        for i in 1:net.n_places

            if net.incidence[i, j] < 0 &&
               last_state[i] <
               -net.incidence[i, j] -
               tol

                can_fire =
                    false

                break
            end
        end

        if can_fire
            return false
        end
    end

    return true
end


# -------------------------------------------------
# Визуализация маркировки
# -------------------------------------------------

function plot_marking_evolution(
    df::DataFrame,
    N::Int
)

    panels =
        Any[]

    for group in [
        "Think",
        "Hungry",
        "Eat",
        "Fork"
    ]

        p =
            plot(
                xlabel="Время",
                ylabel=group,
                title="$group states"
            )

        for i in 1:N

            column =
                "$(group)_$i"

            if column in names(df)

                plot!(
                    p,
                    df.time,
                    df[
                        !,
                        column
                    ];
                    label=column
                )
            end
        end

        push!(
            panels,
            p
        )
    end

    return plot(
        panels...;
        layout=(4, 1),
        size=(850, 1000)
    )
end


end
