metadata    :name        => "Bamgrid agent",
            :description => "run arbitrary Bamgrid commands and get their output",
            :author      => "Jason",
            :license     => "license",
            :version     => "1.0",
            :url         => "http://www.mlb.com",
            :timeout     => 300


action "runcmd", :description => "Executes bgadmin" do
    
    display :always
    
    input	:cmd,
		:prompt      => "Command Name",
		:description => "Command to execute",
		:validation  => '.*',
		:type        => :string,
		:optional    => false,
		:maxlength   => 80
    
    input	:token,
		:prompt      => "Authentication Token",
		:description => "Authentication Token",
		:validation  => '.*',
		:type        => :string,
		:optional    => false,
		:maxlength   => 80
    
    output  	:exitcode,
	    	:description => "Execution result",
           	:display_as  => "Exit Code",
      		:default     => "unknown status"
    output  	:token,
		:description => "token",
		:display_as  => "token",
		:default     => "unknown status"


    output 	:output,
           	:description => "The output of the execution of the command",
           	:display_as   => "Output",
	   	:default     => "unknown status"

    output 	:time,
           	:description => "The time the message was received",
           	:display_as   => "Time",
	   	:default     => "unknown status"
end 

action "echo", :description => "Echos back any message it receives" do
    display :always
    input :msg,
          :prompt      => "Service Name",
          :description => "The service to get the status for",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_ \d]+$',
          :optional    => false,
          :maxlength   => 100
 
    output :msg,
           :description => "The message we received",
           :display_as  => "Message",
	   :default     => "unknown status"

    output :time,
           :description => "The time the message was received",
           :display_as   => "Time",
	   :default     => "unknown status"
end
