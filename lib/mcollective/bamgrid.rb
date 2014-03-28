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
	if(request[:token] != 'LONGSTRING')
	  raise 'Bad Token'
	end
	if(request[:cmd] !~ /hostname|bgadmin|bgdeploy/)
	  raise 'Invalid Command'
	end
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
