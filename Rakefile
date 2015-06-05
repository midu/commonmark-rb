require "bundler/gem_tasks"
require "cocaine"

task :specs_tests, [:test_number] do |t, args|
  test_number = args[:test_number].to_i

  bin_path = File.join(Dir.pwd, 'bin', 'commonmark')
  Dir.chdir 'vendor/CommonMark'
  STDERR.puts test_number
  line = Cocaine::CommandLine.new("python3", "test/spec_tests.py --program #{bin_path} -n #{test_number}")
  puts line.command # => "echo hello 'world'"
  puts line.run
end
