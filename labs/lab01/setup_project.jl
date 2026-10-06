#!/usr/bin/env julia

# setup_project.jl
# Автор: Нечаева Кира Андреевна
# Группа: НКНбд-01-23

using Pkg
Pkg.add("DrWatson")

using DrWatson

project_name = "project"

initialize_project(
    project_name;
    authors="Нечаева Кира Андреевна",
    git=false
)

println("Проект создан: ", project_name)
println("Перейдите в директорию: cd ", project_name)
