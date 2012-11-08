#!/usr/bin/ruby
require 'mcollective'
include MCollective::RPC

mc = rpcclient("helloworld")

puts "\n\n"
trap("SIGINT") { exit! } #handles ctrl-c without raising exceptions

mc.echo(:mess => options[:cmd], :batch_size => 1, :batch_sleep_time => 5) do |resp, simpleresp|
  begin
        puts "\n"
        printrpc simpleresp
        #sleep(2)	#sleep not needed as batch has in built wait
  rescue Exception => e
        puts "The RPC agent returned an error: #{e}"
  end
end

printrpcstats	#stats is available
mc.disconnect
