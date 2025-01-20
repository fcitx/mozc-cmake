qt6_wrap_ui(dictionary_tool_ui_FILES
${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_tool.ui
${MOZC_SOURCE_DIR}/gui/dictionary_tool/find_dialog.ui
${MOZC_SOURCE_DIR}/gui/dictionary_tool/import_dialog.ui
)
qt6_wrap_cpp(dictionary_tool_moc_FILES
${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_tool.h
${MOZC_SOURCE_DIR}/gui/dictionary_tool/import_dialog.h
${MOZC_SOURCE_DIR}/gui/dictionary_tool/find_dialog.h
${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_content_table_widget.h
${MOZC_SOURCE_DIR}/gui/dictionary_tool/zero_width_splitter.h
)

mozc_qt_add_resources(dictionary_tool_rc_FILES qrc_dictionary_tool
${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_tool.qrc
)

add_library(dictionary_tool ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_tool_libmain.cc
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_tool.cc
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/import_dialog.cc
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/find_dialog.cc
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/dictionary_content_table_widget.cc
    ${MOZC_SOURCE_DIR}/gui/dictionary_tool/zero_width_splitter.cc
    ${dictionary_tool_ui_FILES}
    ${dictionary_tool_moc_FILES}
    ${dictionary_tool_rc_FILES}
)

target_include_directories(dictionary_tool PRIVATE ${PROJECT_SOURCE_DIR}/mozc/src)
target_link_libraries(dictionary_tool
    Qt6::Widgets
    protocol
    mozc::base::system_util
    mozc::base::util
    mozc::dictionary::user_dictionary_storage
    mozc::dictionary::user_dictionary_session
    mozc::data_manager::pos_list_provider
    mozc::gui::base
    mozc::client::client
    combobox_delegate
)
