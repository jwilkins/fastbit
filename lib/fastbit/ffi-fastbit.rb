require 'ffi'
require 'debugger'

module Fastbit
  extend FFI::Library
  ffi_lib 'libfastbit'

  Fastbit::DEBUG = 0x7fffffff
  Fastbit::INFO = 5
  Fastbit::WARN = 3
  Fastbit::ERROR = 1
  Fastbit::FATAL = 0

  typedef :uint,    :start
  typedef :uint,    :count
  typedef :string, :dir
  typedef :string, :cname
  typedef :string, :options
  typedef :string, :cfg_file
  typedef :string, :filename
  typedef :string, :colname
  typedef :string, :coltype
  typedef :string, :query_cond
  typedef :pointer, :vals

  #  struct FastBitQuery;
  typedef :pointer, :queryh

  attach_function :add_values_orig, :fastbit_add_values, 
                  [:colname, :coltype, :vals, :count, :start], :int

  attach_function :get_qualified_floats_orig, :fastbit_get_qualified_floats,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_doubles_orig, :fastbit_get_qualified_doubles,  
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_bytes_orig, :fastbit_get_qualified_bytes,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_shorts_orig, :fastbit_get_qualified_shorts,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_ints_orig, :fastbit_get_qualified_ints,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_longs_orig, :fastbit_get_qualified_longs,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_ubytes_orig, :fastbit_get_qualified_ubytes,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_ushorts_orig, :fastbit_get_qualified_ushorts,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_uints_orig, :fastbit_get_qualified_uints,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_ulongs_orig, :fastbit_get_qualified_ulongs,
                  [:queryh, :cname], :pointer
  attach_function :get_qualified_strings_orig, :fastbit_get_qualified_strings,
                  [:queryh, :cname], :pointer

  class IntAry < FFI::Struct
    layout  :intv, :int
  end

  def Fastbit.get_qualified_ints(queryh, col_name)
    debugger
    return nil unless queryh && col_name
    results = []
    count = Fastbit.get_result_rows(queryh)
    intp = Fastbit.get_qualified_ints_orig(queryh, col_name)
    intp.read_array_of_int(count)
  end

  # automatically rename functions and remove redundant fastbit_ prefix
  def self.attach_function(c_name, args, returns)
    ruby_name = c_name.to_s.sub(/\Afastbit_/, "")
    super(ruby_name, c_name, args, returns)
  end

  attach_function :fastbit_get_version_string, [], :string
  attach_function :fastbit_init, [:cfg_file], :void
  attach_function :fastbit_cleanup, [], :void
  attach_function :fastbit_set_verbose_level, [:int ], :int
  attach_function :fastbit_get_verbose_level, [], :int
  attach_function :fastbit_set_logfile, [:filename], :int
  attach_function :fastbit_get_logfile, [], :string
  attach_function :fastbit_get_logfilepointer, [], :pointer

  attach_function :fastbit_flush_buffer, [:dir], :int
  attach_function :fastbit_rows_in_partition, [:dir], :int
  attach_function :fastbit_columns_in_partition, [:dir], :int

  attach_function :fastbit_build_indexes, [:dir, :options], :int
  attach_function :fastbit_purge_indexes, [:dir], :int
  attach_function :fastbit_build_index, [:dir, :cname, :options], :int
  attach_function :fastbit_purge_index, [:dir, :cname], :int
  attach_function :fastbit_reorder_partition, [:string], :int


  def Fastbit.infer_coltype(vals)
    #puts "-"*40
    #puts "infer_coltype(#{vals})"

    signed = false
    val_class = vals.first.class
    vals.each { |vv|
      #puts "#{vv}: #{vv.class}"
      return -1 if vv.class != val_class
      if val_class.ancestors.include?(Numeric)
        signed = true if vv < 0
      end
    }

    #puts "val_class: #{val_class}"

    if val_class == Fixnum
      return('b')  if vals.max < 128 && signed
      return('ub') if vals.max < 256 && !signed
      return('s')  if vals.max < 8192 && signed
      return('us') if vals.max < 16384 && !signed
      return('i')  if vals.max < (0xffffffff+1)/2 && signed
      return('ui') if vals.max < (0xffffffff+1) && !signed
      return('l')  if vals.max < (0xffffffff_ffffffff + 1)/2 && signed
      return('ul') if vals.max < (0xffffffff_ffffffff + 1) && !signed
      #puts "no match for #{vals.max}, #{vals}"
      return(-1)
    elsif val_class == String
      return('t')
    elsif val_class == Float
      return('f')
    else
      return(nil)
    end
  end

  def Fastbit.coltype_to_valtype(ct)
    #puts "coltype_to_valtype(#{ct})"
    case ct
    when 't'
      return :string
    when 'ul'
      return :ulong
    when 'l'
      return :long
    when 'ui'
      return :uint
    when 'i'
      return :int
    when 'us'
      return :ushort
    when 's'
      return :short
    when 'ub'
      return :ubyte
    when 'b'
      return :byte
    end
    return :unknown
  end

  def Fastbit.get_pointer(type, vals)
    #puts "get_pointer(#{type.to_s}, #{vals})"
    p = FFI::MemoryPointer.new(type, vals.length)
    case type
    when :byte
      p.put_array_of_int8(0, vals)
    when :ubyte
      p.put_array_of_uint8(0, vals)
    when :short
      p.put_array_of_int16(0, vals)
    when :ushort
      p.put_array_of_uint16(0, vals)
    when :int
      p.put_array_of_int32(0, vals)
    when :uint
      p.put_array_of_uint32(0, vals)
    when :string
      p = FFI::MemoryPointer.new(:pointer, vals.length + 1)
      ptrs = vals.map {|str| FFI::MemoryPointer.from_string(str)}
      p.put_array_of_pointer(0, ptrs)
    else
      return(nil)
    end
    p
  end

  def Fastbit.add_values(*args)
    val_len = nil
    start = nil
    colname = args[0]
    val_p = nil
    if args.length == 2
      vals = args[1]
      count = vals.length
      start = 0
      coltype = infer_coltype(vals)
      valtype = coltype_to_valtype(coltype)
      puts "args.length == 2\ncoltype #{coltype}, valtype: #{valtype}"
      val_p = get_pointer(valtype, vals)
    elsif args.length >= 3
      coltype = args[1]
      valtype = coltype_to_valtype(coltype)
      puts "args.length == 3\ncoltype #{coltype}, valtype: #{valtype}"
      vals = args[2]
      count = vals.length
      start = 0
      val_p = get_pointer(valtype, vals)
    elsif args.length == 5
      coltype = args[1]
      valtype = coltype_to_valtype(coltype)
      puts "args.length == 5\ncoltype #{coltype}, valtype: #{valtype}"
      vals = args[2]
      count = args[3]
      start = args[4]
      val_len = count
      val_p = get_pointer(valtype, vals)
    end

    unless defined?(vals) && vals.class == Array &&
           vals.length > 0 && (vals.length - start) >= count
      #puts "val error"
      return(nil)
    end

    Fastbit.add_values_orig(colname, coltype, val_p, count, start)
  end


  attach_function :fastbit_build_query, [:string, :string, :string], :queryh
  attach_function :fastbit_destroy_query, [:queryh], :int

  attach_function :fastbit_get_result_rows, [:pointer], :int
  #/** @brief Count the number of columns selected in the select clause of the query. */
  attach_function :fastbit_get_result_columns, [:pointer], :int
  #/** @brief Return the string form of the select clause. */
  attach_function :fastbit_get_select_clause, [:pointer], :string
  #/** @brief Return the table name. */
  attach_function :fastbit_get_from_clause, [:pointer], :string
  #/** @brief Return the where clause of the query. */
  attach_function :fastbit_get_where_clause, [:pointer] , :string

end

if __FILE__ == $0
  puts Fastbit.get_version_string
  FileUtils.rm_r("tmp/demo")
  Fastbit.init("")
  Fastbit.add_values("intcol", (1..1000).to_a)
  Fastbit.flush_buffer("tmp/demo")
  rows = Fastbit.rows_in_partition("tmp/demo")
  puts "created #{rows} rows."
  select_clause = ""
  index_location = "tmp/demo"
  query_conditions = "intcol < 10"
  query = Fastbit.build_query(select_clause, index_location, query_conditions)
  rows = Fastbit.get_result_rows(query)
  puts "query returned #{rows} rows (should be 9)"

  entries = Fastbit.get_qualified_ints(query, "intcol")
  entries.each { |rr|
    puts "  #{rr}"
  }

end
