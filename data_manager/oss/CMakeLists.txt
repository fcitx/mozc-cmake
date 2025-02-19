add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KEN_ALL.CSV ${CMAKE_CURRENT_BINARY_DIR}/JIGYOSYO.CSV
   COMMAND ${CMAKE_COMMAND} -E tar xzf ${PROJECT_SOURCE_DIR}/japanpost_zipcode/ken_all.zip
   COMMAND ${CMAKE_COMMAND} -E tar xzf ${PROJECT_SOURCE_DIR}/japanpost_zipcode/jigyosyo.zip
   COMMAND ${CMAKE_COMMAND} -E touch_nocreate KEN_ALL.CSV JIGYOSYO.CSV
   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
   DEPENDS ${PROJECT_SOURCE_DIR}/japanpost_zipcode/ken_all.zip
           ${PROJECT_SOURCE_DIR}/japanpost_zipcode/jigyosyo.zip
)
add_custom_target( zipcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/KEN_ALL.CSV ${CMAKE_CURRENT_BINARY_DIR}/JIGYOSYO.CSV)

mozc_python_gen_file(dictionary/gen_zip_code_seed.py
    OUTPUTS zip_code.tsv
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/KEN_ALL.CSV
           ${CMAKE_CURRENT_BINARY_DIR}/JIGYOSYO.CSV
    ARGS --output ${CMAKE_CURRENT_BINARY_DIR}/zip_code.tsv
         --zip_code ${CMAKE_CURRENT_BINARY_DIR}/KEN_ALL.CSV
         --jigyosyo ${CMAKE_CURRENT_BINARY_DIR}/JIGYOSYO.CSV
)

set(ID_DEF data/dictionary_oss/id.def)
set(SPECIAL_POS data/rules/special_pos.def)
set(USER_POS data/rules/user_pos.def)
set(CFORMS data/rules/cforms.def)
set(POS_MATCHER_RULE data/rules/pos_matcher_rule.def)
set(TEXT_CONNECTION_FILE data/dictionary_oss/connection_single_column.txt)

set(POS_LIST_DATA pos_list.data)
set(POS_LIST_INC pos_list.inc)
set(TOKEN_ARRAY_DATA user_pos_token_array.data)
set(STRING_ARRAY_DATA user_pos_string_array.data)
set(MOZC_DATA_INC mozc_data.inc)
set(MOZC_DATA mozc.data)
set(POS_MATCHER_DATA pos_matcher.data)
set(USER_POS_MANAGER_DATA user_pos_manager.data)

set(DICTIONARY_FILES
    ${CMAKE_CURRENT_BINARY_DIR}/zip_code.tsv
    data/dictionary_oss/dictionary00.txt
    data/dictionary_oss/dictionary01.txt
    data/dictionary_oss/dictionary02.txt
    data/dictionary_oss/dictionary03.txt
    data/dictionary_oss/dictionary04.txt
    data/dictionary_oss/dictionary05.txt
    data/dictionary_oss/dictionary06.txt
    data/dictionary_oss/dictionary07.txt
    data/dictionary_oss/dictionary08.txt
    data/dictionary_oss/dictionary09.txt
)

mozc_python_gen_file(dictionary/gen_aux_dictionary.py
    OUTPUTS aux_dictionary.txt
    INPUTS ${ID_DEF}
           data/dictionary_oss/aux_dictionary.tsv
           data/dictionary_manual/places.tsv
           data/dictionary_manual/words.tsv
           ${DICTIONARY_FILES}
    ARGS --strict --output ${CMAKE_CURRENT_BINARY_DIR}/aux_dictionary.txt
         --aux_tsv data/dictionary_oss/aux_dictionary.tsv
         --id_def ${ID_DEF}
         --words_tsv data/dictionary_manual/places.tsv
                     data/dictionary_manual/words.tsv
         --dictionary_txts ${DICTIONARY_FILES}
)

