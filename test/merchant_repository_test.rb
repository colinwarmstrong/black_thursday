require './test/test_helper'
require './lib/sales_engine'
require './lib/merchant_repository'

class MerchantRepositoryTest < Minitest::Test
  def setup
    sales_data = { merchants: './data/merchants.csv' }
    engine = SalesEngine.new
    engine.create_merchant_repository(sales_data)
    @merchants = engine.merchants
  end

  def test_it_exists
    assert_instance_of MerchantRepository, @merchants
  end

  def test_all_returns_an_array_of_all_merchant_instances
    expected = @merchants.all
    assert_equal 475, expected.count
  end

  def test_find_by_id_find_a_merchant_by_id
    id = 12335971
    expected = @merchants.find_by_id(id)
    assert_equal 12335971, expected.id
    assert_equal "ivegreenleaves", expected.name
  end

  def test_find_by_id_returns_nil_if_the_merchant_does_not_exist
    id = 101
    expected = @merchants.find_by_id(id)
    assert_nil expected
  end

  def test_find_by_name_finds_the_first_matching_merchant_by_name
    name = 'leaburrot'
    expected = @merchants.find_by_name(name)
    assert_equal 12334411, expected.id
    assert_equal name, expected.name
  end

  def test_find_by_name_is_a_case_insensitive_search
    name = "LEABURROT"
    expected = @merchants.find_by_name(name)
    assert_equal 12334411, expected.id
  end

  def test_find_by_name_returns_nil_if_the_merchant_does_not_exist
    name = "Turing School of Software and Design"
    expected = @merchants.find_by_name(name)
    assert_nil expected
  end

  def test_find_all_by_name_finds_all_merchants_matching_given_name_fragment
    fragment = "style"
    expected = @merchants.find_all_by_name(fragment)
    assert_equal 3, expected.length
    assert expected.map(&:name).include?("justMstyle")
    assert expected.map(&:id).include?(12337211)
  end

  def test_find_all_by_name_returns_an_empty_array_if_there_are_no_matches
    name = "Turing School of Software and Design"
    expected = @merchants.find_all_by_name(name)
    assert_equal [], expected
  end

  def test_create_creates_a_new_merchant_instance
    attributes = { name: 'Turing School of Software and Design'}
    @merchants.create(attributes)
    expected = @merchants.find_by_id(12337412)
    assert_equal 'Turing School of Software and Design', expected.name
  end

  def test_update_updates_a_merchant
    attributes = { name: 'Turing School of Software and Design'}
    @merchants.create(attributes)
    updated_attributes = {name: 'TSSD'}
    @merchants.update(12337412, updated_attributes)
    expected = @merchants.find_by_id(12337412)
    assert_equal 'TSSD', expected.name
    expected = @merchants.find_by_name('Turing School of Software and Design')
    assert_nil expected
  end

  def test_update_cannot_update_id
    attributes = {id: 13000000}
    @merchants.update(12337412, attributes)
    expected = @merchants.find_by_id(13000000)
    assert_nil expected
  end

  def test_update_on_unknown_merchant_does_nothing
    expected = @merchants.update(13000000, {})
    assert_nil expected
  end

  def test_delete_deletes_the_specified_merchant
    @merchants.delete(12337412)
    expected = @merchants.find_by_id(12337412)
    assert_nil expected
  end

  def test_delete_on_unknown_merchant_does_nothing
    expected = @merchants.delete(12337412)
    assert_nil expected
  end
end
