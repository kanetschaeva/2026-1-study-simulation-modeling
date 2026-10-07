#!/usr/bin/env julia

# setup_project.jl
# Автор: Нечаева Кира Андреевна
# Группа: НКНбд-01-23

using Pkg
Pkg.add("DrWatson")

using DrWatson

initialize_project(
    "project";
    authors="Нечаева Кира Андреевна",
    git=false
)

println("Проект лабораторной работы №2 создан.")
