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
