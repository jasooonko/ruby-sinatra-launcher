$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bgmcclient'

class Deployer

  SCRIPT_DIR = '/opt/bamgrid/sbin'

  def initialize(params)
    @params = params
  end	
	
  def start(logger)
    opt = get_options
    cmd = "#{SCRIPT_DIR}/#{@params[:job]} #{opt} >> #{logger.log_file}" 
    logger.info("Command: #{cmd}")
    system(cmd)
  end

  def deploy(logger)
    puts @params[:env]
    puts @params[:group]
    puts @params[:type]
    @mcclient = BGMCClient.new
    @mcclient.mcclient.batch_size = 1
    @mcclient.mcclient.batch_sleep_time = 1
    @mcclient.mcclient.batch_size = @params[:size] if @params[:size]
    @mcclient.mcclient.batch_sleep_time = @params[:sleep] if @params[:sleep]
    @mcclient.add_filter("env","#{@params[:env]}")
    @mcclient.add_filter("group", "#{@params[:group]}") if (@params[:group] != "all")
    @mcclient.add_filter("server_type", "#{@params[:type]}") if (@params[:type] != "all")
    @mcclient.add_command("hostname")
    @mcclient.run_commands do |output|
      logger.info(output)
    end
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
