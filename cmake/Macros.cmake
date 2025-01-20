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
        target_include_directories(${TGT} INTERFACE ${CMAKE_CURRENT_BINARY_DIR})
    else()
        target_include_directories(${TGT} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
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

function(mozc_dataset_writer_gen_file)
    mozc_binary_gen_file(mozc::data_manager::dataset_writer_main ${ARGN})
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

function(mozc_dataset dataset_tag mozc_data_varname )

set(ID_DEF data/dictionary_${dataset_tag}/id.def)
set(SPECIAL_POS data/rules/special_pos.def)
set(USER_POS data/rules/user_pos.def)
set(CFORMS data/rules/cforms.def)
set(POS_MATCHER_RULE data/rules/pos_matcher_rule.def)
set(TEXT_CONNECTION_FILE data/dictionary_${dataset_tag}/connection_single_column.txt)

set(POS_LIST_DATA pos_list.data)
set(POS_LIST_INC pos_list.inc)
set(TOKEN_ARRAY_DATA user_pos_token_array.data)
set(STRING_ARRAY_DATA user_pos_string_array.data)
set(MOZC_DATA_INC mozc_data.inc)
set(MOZC_DATA mozc.data)
set(POS_MATCHER_DATA pos_matcher.data)
set(USER_POS_MANAGER_DATA user_pos_manager.data)

mozc_python_gen_file(dictionary/gen_user_pos_data.py
    OUTPUTS ${TOKEN_ARRAY_DATA}
            ${STRING_ARRAY_DATA}
            ${POS_LIST_DATA}
    INPUTS  ${ID_DEF}
            data/rules/special_pos.def
            data/rules/user_pos.def
            data/rules/cforms.def
    ARGS --id_file=${ID_DEF}
         --special_pos_file=${SPECIAL_POS}
         --user_pos_file=${USER_POS}
         --cforms_file=${CFORMS}
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${TOKEN_ARRAY_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${STRING_ARRAY_DATA}
         --output_pos_list=${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_DATA}
)

mozc_python_gen_file(build_tools/embed_file.py
    OUTPUTS ${POS_LIST_INC}
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_DATA}
    ARGS --input=${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_DATA}
         --name=kPosArray
         --output=${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_INC}
)

add_custom_target(dataset-${dataset_tag}-pos_list
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_INC}
)

mozc_python_gen_file(dictionary/gen_pos_matcher_code.py
    OUTPUTS ${POS_MATCHER_DATA}
    INPUTS ${ID_DEF}
           ${SPECIAL_POS}
           ${POS_MATCHER_RULE}
    ARGS --id_file=${ID_DEF}
         --special_pos_file=${SPECIAL_POS}
         --pos_matcher_rule_file=${POS_MATCHER_RULE}
         --output_pos_matcher_data=${CMAKE_CURRENT_BINARY_DIR}/${POS_MATCHER_DATA}
)

set(COLLOCATION_FILE ${MOZC_SOURCE_DIR}/data/dictionary_oss/collocation.txt)
set(COLLOCATION_DATA collocation_data.data)
mozc_binary_gen_file(mozc::rewriter::gen_collocation_data_main
    OUTPUTS ${COLLOCATION_DATA}
    INPUTS ${COLLOCATION_FILE}
    ARGS --collocation_data=${COLLOCATION_FILE}
         --output=${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_DATA}
         --binary_mode
)

set(COLLOCATION_SUPPRESSION_FILE ${MOZC_SOURCE_DIR}/data/dictionary_oss/collocation_suppression.txt)
set(COLLOCATION_SUPPRESSION_DATA collocation_suppression_data.data)
mozc_binary_gen_file(mozc::rewriter::gen_collocation_suppression_data_main
    OUTPUTS ${COLLOCATION_SUPPRESSION_DATA}
    INPUTS ${COLLOCATION_SUPPRESSION_FILE}
    ARGS --suppression_data=${COLLOCATION_SUPPRESSION_FILE}
         --output=${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_SUPPRESSION_DATA}
         --binary_mode
)

set(CONNECTION_DATA connection.data)
mozc_python_gen_file(data_manager/gen_connection_data.py
    OUTPUTS ${CONNECTION_DATA}
    INPUTS ${TEXT_CONNECTION_FILE}
           ${ID_DEF}
           ${SPECIAL_POS}
    ARGS --text_connection_file ${TEXT_CONNECTION_FILE}
         --id_file ${ID_DEF}
         --special_pos_file ${SPECIAL_POS}
         --binary_output_file ${CMAKE_CURRENT_BINARY_DIR}/${CONNECTION_DATA}
         --use_1byte_cost false
)

