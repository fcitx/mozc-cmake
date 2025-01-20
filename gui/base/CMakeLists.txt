
add_library(gui-base ${MOZC_LIBRARY_TYPE}
${MOZC_SOURCE_DIR}/gui/base/util.cc
${MOZC_SOURCE_DIR}/gui/base/singleton_window_helper.cc
${MOZC_SOURCE_DIR}/gui/base/table_util.cc
${MOZC_SOURCE_DIR}/gui/base/debug_util.cc
${MOZC_SOURCE_DIR}/gui/base/encoding_util.cc
)
add_library(mozc::gui::base ALIAS gui-base)
target_link_libraries(gui-base
    Qt6::Widgets
    absl::log
    mozc::ipc::window_info_pb
    mozc::base::util
    mozc::base::file_stream
    mozc::base::process_mutex
    mozc::base::crash_report_handler
)
