require './test/test_helper'
require './lib/sales_engine'
require './lib/transaction_repository'

class TransactionRepositoryTest < Minitest::Test
  def setup
    sales_data = { transactions: './data/transactions.csv' }
    engine = SalesEngine.new
    engine.create_transaction_repository(sales_data)
    @transactions = engine.transactions
  end

  def test_all_returns_all_transactions
    expected = @transactions.all
    assert_equal 4985, expected.count
  end

  def test_find_by_id_returns_a_transaction_matching_the_given_id
    id = 2
    expected = @transactions.find_by_id(id)

    assert_equal id, expected.id
    assert_instance_of Transaction, expected
  end

  def test_find_all_by_invoice_id_returns_all_transactions_matching_the_given_id
    id = 2179
    expected = @transactions.find_all_by_invoice_id(id)

    assert_equal 2, expected.length
    assert_equal id, expected.first.invoice_id
    assert_instance_of Transaction, expected.first

    id = 14560
    expected = @transactions.find_all_by_invoice_id(id)
    assert expected.empty?
  end

  def test_find_all_by_credit_card_number_returns_all_transactions_matching_given_credit_card_number
    credit_card_number = "4848466917766329"
    expected = @transactions.find_all_by_credit_card_number(credit_card_number)

    assert_equal 1, expected.length
    assert_instance_of Transaction, expected.first
    assert_equal credit_card_number, expected.first.credit_card_number

    credit_card_number = "4848466917766328"
    expected = @transactions.find_all_by_credit_card_number(credit_card_number)

    assert expected.empty?
  end

  def test_find_all_by_result_returns_all_transactions_matching_given_result
    result = :success
    expected = @transactions.find_all_by_result(result)

    assert_equal 4158, expected.length
    assert_instance_of Transaction, expected.first
    assert_equal result, expected.first.result

    result = :failed
    expected = @transactions.find_all_by_result(result)

    assert_equal 827, expected.length
    assert_equal Transaction, expected.first.class
    assert_equal result, expected.first.result
  end

  def test_create_creates_a_new_transaction_instance
    attributes = {
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "success",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @transactions.create(attributes)
    expected = @transactions.find_by_id(4986)
    assert_equal 8, expected.invoice_id
  end

  def test_update_updates_a_transaction
    attributes = {
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "success",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @transactions.create(attributes)
    original_time = @transactions.find_by_id(4986).updated_at
    updated_attributes = {
      result: :failed
    }
    @transactions.update(4986, updated_attributes)
    expected = @transactions.find_by_id(4986)
    assert_equal :failed, expected.result
    assert_equal "0220", expected.credit_card_expiration_date
    assert expected.updated_at > original_time
  end

  def test_update_cannot_update_id_invoice_id_or_created_at
    attributes = {
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "success",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @transactions.create(attributes)
    updated_attributes = {
      id: 5000,
      invoice_id: 2,
      created_at: Time.now
    }
    @transactions.update(4986, updated_attributes)
    expected = @transactions.find_by_id(5000)
    assert_nil expected
    expected = @transactions.find_by_id(4986)
    refute updated_attributes[:invoice_id] == expected.invoice_id
    refute updated_attributes[:created_at] == expected.created_at
  end

  def test_update_on_unknown_transaction_does_nothing
    assert_nil @transactions.update(5000, {})
  end

  def test_delete_deletes_the_specified_transaction
    @transactions.delete(4986)
    expected = @transactions.find_by_id(4986)
    assert_nil expected
  end

  def test_delete_on_unknown_transaction_does_nothing
    assert_nil @transactions.delete(5000)
  end
end
