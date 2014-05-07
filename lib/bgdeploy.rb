$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require 'json'
require 'bglogger'
#require 'uuidtools'
require 'securerandom'
require 'deployer'

class BGDeploy
  
  attr_accessor :params 
 
  def initialize(params, config)
    @config = config
    # Keep only required parameters
    keep_params = ['job','env','group','type','sleep','size','file','token']
    @params = Hash[params.select {|k,v| keep_params.include? k}]		# Params.select returns an array in ruby 1.8.7
    @params = Hash[@params.map{|(k,v)| [k.to_sym,v]}]		      		# Convert Hash key to symbol
    
    #Generate Job ID
    #@params[:jobid] = UUIDTools::UUID.random_create				# Universaly unique ID
    @params[:jobid] = Time.now.strftime("%Y%m%d%H%M") + "-" + SecureRandom.base64(5).tr('+/=','0aZ')	# yyyymmdd-<random hex>

    # Setup logger  
    @params[:log_file] = "#{@params[:job]}-#{@params[:jobid]}.log"
    @logger = BGLogger.new(config['log_dir'], @params[:log_file])
    @logger.debug("Request: #{get_params_json}")
  end
  
  def get_params_json
    JSON.pretty_generate(@params)
  end
  
  def valid_params?
    # Verify if all required keys exist in params
    (@config['required_keys'] - @params.keys).empty?
  end
  
  def run()
    puts "Parent pid: #{Process.pid}"
    pid = fork do
      puts "pid: #{Process.pid} | jobid: #{@params[:jobid]} | start"
      deployer = Deployer.new(@config, @params)     
      begin
	#success = deployer.start(@logger)	    # shell out and call bgadmin/bgdeploy
	success = deployer.deploy(@logger)	    # execute command using BGMCClient
      rescue MCollective::DDLValidationError => ddle
	success = false
	@logger.info("[ERROR] #{ddle.message}")
      rescue Exception => e
	success = false
	@logger.info("[ERROR] #{e.message}")

      end
      puts "pid: #{Process.pid} | jobid: #{@params[:jobid]} | end"
      @logger.info("pid: #{Process.pid} | jobid: #{@params[:jobid]} | success=#{success}")
    end
    Process.detach(pid)
    #is_running(pid)
  end

  private
    def is_running(pid)
      begin
  	Process.kill(0, pid)
	puts ">> #{pid} is running"
      rescue Errno::EPERM                     # changed uid
	puts ">> No permission to query #{pid}!";
      rescue Errno::ESRCH
	puts ">> #{pid} is NOT running.";      # or zombied
      rescue
	puts ">> Unable to determine status for #{pid} : #{$!}"
    end
  end
end
