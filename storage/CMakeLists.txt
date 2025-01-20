mozc_library(tiny_storage.cc DEPENDS
    absl::log
    absl::check
    mozc::base::file_util
    mozc::base::file_stream
    mozc::base::vlog)
mozc_library(registry.cc DEPENDS absl::log mozc::storage::tiny_storage mozc::base::system_util mozc::base::singleton)
mozc_library(lru_storage.cc DEPENDS absl::raw_hash_set absl::statusor absl::log mozc::base::file_stream mozc::base::hash mozc::base::clock mozc::base::mmap mozc::base::vlog mozc::base::file_util)
mozc_library(louds/louds.cc
    SOURCES
    louds/simple_succinct_bit_vector_index.cc
    louds/bit_vector_based_array.cc
    louds/louds_trie.cc
    louds/louds_trie_builder.cc
    louds/bit_stream.cc
    louds/bit_vector_based_array_builder.cc
    DEPENDS
        absl::check)
mozc_library(existence_filter.cc DEPENDS
    absl::log
    absl::statusor
    absl::check
    mozc::base::vlog)
mozc_library(encrypted_string_storage.cc DEPENDS
    absl::log
    mozc::base::mmap
    mozc::base::file_stream
    mozc::base::random
    mozc::base::vlog
    mozc::base::encryptor)
