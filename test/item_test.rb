require './test/test_helper'
require './lib/item'
require 'bigdecimal'
require 'bigdecimal/util'

class ItemTest < Minitest::Test
  def setup
    attributes = { id: '1',
                   name: 'Slinky',
                   description: 'A spring',
                   unit_price: '100',
                   merchant_id: '1234567',
                   created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                   updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @item = Item.new(attributes)
  end

  def test_it_exists
    assert_instance_of Item, @item
  end

  def test_id_returns_the_id
    assert_equal 1, @item.id
  end

  def test_name_returns_the_name
    assert_equal 'Slinky', @item.name
  end

  def test_description_returns_the_description
    assert_equal 'A spring', @item.description
  end

  def test_unit_price_returns_the_unit_price
    assert_equal 1, @item.unit_price
  end

  def test_created_at_returns_the_time_it_was_created
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @item.created_at
  end

  def test_updated_at_returns_the_time_it_was_last_updated
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @item.updated_at
  end

  def test_unit_price_to_dollars_returns_price_as_a_float
    assert_equal 1.00, @item.unit_price_to_dollars
  end
end
