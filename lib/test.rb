require 'yaml'

def read_config
  config = YAML.load_file("config.yaml")
  puts config["config"]["log_dir"]
  puts config["config"]["script_dir"]
end

read_config
