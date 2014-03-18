$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require 'json'
require 'bglogger'
#require 'uuidtools'
require 'securerandom'
require 'deployer'

class BGDeploy
  
  attr_accessor :params, :token
 
  def initialize(job, params)
    @token = params[:token]
    # Keep only required parameters
    keep_params = ['env','group','type','sleep','size','file']
    @params = Hash[params.select {|k,v| keep_params.include? k}]		# Params.select returns an array in ruby 1.8.7
    @params = Hash[@params.map{|(k,v)| [k.to_sym,v]}]		      		# Convert Hash key to symbol
    
    #@params[:jobid] = UUIDTools::UUID.random_create
    @params[:jobid] = Time.now.strftime("%Y%m%d") + "-" + SecureRandom.hex(5)
    @params[:job] = job    

    # Setup logger  
    @params[:log] = "#{job}-#{@params[:jobid]}.log"
    @logger = BGLogger.new("#{@params[:log]}")
    @logger.debug("Request: #{get_params_json}")
  end
  
  def get_params_json
    JSON.pretty_generate(@params)
  end
  
  def valid_params?
    # Verify if all required keys exist
    required_keys = [:env,:group,:type,]
    (required_keys - @params.keys).empty?
  end
  
  def run()
    puts "Parent pid: #{Process.pid}"
    pid = fork do
      puts "pid: #{Process.pid} | jobid: #{@params[:jobid]} | start"
      deployer = Deployer.new(params)     
      #sucess = deployer.start(@logger)
      sucess = deployer.deploy(@logger)
      puts "pid: #{Process.pid} | jobid: #{@params[:jobid]} | end"
      @logger.info("pid: #{Process.pid} | jobid: #{@params[:jobid]} | success=#{sucess}")
    end
    Process.detach(pid)
    is_running(pid)
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
