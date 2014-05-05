require 'pp'
class MCollective::Application::Bamgrid<MCollective::Application

  # copy this file to Mcollective application folder. ie. /usr/libexec/mcollective/mcollective/application

  description "Reports on usage for a specific fact"

  option :cmd,
         :description    => "Command to execute",
         :arguments      => ["-m", "--cmd COMMAND"],
         :type           => String

  option :token,
         :description    => "Auth Token",
         :arguments      => ["-k", "--token TOKEN"],
         :type           => String

  option :server_type,
         :description    => "Server Type",
         :arguments      => ["-t", "--server_type TYPE"],
         :type           => String

  option :group,
         :description    => "Group",
         :arguments      => ["-t", "--group GROUP"],
         :type           => String,
         :validate       => Proc.new {|val| val =~ /^mob$|^dev$|^qa$|^ops$/ ? true : "Invalid Group" }

  option :zone,
         :description    => "Availability zone",
         :arguments      => ["-z", "--az ZONE"],
         :type           => String



  def post_option_parser(configuration)
    puts ARGV
    if ARGV.length >= 1
      configuration[:cmd] = ARGV[0]
      ARGV.delete_at(0)
    else
      STDERR.puts("No command specified")
      exit!
    end
    ARGV.each do |v|
      puts '==========================='
      puts v
      if v =~ /^(.+?)=(.+)$/
        configuration[:arguments] = [] unless configuration.include?(:arguments)
        configuration[:arguments] << v
      else
        STDERR.puts("Could not parse --arg #{v}")
      end
    end
  end

  def main
    options[:output_format] = :console
    options[:collective] = "mcollective"
    options[:verbose] = true
    options[:timeout] = 600
    options[:disctimeout] = 5
    options[:ttl] = 600
    #options[:filter] = {"fact"=>[], "compound"=>[], "cf_class"=>[], "identity"=>[], "agent"=>["bamgrid"]}
    options[:config] = "/etc/mcollective/client.cfg"
    
    mc = rpcclient("bamgrid", :options => options)
    
    if(configuration[:server_type] != nil)
      mc.fact_filter("server_type=#{configuration[:server_type]}")
    end
    if(configuration[:group] != nil)
      mc.fact_filter("group=#{configuration[:group]}")
    end

    #pp options
    #pp configuration


    #mc = rpcclient("bamgrid")
    #mc.fact_filter("server_type=controller")
    printrpc mc.runcmd(:cmd => configuration[:cmd], :token => 'LONGSTRING')
    printrpcstats
  end
end
