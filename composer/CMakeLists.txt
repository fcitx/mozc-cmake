mozc_library(composer.cc
             SOURCES
                composition.cc
                mode_switching_handler.cc
                char_chunk.cc
                composition_input.cc
                special_key.cc
                transliterators.cc
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
