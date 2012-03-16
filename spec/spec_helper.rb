require 'simplecov'
require 'redis/connection/hiredis'
require 'redis'

SimpleCov.start

$: << File.join(File.dirname(__FILE__), '..', 'lib')

ENV['RAILS_ENV'] = 'test'
require 'dummy/config/environment'

require 'rspec/rails'

require 'fileutils'

RSpec.configure do |config|
  # ==========================> Redis test configuration
  REDIS_PID = Rails.root.join 'tmp', 'pids', 'redis.pid'

  FileUtils.mkdir_p Rails.root.join 'tmp', 'pids'
  FileUtils.mkdir_p Rails.root.join 'tmp', 'cache'

  config.before(:suite) do
    redis_options = {
      "daemonize"     => 'yes',
      "pidfile"       => REDIS_PID,
      "port"          => 6397,
      "dir"           => Rails.root.join('tmp', 'cache'),
      "loglevel"      => "debug",
      "logfile"       => "stdout",
    }.map { |k, v| "#{k} #{v}" }.join('\n')
    `echo '#{redis_options}' | redis-server -`

    $redis = Redis.new(:host => '127.0.0.1', :port => 6397)
  end

  config.before(:each) do
    $redis.flushdb
    Rails.cache.clear
  end

  config.after :suite do
    Process.kill "TERM", File.read(REDIS_PID).to_i
  end
end
