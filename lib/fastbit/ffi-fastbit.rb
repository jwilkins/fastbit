require 'ffi'

module Fastbit
  extend FFI::Library
  ffi_lib 'libfastbit'

  def self.attach_function(c_name, args, returns)
    ruby_name = c_name.to_s.sub(/\Afastbit_/, "")
    super(ruby_name, c_name, args, returns)
  end

  Fastbit::DEBUG = 7
  Fastbit::INFO = 5
  Fastbit::WARN = 3
  Fastbit::ERROR = 1

  typedef :string, :dir
  typedef :string, :cname
  typedef :string, :options
  typedef :string, :cfg_file
  typedef :string, :filename
  typedef :string, :colname
  typedef :string, :coltype
  typedef :pointer, :vals

  attach_function :fastbit_get_version_string, [], :string
  attach_function :fastbit_init, [:cfg_file], :void
  attach_function :fastbit_cleanup, [], :void
  attach_function :fastbit_set_verbose_level, [:int ], :int
  attach_function :fastbit_get_verbose_level, [], :int
  attach_function :fastbit_set_logfile, [:filename], :int
  attach_function :fastbit_get_logfile, [], :string
  attach_function :fastbit_get_logfilepointer, [], :pointer

  attach_function :fastbit_flush_buffer, [:dir], :int
  attach_function :fastbit_add_values, [:colname, :coltype, :vals, :uint, :uint], :int  # :vals is a pointer to a list
  attach_function :fastbit_rows_in_partition, [:dir], :int
  attach_function :fastbit_columns_in_partition, [:dir], :int

  attach_function :fastbit_build_indexes, [:dir, :options], :int
  attach_function :fastbit_purge_indexes, [:dir], :int
  attach_function :fastbit_build_index, [:dir, :cname, :options], :int
  attach_function :fastbit_purge_index, [:dir, :cname], :int
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
