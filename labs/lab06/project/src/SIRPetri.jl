module SIRPetri

using AlgebraicPetri
using Catlab.CategoricalAlgebra
using Catlab.Graphics
using OrdinaryDiffEq
using Plots
using DataFrames
using Random


export build_sir_network
export sir_ode
export simulate_deterministic
export simulate_stochastic
export plot_sir
export to_graphviz_sir


# -------------------------------------------------
# Построение сети Петри SIR
# -------------------------------------------------

function build_sir_network(
    β=0.3,
    γ=0.1
)

    states =
        [
            :S,
            :I,
            :R
        ]

    net =
        LabelledPetriNet(
            states,
            :infection =>
                (
                    [:S, :I] =>
                    [:I, :I]
                ),
            :recovery =>
                (
                    [:I] =>
                    [:R]
                )
        )

    u0 =
        [
            990.0,
            10.0,
            0.0
        ]

    return (
        net,
        u0,
        states
    )
end


# -------------------------------------------------
# Правая часть системы ОДУ
# -------------------------------------------------

function sir_ode(
    net,
    rates=[
        0.3,
        0.1
    ]
)

    function f!(
        du,
        u,
        p,
        t
    )

        S,
        I,
        R =
            u

        β,
        γ =
            rates

        infection_rate =
            β *
            S *
            I

        recovery_rate =
            γ *
            I

        du[1] =
            -infection_rate

        du[2] =
            infection_rate -
            recovery_rate

        du[3] =
            recovery_rate

        return nothing
    end

    return f!
end


# -------------------------------------------------
# Детерминированная симуляция
# -------------------------------------------------

function simulate_deterministic(
    net,
    u0,
    tspan;
    saveat=0.1,
    rates=[
        0.3,
        0.1
    ]
)

    f =
        sir_ode(
            net,
            rates
        )

    prob =
        ODEProblem(
            f,
            u0,
            tspan
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

    df.S =
        sol[1, :]

    df.I =
        sol[2, :]

    df.R =
        sol[3, :]

    return df
end


# -------------------------------------------------
# Стохастическая симуляция
# Прямой алгоритм Гиллеспи
# -------------------------------------------------

function simulate_stochastic(
    net,
    u0,
    tspan;
    rates=[
        0.3,
        0.1
    ],
    rng=
        Random.GLOBAL_RNG
)

    u =
        copy(u0)

    t =
        Float64(
            tspan[1]
        )

    times =
        [
            t
        ]

    states =
        [
            copy(u)
        ]

    β,
    γ =
        rates

    while t < tspan[2]

        S,
        I,
        R =
            u

        infection_activity =
            β *
            S *
            I

        recovery_activity =
            γ *
            I

        total_activity =
            infection_activity +
            recovery_activity

        if total_activity <= 0
            break
        end

        dt =
            -log(
                rand(rng)
            ) /
            total_activity

        next_time =
            t +
            dt

        if next_time > tspan[2]
            break
        end

        random_threshold =
            rand(rng) *
            total_activity

        if random_threshold <
           infection_activity

            if u[1] >= 1

                u[1] -=
                    1

                u[2] +=
                    1
            end

        else

            if u[2] >= 1

                u[2] -=
                    1

                u[3] +=
                    1
            end
        end

        t =
            next_time

        push!(
            times,
            t
        )

        push!(
            states,
            copy(u)
        )
    end

    df =
        DataFrame(
            time=times
        )

    df.S =
        [
            state[1]
            for state in states
        ]

    df.I =
        [
            state[2]
            for state in states
        ]

    df.R =
        [
            state[3]
            for state in states
        ]

    return df
end


# -------------------------------------------------
# График SIR
# -------------------------------------------------

function plot_sir(
    df::DataFrame;
    title="SIR dynamics"
)

    p =
        plot(
            df.time,
            df.S;
            label="S (Susceptible)",
            xlabel="Время",
            ylabel="Численность",
            linewidth=2,
            title=title
        )

    plot!(
        p,
        df.time,
        df.I;
        label="I (Infected)",
        linewidth=2
    )

    plot!(
        p,
        df.time,
        df.R;
        label="R (Recovered)",
        linewidth=2
    )

    return p
end

# -------------------------------------------------
# Graphviz-представление сети
# -------------------------------------------------

function to_graphviz_sir(
    net
)

    return to_graphviz(
        net;
        prog="dot"
    )
end


end