set(SYSTEM_DICTIONARY system.dictionary)
set(DICTIONARY_FILES
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary00.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary01.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary02.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary03.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary04.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary05.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary06.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary07.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary08.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/dictionary09.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/reading_correction.tsv
    ${MOZC_SOURCE_DIR}/data/dictionary_manual/domain.txt
)
list(JOIN DICTIONARY_FILES " " DICTIONARY_FILES_ARG) 
mozc_binary_gen_file(mozc::dictionary::gen_system_dictionary_data_main
    OUTPUTS ${SYSTEM_DICTIONARY}
    INPUTS ${DICTIONARY_FILES}
           ${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
    ARGS "--input=${DICTIONARY_FILES_ARG}"
        --user_pos_manager_data=${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
        --output=${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}
)
add_custom_target(dataset-${dataset_tag}-system_dictionary
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}
)

set(SUGGESTION_FILTER_FILE ${MOZC_SOURCE_DIR}/data/dictionary_oss/suggestion_filter.txt)
set(SUGGESTION_FILTER_DATA suggestion_filter_data.data)
mozc_binary_gen_file(mozc::prediction::gen_suggestion_filter_main
    OUTPUTS ${SUGGESTION_FILTER_DATA}
    INPUTS ${SUGGESTION_FILTER_FILE}
    ARGS "--input=${SUGGESTION_FILTER_FILE}"
        --header=false
        --safe_list_files=""
        --output=${CMAKE_CURRENT_BINARY_DIR}/${SUGGESTION_FILTER_DATA}
)

set(POS_GROUP_DEF data/rules/user_segment_history_pos_group.def)
set(POS_GROUP_DATA pos_group.data)
mozc_python_gen_file(dictionary/gen_pos_rewrite_rule.py
    OUTPUTS ${POS_GROUP_DATA}
    INPUTS ${ID_DEF}
           ${SPECIAL_POS}
           ${POS_GROUP_DEF}
    ARGS
        --id_def=${ID_DEF}
        --special_pos=${SPECIAL_POS}
        --pos_group_def=${POS_GROUP_DEF}
        --output=${CMAKE_CURRENT_BINARY_DIR}/${POS_GROUP_DATA}
)

set(BOUNDARY_DEF data/rules/boundary.def)
set(BOUNDARY_DATA boundary.data)
mozc_python_gen_file(converter/gen_boundary_data.py
    OUTPUTS ${BOUNDARY_DATA}
    INPUTS ${ID_DEF}
           ${SPECIAL_POS}
           ${BOUNDARY_DEF}
    ARGS
        --id_def=${ID_DEF}
        --special_pos=${SPECIAL_POS}
        --boundary_def=${BOUNDARY_DEF}
        --output=${CMAKE_CURRENT_BINARY_DIR}/${BOUNDARY_DATA}
)

set(SEGMENTER_SIZEINFO_DATA segmenter_sizeinfo.data)
set(SEGMENTER_LTABLE_DATA segmenter_ltable.data)
set(SEGMENTER_RTABLE_DATA segmenter_rtable.data)
set(SEGMENTER_BITARRAY_DATA segmenter_bitarray.data)
mozc_binary_gen_file(mozc::data_manager::oss::gen_oss_segmenter_bitarray_main
    OUTPUTS ${SEGMENTER_SIZEINFO_DATA}
            ${SEGMENTER_LTABLE_DATA}
            ${SEGMENTER_RTABLE_DATA}
            ${SEGMENTER_BITARRAY_DATA}
    ARGS --output_size_info=${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_SIZEINFO_DATA}
        --output_ltable=${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_LTABLE_DATA}
        --output_rtable=${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_RTABLE_DATA}
        --output_bitarray=${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_BITARRAY_DATA}
)

set(COUNTER_SUFFIX_DATA counter_suffix.data)
mozc_python_gen_file(rewriter/gen_counter_suffix_array.py
    OUTPUTS ${COUNTER_SUFFIX_DATA}
    INPUTS ${ID_DEF} ${DICTIONARY_FILES}
    ARGS --id_file=${ID_DEF}
         --output=${CMAKE_CURRENT_BINARY_DIR}/${COUNTER_SUFFIX_DATA}
         ${DICTIONARY_FILES}
)

set(SUFFIX_FILE data/dictionary_oss/suffix.txt)
set(SUFFIX_KEY_DATA suffix_key.data)
set(SUFFIX_VALUE_DATA suffix_value.data)
set(SUFFIX_TOKEN_DATA suffix_token.data)
mozc_python_gen_file(dictionary/gen_suffix_data.py
    OUTPUTS ${SUFFIX_KEY_DATA}
            ${SUFFIX_VALUE_DATA}
            ${SUFFIX_TOKEN_DATA}
    INPUTS ${SUFFIX_FILE}
    ARGS --input=${SUFFIX_FILE}
         --output_key_array=${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_KEY_DATA}
         --output_value_array=${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_VALUE_DATA}
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_TOKEN_DATA}
         ${SUFFIX_FILE}
)

