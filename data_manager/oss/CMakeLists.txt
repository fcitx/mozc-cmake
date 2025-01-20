mozc_dataset(oss kOssMozcDataSet)

mozc_library(oss_data_manager.cc
    DEPENDS mozc::data_manager::data_manager
)
add_dependencies(data_manager-oss-oss_data_manager dataset-oss-mozc_data)
target_include_directories(data_manager-oss-oss_data_manager PRIVATE ${PROJECT_BINARY_DIR})
target_compile_definitions(data_manager-oss-oss_data_manager PRIVATE -DMOZC_DATASET_MAGIC_NUMBER_LENGTH=7)

mozc_python_gen_file(build_tools/redirect.py
    OUTPUTS segmenter_inl.inc
    INPUTS data/dictionary_oss/id.def
           data/rules/special_pos.def
           data/rules/segmenter.def
    ARGS ${CMAKE_CURRENT_BINARY_DIR}/segmenter_inl.inc
         ${MOZC_SOURCE_DIR}/converter/gen_segmenter_code.py
         data/dictionary_oss/id.def
         data/rules/special_pos.def
         data/rules/segmenter.def
)

add_custom_target(segmenter_inl
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/segmenter_inl.inc
)
set_target_properties(segmenter_inl PROPERTIES EXCLUDE_FROM_ALL TRUE)

mozc_executable(gen_oss_segmenter_bitarray_main.cc
    DEPENDS 
    mozc::base::init_mozc
    absl::flags
    mozc::converter::gen_segmenter_bitarray
)
add_dependencies(data_manager-oss-gen_oss_segmenter_bitarray_main segmenter_inl)
target_include_directories(data_manager-oss-gen_oss_segmenter_bitarray_main PRIVATE ${PROJECT_BINARY_DIR})
