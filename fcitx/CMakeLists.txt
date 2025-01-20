find_package(Gettext REQUIRED)

add_library(fcitx5-mozc MODULE
    ${MOZC_SOURCE_DIR}/unix/fcitx5/surrounding_text_util.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/fcitx_key_event_handler.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/fcitx_key_translator.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_client_pool.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_engine_factory.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_engine.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_ipc_client.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_response_parser.cc
    ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc_state.cc
)
set_target_properties(fcitx5-mozc PROPERTIES PREFIX "")

target_link_libraries(fcitx5-mozc 
    Fcitx5::Core
    PkgConfig::Fcitx5Module
    mozc::protocol::protocol 
    mozc::base::vlog
    mozc::base::process
    mozc::base::util
    mozc::base::init_mozc
    mozc::client::client)
install(TARGETS fcitx5-mozc DESTINATION "${CMAKE_INSTALL_LIBDIR}/fcitx5")
install(FILES ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc-addon.conf RENAME mozc.conf DESTINATION "${FCITX_INSTALL_PKGDATADIR}/addon"
         COMPONENT config)
install(FILES ${MOZC_SOURCE_DIR}/unix/fcitx5/mozc.conf RENAME mozc.conf DESTINATION "${FCITX_INSTALL_PKGDATADIR}/inputmethod"
         COMPONENT config)
fcitx5_translate_desktop_file(${MOZC_SOURCE_DIR}/unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml.in
         org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml XML PO_DIRECTORY ${MOZC_SOURCE_DIR}/unix/fcitx5/po)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml" DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo)

install(FILES ${MOZC_SOURCE_DIR}/data/images/product_icon_32bpp-128.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/128x128/apps")
install(FILES ${MOZC_SOURCE_DIR}/data/images/unix/ime_product_icon_opensource-32.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/32x32/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-alpha_full.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_alpha_full.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-direct.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_direct.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-hiragana.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_hiragana.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-katakana_full.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_katakana_full.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-katakana_half.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_katakana_half.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-dictionary.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_dictionary.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-properties.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_properties.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES ${MOZC_SOURCE_DIR}/../scripts/icons/ui-tool.png
    RENAME org.fcitx.Fcitx5.fcitx_mozc_tool.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")

install(FILES icons/fcitx_mozc.png DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/128x128/apps")
install(FILES icons/fcitx_mozc.png DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/32x32/apps")
install(FILES
    icons/fcitx_mozc_alpha_full.png
    icons/fcitx_mozc_properties.png
    icons/fcitx_mozc_hiragana.png
    icons/fcitx_mozc_dictionary.png
    icons/fcitx_mozc_katakana_half.png
    icons/fcitx_mozc_alpha_half.png
    icons/fcitx_mozc_direct.png
    icons/fcitx_mozc_tool.png
    icons/fcitx_mozc_katakana_full.png
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps"
)

file(GLOB PO_FILES "${MOZC_SOURCE_DIR}/unix/fcitx5/po/*.po")
set(MO_FILES)
foreach(PO_FILE IN LISTS PO_FILES)
  get_filename_component(PO_LANG ${PO_FILE} NAME_WE)
  get_filename_component(ABS_PO_FILE ${PO_FILE} ABSOLUTE)
  set(MO_FILE ${CMAKE_CURRENT_BINARY_DIR}/fcitx5-mozc-${PO_LANG}.mo)

  add_custom_command(
      OUTPUT ${MO_FILE} 
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${MO_FILE} ${ABS_PO_FILE}
      DEPENDS ${ABS_PO_FILE}
  )
  
  install(FILES ${MO_FILE} RENAME fcitx5-mozc.mo DESTINATION ${FCITX_INSTALL_LOCALEDIR}/${PO_LANG}/LC_MESSAGES
          COMPONENT translation)
  set(MO_FILES ${MO_FILES} ${MO_FILE})
endforeach ()
add_custom_target("fcitx5-mozc-translation" ALL DEPENDS ${MO_FILES})