set(READING_CORRECITON_VALUE_DATA reading_correction_value.data)
set(READING_CORRECITON_ERROR_DATA reading_correction_error.data)
set(READING_CORRECITON_CORRECTION_DATA reading_correction_correction.data)
mozc_python_gen_file(rewriter/gen_reading_correction_data.py
    OUTPUTS ${READING_CORRECITON_VALUE_DATA}
            ${READING_CORRECITON_ERROR_DATA}
            ${READING_CORRECITON_CORRECTION_DATA}
    INPUTS data/dictionary_oss/reading_correction.tsv
    ARGS --input=data/dictionary_oss/reading_correction.tsv
         --output_value_array=${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_VALUE_DATA}
         --output_error_array=${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_ERROR_DATA}
         --output_correction_array=${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_CORRECTION_DATA}
)

mozc_dataset_writer_gen_file(
    OUTPUTS ${USER_POS_MANAGER_DATA}
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/${POS_MATCHER_DATA}
           ${CMAKE_CURRENT_BINARY_DIR}/${TOKEN_ARRAY_DATA}
           ${CMAKE_CURRENT_BINARY_DIR}/${STRING_ARRAY_DATA}
    ARGS --output=${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
         "pos_matcher:32:${CMAKE_CURRENT_BINARY_DIR}/${POS_MATCHER_DATA}"
         "user_pos_token:32:${CMAKE_CURRENT_BINARY_DIR}/${TOKEN_ARRAY_DATA}"
         "user_pos_string:32:${CMAKE_CURRENT_BINARY_DIR}/${STRING_ARRAY_DATA}"
)

set(SYMBOL_TOKEN_DATA symbol_token.data)
set(SYMBOL_STRING_DATA symbol_string.data)
mozc_binary_gen_file(mozc::rewriter::gen_symbol_rewriter_dictionary_main
    OUTPUTS ${SYMBOL_TOKEN_DATA}
            ${SYMBOL_STRING_DATA}
    INPUTS ${MOZC_SOURCE_DIR}/data/symbol/symbol.tsv
           ${MOZC_SOURCE_DIR}/data/rules/sorting_map.tsv
           ${MOZC_SOURCE_DIR}/data/symbol/ordering_rule.txt
           ${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
    ARGS --input=data/symbol/symbol.tsv
         --user_pos_manager_data=${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
         --sorting_table=data/rules/sorting_map.tsv
         --ordering_rule=data/symbol/ordering_rule.txt
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_STRING_DATA}
)

set(EMOTICON_TOKEN_DATA emoticon_token.data)
set(EMOTICON_STRING_DATA emoticon_string.data)
mozc_binary_gen_file(mozc::rewriter::gen_emoticon_rewriter_data
    OUTPUTS ${EMOTICON_TOKEN_DATA}
            ${EMOTICON_STRING_DATA}
    INPUTS ${MOZC_SOURCE_DIR}/data/emoticon/emoticon.tsv
    ARGS --input=data/emoticon/emoticon.tsv
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_STRING_DATA}
)

set(EMOJI_TOKEN_DATA emoji_token.data)
set(EMOJI_STRING_DATA emoji_string.data)
mozc_python_gen_file(rewriter/gen_emoji_rewriter_data.py
    OUTPUTS ${EMOJI_TOKEN_DATA}
            ${EMOJI_STRING_DATA}
    INPUTS data/emoji/emoji_data.tsv
    ARGS --input=data/emoji/emoji_data.tsv
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_STRING_DATA}
)

