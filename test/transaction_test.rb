require './test/test_helper'
require './lib/transaction'
require 'bigdecimal'
require 'bigdecimal/util'

class TransactionTest < Minitest::Test
  def setup
    attributes= { id: '1',
                  invoice_id: '12',
                  credit_card_number: '1234123412341234',
                  credit_card_expiration_date: '0217',
                  result: 'success',
                  created_at: Time.parse("2012-03-27 14:56:08 UTC"),
                  updated_at: Time.parse("2012-03-27 14:56:08 UTC") }
    @transaction = Transaction.new(attributes)
  end

  def test_it_exists
    assert_instance_of Transaction, @transaction
  end

  def test_id_returns_the_transaction_id
    assert_equal 1, @transaction.id
  end

  def test_invoice_id_returns_the_invoice_id
    assert_equal 12, @transaction.invoice_id
  end

  def test_credit_card_number_returns_the_credit_card_number
    assert_equal '1234123412341234', @transaction.credit_card_number
  end

  def test_credit_card_expiration_date_returns_correct_date
    assert_equal '0217', @transaction.credit_card_expiration_date
  end

  def test_result_returns_the_correct_result
    assert_equal :success, @transaction.result
  end

  def test_created_at_returns_correct_time
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @transaction.created_at
  end

  def test_updated_at_returns_correct_time
    assert_equal Time.parse("2012-03-27 14:56:08 UTC"), @transaction.updated_at
  end
end
