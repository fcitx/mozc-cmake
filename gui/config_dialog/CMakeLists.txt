
qt6_wrap_cpp(combobox_delegate_moc_FILES
${MOZC_SOURCE_DIR}/gui/config_dialog/combobox_delegate.h
)

add_library(combobox_delegate ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/config_dialog/combobox_delegate.cc
    ${combobox_delegate_moc_FILES}
)

target_include_directories(combobox_delegate PRIVATE ${PROJECT_SOURCE_DIR}/mozc/src ${PROJECT_BINARY_DIR})
target_link_libraries(combobox_delegate
    Qt6::Widgets
)

qt6_wrap_ui(config_dialog_ui_FILES
    ${MOZC_SOURCE_DIR}/gui/config_dialog/config_dialog.ui
    ${MOZC_SOURCE_DIR}/gui/config_dialog/generic_table_editor.ui
    ${MOZC_SOURCE_DIR}/gui/config_dialog/keybinding_editor.ui
)
qt6_wrap_cpp(config_dialog_moc_FILES
${MOZC_SOURCE_DIR}/gui/config_dialog/config_dialog.h
${MOZC_SOURCE_DIR}/gui/config_dialog/character_form_editor.h
${MOZC_SOURCE_DIR}/gui/config_dialog/keymap_editor.h
${MOZC_SOURCE_DIR}/gui/config_dialog/keybinding_editor.h
${MOZC_SOURCE_DIR}/gui/config_dialog/keybinding_editor_delegate.h
${MOZC_SOURCE_DIR}/gui/config_dialog/generic_table_editor.h
${MOZC_SOURCE_DIR}/gui/config_dialog/roman_table_editor.h
)

mozc_qt_add_resources(config_dialog_rc_FILES qrc_config_dialog
${MOZC_SOURCE_DIR}/gui/config_dialog/config_dialog.qrc
)

add_library(config_dialog ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/config_dialog/config_dialog_libmain.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/config_dialog.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/character_form_editor.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/keymap_editor.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/keybinding_editor.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/keybinding_editor_delegate.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/generic_table_editor.cc
    ${MOZC_SOURCE_DIR}/gui/config_dialog/roman_table_editor.cc
    ${config_dialog_ui_FILES}
    ${config_dialog_moc_FILES}
    ${config_dialog_rc_FILES}
)

target_include_directories(config_dialog PRIVATE ${MOZC_SOURCE_DIR} ${PROJECT_BINARY_DIR})
target_link_libraries(config_dialog
    Qt6::Widgets
    mozc::protocol::protocol
    mozc::base::system_util
    mozc::base::config_file_stream
    mozc::session::keymap
    mozc::gui::base
    mozc::client::client
    mozc::config::stats_config_util
    combobox_delegate
)
