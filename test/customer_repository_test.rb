require './test/test_helper'
require './lib/sales_engine'
require './lib/customer_repository'

class CustomerRepositoryTest < Minitest::Test
  def setup
    sales_data = { customers: './data/customers.csv' }
    engine = SalesEngine.new
    engine.create_customer_repository(sales_data)
    @customers = engine.customers
  end

  def test_all_returns_all_of_the_customers
    expected = @customers.all
    assert_equal 1000, expected.length
    assert_equal Customer, expected.first.class
  end

  def test_find_by_id_returns_the_customer_with_matching_id
    id = 100
    expected = @customers.find_by_id(id)

    assert_equal id, expected.id
    assert_equal Customer, expected.class
  end

  def test_find_all_by_first_name_returns_all_customers_with_matching_first_name
    fragment = "oe"
    expected = @customers.find_all_by_first_name(fragment)

    assert_equal 8, expected.length
    assert_equal Customer, expected.first.class
  end

  def test_find_all_by_last_name_returns_all_customers_with_matching_last_name
    fragment = "On"
    expected = @customers.find_all_by_last_name(fragment)

    assert_equal 85, expected.length
    assert_equal Customer, expected.first.class
  end

  def test_find_all_by_first_name_and_find_all_by_last_name_are_case_insensitive
    fragment = "NN"
    expected = @customers.find_all_by_first_name(fragment)

    assert_equal 57, expected.length
    assert_equal Customer, expected.first.class

    fragment = "oN"
    expected = @customers.find_all_by_last_name(fragment)

    assert_equal 85, expected.length
    assert_equal Customer, expected.first.class
  end

  def test_create_creates_a_new_customer_instance
    attributes = {
      :first_name => "Joan",
      :last_name => "Clarke",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @customers.create(attributes)
    expected = @customers.find_by_id(1001)
    assert_equal "Joan", expected.first_name
  end

  def test_update_updates_a_customer
    attributes = {
      :first_name => "Joan",
      :last_name => "Clarke",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @customers.create(attributes)
    original_time = @customers.find_by_id(1001).updated_at
    updated_attributes = {
      last_name: "Smith"
    }
    @customers.update(1001, updated_attributes)
    expected = @customers.find_by_id(1001)
    assert_equal "Smith", expected.last_name
    assert_equal "Joan", expected.first_name
    assert expected.updated_at > original_time
  end

  def test_update_cannot_update_id_or_created_at
    attributes = {
      :first_name => "Joan",
      :last_name => "Clarke",
      :created_at => Time.now,
      :updated_at => Time.now
    }
    @customers.create(attributes)
    updated_attributes = {
      id: 2000,
      created_at: Time.now
    }
    @customers.update(1001, updated_attributes)
    expected = @customers.find_by_id(2000)
    assert_nil expected
    expected = @customers.find_by_id(1001)
    refute updated_attributes[:created_at] == expected.created_at
  end

  def test_update_on_unknown_customer_does_nothing
    assert_nil @customers.update(2000, {})
  end

  def test_delete_deletes_the_specified_customer
    @customers.delete(1001)
    expected = @customers.find_by_id(1001)
    assert_nil expected
  end

  def test_delete_on_unknown_customer_does_nothing
    assert_nil @customers.delete(2000)
  end
end
