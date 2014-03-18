require 'mcollective'
require 'pp'

include MCollective::RPC

class BGMCClient

  attr_accessor :commands, :mcoptions, :verbose, :timeout, :disctimeout, :mcclient

  def initialize
    @commands = Array.new
    @mcoptions = 
    {
      :output_format=>:console,
      :collective=>"mcollective",
      :verbose=>true,
      :timeout=>600,
      :disctimeout=>10,
      :ttl=>600,
      :filter=>{"fact"=>[], "compound"=>[], "cf_class"=>[], "identity"=>[], "agent"=>["shellcmd"]},
      :config=>"/etc/mcollective/client.cfg"
    }
    pp @mcoptions
    @mcclient = rpcclient("shellcmd", :options => @mcoptions)
    #pp @mcclient
  end

  public

# Setters
  def verbose=(verbose)
    @mcoptions[:verbose] = verbose
  end

  def timeout=(timeout)
    @mcoptions[:timeout] = timeout
  end

  def disctimeout=(disctimeout)
    @mcoptions[:disctimeout] = disctimeout
  end

# Getters
  def verbose
    return @mcoptions[:verbose]
  end

  def timeout
    return @mcoptions[:timeout]
  end

  def disctimeout
    return @mcoptions[:disctimeout]
  end

# Public Methods
  def add_command(newcommand)
    @commands << newcommand
  end

  def add_filter(key, value)
    @mcclient.fact_filter("#{key}=#{value}")
  end

  def run_commands
    if (block_given?)
      self.process_commands do |response|
        yield response
      end
    else
      return self.process_commands
    end
  end

  protected

  def process_commands
    # Create string of commands to send over from @commands array
    myCommands = ""
    @commands.each do |command|
      echoCommand = ("echo Command: \"" + command + "\"" + ";\n")
      myCommands += echoCommand
      sendCommand = command + ";\n"
      myCommands += sendCommand
      echoExitCodeCommand = "echo \"Exit Code: $?\";\n"
      myCommands += echoExitCodeCommand
    end
    # Send myCommands string over, return response object
    resultsArray = Array.new
    @mcclient.runcmd(:cmd => myCommands) do |resp|
      full_response = ""
      resplines = resp[:body][:data][:output].split("\n")
      resplines.each do |respline|
        if (block_given?)
          yield "#{resp[:senderid]}: #{respline}"
        end
        resultsArray << "#{resp[:senderid]}: #{respline}"
      end
      if !(block_given?)
        return resultsArray
      end
    end
  end
end
