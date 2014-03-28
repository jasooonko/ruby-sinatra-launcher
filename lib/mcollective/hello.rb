#!/usr/bin/ruby
 
require 'mcollective'

include MCollective::RPC
mc = rpcclient("bamgrid")
mc.verbose = true
mc.progress =false
report = mc.echo(:msg => "Welcome to MCollective Simple RPC")

puts report
printrpcstats
mc.disconnect
