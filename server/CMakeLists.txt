
add_executable(mozc_server
    ${MOZC_SOURCE_DIR}/server/mozc_server.cc
    ${MOZC_SOURCE_DIR}/server/mozc_server_main.cc
)

target_link_libraries(mozc_server
    mozc::protocol::protocol
    mozc::base::system_util
    mozc::base::run_level
    mozc::base::init_mozc
    mozc::base::crash_report_handler
    mozc::base::process_mutex
    mozc::session::session_server
    config-stats_config_util
)

install(TARGETS mozc_server DESTINATION "${CMAKE_INSTALL_LIBDIR}/mozc")
