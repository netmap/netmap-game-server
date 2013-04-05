listen ENV['PORT'].to_i
preload_app true

cores = if File.exist?('/proc/cpuinfo')
  File.read('/proc/cpuinfo').scan(/^\s*processor\s*:\s*(\d+)(\s+|$)/).length
else
  2
end
worker_processes [2, cores / 2].max

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
