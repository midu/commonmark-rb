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


namespace :specs do
  class Runner
    def self.bin_path
      File.join(Dir.pwd, '../..', 'bin', 'commonmark')
    end

    def self.common_mark_path
      'vendor/CommonMark'
    end

    def self.skipped_tests
      @skipped_tests ||= ENV.fetch('SKIP') { '' }.split(',').map(&:to_i).uniq.compact
    end

    def self.fail_fast?
      !ENV['FF'].nil?
    end

    def self.run(n)
      if skipped_tests.include?(n)
        print 'S'
        return
      end

      Dir.chdir(common_mark_path) do
        line = Cocaine::CommandLine.new("python3", "test/spec_tests.py --program #{bin_path} -n #{n}")
        res = nil

        begin
          line.run
          print '.'
        rescue Cocaine::ExitStatusError => e
          print 'F'
          puts e.message
          raise if fail_fast?
        end
      end
    end
  end


  task :test_one, [:n] do |_, args|
    n = args[:n].to_i
    Runner.run(n)
  end

  task :all do
    1.upto(550) { |n| Runner.run(n) }
  end

  task :upto, [:n] do |_, args|
    max = args[:n].to_i

    1.upto(max) { |n| Runner.run(n) }
  end
end
