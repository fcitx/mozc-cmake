add_executable(mozc_tool
    ${MOZC_SOURCE_DIR}/gui/tool/mozc_tool_main.cc
    ${MOZC_SOURCE_DIR}/gui/tool/mozc_tool_libmain.cc
)

target_link_libraries(mozc_tool
    Qt6::Gui
    absl::log
    mozc::base::init_mozc
    config_dialog
    about_dialog
    error_message_dialog
    word_register_dialog
    dictionary_tool
)
