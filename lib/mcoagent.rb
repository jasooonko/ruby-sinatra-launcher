require 'mcollective'
require 'pp'
require 'json'
include MCollective::RPC

class MCOagent

  def initialize(params, config)
    @agent = params[:agent]
    puts "agent: #{@agent}"
    @config = config
    @params = Hash[params.map{|(k,v)| [k.to_sym,v]}]
    jdata = {}
    @params[:jdata].split(',').each do |pair|
      key,value = pair.split(/:/)
      jdata[key.to_sym] = value
    end
    puts jdata.inspect
    @params[:jdata] = jdata
    @options =
    {	
      :output_format=>:console,
      :collective=>"mcollective",
      :verbose=>true,
      :timeout=>600,
      :disctimeout=>5,
      :ttl=>600,
      :filter=>{"fact"=>[], "compound"=>[], "cf_class"=>[], "identity"=>[], "agent"=>[@agent]},
      :config=>"/etc/mcollective/client.cfg"
    }
    @mc = rpcclient(@agent, :options => @options )

    # Setup logger
    @params[:log_file] = "#{@params[:jobid]}.log"
    puts @params[:log_file]
    @logger = BGLogger.new(config['log_dir'], @params[:log_file])
    @logger.debug("Request: #{get_params_json}")
  end
 
  def get_params_json
    JSON.pretty_generate(@params)
  end
 
  def valid_params()
    # Verify if all required keys exist in params
    missing = (@config['required_keys'] - @params.keys)
    if(missing.empty? == false)
      raise "Missing param: #{missing.inspect}"
    end
    if(@params[:group] == 'all')
      raise 'Must provide group'
    end

    return missing.empty?
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
    add_filter("group", "#{@params[:group]}") 
    add_filter("server_type", "#{@params[:type]}") if (@params[:type] != "all")
    run_action()
  end

  def run_action()
    result_set = Hash.new
    puts "json_data: #{@params[:jdata]}"
    if(@params[:action] =~ /status|runcmd/)
      @mc.send(@params[:action], @params[:jdata]) do |response|
        result_set[response[:senderid]] = response[:body][:data]
      end
      #pp result_set
      @logger.info(result_set)
    else 
      @logger.info("unknown action: #{@params[:action]}")
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

