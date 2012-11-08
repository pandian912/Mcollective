#!/usr/bin/ruby
require ‘mcollective’
include MCollective::RPC
mc = rpcclient(“rpcutil”)
mc.discover(:nodes => [“node1”,”node2”])     #custom discovery
printrpc mc.ping                              #execution
sleep(2)
printrpc mc.ping({“identity” => “node3”})  #discovery and execution
printrpcstats
mc.disconnect
