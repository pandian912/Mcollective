#!/usr/bin/ruby
require 'mcollective'
include MCollective::RPC

mc = rpcclient("helloworld")
disc = mc.discover	#performs discovery and returnns a list of discovered nodes

puts "\n\n"		#for spacing
trap("SIGINT") { exit! } #handles ctrl-c without raising exceptions
mc.progress = false

disc.each do |dis|
  printrpc mc.custom_request("echo", {:mess => "hi"}, dis, {"identity" => dis})
  puts "\n"
  sleep(2)		#to give time to abort, can be replaced with y/n prompt
end

puts "\n"		#for spacing
mc.disconnect
