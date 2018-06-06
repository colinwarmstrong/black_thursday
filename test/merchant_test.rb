require './test/test_helper'
require'./lib/merchant'

class MerchantTest < Minitest::Test
  def setup
    attributes = { id: '1234567',
                   name: "Joe's Hot Dogs",
                   created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                   updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @merchant = Merchant.new(attributes)
  end

  def test_it_exists
    assert_instance_of Merchant, @merchant
  end

  def test_id_returns_the_merchant_id
    assert_equal 1234567, @merchant.id
  end

  def test_name_returns_the_merchant_name
    assert_equal "Joe's Hot Dogs", @merchant.name
  end
end
