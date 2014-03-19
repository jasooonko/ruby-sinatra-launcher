$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'logger'

class BGLogger
 
  attr_accessor :logger, :log_dir, :log_file
 
  def initialize(log_dir, log_file, range=nil)
    puts 'create log file: ' + log_dir+'/'+log_file
    @log_dir = log_dir
    @log_file = log_file 
    @logger = Logger.new(@log_dir + '/' + @log_file)
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}][#{severity}] #{msg}\n"
    end
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
    File.read(file)
  end
end
