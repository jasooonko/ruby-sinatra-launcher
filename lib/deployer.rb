$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bgmcclient'

class Deployer

  def initialize(config, params)
    @config = config
    params[:cmd] = 'hostname'
    @params = params
  end	
	
  def start(logger)
    opt = get_options
    cmd = "#{config['script_dir']}/#{@params[:job]} #{opt} >> #{logger.log_file}" 
    logger.info("Command: #{cmd}")
    system(cmd)
  end

  def deploy(logger)
    @mcclient = BGMCClient.new
    @mcclient.token=@params.delete(:token)
    @mcclient.mcclient.batch_size = 1
    @mcclient.mcclient.batch_sleep_time = 1
    @mcclient.mcclient.batch_size = @params[:size] if @params[:size]
    @mcclient.mcclient.batch_sleep_time = @params[:sleep] if @params[:sleep]
    @mcclient.add_filter("env","#{@params[:env]}")
    @mcclient.add_filter("group", "#{@params[:group]}") if (@params[:group] != "all")
    @mcclient.add_filter("server_type", "#{@params[:type]}") if (@params[:type] != "all")
    @mcclient.add_command(@params[:cmd])
    @mcclient.run_commands do |output|
      logger.info(output)
    end
    @mcclient.disconnect
    return $?==0
  end

  private
  def get_options
    opt = "-e #{@params[:env]} -g #{@params[:group]} -t #{@params[:type]} "
    if(@params.has_key?('size'))
      opt += "-b #{@params['size']} "
    end
    if(@params.has_key?('sleep'))
      opt += "-s #{@params['sleep']} "
    end
    return opt
  end
end
