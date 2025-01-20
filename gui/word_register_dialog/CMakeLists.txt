qt6_wrap_ui(word_register_dialog_ui_FILES
    ${MOZC_SOURCE_DIR}/gui/word_register_dialog/word_register_dialog.ui
)
qt6_wrap_cpp(word_register_dialog_moc_FILES
${MOZC_SOURCE_DIR}/gui/word_register_dialog/word_register_dialog.h
)

mozc_qt_add_resources(word_register_dialog_rc_FILES qrc_word_register_dialog
${MOZC_SOURCE_DIR}/gui/word_register_dialog/word_register_dialog.qrc
)

add_library(word_register_dialog ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/word_register_dialog/word_register_dialog_libmain.cc
    ${MOZC_SOURCE_DIR}/gui/word_register_dialog/word_register_dialog.cc
    ${word_register_dialog_ui_FILES}
    ${word_register_dialog_moc_FILES}
    ${word_register_dialog_rc_FILES}
)

target_include_directories(word_register_dialog PRIVATE ${PROJECT_SOURCE_DIR}/mozc/src ${PROJECT_BINARY_DIR})
target_link_libraries(word_register_dialog
    Qt6::Widgets
    protocol
    mozc::gui::base
    mozc::dictionary::user_dictionary_util
    mozc::dictionary::user_dictionary_storage
    mozc::dictionary::user_dictionary_session
    mozc::client::client
    mozc::data_manager::pos_list_provider
    absl::log
)
