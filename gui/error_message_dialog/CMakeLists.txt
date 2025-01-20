
qt6_wrap_cpp(error_message_dialog_moc_FILES
${MOZC_SOURCE_DIR}/gui/error_message_dialog/error_message_dialog.h
)

mozc_qt_add_resources(error_message_dialog_rc_FILES qrc_error_message_dialog
${MOZC_SOURCE_DIR}/gui/error_message_dialog/error_message_dialog.qrc
)

add_library(error_message_dialog ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/error_message_dialog/error_message_dialog_libmain.cc
    ${MOZC_SOURCE_DIR}/gui/error_message_dialog/error_message_dialog.cc
    ${error_message_dialog_ui_FILES}
    ${error_message_dialog_moc_FILES}
    ${error_message_dialog_rc_FILES}
)

target_include_directories(error_message_dialog PRIVATE ${PROJECT_SOURCE_DIR}/mozc/src ${PROJECT_BINARY_DIR})
target_link_libraries(error_message_dialog
    Qt6::Widgets
    absl::log
    mozc::base::system_util
    mozc::base::process_mutex
    mozc::gui::base
)
