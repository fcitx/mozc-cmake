add_subdirectory(oss)
mozc_library(pos_list_provider.cc
             DEPENDS absl::log absl::check mozc::base::container::serialized_string_array)
add_dependencies(data_manager-pos_list_provider dataset-oss-pos_list)
target_include_directories(data_manager-pos_list_provider PRIVATE ${PROJECT_BINARY_DIR})
mozc_library(dataset.proto)
mozc_library(dataset_writer.cc DEPENDS
    mozc::data_manager::dataset_pb
    mozc::base::file_util
    mozc::base::util
    mozc::base::vlog
    mozc::base::unverified_sha1
)
mozc_library(serialized_dictionary.cc DEPENDS
    mozc::base::file_util
    mozc::base::container::serialized_string_array
    mozc::base::number_util
)
mozc_library(dataset_reader.cc DEPENDS
    mozc::data_manager::dataset_pb
    mozc::base::util
    mozc::base::unverified_sha1
)
mozc_library(data_manager.cc DEPENDS
    mozc::protocol::segmenter_data_pb
    mozc::base::mmap
    mozc::base::version
    mozc::base::vlog
    mozc::base::container::serialized_string_array
    mozc::data_manager::dataset_reader
    mozc::data_manager::serialized_dictionary
)
mozc_executable(dataset_writer_main.cc DEPENDS
    mozc::data_manager::dataset_pb
    mozc::base::init_mozc
    mozc::base::vlog
    mozc::base::file_stream
    mozc::base::number_util
    mozc::data_manager::dataset_writer
    )
