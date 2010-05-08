#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'net/ssh'

if ARGV.size < 1
  puts "usage: port_forward.rb host [config_file]"
  exit 1
end

remote_host = ARGV[0]
config = YAML.load_file(ARGV[1] || 'ssh.yml')

puts "connecting #{remote_host} with params:"
p config[remote_host]
options = {
  :forward_agent => true,
  :encryption => 'aes256-cbc',
  :compression => true,
  :logger => Logger.new(STDOUT)
}
options = options.merge(:keys => config[remote_host]['identity_file']) if !config[remote_host]['identity_file'].nil?
Net::SSH.start(remote_host,
               config[remote_host]['username'],
               options) do |ssh|
  config[remote_host]['local_forward'].each do |forward|
    local_addr, local_port, remote_addr, remote_port = forward.split(':')
    ssh.forward.local(local_addr, local_port,
                      remote_addr, remote_port)
  end
  ssh.loop { true }
end
