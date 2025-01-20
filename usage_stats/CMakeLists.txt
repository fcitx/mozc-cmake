mozc_python_gen_file(usage_stats/gen_stats_list.py
    OUTPUTS usage_stats_list.inc
    INPUTS data/usage_stats/stats.def
    ARGS --output=${CMAKE_CURRENT_BINARY_DIR}/usage_stats_list.inc
         data/usage_stats/stats.def
)
add_custom_target(usage_state_list
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/usage_stats_list.inc
)

mozc_library(usage_stats.proto)
mozc_library(usage_stats_uploader.cc DEPENDS mozc::storage::registry absl::strings)
mozc_library(usage_stats.cc
             DEPENDS mozc::usage_stats::usage_stats_uploader mozc::base::vlog mozc::storage::registry mozc::usage_stats::usage_stats_pb)
target_include_directories(usage_stats-usage_stats PRIVATE ${PROJECT_BINARY_DIR})
add_dependencies(usage_stats-usage_stats usage_state_list)
