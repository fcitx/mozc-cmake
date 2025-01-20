mozc_library(config_handler.cc DEPENDS
    protocol
    mozc::base::vlog
    mozc::base::clock
    mozc::base::version
    mozc::base::singleton
    mozc::base::hash
    mozc::base::config_file_stream
    mozc::base::system_util)
mozc_library(stats_config_util.cc DEPENDS mozc::base::singleton absl::base)
mozc_library(character_form_manager.cc DEPENDS
    protocol
    absl::raw_hash_set
    absl::log
    absl::check
    mozc::base::strings
    mozc::base::util
    mozc::base::vlog
    mozc::base::mmap
    mozc::base::singleton
    mozc::base::config_file_stream
    mozc::config::config_handler
    mozc::storage::lru_storage
)
