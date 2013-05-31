require_relative '../test/test_helper'

describe Fastbit do
  it "must have a version" do
    Fastbit::VERSION.wont_be_nil
  end

  it "must grab version via ffi" do
    Fastbit.get_version_string.wont_be_nil
  end

  it "must set and remember logfile" do
    Fastbit.set_logfile("fastbit.log")
    Fastbit.get_logfile.must_equal "fastbit.log"
  end

  it "must set and remember verbosity" do
    Fastbit.set_verbose_level(Fastbit::INFO)
    Fastbit.get_verbose_level.must_equal Fastbit::INFO
  end

  def add_int_array
    Fastbit.purge_indexes("part1")
    p = FFI::MemoryPointer.new(:int, 6)
    p.put_array_of_int32(0, [ 2, 1, 4, 6, 3, 5 ])
    res = Fastbit.add_values_orig("col1", "int", p, 6, 0)
    puts "add_values returned #{res}"
    Fastbit.flush_buffer("part1")
  end

  it "must infer coltype" do
    Fastbit.infer_coltype([1, 2, 3, 4, 5]).must_equal "ub"
    Fastbit.infer_coltype([1, -2, 3, 4, -5]).must_equal "b"
  end

  it "must write values (short)" do
    res = Fastbit.add_values("col2", [2048, -1024])
  end

  it "must write values (string)" do
    res = Fastbit.add_values("col3", %w(one two three four))
  end

  it "must write values" do
    p = FFI::MemoryPointer.new(:int, 6)
    p.put_array_of_int32(0, [ 2, 1, 4, 6, 3, 5 ])
    Fastbit.add_values_orig("col1", "int", p, 6, 0)
  end

  it "must log to logfile" do
    `rm fastbit-debug.log`
    Fastbit.set_logfile("fastbit-debug.log")
    Fastbit.set_verbose_level(Fastbit::DEBUG)
    add_int_array
    File.exist?("fastbit-debug.log").wont_equal false

    `rm fastbit-info.log`
    Fastbit.set_logfile("fastbit-info.log")
    Fastbit.set_verbose_level(Fastbit::INFO)
    add_int_array

    `rm fastbit-warn.log`
    Fastbit.set_logfile("fastbit-warn.log")
    Fastbit.set_verbose_level(Fastbit::WARN)
    add_int_array

    `rm fastbit-error.log`
    Fastbit.set_logfile("fastbit-error.log")
    Fastbit.set_verbose_level(Fastbit::ERROR)
    add_int_array

    `rm fastbit-fatal.log`
    Fastbit.set_verbose_level(Fastbit::FATAL)
    Fastbit.set_logfile("fastbit-fatal.log")
    add_int_array

    Fastbit.set_logfile("fastbit.log")
  end

  it "must store data" do
    Fastbit.set_verbose_level(Fastbit::FATAL)
    Fastbit.init("")
    Fastbit.flush_buffer("part1")
    add_int_array
    Fastbit.rows_in_partition("part1").must_be :>, 6
    cols = Fastbit.columns_in_partition("part1")
    cols.must_equal 1

  end

  it "must count rows" do

  end

end
