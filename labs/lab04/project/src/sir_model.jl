using Agents
using Random
using Graphs

using StatsBase:
    sample,
    Weights

using Distributions:
    Poisson

using DrWatson:
    @dict


# -------------------------------------------------
# Агент
# -------------------------------------------------

@agent struct Person(GraphAgent)
    days_infected::Int
    status::Symbol
end


# -------------------------------------------------
# Инициализация модели
# -------------------------------------------------

function initialize_sir(;
    Ns=[1000, 1000, 1000],
    migration_rates=nothing,
    β_und=[0.5, 0.5, 0.5],
    β_det=[0.05, 0.05, 0.05],
    infection_period=14,
    detection_time=7,
    death_rate=0.02,
    reinfection_probability=0.1,
    Is=[0, 0, 1],
    seed=42,
    n_steps=100
)

    rng = Xoshiro(seed)

    C = length(Ns)

    # Если матрица миграции не передана,
    # создаём её автоматически.

    if migration_rates === nothing

        migration_rates =
            zeros(C, C)

        for i in 1:C
            for j in 1:C

                migration_rates[i, j] =
                    (Ns[i] + Ns[j]) /
                    Ns[i]
            end
        end

        # Превращаем строки в вероятности.

        for i in 1:C

            migration_rates[i, :] ./=
                sum(
                    migration_rates[i, :]
                )
        end
    end

    properties =
        @dict(
            Ns,
            β_und,
            β_det,
            migration_rates,
            infection_period,
            detection_time,
            death_rate,
            reinfection_probability,
            C
        )

    # Города — вершины полного графа.

    space =
        GraphSpace(
            complete_graph(C)
        )

    model =
        StandardABM(
            Person,
            space;
            properties=properties,
            rng=rng,
            agent_step! = sir_agent_step!
        )

    # Заполняем города восприимчивыми агентами.

    for city in 1:C

        for _ in 1:Ns[city]

            add_agent!(
                city,
                model,
                0,
                :S
            )
        end
    end

    # Задаём начальные случаи инфекции.

    for city in 1:C

        if Is[city] > 0

            city_agents =
                collect(
                    ids_in_position(
                        city,
                        model
                    )
                )

            infected_ids =
                sample(
                    rng,
                    city_agents,
                    Is[city];
                    replace=false
                )

            for id in infected_ids

                agent = model[id]

                agent.status = :I
                agent.days_infected = 1
            end
        end
    end

    return model
end


# -------------------------------------------------
# Один модельный шаг агента
# -------------------------------------------------

function sir_agent_step!(
    agent,
    model
)

    migrate!(
        agent,
        model
    )

    if agent.status == :I

        transmit!(
            agent,
            model
        )

        agent.days_infected += 1
    end

    recover_or_die!(
        agent,
        model
    )

    return nothing
end


# -------------------------------------------------
# Миграция
# -------------------------------------------------

function migrate!(
    agent,
    model
)

    current_city =
        agent.pos

    probabilities =
        model.migration_rates[
            current_city,
            :
        ]

    target_city =
        sample(
            abmrng(model),
            1:model.C,
            Weights(probabilities)
        )

    if target_city != current_city

        move_agent!(
            agent,
            target_city,
            model
        )
    end

    return nothing
end


# -------------------------------------------------
# Передача инфекции
# -------------------------------------------------

function transmit!(
    agent,
    model
)

    # До выявления заразность выше.

    rate =
        if agent.days_infected <
           model.detection_time

            model.β_und[
                agent.pos
            ]

        else

            model.β_det[
                agent.pos
            ]
        end

    # Количество новых заражений случайно
    # и моделируется распределением Пуассона.

    n_infections =
        rand(
            abmrng(model),
            Poisson(rate)
        )

    n_infections == 0 &&
        return nothing

    contacts =
        [
            a
            for a in
            agents_in_position(
                agent.pos,
                model
            )
            if a.id != agent.id
        ]

    shuffle!(
        abmrng(model),
        contacts
    )

    for contact in contacts

        if contact.status == :S

            contact.status = :I
            contact.days_infected = 1

            n_infections -= 1

        elseif contact.status == :R &&
               rand(abmrng(model)) <=
               model.reinfection_probability

            contact.status = :I
            contact.days_infected = 1

            n_infections -= 1
        end

        if n_infections == 0
            return nothing
        end
    end

    return nothing
end


# -------------------------------------------------
# Выздоровление или смерть
# -------------------------------------------------

function recover_or_die!(
    agent,
    model
)

    if agent.status == :I &&
       agent.days_infected >=
       model.infection_period

        if rand(abmrng(model)) <=
           model.death_rate

            remove_agent!(
                agent,
                model
            )

        else

            agent.status = :R
            agent.days_infected = 0
        end
    end

    return nothing
end


# -------------------------------------------------
# Общие показатели
# -------------------------------------------------

susceptible_count(model) =
    count(
        a -> a.status == :S,
        allagents(model)
    )

infected_count(model) =
    count(
        a -> a.status == :I,
        allagents(model)
    )

recovered_count(model) =
    count(
        a -> a.status == :R,
        allagents(model)
    )

total_count(model) =
    nagents(model)


# -------------------------------------------------
# Показатели по городу
# -------------------------------------------------

function city_status_count(
    model,
    city,
    status
)

    return count(
        a -> a.status == status,
        agents_in_position(
            city,
            model
        )
    )
end


function city_population(
    model,
    city
)

    return count(
        _ -> true,
        agents_in_position(
            city,
            model
        )
    )
end


# -------------------------------------------------
# Безопасный ручной шаг
# -------------------------------------------------

function sir_manual_step!(
    model
)

    ids =
        collect(
            allids(model)
        )

    # Перемешиваем порядок агентов,
    # чтобы фиксированный порядок не влиял
    # на результат.

    shuffle!(
        abmrng(model),
        ids
    )

    for id in ids

        agent =
            try
                model[id]
            catch
                nothing
            end

        # Агент мог быть удалён ранее
        # на этом же модельном шаге.

        if agent !== nothing

            sir_agent_step!(
                agent,
                model
            )
        end
    end

    return nothing
end
