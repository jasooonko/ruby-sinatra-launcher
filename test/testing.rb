$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'test/unit'
require 'yaml'
require '../lib/bgdeploy'

class TestDeployer < Test::Unit::TestCase
  CONFIG = YAML.load_file("../lib/config.yaml")['config']
  PARAMS = [[{},false],
	    [{:env=>'dev'},false],
	    [{'env'=>'dev','group'=>'ops','type'=>'all'},true],
	    [{'env'=>'dev','group'=>'ops','type'=>'all','sleep'=>3},true],
	    ] 
  

def test_params  
    PARAMS.each do |params|
      deploy = BGDeploy.new(params[0], CONFIG)
      assert_equal(params[1], deploy.valid_params?)
    end
  end
end
