include(CMakeParseArguments)

function(mozc_target add_target TGT_OR_FILE)

set(options PROTO)
set(oneValueArgs)
set(multiValueArgs DEPENDS SOURCES)
cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${oneValueArgs}" "${multiValueArgs}"
)

file(RELATIVE_PATH relpath ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

set(LIBRARY_TYPE ${MOZC_LIBRARY_TYPE})
if (TGT_OR_FILE MATCHES "\.cc$")
    string(REPLACE "/" "-" TGT "${TGT_OR_FILE}")
    string(REGEX REPLACE "\.cc$" "" TGT "${TGT}")
    list(APPEND arg_SOURCES "${TGT_OR_FILE}")
elseif (TGT_OR_FILE MATCHES "\.h$")
    string(REPLACE "/" "-" TGT "${TGT_OR_FILE}")
    string(REGEX REPLACE "\.h$" "" TGT "${TGT}")
    list(APPEND arg_SOURCES "${TGT_OR_FILE}")
    set(LIBRARY_TYPE INTERFACE)
elseif (TGT_OR_FILE MATCHES "\.proto$")
    string(REPLACE "/" "-" TGT "${TGT_OR_FILE}")
    string(REGEX REPLACE "\.proto$" "_pb" TGT "${TGT}")
    list(APPEND arg_SOURCES "${TGT_OR_FILE}")
    set(arg_PROTO TRUE)
else()
    set(TGT "${TGT_OR_FILE}")
endif()
if (NOT "${relpath}" STREQUAL "")
    string(REPLACE "/" "-" TGT_PREFIX "${relpath}")
    set(TGT "${TGT_PREFIX}-${TGT}")
endif()

if (add_target STREQUAL add_executable)
add_executable(${TGT})
elseif (add_target STREQUAL add_library)
add_library(${TGT} ${LIBRARY_TYPE})
endif()

set_target_properties(${TGT} PROPERTIES EXCLUDE_FROM_ALL TRUE)

set(sources)
foreach(source_arg IN LISTS arg_SOURCES)
    if (NOT IS_ABSOLUTE ${source_arg})
        string(PREPEND source_arg ${MOZC_SOURCE_DIR}/${relpath}/)
    endif()
    list(APPEND sources "${source_arg}")
endforeach()

target_sources(${TGT} PRIVATE ${sources})

string(REPLACE "-" "::" ALIAS_TGT "${TGT}")
if ((NOT LIBRART_TYPE STREQUAL "INTERFACE") AND add_target STREQUAL add_library)
    target_link_libraries(${TGT} PUBLIC ${arg_DEPENDS})
else()
    target_link_libraries(${TGT} ${arg_DEPENDS})
endif()

if (add_target STREQUAL add_executable)
add_executable(mozc::${ALIAS_TGT} ALIAS "${TGT}")
elseif (add_target STREQUAL add_library)
add_library(mozc::${ALIAS_TGT} ALIAS "${TGT}")
endif()

set(INC ${arg_SOURCES})
list(FILTER INC INCLUDE REGEX "\.(inc|h)")
if (INC)
    if (LIBRARY_TYPE STREQUAL INTERFACE)
        target_include_directories(${TGT} INTERFACE ${PROJECT_BINARY_DIR})
    else()
        target_include_directories(${TGT} PUBLIC ${PROJECT_BINARY_DIR})
    endif()
endif()

if (arg_PROTO)
    target_include_directories(${TGT} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
    target_link_libraries(${TGT} PUBLIC protobuf::libprotobuf)
    protobuf_generate(TARGET ${TGT} LANGUAGE cpp
        IMPORT_DIRS ${MOZC_SOURCE_DIR})
endif()

endfunction()

function(mozc_executable)
mozc_target(add_executable ${ARGN})
endfunction()

function(mozc_library)
mozc_target(add_library ${ARGN})
endfunction()

function(mozc_python_gen_file PYTHON_SCRIPT)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OUTPUTS INPUTS ARGS)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )

    set(inputs)
    foreach(input_arg IN LISTS arg_INPUTS)
        if (NOT IS_ABSOLUTE ${input_arg})
            string(PREPEND input_arg ${MOZC_SOURCE_DIR}/)
        endif()
        list(APPEND inputs "${input_arg}")
    endforeach()

    set(outputs)
    set(dirs)
    foreach(output_arg IN LISTS arg_OUTPUTS)
        if (NOT IS_ABSOLUTE ${output_arg})
            string(PREPEND output_arg ${CMAKE_CURRENT_BINARY_DIR}/)
        endif()
        list(APPEND outputs "${output_arg}")

        get_filename_component(dir ${output_arg} DIRECTORY)
        list(APPEND dirs "${dir}")
    endforeach()
    list(REMOVE_DUPLICATES dirs)

    add_custom_command(
        OUTPUT ${outputs}
        DEPENDS ${MOZC_SOURCE_DIR}/${PYTHON_SCRIPT} ${inputs}
        WORKING_DIRECTORY ${MOZC_SOURCE_DIR}
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=. $<TARGET_FILE:Python3::Interpreter> ${MOZC_SOURCE_DIR}/${PYTHON_SCRIPT} ${arg_ARGS}
    )
endfunction()

function(mozc_binary_gen_file BINARY)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OUTPUTS INPUTS ARGS)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )

    set(inputs)
    foreach(input_arg IN LISTS arg_INPUTS)
        if (NOT IS_ABSOLUTE ${input_arg})
            string(PREPEND input_arg mozc/src/)
        endif()
        list(APPEND inputs "${input_arg}")
    endforeach()

    set(outputs)
    set(dirs)
    foreach(output_arg IN LISTS arg_OUTPUTS)
        if (NOT IS_ABSOLUTE ${output_arg})
            string(PREPEND output_arg ${CMAKE_CURRENT_BINARY_DIR}/)
        endif()
        list(APPEND outputs "${output_arg}")

        get_filename_component(dir ${output_arg} DIRECTORY)
        list(APPEND dirs "${dir}")
    endforeach()
    list(REMOVE_DUPLICATES dirs)

    add_custom_command(
        OUTPUT ${outputs}
        DEPENDS ${BINARY} ${inputs}
        WORKING_DIRECTORY ${MOZC_SOURCE_DIR}
        COMMAND $<TARGET_FILE:${BINARY}> ${arg_ARGS}
    )
endfunction()

function(mozc_qt_add_resources outfiles resource_name resource)
get_filename_component(outfilename ${resource} NAME_WE)
get_filename_component(infile ${resource} ABSOLUTE)
set(outfile ${CMAKE_CURRENT_BINARY_DIR}/qrc_${outfilename}.cpp)

set_source_files_properties(${infile} PROPERTIES SKIP_AUTORCC ON)

add_custom_command(OUTPUT ${outfile}
                   COMMAND Qt6::rcc
                   ARGS --name ${resource_name} --output ${outfile} ${infile}
                   MAIN_DEPENDENCY ${infile}
                   DEPENDS Qt6::rcc
                   VERBATIM)
set_source_files_properties(${outfile} PROPERTIES SKIP_AUTOMOC ON
                                                  SKIP_AUTOUIC ON
                                                  SKIP_UNITY_BUILD_INCLUSION ON
                                                  SKIP_PRECOMPILE_HEADERS ON
                                                  )
list(APPEND ${outfiles} ${outfile})
set(${outfiles} ${${outfiles}} PARENT_SCOPE)

endfunction()
