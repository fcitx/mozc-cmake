mozc_library(minimal_converter.cc DEPENDS
    protocol
    mozc::converter::segments)
mozc_library(modules.cc DEPENDS
    protocol
    mozc::converter::connector
    mozc::converter::segmenter
    mozc::prediction::suggestion_filter
    mozc::prediction::single_kanji_prediction_aggregator
    mozc::dictionary::user_pos
    mozc::dictionary::user_dictionary
    mozc::dictionary::suffix_dictionary
    mozc::dictionary::dictionary_impl
    mozc::dictionary::system::system_dictionary)
mozc_library(data_loader.cc DEPENDS
    mozc::engine::modules
    mozc::data_manager::data_manager)
mozc_library(engine.cc DEPENDS
    protocol
    mozc::prediction::user_history_predictor
    mozc::converter::converter
    mozc::engine::minimal_converter
    mozc::engine::data_loader
    mozc::prediction::predictor
    mozc::converter::immutable_converter
    mozc::prediction::dictionary_predictor
    mozc::rewriter::rewriter
    mozc::dictionary::user_dictionary_session_handler
)
