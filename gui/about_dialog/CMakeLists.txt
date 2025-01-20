qt6_wrap_ui(about_dialog_ui_FILES
    ${MOZC_SOURCE_DIR}/gui/about_dialog/about_dialog.ui
)
qt6_wrap_cpp(about_dialog_moc_FILES
${MOZC_SOURCE_DIR}/gui/about_dialog/about_dialog.h
)

mozc_qt_add_resources(about_dialog_rc_FILES qrc_about_dialog
${MOZC_SOURCE_DIR}/gui/about_dialog/about_dialog.qrc
)

add_library(about_dialog ${MOZC_LIBRARY_TYPE}
    ${MOZC_SOURCE_DIR}/gui/about_dialog/about_dialog_libmain.cc
    ${MOZC_SOURCE_DIR}/gui/about_dialog/about_dialog.cc
    ${about_dialog_ui_FILES}
    ${about_dialog_moc_FILES}
    ${about_dialog_rc_FILES}
)

target_include_directories(about_dialog PRIVATE ${PROJECT_SOURCE_DIR}/mozc/src ${PROJECT_BINARY_DIR})
target_link_libraries(about_dialog
    Qt6::Widgets
    mozc::base::system_util
    mozc::base::process
    mozc::base::file_util
    mozc::base::version
    mozc::base::run_level
    mozc::gui::base
)
