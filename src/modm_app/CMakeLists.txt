
project(digital_clock CXX C)

add_library(project_options INTERFACE)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(modm)

add_executable(${CMAKE_PROJECT_NAME}
  main.cpp
  rtc.cpp
)

target_link_libraries(${CMAKE_PROJECT_NAME}
#   my_header_lib
  project_options
#  modm_arch_options
  modm_options
  modm_warnings
  modm
)

# Outputs hex and bin files.
modm_targets_create(${CMAKE_PROJECT_NAME})
