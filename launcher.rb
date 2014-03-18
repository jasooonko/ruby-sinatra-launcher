#!/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'json'
require 'yaml'
require './lib/bgdeploy'
require './lib/bglogger'

set :port, 9494

  UNAUTHORIZED = 401
  BAD_REQUEST = 400
  ACCEPTED = 202
  OK = 200

  CONFIG = YAML.load_file("./lib/config.yaml")['config']
  ACCESS_LOG = BGLogger.new(CONFIG, 'access.log', 'weekly')
 
  get '/' do
    ACCESS_LOG.info(request.ip)
    'Hello World\n'
  end

  post '/bamgrid/:job' do
    ACCESS_LOG.info("Request from: " + request.ip)
    if authenticate(params.delete('token'))	    # delete token to avoid logging
      body "Authentication Failed\n"
      return UNAUTHORIZED
    end
    ACCESS_LOG.info(params.to_json)
    if(['bgadmin','bgdeploy'].include? params[:job])
      deploy(params[:job], params)
    elsif 'log' == params[:job]
      get_log(params[:job], params)  
    else
      return 404
    end
  end 

  helpers do 
    def deploy(job, params)
      deployjob = BGDeploy.new(job, params, CONFIG)
      if(!deployjob.valid_params?)
	body "Missing Params\n"
	return BAD_REQUEST
      end
      deployjob.run()
      headers "Content-Type" => "application/json"
      body "#{deployjob.get_params_json}\n"
      return ACCEPTED
    end
    def get_log(job, params)
      begin
	body BGLogger.get_log(CONFIG['log_dir'] + "/" + params[:file])
      rescue
      	body "Log file not found\n"
	return BAD_REQUEST
      end
	return OK
    end
    def authenticate(token)
      return (token!=CONFIG['auth_token'])
    end
  end
