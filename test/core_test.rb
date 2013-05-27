require_relative '../test/test_helper'

describe Fastbit do
  it "must have a version" do
    Fastbit::VERSION.wont_be_nil
  end

  it "must grab version via ffi" do
    Fastbit.fastbit_get_version_string.wont_be_nil
  end

  it "must store shit" do
    Fastbit.fastbit_init("")
  end

  it "must set and remember logfile" do
    Fastbit.fastbit_set_logfile("fastbit.log")
    Fastbit.fastbit_get_logfile.must_equal "fastbit.log"
  end

  it "must log to logfile" do
    File.exist?("fastbit.log").wont_equal false
  end


end
