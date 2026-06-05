if (NOT DEFINED LIBICONV_RELEASE)
    message(FATAL_ERROR "LIBICONV_RELEASE must be set")
endif ()

file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/libs)

if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz)
    file(
        DOWNLOAD
        https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_RELEASE}.tar.gz
        ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz
        SHOW_PROGRESS
    )

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz)
        message(FATAL_ERROR "Failed to download libiconv-${LIBICONV_RELEASE}.tar.gz")
    endif ()
endif ()

if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar -xzf ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}.tar.gz
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs
        RESULT_VARIABLE ICONV_EXTRACT_RESULT
    )

    if (NOT ICONV_EXTRACT_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to extract libiconv-${LIBICONV_RELEASE}.tar.gz")
    endif ()
endif ()

if (NOT EXISTS ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/lib/.libs/libiconv.a)
    execute_process(
        COMMAND ./configure --enable-static
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}
        RESULT_VARIABLE ICONV_CONFIGURE_RESULT
    )

    if (NOT ICONV_CONFIGURE_RESULT EQUAL 0)
        file(READ ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/config.log ICONV_CONFIG_LOG)
        message("libiconv config.log:\n${ICONV_CONFIG_LOG}")
        message(FATAL_ERROR "Failed to configure libiconv")
    endif ()

    execute_process(
        COMMAND make
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}
        RESULT_VARIABLE ICONV_BUILD_RESULT
    )

    if (NOT ICONV_BUILD_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to build libiconv")
    endif ()
endif ()

file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/libs/libiconv/include ${CMAKE_SOURCE_DIR}/libs/libiconv/lib)
file(COPY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/include/iconv.h
     DESTINATION ${CMAKE_SOURCE_DIR}/libs/libiconv/include)
file(COPY ${CMAKE_SOURCE_DIR}/libs/libiconv-${LIBICONV_RELEASE}/lib/.libs/libiconv.a
     DESTINATION ${CMAKE_SOURCE_DIR}/libs/libiconv/lib)

set(ICONV_INCLUDES ${CMAKE_SOURCE_DIR}/libs/libiconv/include)
set(ICONV_LIBS ${CMAKE_SOURCE_DIR}/libs/libiconv/lib/libiconv.a)
