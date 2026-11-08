cmake_minimum_required(VERSION 4.0)
project(processbridge)
project(processbridge LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(processbridge SHARED
        api.cpp
)
