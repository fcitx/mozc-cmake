cmake_minimum_required(VERSION 3.12)
project(mozc)

find_package(Fcitx5Core REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(Fcitx5Module REQUIRED "Fcitx5Module" IMPORTED_TARGET)
find_package(absl REQUIRED CONFIG)
find_package(Protobuf REQUIRED CONFIG)
find_package(Python3 REQUIRED COMPONENTS Interpreter)
find_package(Qt6 REQUIRED COMPONENTS Gui Widgets)

include(cmake/Macros.cmake)

include(GNUInstallDirs)

set(CMAKE_CXX_FLAGS "-funsigned-char ${CMAKE_CXX_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined -Wl,--as-needed ${CMAKE_SHARED_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "-Wl,--no-undefined -Wl,--as-needed ${CMAKE_MODULE_LINKER_FLAGS}")
add_definitions(-DMOZC_BUILD)
set(MOZC_SOURCE_DIR ${PROJECT_SOURCE_DIR}/mozc/src)

include_directories(mozc/src)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(MOZC_LIBRARY_TYPE STATIC)
# set(MOZC_LIBRARY_TYPE SHARED) # Uncomment to test dependency and missing symbols.

add_library(protocol ${MOZC_LIBRARY_TYPE}
    mozc/src/protocol/commands.proto
    mozc/src/protocol/candidate_window.proto
    mozc/src/protocol/config.proto
    mozc/src/protocol/engine_builder.proto
    mozc/src/protocol/user_dictionary_storage.proto
    mozc/src/protocol/state.proto
)
target_include_directories(protocol PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(protocol PUBLIC protobuf::libprotobuf)
protobuf_generate(TARGET protocol LANGUAGE cpp
    IMPORT_DIRS mozc/src)

mozc_library(protocol/segmenter_data.proto)

add_subdirectory(base)
add_subdirectory(config)
add_subdirectory(composer)
add_subdirectory(converter)
add_subdirectory(dictionary)
add_subdirectory(data_manager)
add_subdirectory(rewriter)
add_subdirectory(storage)
add_subdirectory(usage_stats)
add_subdirectory(ipc)
add_subdirectory(client)
add_subdirectory(transliteration)
add_subdirectory(session)
add_subdirectory(prediction)
add_subdirectory(engine)
add_subdirectory(gui)

add_executable(mozc_server
    mozc/src/server/mozc_server.cc
    mozc/src/server/mozc_server_main.cc
)

target_include_directories(mozc_server PRIVATE mozc/src)
target_link_libraries(mozc_server
    protocol
    mozc::base::system_util
    mozc::base::run_level
    mozc::base::init_mozc
    mozc::base::crash_report_handler
    mozc::base::process_mutex
    mozc::session::session_server
    config-stats_config_util
)

add_library(fcitx5-mozc MODULE
    mozc/src/unix/fcitx5/surrounding_text_util.cc
    mozc/src/unix/fcitx5/fcitx_key_event_handler.cc
    mozc/src/unix/fcitx5/fcitx_key_translator.cc
    mozc/src/unix/fcitx5/mozc_client_pool.cc
    mozc/src/unix/fcitx5/mozc_engine_factory.cc
    mozc/src/unix/fcitx5/mozc_engine.cc
    mozc/src/unix/fcitx5/mozc_ipc_client.cc
    mozc/src/unix/fcitx5/mozc_response_parser.cc
    mozc/src/unix/fcitx5/mozc_state.cc
)
set_target_properties(fcitx5-mozc PROPERTIES PREFIX "")

target_link_libraries(fcitx5-mozc 
    Fcitx5::Core
    PkgConfig::Fcitx5Module
    protocol 
    mozc::base::vlog
    mozc::base::process
    mozc::base::util
    mozc::base::init_mozc
    mozc::client::client)

install(TARGETS mozc_server DESTINATION "${CMAKE_INSTALL_LIBDIR}/mozc")
install(TARGETS mozc_tool DESTINATION "${CMAKE_INSTALL_LIBDIR}/mozc")
install(TARGETS fcitx5-mozc DESTINATION "${CMAKE_INSTALL_LIBDIR}/fcitx5")
