mozc_library(user_history_predictor.proto)
mozc_library(user_history_predictor.cc DEPENDS
    mozc::prediction::user_history_predictor_pb
    mozc::base::util
    mozc::base::clock
    mozc::base::vlog
    mozc::base::hash
    mozc::composer::composer
    mozc::converter::segments
    mozc::base::config_file_stream
    mozc::storage::encrypted_string_storage
    mozc::rewriter::variants_rewriter
    mozc::dictionary::suppression_dictionary
)
mozc_library(suggestion_filter.cc DEPENDS
    absl::statusor
    absl::log
    mozc::base::hash
    mozc::base::util
    mozc::storage::existence_filter)
mozc_library(single_kanji_prediction_aggregator.cc DEPENDS
    mozc::dictionary::pos_matcher
    mozc::base::util
    mozc::composer::composer
    mozc::dictionary::single_kanji_dictionary
)
mozc_library(number_decoder.cc DEPENDS
    absl::log
    absl::check
    absl::raw_hash_set
    mozc::base::util
)
mozc_library(dictionary_prediction_aggregator.cc DEPENDS
    mozc::protocol::protocol
    mozc::base::util
    mozc::base::number_util
    mozc::converter::segments
    mozc::composer::composer
    mozc::prediction::result
    mozc::prediction::number_decoder
)
mozc_library(result.cc DEPENDS
    absl::log
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
