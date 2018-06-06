require './test/test_helper'
require './lib/invoice_item'
require 'bigdecimal'
require 'bigdecimal/util'

class InvoiceItemTest < Minitest::Test
  def setup
    attributes = { id: '1',
                   item_id: '12',
                   invoice_id: '123',
                   quantity: '10',
                   unit_price: '100',
                   created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                   updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @invoice_item = InvoiceItem.new(attributes)
  end

  def test_it_exists
    assert_instance_of InvoiceItem, @invoice_item
  end

  def test_id_returns_the_invoice_item_id
    assert_equal 1, @invoice_item.id
  end

  def test_item_id_returns_the_item_id
    assert_equal 12, @invoice_item.item_id
  end

  def test_invoice_id_returns_the_invoice_id
    assert_equal 123, @invoice_item.invoice_id
  end

  def test_unit_price_returns_the_unit_price
    assert_equal 1, @invoice_item.unit_price
  end

  def test_created_at_returns_the_correct_time
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @invoice_item.created_at
  end

  def test_updated_at_returns_the_correct_time
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @invoice_item.updated_at
  end
end
