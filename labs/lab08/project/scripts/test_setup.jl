using DrWatson
@quickactivate "project"

using ResumableFunctions
using ConcurrentSim
using Distributions
using DataFrames
using Random
using StatsPlots
using BenchmarkTools
using CSV
using Dates
using Literate
using IJulia
using Quarto

println("Все необходимые пакеты успешно загружены.")
println("Проект: ", projectdir())