mozc_python_gen_file(dictionary/gen_filtered_dictionary.py
    OUTPUTS dictionary.txt
    INPUTS data/dictionary_oss/dictionary_filter.tsv
           ${DICTIONARY_FILES}
    ARGS --output ${CMAKE_CURRENT_BINARY_DIR}/dictionary.txt
         --filter_tsv data/dictionary_oss/dictionary_filter.tsv
         --dictionary_txts ${DICTIONARY_FILES}
)

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

add_custom_target(dataset-oss-pos_list
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${POS_LIST_INC}
)
set_target_properties(dataset-oss-pos_list PROPERTIES EXCLUDE_FROM_ALL TRUE)

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
set(COLLOCATION_DATA collocation.data)
mozc_binary_gen_file(mozc::rewriter::gen_collocation_data_main
    OUTPUTS ${COLLOCATION_DATA}
    INPUTS ${COLLOCATION_FILE}
    ARGS --collocation_data=${COLLOCATION_FILE}
         --output=${CMAKE_CURRENT_BINARY_DIR}/${COLLOCATION_DATA}
         --binary_mode
)

set(COLLOCATION_SUPPRESSION_FILE ${MOZC_SOURCE_DIR}/data/dictionary_oss/collocation_suppression.txt)
set(COLLOCATION_SUPPRESSION_DATA collocation_suppression.data)
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

set(SYSTEM_DICTIONARY dictionary.data)
set(DICTIONARY_FILE_ARGS
    ${CMAKE_CURRENT_BINARY_DIR}/aux_dictionary.txt
    ${CMAKE_CURRENT_BINARY_DIR}/dictionary.txt
    ${MOZC_SOURCE_DIR}/data/dictionary_oss/reading_correction.tsv
    ${MOZC_SOURCE_DIR}/data/dictionary_manual/domain.txt
    )
