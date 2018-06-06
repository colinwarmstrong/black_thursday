require './test/test_helper'
require './lib/customer'

class CustomerTest < Minitest::Test
  def setup
    attributes = { id: '1',
                   first_name: 'Joe',
                   last_name: 'Smith',
                   created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                   updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @customer = Customer.new(attributes)
  end

  def test_customer_exists
    assert_instance_of Customer, @customer
  end

  def test_id_returns_the_id
    assert_equal 1, @customer.id
  end

  def test_first_name_returns_the_first_name
    assert_equal 'Joe', @customer.first_name
  end

  def test_last_name_returns_the_last_name
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @customer.created_at
  end

  def test_created_at_returns_a_time_instance
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @customer.updated_at
  end
end
