#!/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'json'
require 'yaml'
require 'uuidtools'
require './lib/bgdeploy'
require './lib/bglogger'

set :port, 9494

  UNAUTHORIZED = 401
  BAD_REQUEST = 400
  ACCEPTED = 202
  OK = 200

  CONFIG = YAML.load_file("./lib/config.yaml")

  get '/' do
    puts CONFIG
    'Hello World\n'
  end

  post '/bamgrid/:job' do
    job = params[:job] 
    if authenticate(params[:token])
      body "Authentication Failed\n"
      return UNAUTHORIZED
    elsif(['bgadmin','bgdeploy'].include? job)
      deploy(job, params)
    elsif 'log' == job
      get_log(job, params)  
    else
      return 404
    end
  end 

  helpers do 
    def deploy(job, params)
      deployjob = BGDeploy.new(job, params)
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
      body "Log file not found\n"
      begin
	body BGLogger.get_log(params[:file])
      rescue
	return BAD_REQUEST
      end
	return OK
    end
    def authenticate(token)
      return (token!=CONFIG['config']['token'])
    end
  end
