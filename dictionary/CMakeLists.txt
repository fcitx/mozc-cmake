mozc_python_gen_file(dictionary/gen_pos_matcher_code.py
    OUTPUTS pos_matcher_impl.inc
    INPUTS data/rules/pos_matcher_rule.def
    ARGS --pos_matcher_rule_file=data/rules/pos_matcher_rule.def
         --output_pos_matcher_h=${CMAKE_CURRENT_BINARY_DIR}/pos_matcher_impl.inc
)
add_custom_target(pos_matcher_impl DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/pos_matcher_impl.inc)

mozc_library(pos_matcher.h)
target_include_directories(dictionary-pos_matcher INTERFACE ${PROJECT_BINARY_DIR})
add_dependencies(dictionary-pos_matcher pos_matcher_impl)
mozc_library(user_dictionary_util.cc DEPENDS protocol mozc::base::vlog mozc::base::strings mozc::base::config_file_stream)
mozc_library(user_dictionary_storage.cc DEPENDS protocol mozc::dictionary::user_dictionary_util mozc::base::process_mutex)
mozc_library(user_dictionary_session_handler.cc DEPENDS absl::log absl::random_random mozc::dictionary::user_dictionary_session)
mozc_library(user_dictionary_session.cc DEPENDS
    protocol
    mozc::dictionary::user_dictionary_util 
    mozc::dictionary::user_dictionary_importer
    mozc::dictionary::user_dictionary_storage)
mozc_python_gen_file(dictionary/gen_pos_map.py
    OUTPUTS pos_map.inc
    INPUTS data/rules/third_party_pos_map.def
           data/rules/user_pos.def
    ARGS --user_pos_file=data/rules/user_pos.def
         --third_party_pos_map_file=data/rules/third_party_pos_map.def
         --output=${CMAKE_CURRENT_BINARY_DIR}/pos_map.inc
)
add_custom_target(pos_map DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/pos_map.inc)
mozc_library(user_dictionary_importer.cc 
    DEPENDS protocol mozc::base::mmap mozc::base::strings mozc::base::vlog mozc::base::number_util mozc::base::hash mozc::dictionary::user_dictionary_util)
add_dependencies(dictionary-user_dictionary_importer pos_map)
target_include_directories(dictionary-user_dictionary_importer PRIVATE ${PROJECT_BINARY_DIR})
mozc_library(suppression_dictionary.cc DEPENDS
    absl::log
    absl::raw_hash_set
    )
mozc_library(file/dictionary_file.cc
    SOURCES
    file/codec_factory.cc
    file/codec.cc
    file/codec_util.cc
    DEPENDS
    absl::log
    absl::statusor
    mozc::base::mmap
    mozc::base::vlog
    mozc::base::hash
    mozc::base::singleton)
mozc_library(user_pos.cc
    DEPENDS
        absl::log
        absl::raw_hash_set
        absl::check
        mozc::base::container::serialized_string_array
)
mozc_library(system/system_dictionary.cc
    SOURCES
        system/value_dictionary.cc
        system/codec.cc
    DEPENDS
        protocol
        mozc::dictionary::pos_matcher
        mozc::base::vlog
        mozc::base::singleton
        mozc::base::mmap
        mozc::base::strings
        mozc::base::util
        mozc::storage::louds::louds
        mozc::dictionary::file::dictionary_file
)
mozc_library(system/system_dictionary_builder.cc
    DEPENDS
        mozc::storage::louds::louds
        mozc::dictionary::system::system_dictionary
        mozc::base::file_stream
        mozc::base::file_util
)
mozc_library(dictionary_impl.cc
    DEPENDS
    protocol
    mozc::base::util
    mozc::dictionary::suppression_dictionary 
)
mozc_library(suffix_dictionary.cc
    DEPENDS
    protocol
    mozc::base::container::serialized_string_array
)
mozc_library(single_kanji_dictionary.cc
    DEPENDS
    protocol
    mozc::base::container::serialized_string_array
    mozc::data_manager::serialized_dictionary
    mozc::base::text_normalizer
)
mozc_library(user_dictionary.cc
    DEPENDS
        protocol
        mozc::base::vlog
        mozc::base::hash 
        mozc::dictionary::user_dictionary_util 
        mozc::dictionary::user_dictionary_storage
        mozc::dictionary::suppression_dictionary 
        mozc::usage_stats::usage_stats
)
mozc_library(text_dictionary_loader.cc DEPENDS
    mozc::dictionary::pos_matcher
    mozc::base::multifile
    mozc::base::util
    mozc::base::vlog
    absl::check
)
mozc_executable(gen_system_dictionary_data_main.cc DEPENDS
    mozc::base::init_mozc
    mozc::data_manager::data_manager
    mozc::dictionary::text_dictionary_loader
    mozc::dictionary::system::system_dictionary_builder
    mozc::dictionary::pos_matcher
)
