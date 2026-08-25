mozc_library(user_history_predictor.proto)
mozc_library(user_history_storage.cc DEPENDS
    mozc::prediction::user_history_predictor_pb
    mozc::base::config_file_stream
    mozc::base::hash
    mozc::storage::encrypted_string_storage
)
mozc_library(user_history_predictor.cc DEPENDS
    mozc::prediction::user_history_predictor_pb
    mozc::prediction::user_history_storage
    mozc::base::util
    mozc::base::clock
    mozc::base::vlog
    mozc::base::hash
    mozc::composer::composer
    mozc::converter::segments
    mozc::base::config_file_stream
    mozc::storage::encrypted_string_storage
    mozc::rewriter::variants_rewriter
    mozc::converter::segmenter
    mozc::converter::connector
)
mozc_library(suggestion_filter.cc DEPENDS
    absl::statusor
    absl::log
    mozc::base::hash
    mozc::base::util
    mozc::storage::existence_filter)
mozc_library(number_decoder.cc DEPENDS
    absl::log
    absl::check
    absl::raw_hash_set
    mozc::base::util
    mozc::dictionary::pos_matcher
    mozc::request::conversion_request
    mozc::composer::composer
)
mozc_library(dictionary_prediction_aggregator.cc DEPENDS
    mozc::protocol::protocol
    mozc::base::util
    mozc::base::number_util
    mozc::converter::segments
    mozc::composer::composer
    mozc::prediction::result
    mozc::prediction::single_kanji_decoder
    mozc::prediction::number_decoder
    mozc::prediction::zero_query_decoder
    mozc::prediction::english_decoder
    mozc::prediction::result_filter
    mozc::engine::modules
)
mozc_library(handwriting_decoder.cc DEPENDS
    mozc::dictionary::dictionary_interface
    mozc::prediction::user_history_predictor
    mozc::prediction::result
)
mozc_library(english_decoder.cc DEPENDS
    mozc::dictionary::dictionary_interface
    mozc::engine::modules
    mozc::prediction::result
    mozc::composer::composer
)
mozc_library(single_kanji_decoder.cc DEPENDS
    mozc::dictionary::pos_matcher
    mozc::request::conversion_request
)
mozc_library(realtime_decoder.cc DEPENDS
    mozc::request::conversion_request
    mozc::converter::converter_util
    mozc::converter::segments
    mozc::prediction::result
)
mozc_library(zero_query_decoder.cc
    DEPENDS
        mozc::engine::modules
        mozc::dictionary::dictionary_interface
        mozc::composer::composer
        mozc::prediction::result
        mozc::prediction::handwriting_decoder
)
mozc_library(result.cc DEPENDS
    absl::log
)
mozc_library(result_filter.cc DEPENDS
    mozc::converter::connector
    mozc::prediction::result
    mozc::prediction::suggestion_filter
    mozc::request::conversion_request
)
mozc_library(dictionary_predictor.cc DEPENDS
    mozc::protocol::protocol
    mozc::composer::composer
    mozc::converter::segments
    mozc::converter::connector
    mozc::converter::segmenter
    mozc::prediction::suggestion_filter
    mozc::prediction::result
    mozc::dictionary::single_kanji_dictionary
    mozc::prediction::dictionary_prediction_aggregator)
mozc_library(predictor.cc DEPENDS
    mozc::protocol::protocol
    mozc::composer::composer
    mozc::converter::segments
    mozc::prediction::dictionary_predictor
    mozc::prediction::user_history_storage
    mozc::prediction::realtime_decoder
)
mozc_executable(gen_suggestion_filter_main.cc DEPENDS
    mozc::base::file_stream
    mozc::base::util
    mozc::base::hash
    mozc::base::multifile
    mozc::base::init_mozc
    mozc::base::codegen_bytearray_stream
    mozc::storage::existence_filter
)
