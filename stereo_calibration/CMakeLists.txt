cmake_minimum_required(VERSION 2.8)
project( Calibration )
include_directories(${PROJECT_SOURCE_DIR}/include)
set(BIN "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BIN})
set(SOURCES src/main.cpp)
find_package( OpenCV REQUIRED)
add_subdirectory(src)
add_executable( stereoCalibration ${SOURCES})
target_link_libraries( stereoCalibration lib)