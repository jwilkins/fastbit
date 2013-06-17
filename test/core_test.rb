require_relative '../test/test_helper'

describe Fastbit do
  def self.prepare
    FileUtils.mkdir_p("tmp/part1")
  end

  prepare 
  it "must have a version" do
    Fastbit::VERSION.wont_be_nil
  end

  it "must grab version via ffi" do
    Fastbit.get_version_string.wont_be_nil
  end

  it "must set and remember logfile" do
    Fastbit.set_logfile("tmp/fastbit.log")
    Fastbit.get_logfile.must_equal "tmp/fastbit.log"
  end

  it "must set and remember verbosity" do
    Fastbit.set_verbose_level(Fastbit::INFO)
    Fastbit.get_verbose_level.must_equal Fastbit::INFO
  end

  def add_int_array
    Fastbit.purge_indexes("tmp/part1")
    p = FFI::MemoryPointer.new(:int, 6)
    p.put_array_of_int32(0, [ 2, 1, 4, 6, 3, 5 ])
    res = Fastbit.add_values_orig("col1", "int", p, 6, 0)
    puts "add_values returned #{res}"
    Fastbit.flush_buffer("tmp/part1")
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
  end

  def log_at_level(level)
    return nil unless %w(debug info warn error fatal).include?(level.downcase)
    `rm tmp/fastbit-#{level.downcase}.log`
    Fastbit.set_logfile("tmp/fastbit-#{level.downcase}.log")
    Fastbit.set_verbose_level(eval("Fastbit::#{level.upcase}"))
  end

  it "should log most at log level DEBUG" do
    log_at_level('debug')
    add_int_array
    File.exist?("tmp/fastbit-debug.log").wont_equal false
    dlog_size = File.stat('tmp/fastbit-debug.log').size
  end

  it "should log less at log level INFO" do
    log_at_level('info')
    add_int_array
    File.exist?("tmp/fastbit-debug.log").wont_equal false
  end

  it "should log less at log level WARN" do
    log_at_level('warn')
    add_int_array
    File.exist?("tmp/fastbit-debug.log").wont_equal false
  end

  it "should log less at log level ERROR" do
    log_at_level('error')
    add_int_array
    File.exist?("tmp/fastbit-debug.log").wont_equal false
  end

  it "should log least at log level FATAL" do
    `rm tmp/fastbit-fatal.log`
    Fastbit.set_verbose_level(Fastbit::FATAL)
    Fastbit.set_logfile("tmp/fastbit-fatal.log")
    add_int_array
    File.exist?("tmp/fastbit-debug.log").wont_equal false

    Fastbit.set_logfile("tmp/fastbit.log")
  end

  it "must store data" do
    Fastbit.set_verbose_level(Fastbit::FATAL)
    Fastbit.init("")
    Fastbit.flush_buffer("tmp/part1")
    add_int_array
    Fastbit.rows_in_partition("tmp/part1").must_be :>, 6
    cols = Fastbit.columns_in_partition("tmp/part1")
    cols.must_equal 1

  end

  it "must count rows" do
    rows = Fastbit.rows_in_partition("tmp/part1")
    rows.must_equal 1550
  end

end

MiniTest::Unit.after_tests {
  FileUtils.mv("tmp/part1", "tmp/part1-#{Time.now.strftime('%Y%m%d%H%M%S')}")
}

