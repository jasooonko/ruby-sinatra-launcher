class MCollective::Application::Bamgrid<MCollective::Application
description "Reports on usage for a specific fact"

option :cmd,
       :description    => "Command to execute",
       :arguments      => ["-m", "--cmd COMMAND"],
       :type           => String

       option :token,
       :description    => "Auth Token",
       :arguments      => ["-t", "--token TOKEN"],
       :type           => String


       def post_option_parser(configuration)
	    if ARGV.length >= 1
		configuration[:cmd] = ARGV[0]
		ARGV.delete_at(0)
	    else
		STDERR.puts("No command specified")
		exit!
	    end
	end


	def main
	    mc = rpcclient("bamgrid")

	    printrpc mc.runcmd(:cmd => configuration[:cmd], :token => 'LONGSTRING')

	    printrpcstats
	end
end
