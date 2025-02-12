mozc_library(key_info_util.cc DEPENDS mozc::protocol::protocol mozc::composer::composer mozc::session::keymap)
mozc_library(keymap.cc DEPENDS mozc::protocol::protocol mozc::composer::composer)
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
        key_event_transformer.cc
        ime_context.cc
    DEPENDS
        mozc::protocol::protocol
        mozc::engine::engine_converter
        mozc::transliteration::transliteration
        mozc::session::keymap
        mozc::engine::candidate_list
        mozc::engine::engine_output)
mozc_library(session_handler.cc DEPENDS
    absl::raw_hash_set
    absl::random_random
    absl::flags
    mozc::protocol::protocol
    mozc::config::config_handler
    mozc::config::character_form_manager
    mozc::base::process
    mozc::composer::composer
    mozc::session::keymap
    mozc::session::session
    mozc::session::session_watch_dog
    mozc::dictionary::user_dictionary_session_handler
    mozc::base::stopwatch )
mozc_library(session_server.cc DEPENDS
    mozc::data_manager::oss::oss_data_manager
    mozc::session::session_handler
    mozc::protocol::protocol
    mozc::ipc::named_event
    mozc::ipc::ipc
    mozc::ipc::ipc_path_manager
    mozc::base::vlog
    mozc::base::random
    mozc::base::process_mutex
    mozc::engine::engine)
