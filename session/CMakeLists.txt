mozc_library(key_info_util.cc DEPENDS protocol mozc::composer::composer mozc::session::internal::keymap)
mozc_library(internal/keymap.cc DEPENDS protocol mozc::composer::composer)
mozc_library(session_usage_observer.cc DEPENDS  protocol mozc::usage_stats::usage_stats mozc::config::stats_config_util mozc::base::clock mozc::base::vlog)
mozc_library(session_usage_stats_util.cc DEPENDS protocol mozc::base::util mozc::usage_stats::usage_stats)
mozc_library(session_observer_handler.cc DEPENDS protocol)
mozc_library(internal/candidate_list.cc DEPENDS
    absl::raw_hash_set
    absl::log
    mozc::base::hash)
mozc_library(internal/session_output.cc DEPENDS
    protocol
    mozc::session::internal::candidate_list
    mozc::base::text_normalizer
    mozc::converter::segments
    mozc::composer::composer)
mozc_library(session_converter.cc DEPENDS
    protocol
    mozc::usage_stats::usage_stats
    mozc::session::internal::candidate_list
    mozc::converter::segments
    mozc::base::util
    mozc::composer::composer
    mozc::session::internal::session_output
    mozc::session::session_usage_stats_util)
mozc_library(session_watch_dog.cc DEPENDS
    absl::log
    absl::check
    mozc::client::client
    mozc::base::cpu_stats
    mozc::base::vlog
    mozc::base::clock
    mozc::base::system_util)
mozc_library(session.cc
    SOURCES
    internal/ime_context.cc
    internal/key_event_transformer.cc
    DEPENDS
        protocol
        mozc::session::session_converter
        mozc::session::session_usage_stats_util
        mozc::usage_stats::usage_stats
        mozc::transliteration::transliteration
        mozc::session::internal::keymap
        mozc::session::internal::candidate_list
        mozc::session::internal::session_output)
mozc_library(session_handler.cc DEPENDS
    absl::raw_hash_set
    absl::random_random
    absl::flags
    protocol
    mozc::config::config_handler
    mozc::usage_stats::usage_stats
    mozc::config::character_form_manager
    mozc::base::process
    mozc::composer::composer
    mozc::session::internal::keymap
    mozc::session::session
    mozc::session::session_observer_handler
    mozc::session::session_watch_dog
    mozc::dictionary::user_dictionary_session_handler
    mozc::base::stopwatch )
mozc_library(session_server.cc DEPENDS
    mozc::data_manager::oss::oss_data_manager
    mozc::session::session_usage_observer
    mozc::session::session_handler
    protocol
    mozc::ipc::named_event
    mozc::ipc::ipc
    mozc::ipc::ipc_path_manager
    mozc::base::vlog
    mozc::base::random
    mozc::base::process_mutex
    mozc::engine::engine)
