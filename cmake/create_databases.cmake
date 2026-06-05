# Create bayes db files using the executables we just built
foreach (BAYES_TRAIN_FILE data/main_bayes_train.dat data/two_bayes_train.dat)
    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/${BAYES_TRAIN_FILE})
        message(FATAL_ERROR "Missing source training data: ${BAYES_TRAIN_FILE}")
    endif ()
endforeach ()

add_custom_command(TARGET create_bayes_db POST_BUILD
    COMMAND $<TARGET_FILE:create_bayes_db> data/bayes.db data/main_bayes_train.dat
    COMMAND $<TARGET_FILE:create_bayes_db> data/two_bayes.db data/two_bayes_train.dat
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    VERBATIM
)