set(SINGLE_KANJI_STRING_DATA single_kanji_string.data)
set(SINGLE_KANJI_TOKEN_DATA single_kanji_token.data)
set(SINGLE_KANJI_VARIANT_TYPE_DATA single_kanji_variant_type.data)
set(SINGLE_KANJI_VARIANT_TOKEN_DATA single_kanji_variant_token.data)
set(SINGLE_KANJI_VARIANT_STRING_DATA single_kanji_variant_string.data)
mozc_python_gen_file(rewriter/gen_single_kanji_rewriter_data.py
    OUTPUTS ${SINGLE_KANJI_STRING_DATA}
            ${SINGLE_KANJI_TOKEN_DATA}
            ${SINGLE_KANJI_VARIANT_TYPE_DATA}
            ${SINGLE_KANJI_VARIANT_TOKEN_DATA}
            ${SINGLE_KANJI_VARIANT_STRING_DATA}
    INPUTS data/single_kanji/single_kanji.tsv
           data/single_kanji/variant_rule.txt
    ARGS --single_kanji_file=data/single_kanji/single_kanji.tsv
         --variant_file=data/single_kanji/variant_rule.txt
         --output_single_kanji_token=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_TOKEN_DATA}
         --output_single_kanji_string=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_STRING_DATA}
         --output_variant_types=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TYPE_DATA}
         --output_variant_tokens=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TOKEN_DATA}
         --output_variant_strings=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_STRING_DATA}
)

set(SINGLE_KANJI_NOUN_PREFIX_TOKEN_DATA single_kanji_noun_prefix_token.data)
set(SINGLE_KANJI_NOUN_PREFIX_STRING_DATA single_kanji_noun_prefix_string.data)
mozc_binary_gen_file(mozc::rewriter::gen_single_kanji_noun_prefix_data
    OUTPUTS ${SINGLE_KANJI_NOUN_PREFIX_TOKEN_DATA}
            ${SINGLE_KANJI_NOUN_PREFIX_STRING_DATA}
    ARGS --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_STRING_DATA}
)

set(ZERO_QUERY_TOKEN_DATA zero_query_token.data)
set(ZERO_QUERY_STRING_DATA zero_query_string.data)
mozc_python_gen_file(prediction/gen_zero_query_data.py
    OUTPUTS ${ZERO_QUERY_TOKEN_DATA}
            ${ZERO_QUERY_STRING_DATA}
    INPUTS  data/emoji/emoji_data.tsv
            data/emoticon/categorized.tsv
            data/symbol/symbol.tsv
            data/zero_query/zero_query.def
    ARGS --input_rule=data/zero_query/zero_query.def
         --input_symbol=data/symbol/symbol.tsv
         --input_emoji=data/emoji/emoji_data.tsv
         --input_emoticon=data/emoticon/categorized.tsv
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_STRING_DATA}
)

set(ZERO_QUERY_NUMBER_TOKEN_DATA zero_query_number_token.data)
set(ZERO_QUERY_NUMBER_STRING_DATA zero_query_number_string.data)
mozc_python_gen_file(prediction/gen_zero_query_number_data.py
    OUTPUTS ${ZERO_QUERY_NUMBER_TOKEN_DATA}
            ${ZERO_QUERY_NUMBER_STRING_DATA}
    INPUTS  data/zero_query/zero_query_number.def
    ARGS --input=data/zero_query/zero_query_number.def
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_STRING_DATA}
)

set(A11Y_DESCRIPTION_TOKEN_DATA a11y_description_token.data)
set(A11Y_DESCRIPTION_STRING_DATA a11y_description_string.data)
mozc_python_gen_file(rewriter/gen_a11y_description_rewriter_data.py
    OUTPUTS ${A11Y_DESCRIPTION_TOKEN_DATA}
            ${A11Y_DESCRIPTION_STRING_DATA}
    INPUTS  data/a11y_description/a11y_description_data.tsv
    ARGS --input=data/a11y_description/a11y_description_data.tsv
         --output_token_array=${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_TOKEN_DATA}
         --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_STRING_DATA}
)

set(VERSION_DATA version.data)
mozc_python_gen_file(data_manager/gen_data_version.py
    OUTPUTS ${VERSION_DATA}
    INPUTS data/version/mozc_version_template.bzl
    ARGS --tag=oss
         --mozc_version_template=data/version/mozc_version_template.bzl
         --output=${CMAKE_CURRENT_BINARY_DIR}/${VERSION_DATA}
)

