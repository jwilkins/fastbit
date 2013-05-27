require 'ffi'

module Fastbit
  extend FFI::Library
  ffi_lib 'libfastbit'

  attach_function :fastbit_get_version_string, [ ], :string
  attach_function :fastbit_init, [:string], :void
  attach_function :fastbit_cleanup, [], :void
  attach_function :fastbit_set_verbose_level, [:int ], :int
  #/** @brief Return the current verboseness level. */
  attach_function :fastbit_get_verbose_level, [], :int
  #/** @brief Change the name of the log file. */
  attach_function :fastbit_set_logfile, [:string], :int
  #/** @brief Find out the name of the current log file. */
  attach_function :fastbit_get_logfile, [], :string
  #/** @brief Return the file pointer to the log file. */
  attach_function :fastbit_get_logfilepointer, [], :pointer



  attach_function :fastbit_build_indexes, [:string, :string], :int
  attach_function :fastbit_purge_indexes, [:string], :int
  attach_function :fastbit_build_index, [:string, :string, :string], :string
  attach_function :fastbit_purge_index, [:string, :string], :int
  attach_function :fastbit_reorder_partition, [:string], :int


  #  struct FastBitQuery;
  #  typedef struct FastBitQuery* FastBitQueryHandle;


  attach_function :fastbit_build_query, [:string, :string, :string], :pointer  # FASTBIT_DLLSPEC FastBitQueryHandle
  attach_function :fastbit_destroy_query, [:pointer], :int # (FastBitQueryHandle query)

  attach_function :fastbit_get_result_rows, [:pointer], :int
  #/** @brief Count the number of columns selected in the select clause of the query. */
  attach_function :fastbit_get_result_columns, [:pointer], :int
  #/** @brief Return the string form of the select clause. */
  attach_function :fastbit_get_select_clause, [:pointer], :string
  #/** @brief Return the table name. */
  attach_function :fastbit_get_from_clause, [:pointer], :string
  #/** @brief Return the where clause of the query. */
  attach_function :fastbit_get_where_clause, [:pointer] , :string

#    FASTBIT_DLLSPEC const float* fastbit_get_qualified_floats(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const double* fastbit_get_qualified_doubles(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const signed char* fastbit_get_qualified_bytes(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const int16_t* fastbit_get_qualified_shorts(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const int32_t* fastbit_get_qualified_ints(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const int64_t* fastbit_get_qualified_longs(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const unsigned char* fastbit_get_qualified_ubytes(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const uint16_t* fastbit_get_qualified_ushorts(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const uint32_t* fastbit_get_qualified_uints(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const uint64_t* fastbit_get_qualified_ulongs(FastBitQueryHandle query, const char* cname)
#    FASTBIT_DLLSPEC const char** fastbit_get_qualified_strings(FastBitQueryHandle query, const char* cname)
end

if __FILE__ == $0
  puts Fastbit.fastbit_get_version_string
end
