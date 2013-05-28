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

  it "must log to logfile" do
    `rm fastbit-debug.log`
    Fastbit.set_logfile("fastbit-debug.log")
    Fastbit.set_verbose_level(Fastbit::DEBUG)
    p = FFI::MemoryPointer.new(:int, 6)
    p.put_array_of_int32(0, [ 2, 1, 4, 6, 3, 5 ])
    Fastbit.add_values("col1", "int", p, 6, 0)
    Fastbit.purge_indexes("part1")
    Fastbit.flush_buffer("part1")
    File.exist?("fastbit-debug.log").wont_equal false

    `rm fastbit-info.log`
    Fastbit.set_logfile("fastbit-info.log")
    Fastbit.set_verbose_level(Fastbit::INFO)
    Fastbit.purge_indexes("part1")
    Fastbit.flush_buffer("part1")

    `rm fastbit-warn.log`
    Fastbit.set_logfile("fastbit-warn.log")
    Fastbit.set_verbose_level(Fastbit::INFO)
    Fastbit.purge_indexes("part1")
    Fastbit.flush_buffer("part1")

    `rm fastbit-error.log`
    Fastbit.set_logfile("fastbit-error.log")
    Fastbit.set_verbose_level(Fastbit::INFO)
    Fastbit.purge_indexes("part1")
    Fastbit.flush_buffer("part1")

    Fastbit.set_logfile("fastbit.log")
  end

  it "must store data" do
    Fastbit.set_verbose_level(Fastbit::DEBUG)
    Fastbit.init("")
    Fastbit.flush_buffer("part1")
    Fastbit.rows_in_partition("part1")

    Fastbit.set_verbose_level(Fastbit::WARN)
    Fastbit.columns_in_partition("part1")
    Fastbit.set_verbose_level(Fastbit::ERROR)
    Fastbit.purge_indexes("part1")

  end


end