list(JOIN DICTIONARY_FILE_ARGS " " DICTIONARY_FILES_ARG) 
mozc_binary_gen_file(mozc::dictionary::gen_system_dictionary_data_main
    OUTPUTS ${SYSTEM_DICTIONARY}
    INPUTS ${DICTIONARY_FILE_ARGS}
           ${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
    ARGS "--input=${DICTIONARY_FILES_ARG}"
        --user_pos_manager_data=${CMAKE_CURRENT_BINARY_DIR}/${USER_POS_MANAGER_DATA}
        --output=${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}
)
add_custom_target(dataset-oss-system_dictionary
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${SYSTEM_DICTIONARY}
)
set_target_properties(dataset-oss-system_dictionary PROPERTIES EXCLUDE_FROM_ALL TRUE)

set(SUGGESTION_FILTER_FILE ${MOZC_SOURCE_DIR}/data/dictionary_oss/suggestion_filter.txt)
set(SUGGESTION_FILTER_DATA suggestion_filter.data)
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

mozc_binary_gen_file(mozc::data_manager::dataset_writer_main
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

set(USAGE_BASE_CONJ_SUFFIX_DATA usage_base_conj_suffix.data)
set(USAGE_CONJ_INDEX_DATA usage_conj_index.data)
set(USAGE_CONJ_SUFFIX_DATA usage_conj_suffix.data)
set(USAGE_ITEM_ARRAY_DATA usage_item_array.data)
set(USAGE_STRING_ARRAY_DATA usage_string_array.data)

mozc_binary_gen_file(mozc::rewriter::gen_usage_rewriter_dictionary_main
    OUTPUTS
        ${USAGE_BASE_CONJ_SUFFIX_DATA}
        ${USAGE_CONJ_INDEX_DATA}
        ${USAGE_CONJ_SUFFIX_DATA}
        ${USAGE_ITEM_ARRAY_DATA}
        ${USAGE_STRING_ARRAY_DATA}
        ${CFORMS}
        third_party/japanese_usage_dictionary/usage_dict.txt
    INPUTS

    ARGS
        --usage_data_file=third_party/japanese_usage_dictionary/usage_dict.txt
        --cforms_file=${CFORMS}
        --output_base_conjugation_suffix=${CMAKE_CURRENT_BINARY_DIR}/${USAGE_BASE_CONJ_SUFFIX_DATA}
        --output_conjugation_suffix=${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_SUFFIX_DATA}
        --output_conjugation_index=${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_INDEX_DATA}
        --output_usage_item_array=${CMAKE_CURRENT_BINARY_DIR}/${USAGE_ITEM_ARRAY_DATA}
        --output_string_array=${CMAKE_CURRENT_BINARY_DIR}/${USAGE_STRING_ARRAY_DATA}
)

mozc_binary_gen_file(mozc::data_manager::dataset_writer_main
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

    ${CMAKE_CURRENT_BINARY_DIR}/${USAGE_BASE_CONJ_SUFFIX_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_INDEX_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_SUFFIX_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${USAGE_ITEM_ARRAY_DATA}
    ${CMAKE_CURRENT_BINARY_DIR}/${USAGE_STRING_ARRAY_DATA}

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
        "suffix_key:32:${CMAKE_CURRENT_BINARY_DIR}//${SUFFIX_KEY_DATA}"
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
        "usage_base_conjugation_suffix:32:${CMAKE_CURRENT_BINARY_DIR}/${USAGE_BASE_CONJ_SUFFIX_DATA}"
        "usage_conjugation_suffix:32:${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_SUFFIX_DATA}"
        "usage_conjugation_index:32:${CMAKE_CURRENT_BINARY_DIR}/${USAGE_CONJ_INDEX_DATA}"
        "usage_item_array:32:${CMAKE_CURRENT_BINARY_DIR}/${USAGE_ITEM_ARRAY_DATA}"
        "usage_string_array:32:${CMAKE_CURRENT_BINARY_DIR}/${USAGE_STRING_ARRAY_DATA}"
)

mozc_python_gen_file(build_tools/embed_file.py
    OUTPUTS ${MOZC_DATA_INC}
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA}
    ARGS --input=${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA}
         --name=kOssMozcDataSet
         --output=${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA_INC}
)
add_custom_target(dataset-oss-mozc_data
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${MOZC_DATA_INC}
)
set_target_properties(dataset-oss-mozc_data PROPERTIES EXCLUDE_FROM_ALL TRUE)

mozc_library(oss_data_manager.cc
    DEPENDS mozc::data_manager::data_manager
)
add_dependencies(data_manager-oss-oss_data_manager dataset-oss-mozc_data)
target_include_directories(data_manager-oss-oss_data_manager PRIVATE ${PROJECT_BINARY_DIR})
target_compile_definitions(data_manager-oss-oss_data_manager PRIVATE -DMOZC_DATASET_MAGIC_NUMBER_LENGTH=7)

mozc_python_gen_file(build_tools/redirect.py
    OUTPUTS segmenter_inl.inc
    INPUTS data/dictionary_oss/id.def
           data/rules/special_pos.def
           data/rules/segmenter.def
    ARGS ${CMAKE_CURRENT_BINARY_DIR}/segmenter_inl.inc
         ${MOZC_SOURCE_DIR}/converter/gen_segmenter_code.py
         data/dictionary_oss/id.def
         data/rules/special_pos.def
         data/rules/segmenter.def
)

add_custom_target(segmenter_inl
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/segmenter_inl.inc
)
set_target_properties(segmenter_inl PROPERTIES EXCLUDE_FROM_ALL TRUE)

mozc_executable(gen_oss_segmenter_bitarray_main.cc
    DEPENDS 
    mozc::base::init_mozc
    absl::flags
    mozc::converter::gen_segmenter_bitarray
)
add_dependencies(data_manager-oss-gen_oss_segmenter_bitarray_main segmenter_inl)
target_include_directories(data_manager-oss-gen_oss_segmenter_bitarray_main PRIVATE ${PROJECT_BINARY_DIR})
