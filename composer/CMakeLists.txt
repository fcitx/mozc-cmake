mozc_library(composer.cc
             SOURCES
                internal/mode_switching_handler.cc
                internal/composition.cc
                internal/char_chunk.cc
                internal/composition_input.cc
                internal/special_key.cc
                internal/transliterators.cc
                table.cc
                key_parser.cc
                key_event_util.cc
             DEPENDS
                mozc::protocol::protocol
                mozc::base::strings
                mozc::base::util
                mozc::base::vlog
                mozc::base::hash
                mozc::base::singleton
                mozc::base::clock
                mozc::config::config_handler
                mozc::config::character_form_manager
                )
