mozc_library(file_stream.cc DEPENDS absl::status absl::log)
mozc_library(file/recursive.cc DEPENDS absl::log mozc::base::file_util)
mozc_library(file/temp_dir.cc DEPENDS absl::log absl::statusor mozc::base::file_util mozc::base::file::recursive mozc::base::environ)
mozc_library(container/serialized_string_array.cc DEPENDS absl::log mozc::base::file_util)

file(GLOB KEYMAP_FILES ${MOZC_SOURCE_DIR}/data/keymap/*.tsv)
file(GLOB COMPOSITION_TABLES ${MOZC_SOURCE_DIR}/data/preedit/*.tsv)
mozc_python_gen_file(base/gen_config_file_stream_data.py
    OUTPUTS config_file_stream_data.inc
    INPUTS ${COMPOSITION_TABLES}
           ${KEYMAP_FILES}
    ARGS --output ${CMAKE_CURRENT_BINARY_DIR}/config_file_stream_data.inc
        ${COMPOSITION_TABLES}
        ${KEYMAP_FILES})
mozc_library(config_file_stream.cc
             SOURCES
                ${CMAKE_CURRENT_BINARY_DIR}/config_file_stream_data.inc
             DEPENDS
                absl::raw_hash_set
                absl::log
                mozc::base::file_util
                mozc::base::system_util
                )
target_include_directories(base-config_file_stream PRIVATE ${PROJECT_BINARY_DIR})

mozc_library(mmap.cc DEPENDS absl::str_format absl::log absl::status absl::statusor)
mozc_library(environ.cc)
mozc_library(singleton.cc)
mozc_library(file_util.cc DEPENDS mozc::base::mmap mozc::base::file_stream absl::status absl::log)
mozc_library(system_util.cc DEPENDS mozc::base::file_util mozc::base::environ mozc::base::singleton absl::log absl::check)
mozc_library(run_level.cc)
mozc_library(log_file.cc DEPENDS absl::log mozc::base::file_stream absl::log_initialize)
mozc_library(init_mozc.cc DEPENDS absl::flags mozc::base::file_util mozc::base::system_util mozc::base::log_file absl::flags_parse)
mozc_library(crash_report_handler.cc)
mozc_library(vlog.cc DEPENDS absl::log_flags absl::base absl::log)
mozc_library(process_mutex.cc DEPENDS mozc::base::vlog absl::log absl::status absl::strings mozc::base::system_util)
mozc_library(clock.cc DEPENDS absl::time)
mozc_library(cpu_stats.cc DEPENDS absl::log)
mozc_library(hash.cc DEPENDS absl::log absl::check)
mozc_library(number_util.cc DEPENDS absl::strings absl::str_format absl::log mozc::base::util)
mozc_library(process.cc DEPENDS absl::log mozc::base::vlog mozc::base::system_util)
mozc_library(stopwatch.cc DEPENDS mozc::base::clock)
mozc_library(text_normalizer.cc DEPENDS mozc::base::util)
mozc_library(encryptor.cc DEPENDS
    absl::log
    absl::random_random
    absl::check
    mozc::base::unverified_sha1
    mozc::base::unverified_aes256
    mozc::base::password_manager)
mozc_library(password_manager.cc DEPENDS
    absl::log
    absl::random_random
    mozc::base::mmap
    mozc::base::file_util
    mozc::base::system_util
    mozc::base::random)
mozc_library(unverified_sha1.cc DEPENDS absl::log absl::check)
mozc_library(unverified_aes256.cc DEPENDS absl::log absl::check)
mozc_python_gen_file(build_tools/mozc_version.py
    OUTPUTS mozc_version.txt
    INPUTS data/version/mozc_version_template.bzl
    ARGS --template_path data/version/mozc_version_template.bzl
         --output "${CMAKE_CURRENT_BINARY_DIR}/mozc_version.txt"
         --target_platform=Linux
)
mozc_python_gen_file(build_tools/replace_version.py
    OUTPUTS version_def.h
    INPUTS ${CMAKE_CURRENT_BINARY_DIR}/mozc_version.txt
           base/version_def_template.h
    ARGS --version_file "${CMAKE_CURRENT_BINARY_DIR}/mozc_version.txt"
         --input base/version_def_template.h
         --output "${CMAKE_CURRENT_BINARY_DIR}/version_def.h"
         --branding=Mozc
)

mozc_library(version.cc SOURCES ${CMAKE_CURRENT_BINARY_DIR}/version_def.h DEPENDS absl::log mozc::base::number_util)
set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/version_def.h PROPERTIES GENERATED TRUE)
target_include_directories(base-version PRIVATE ${PROJECT_BINARY_DIR})
mozc_python_gen_file(base/gen_character_set.py
    OUTPUTS character_set.inc
    INPUTS data/unicode/JIS0201.TXT
           data/unicode/JIS0208.TXT
    ARGS --jisx0201file=data/unicode/JIS0201.TXT
         --jisx0208file=data/unicode/JIS0208.TXT
         --output=${CMAKE_CURRENT_BINARY_DIR}/character_set.inc)
add_custom_target(character_set DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/character_set.inc)
set_target_properties(character_set PROPERTIES EXCLUDE_FROM_ALL TRUE)
mozc_library(strings
             SOURCES
                strings/internal/double_array.cc
                strings/internal/japanese_rules.cc
                strings/internal/utf8_internal.cc
                strings/japanese.cc
                strings/unicode.cc
             DEPENDS absl::strings absl::log
             )
mozc_library(util.cc
             DEPENDS absl::log absl::check mozc::base::strings
            )
add_dependencies(base-util character_set)
target_include_directories(base-util PRIVATE ${PROJECT_BINARY_DIR})
mozc_library(random.cc DEPENDS absl::random_random mozc::base::util)
mozc_library(multifile.cc DEPENDS absl::log mozc::base::file_stream)
mozc_library(codegen_bytearray_stream.cc DEPENDS absl::str_format)
