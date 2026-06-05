cmake_minimum_required(VERSION 3.18)
project(ClueBotNGCore)

# Build options
option(COMPILE_BAYES_DB "Create bayes.db & two_bayes.db after compiling" ON)
option(CLEANUP_WORKSPACE "Remove all files from /workspace except the build output" ON)

# External packages
cmake_policy(SET CMP0167 NEW)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
find_package(Boost REQUIRED COMPONENTS thread system regex)

# We require a specific implementation of iconv (unicode support)
set(LIBICONV_RELEASE "1.17")
include(cmake/compile_iconv.cmake)

# Main binaries
add_executable(cluebotng src/bayesdb.hpp
                         src/framework.hpp
                         src/xmleditloader.hpp
                         src/bayesprocessors.hpp
                         src/faststringops.hpp
                         src/neuralnet.hpp
                         src/standardprocessors.hpp
                         src/main.cpp)
target_include_directories(cluebotng PRIVATE ${ICONV_INCLUDES})
target_compile_options(cluebotng PRIVATE -fno-pie)
target_link_options(cluebotng PRIVATE -no-pie)
target_link_libraries(cluebotng PRIVATE
    -Wl,-Bstatic
    expat
    db_cxx
    ${ICONV_LIBS}
    fann
    config++
    boost_thread
    boost_system
    boost_regex
    m
    matheval
    fl
    -Wl,-Bdynamic
    Threads::Threads
)

add_executable(create_ann src/create_ann.cpp)
target_compile_options(create_ann PRIVATE -fno-pie)
target_link_options(create_ann PRIVATE -no-pie)
target_link_libraries(create_ann PRIVATE -Wl,-Bstatic fann -Wl,-Bdynamic)

add_executable(create_bayes_db src/bayesdb.hpp src/create_bayes_db.cpp)
target_link_libraries(create_bayes_db PRIVATE -Wl,-Bstatic db_cxx -Wl,-Bdynamic Threads::Threads)

add_executable(print_bayes_db src/bayesdb.hpp src/print_bayes_db.cpp)
target_link_libraries(print_bayes_db PRIVATE -Wl,-Bstatic db_cxx -Wl,-Bdynamic Threads::Threads)

if (COMPILE_BAYES_DB)
    include(cmake/create_databases.cmake)
endif ()

if (CLEANUP_WORKSPACE)
    include(cmake/cleanup_workspace.cmake)
endif ()
