require 'digest/sha2'

module MCollective
 module Agent
  class Bamgrid<RPC::Agent

    metadata    :name        => "Bamgrid agent",
                :description => "run arbitrary Bamgrid commands and get their output",
                :author      => "Jason",
                :license     => "license",
    		:version     => "1.0",
                :url         => "http://www.mlb.com",
                :timeout     => 300

    action "runcmd" do
	token = Digest::SHA2.new << request[:token]
	if(token != '37412f4a86ddf4ed751225bfaace2f0d7a364b57b90482765aa352276874aa3a')
	  raise 'Bad Token'
	end
	if(request[:cmd] !~ /hostname|bgadminNEW|bgdeployNEW/)
	  raise 'Invalid Command'
	end
	  reply[:command] = request[:cmd]
	  reply[:output]   = %x[ #{request[:cmd]} ]
	  reply[:time] = Time.now.to_s
	  reply[:exitcode] = $?.exitstatus
    end
    action "echo" do
	validate :msg, String
	reply[:msg] = request[:msg]
	reply[:time] = Time.now.to_s
    end
  end
 end
end
