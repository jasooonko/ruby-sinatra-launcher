#!/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'json'
require 'yaml'
require 'securerandom'
require './lib/bgdeploy'
require './lib/bglogger'
require './lib/mcoagent'

set :port, 9494

  # HTTP RETURN CODES
  BAD_REQUEST = 400
  UNAUTHORIZED = 401
  NOT_FOUND = 404
  ACCEPTED = 202
  OK = 200
  CREATED = 201

  CONFIG = YAML.load_file("./lib/config.yaml")['config']
  ACCESS_LOG = BGLogger.new(CONFIG['log_dir'], 'access.log', 'weekly')
 
  get '/' do
    ACCESS_LOG.info(request.ip)
    'Hello World\n'
  end

  post '/bamgrid/:job' do
    log_access(request.ip, params)
    if(['bgadmin','bgdeploy'].include? params[:job])
      deploy(params)
    elsif 'log' == params[:job]
      get_log(params) 
    else
      return NOT_FOUND
    end
  end 
  
  get '/mco/:agent/:action' do
    log_access(request.ip, params)
    mcoagent(params)
    #return ACCEPTED
  end 
  
  helpers do 
    
    def get_jobid() 
    	Time.now.strftime("%Y%m%d%H%M") + "-" + SecureRandom.base64(5).tr('+/=','0aZ')	# yyyymmdd-<random hex>
    end

    def log_access(ip, params)
      ACCESS_LOG.info("Request from: " + ip)
      ACCESS_LOG.info(params.to_json)
    end

    def deploy(params)
      params[:jobid] = "bamgrid-#{params[:job]}-#{get_jobid()}"
      deployjob = BGDeploy.new(params, CONFIG)
      if(!deployjob.valid_params?)
	body "Missing Params\n"
	return BAD_REQUEST
      end
      deployjob.run()
      headers "Content-Type" => "application/json"
      body "#{deployjob.get_params_json}\n"
      return ACCEPTED
    end

    def mcoagent(params)
      params[:jobid] = "mco-#{params[:agent]}-#{get_jobid()}"
      mcoagent = MCOagent.new(params, CONFIG)
      begin
      	mcoagent.valid_params
      rescue Exception => e
        body e.message
        return BAD_REQUEST
      end
      headers "Content-Type" => "application/json"
      #result =  mcoagent.run()
      #pp result
      #result.to_json
      pid = fork do
        mcoagent.run()
      end
      Process.detach(pid)
      body "#{mcoagent.get_params_json}\n"
      return ACCEPTED
    end
    
    def get_log(params)
      begin
	body BGLogger.get_log(CONFIG['log_dir'] + "/" + params[:file])
      rescue
      	body "Log file not found\n"
	return BAD_REQUEST
      end
	return OK
    end
  end
