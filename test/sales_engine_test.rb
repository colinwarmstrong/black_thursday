require './test/test_helper'
require './lib/sales_engine'

class SalesEngineTest < Minitest::Test
  def test_it_exists
    assert_instance_of SalesEngine, SalesEngine.new
  end
end
