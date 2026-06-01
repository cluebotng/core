cmake_minimum_required(VERSION 3.10)
project(ClueBotNGCore)

# Compiler flags
set(THREADS_PREFER_PTHREAD_FLAG ON)

# Executables
add_executable(cluebotng src/bayesdb.hpp
                         src/framework.hpp
                         src/xmleditloader.hpp
                         src/bayesprocessors.hpp
                         src/faststringops.hpp
                         src/neuralnet.hpp
                         src/standardprocessors.hpp
                         src/main.cpp)

# We require a specific implementation of iconv (unicode support) - compile and static link it
set(COMPILE_LIBICONV "ON")
if (COMPILE_LIBICONV)
    set(LIBICONV_RELEASE "1.17")

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz)
        file(
            DOWNLOAD
            https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_RELEASE}.tar.gz
            ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz
            SHOW_PROGRESS
        )
    endif ()

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE})
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar -xzf ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs
        )
    endif ()

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/Makefile)
        execute_process(
            COMMAND ./configure --enable-static
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}
        )
    endif ()

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/lib/.libs/libiconv.a)
        execute_process(
            COMMAND make
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}
        )
    endif ()

    file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/include ${CMAKE_SOURCE_DIR}/libs/lib)
    file(COPY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/include/iconv.h
         DESTINATION ${CMAKE_SOURCE_DIR}/libs/include)
    file(COPY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/lib/.libs/libiconv.a
         DESTINATION ${CMAKE_SOURCE_DIR}/libs/lib)

    target_include_directories(cluebotng PRIVATE ${CMAKE_SOURCE_DIR}/libs/include)
    target_link_libraries(cluebotng PRIVATE ${CMAKE_SOURCE_DIR}/libs/lib/libiconv.a)
else ()
    messsage(WARNING, "Using system iconv implementation - may not provide unicode support")
    target_link_libraries(cluebotng PRIVATE iconv)
endif ()

target_link_libraries(cluebotng PRIVATE expat db_cxx fann config++ boost_thread boost_system boost_regex m matheval fl pthread)

add_executable(create_ann src/create_ann.cpp)
target_link_libraries(create_ann PRIVATE fann)

add_executable(create_bayes_db src/bayesdb.hpp src/create_bayes_db.cpp)
target_link_libraries(create_bayes_db PRIVATE db_cxx pthread)

add_executable(print_bayes_db src/bayesdb.hpp src/print_bayes_db.cpp)
target_link_libraries(print_bayes_db PRIVATE db_cxx pthread)

# Create bayes db files using built executables
set(COMPILE_BAYES_DB "ON")
if (COMPILE_BAYES_DB)
    add_custom_command(TARGET create_bayes_db POST_BUILD
        COMMAND ./create_bayes_db data/bayes.db data/main_bayes_train.dat
        COMMAND ./create_bayes_db data/two_bayes.db data/two_bayes_train.dat
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        VERBATIM
    )
endif ()

# Cleanup buildpack workspace to only "release" artifacts
if (CMAKE_SOURCE_DIR STREQUAL "/workspace" AND DEFINED ENV{CNB_PLATFORM_DIR} AND EXISTS /layers)
    add_custom_target(workspace_cleanup ALL
        COMMAND find ${CMAKE_SOURCE_DIR} -maxdepth 1 -mindepth 1
            ! -name cluebotng
            ! -name create_ann
            ! -name create_bayes_db
            ! -name print_bayes_db
            ! -name data
            ! -name conf
            ! -name Procfile
            -exec rm -rf {} +
        DEPENDS cluebotng create_ann create_bayes_db print_bayes_db
        VERBATIM
    )
endif ()