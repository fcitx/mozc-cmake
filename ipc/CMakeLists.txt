mozc_library(ipc.proto)
mozc_library(window_info.proto)
mozc_library(named_event.cc DEPENDS absl::log mozc::base::system_util mozc::base::vlog mozc::base::hash)
mozc_library(ipc_path_manager.cc DEPENDS mozc::ipc::ipc_pb mozc::base::system_util  mozc::base::random mozc::base::vlog mozc::base::process_mutex mozc::base::version)
mozc_library(ipc.cc
             SOURCES
                unix_ipc.cc
             DEPENDS mozc::ipc::ipc_pb mozc::base::file_util mozc::base::vlog mozc::ipc::ipc_path_manager)
