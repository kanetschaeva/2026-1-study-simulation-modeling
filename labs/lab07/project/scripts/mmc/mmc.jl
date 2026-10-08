ENV["GKSwstype"] = "100"

using DrWatson
@quickactivate "project"

using StableRNGs
using Distributions
using ConcurrentSim
using ResumableFunctions

using DataFrames
using CSV
using Plots

rng =
    StableRNG(
        123
    )

num_customers =
    10

num_servers =
    2

mu =
    1.0 / 2

lam =
    0.9

arrival_dist =
    Exponential(
        1 / lam
    )

service_dist =
    Exponential(
        1 / mu
    )

arrival_times =
    fill(
        NaN,
        num_customers
    )

service_start_times =
    fill(
        NaN,
        num_customers
    )

exit_times =
    fill(
        NaN,
        num_customers
    )

@resumable function customer(
    env::Environment,
    server::Resource,
    id::Integer,
    t_a::Float64,
    d_s::Distribution
)

    @yield timeout(
        env,
        t_a
    )

    arrival_times[id] =
        now(env)

    println(
        "Customer $id arrived: ",
        now(env)
    )

    @yield request(
        server
    )

    service_start_times[id] =
        now(env)

    println(
        "Customer $id entered service: ",
        now(env)
    )

    @yield timeout(
        env,
        rand(
            rng,
            d_s
        )
    )

    @yield unlock(
        server
    )

    exit_times[id] =
        now(env)

    println(
        "Customer $id exited service: ",
        now(env)
    )
end

function setup_and_run()

    sim =
        Simulation()

    server =
        Resource(
            sim,
            num_servers
        )

    arrival_time =
        0.0

    for i in 1:num_customers

        arrival_time +=
            rand(
                rng,
                arrival_dist
            )

        @process customer(
            sim,
            server,
            i,
            arrival_time,
            service_dist
        )
    end

    run(sim)
end


setup_and_run()

df =
    DataFrame(
        customer=
            1:num_customers,
        arrival=
            arrival_times,
        service_start=
            service_start_times,
        exit=
            exit_times
    )

df.waiting =
    df.service_start -
    df.arrival

df.service =
    df.exit -
    df.service_start

df.system_time =
    df.exit -
    df.arrival

CSV.write(
    datadir(
        "mmc_results.csv"
    ),
    df
)

println(
    "\nСреднее время ожидания: ",
    mean(
        df.waiting
    )
)

println(
    "Среднее время в системе: ",
    mean(
        df.system_time
    )
)

p1 =
    plot(
        df.customer,
        df.arrival;
        marker=:circle,
        label="Arrival",
        xlabel="Customer",
        ylabel="Time",
        title="M/M/c: времена событий"
    )

plot!(
    p1,
    df.customer,
    df.service_start;
    marker=:circle,
    label="Service start"
)

plot!(
    p1,
    df.customer,
    df.exit;
    marker=:circle,
    label="Exit"
)

savefig(
    p1,
    plotsdir(
        "mmc_timeline.png"
    )
)

p2 =
    bar(
        df.customer,
        df.waiting;
        xlabel="Customer",
        ylabel="Waiting time",
        title="M/M/c: время ожидания",
        legend=false
    )

savefig(
    p2,
    plotsdir(
        "mmc_waiting_time.png"
    )
)

println(
    "\nСохранено:"
)

println(
    "data/mmc_results.csv"
)

println(
    "plots/mmc_timeline.png"
)

println(
    "plots/mmc_waiting_time.png"
)
