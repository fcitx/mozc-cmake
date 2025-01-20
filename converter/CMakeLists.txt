mozc_library(history_reconstructor.cc DEPENDS mozc::protocol::protocol mozc::dictionary::pos_matcher mozc::base::util mozc::converter::segments)
mozc_library(segments.cc DEPENDS absl::log absl::check mozc::base::vlog)
mozc_library(reverse_converter.cc DEPENDS mozc::protocol::protocol mozc::converter::segments mozc::base::util mozc::composer::composer)
mozc_library(converter.cc DEPENDS
    mozc::protocol::protocol
    mozc::converter::history_reconstructor
    mozc::converter::reverse_converter
    mozc::dictionary::suppression_dictionary
    mozc::usage_stats::usage_stats)
mozc_library(key_corrector.cc DEPENDS
    mozc::protocol::protocol
    mozc::base::util
    mozc::base::vlog)
mozc_library(lattice.cc DEPENDS
        mozc::base::singleton absl::log absl::check)
mozc_library(node_list_builder.cc DEPENDS
    mozc::protocol::protocol
)

mozc_library(candidate_filter.cc DEPENDS
    mozc::protocol::protocol
    mozc::converter::segments
    mozc::base::vlog
    mozc::base::number_util
    mozc::base::util
    mozc::prediction::suggestion_filter
    mozc::dictionary::suppression_dictionary)
mozc_library(nbest_generator.cc DEPENDS
    mozc::protocol::protocol
    mozc::converter::segmenter
    mozc::converter::connector
    mozc::converter::candidate_filter
    mozc::converter::segments)
mozc_library(immutable_converter.cc DEPENDS
    mozc::protocol::protocol
    mozc::base::util
    mozc::converter::key_corrector
    mozc::converter::lattice
    mozc::converter::segments
    mozc::converter::segmenter
    mozc::converter::connector
    mozc::converter::nbest_generator
    mozc::converter::node_list_builder)
mozc_library(connector.cc DEPENDS absl::log absl::check absl::statusor mozc::storage::louds::louds)
mozc_library(segmenter.cc DEPENDS absl::log absl::check)
mozc_library(gen_segmenter_bitarray.cc DEPENDS mozc::protocol::segmenter_data_pb mozc::base::file_stream)