mozc_dataset_writer_gen_file(
    OUTPUTS ${MOZC_DATA}
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/${POS_MATCHER_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${TOKEN_ARRAY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${STRING_ARRAY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_SUPPRESSION_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${CONNECTION_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}
    ${CMAKE_CURRENT_BINARY_DIR}/${SUGGESTION_FILTER_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${POS_GROUP_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${BOUNDARY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_SIZEINFO_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_LTABLE_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_RTABLE_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_BITARRAY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${COUNTER_SUFFIX_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_KEY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_VALUE_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_TOKEN_DATA}

    ${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_VALUE_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_ERROR_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_CORRECTION_DATA}
    
    ${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_STRING_DATA}
    
    ${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_STRING_DATA}
    
    ${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_STRING_DATA}

    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_STRING_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TYPE_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_STRING_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_STRING_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_STRING_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_STRING_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_TOKEN_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_STRING_DATA}

    ${CMAKE_CURRENT_BINARY_DIR}/${VERSION_DATA}

    ARGS --magic="\\xEF\\x4D\\x4F\\x5A\\x43\\x0D\\x0A"
         --output=${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA}
        "pos_matcher:32:${CMAKE_CURRENT_BINARY_DIR}/${POS_MATCHER_DATA}"
        "user_pos_token:32:${CMAKE_CURRENT_BINARY_DIR}/${TOKEN_ARRAY_DATA}"
        "user_pos_string:32:${CMAKE_CURRENT_BINARY_DIR}/${STRING_ARRAY_DATA}"
        "coll:32:${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_DATA}"
        "cols:32:${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_SUPPRESSION_DATA}"
        "conn:32:${CMAKE_CURRENT_BINARY_DIR}/${CONNECTION_DATA}"
        "dict:32:${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}"
        "sugg:32:${CMAKE_CURRENT_BINARY_DIR}/${SUGGESTION_FILTER_DATA}"
        "posg:32:${CMAKE_CURRENT_BINARY_DIR}/${POS_GROUP_DATA}"
        "bdry:32:${CMAKE_CURRENT_BINARY_DIR}/${BOUNDARY_DATA}"
        "segmenter_sizeinfo:32:${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_SIZEINFO_DATA}"
        "segmenter_ltable:32:${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_LTABLE_DATA}"
        "segmenter_rtable:32:${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_RTABLE_DATA}"
        "segmenter_bitarray:32:${CMAKE_CURRENT_BINARY_DIR}/${SEGMENTER_BITARRAY_DATA}"
        "counter_suffix:32:${CMAKE_CURRENT_BINARY_DIR}/${COUNTER_SUFFIX_DATA}"
        "suffix_key:32:${CMAKE_CURRENT_BINARY_DIR}//${SUFFIX_VALUE_DATA}"
        "suffix_value:32:${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_VALUE_DATA}"
        "suffix_token:32:${CMAKE_CURRENT_BINARY_DIR}/${SUFFIX_TOKEN_DATA}"
        "reading_correction_value:32:${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_VALUE_DATA}"
        "reading_correction_error:32:${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_ERROR_DATA}"
        "reading_correction_correction:32:${CMAKE_CURRENT_BINARY_DIR}/${READING_CORRECITON_CORRECTION_DATA}"
        "symbol_token:32:${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_TOKEN_DATA}"
        "symbol_string:32:${CMAKE_CURRENT_BINARY_DIR}/${SYMBOL_STRING_DATA}"
        "emoticon_token:32:${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_TOKEN_DATA}"
        "emoticon_string:32:${CMAKE_CURRENT_BINARY_DIR}/${EMOTICON_STRING_DATA}"
        "emoji_token:32:${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_TOKEN_DATA}"
        "emoji_string:32:${CMAKE_CURRENT_BINARY_DIR}/${EMOJI_STRING_DATA}"
        "single_kanji_token:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_TOKEN_DATA}"
        "single_kanji_string:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_STRING_DATA}"
        "single_kanji_variant_type:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TYPE_DATA}"
        "single_kanji_variant_token:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_TOKEN_DATA}"
        "single_kanji_variant_string:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_VARIANT_STRING_DATA}"
        "single_kanji_noun_prefix_token:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_TOKEN_DATA}"
        "single_kanji_noun_prefix_string:32:${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_KANJI_NOUN_PREFIX_STRING_DATA}"
        "zero_query_token_array:32:${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_TOKEN_DATA}"
        "zero_query_string_array:32:${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_STRING_DATA}"
        "zero_query_number_token_array:32:${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_TOKEN_DATA}"
        "zero_query_number_string_array:32:${CMAKE_CURRENT_BINARY_DIR}/${ZERO_QUERY_NUMBER_STRING_DATA}"
        "a11y_description_token:32:${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_TOKEN_DATA}"
        "a11y_description_string:32:${CMAKE_CURRENT_BINARY_DIR}/${A11Y_DESCRIPTION_STRING_DATA}"
        "version:32:${CMAKE_CURRENT_BINARY_DIR}/${VERSION_DATA}"
)

mozc_python_gen_file(build_tools/embed_file.py
    OUTPUTS ${MOZC_DATA_INC}
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA}
    ARGS --input=${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA}
         --name=${mozc_data_varname}
         --output=${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA_INC}
)
add_custom_target(dataset-${dataset_tag}-mozc_data
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA_INC}
)

endfunction()
