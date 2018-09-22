require './test/test_helper'
require './lib/invoice'

class InvoiceTest < Minitest::Test
  def setup
    attributes = { id: '1',
                   customer_id: '12',
                   merchant_id: '1234567',
                   status: 'pending',
                   created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                   updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @invoice = Invoice.new(attributes)
  end

  def test_it_exists
    assert_instance_of Invoice, @invoice
  end

  def test_id_returns_the_invoice_id
    assert_equal 1, @invoice.id
  end

  def test_customer_id_returns_the_invoice_customer_id
    assert_equal 12, @invoice.customer_id
  end

  def test_merchant_id_returns_the_invoice_merchant_id
    assert_equal 1234567, @invoice.merchant_id
  end

  def test_status_returns_the_invoice_status
    assert_equal :pending, @invoice.status
  end

  def test_create_at_returns_a_time_instance_for_the_created_at_date
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @invoice.created_at
  end

  def test_updated_at_returns_a_time_instance_for_last_time_invoice_was_updated
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @invoice.updated_at
  end
end
