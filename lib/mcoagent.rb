require 'mcollective'
require 'pp'

include MCollective::RPC

class MCOagent

  def initialize(params, config)
    @agent = params[:agent]
    puts "agent: #{@agent}"
    @config = config
    @params = Hash[params.map{|(k,v)| [k.to_sym,v]}]
    @options =
    {	
      :output_format=>:console,
      :collective=>"mcollective",
      :verbose=>true,
      :timeout=>600,
      :disctimeout=>1,
      :ttl=>600,
      :filter=>{"fact"=>[], "compound"=>[], "cf_class"=>[], "identity"=>[], "agent"=>[@agent]},
      :config=>"/etc/mcollective/client.cfg"
    }
    @mc = rpcclient(@agent, :options => @options )
  end
  
  def valid_params?
    # Verify if all required keys exist in params
    (@config['required_keys'] - @params.keys).empty?
  end

  def add_filter(key, value)
    @mc.fact_filter(key, value)
  end
  
  def run()
    $, = "=>" 
    puts "action #{@params[:action]}"
    pp @params
    @mc.batch_size = 20
    @mc.batch_sleep_time = 0
    add_filter("env", @params[:env])
    add_filter("group", "#{@params[:group]}") if (@params[:group] != "all")
    add_filter("server_type", "#{@params[:type]}") if (@params[:type] != "all")
    run_action()
  end

  def run_action()
    result_set = Hash.new
    puts @params[:jdata]
    if(@params[:action] =~ /status/)
      @mc.send(@params[:action], @params[:jdata]) do |response|
        result_set[response[:senderid]] = response[:body][:data]
      end
      return result_set
    else 
      puts "unknown action: #{@params[:action]}"
    end 
  end

  def disconnect
    @mc.disconnect
  end

end

#client = MCOagent.new("package")
#client.add_filter('server_type','jasondev')
#client.add_filter('group','ops')
#pp client.run('status', :package=>'ntp')
#client.disconnect

