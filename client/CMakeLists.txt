mozc_library(server_launcher.cc DEPENDS mozc::protocol::protocol absl::log mozc::ipc::ipc mozc::ipc::named_event mozc::base::system_util mozc::base::vlog mozc::base::process)
mozc_library(client.cc DEPENDS mozc::protocol::protocol mozc::base::process mozc::client::server_launcher mozc::session::key_info_util mozc::base::run_level)
