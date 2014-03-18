$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'logger'

class BGLogger
 
  LOG_DIR = '/home/jko/bamgrid/log' 
  attr_accessor :logger, :log_file
  
  def initialize(log_file)
    @log_file = LOG_DIR+"/"+log_file 
    @logger = Logger.new(@log_file)
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}][#{severity}] #{msg}\n"
    end
  end
  def self.get_logger(log_file)
      instance.log_file = log_file
      instance
  end
  def debug(log)
    puts "[DEBUG] #{log}"
    @logger.debug(log)
  end
  def info(log)
    puts "[INFO] #{log}"
    @logger.info(log)
  end
  def self.get_log(file)
    File.read("#{LOG_DIR}/#{file}")
  end
end
