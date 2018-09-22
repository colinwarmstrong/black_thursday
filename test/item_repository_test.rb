require './test/test_helper'
require './lib/sales_engine'
require './lib/item_repository'

class ItemRepositoryTest < Minitest::Test
  def setup
    sales_data = { items: './data/items.csv' }
    engine = SalesEngine.new
    engine.create_item_repository(sales_data)
    @items = engine.items
  end

  def test_it_exists
    assert_instance_of ItemRepository, @items
  end

  def test_find_by_id_finds_an_item_by_od
    id = 263538760
    expected = @items.find_by_id(id)
    assert_equal id, expected.id
    assert_equal 'Puppy blankie', expected.name
    id = 1
    expected = @items.find_by_id(id)
    assert_nil expected
  end

  def test_find_by_name_finds_an_item_by_name
    name = 'Puppy blankie'
    expected = @items.find_by_name(name)
    assert_equal name, expected.name
    name = 'Sales Engine'
    expected = @items.find_by_name(name)
    assert_nil expected
  end

  def test_find_all_with_description_find_all_items_matching_given_description
    description = 'A large Yeti of sorts, casually devours a cow as the others watch numbly.'
    expected = @items.find_all_with_description(description)
    assert_equal description, expected.first.description
    assert_equal 263550472, expected.first.id
    description = 'A LARGE yeti of SOrtS, casually devoURS a COw as the OTHERS WaTch NUmbly.'
    expected = @items.find_all_with_description(description)
    assert_equal 263550472, expected.first.id
    description = 'Sales Engine is a relational database'
    expected = @items.find_all_with_description(description)
    assert_equal 0, expected.length
  end

  def test_find_all_by_price_finds_all_items_matching_given_price
    price = BigDecimal.new(25)
    expected = @items.find_all_by_price(price)
    assert_equal 79, expected.length
    price = BigDecimal.new(10)
    expected = @items.find_all_by_price(price)
    assert_equal 63, expected.length
    price = BigDecimal.new(20000)
    expected = @items.find_all_by_price(price)
    assert_equal 0, expected.length
  end

  def test_all_by_price_in_range_returns_an_array_of_items_priced_within_range
    range = (1000.00..1500.00)
    expected = @items.find_all_by_price_in_range(range)
    assert_equal 19, expected.length
    range = (10.00..150.00)
    expected = @items.find_all_by_price_in_range(range)
    assert_equal 910, expected.length
    range = (10.00..15.00)
    expected = @items.find_all_by_price_in_range(range)
    assert_equal 205, expected.length
    range = (0..10.0)
    expected = @items.find_all_by_price_in_range(range)
    assert_equal 302, expected.length
  end

  def test_find_all_by_merchant_id_returns_an_array_of_items_with_merchant_id
    merchant_id = 12334326
    expected = @items.find_all_by_merchant_id(merchant_id)
    assert_equal 6, expected.length
    merchant_id = 12336020
    expected = @items.find_all_by_merchant_id(merchant_id)
    assert_equal 2, expected.length
  end

  def test_create_creates_a_new_item_instance
    attributes = {
      name: "Capita Defenders of Awesome 2018",
      description: "This board both rips and shreds",
      unit_price: BigDecimal.new(399.99, 5),
      created_at: Time.now,
      updated_at: Time.now,
      merchant_id: 25
    }
    @items.create(attributes)
    expected = @items.find_by_id(263567475)
    assert_equal 'Capita Defenders of Awesome 2018', expected.name
  end

  def test_update_updates_an_item
    attributes = {
      name: "Capita Defenders of Awesome 2018",
      description: "This board both rips and shreds",
      unit_price: BigDecimal.new(399.99, 5),
      created_at: Time.now,
      updated_at: Time.now,
      merchant_id: 25
    }
    @items.create(attributes)
    original_time = @items.find_by_id(263567475).updated_at
    updated_attributes = {
      unit_price: BigDecimal.new(379.99, 5)
    }
    @items.update(263567475, updated_attributes)
    expected = @items.find_by_id(263567475)
    assert_equal 379.99, expected.unit_price
    assert_equal 'Capita Defenders of Awesome 2018', expected.name
    assert expected.updated_at > original_time
  end

  def test_update_cannot_update_id_created_at_or_merchant_id
    attributes = {
      name: "Capita Defenders of Awesome 2018",
      description: "This board both rips and shreds",
      unit_price: BigDecimal.new(399.99, 5),
      created_at: Time.now,
      updated_at: Time.now,
      merchant_id: 25
    }
    @items.create(attributes)
    updated_attributes = {
      id: 270000000,
      created_at: Time.now,
      merchant_id: 1
    }

    @items.update(263567475, updated_attributes)
    expected = @items.find_by_id(270000000)
    assert_nil expected
    expected = @items.find_by_id(263567475)
    assert updated_attributes[:created_at] != expected.created_at
    assert updated_attributes[:merchant_id] != expected.merchant_id
  end

  def test_update_on_unknown_item_does_nothing
    expected = @items.update(270000000, {})
    assert_nil expected
  end

  def test_delete_deletes_the_specified_item
    @items.delete(263567475)
    expected = @items.find_by_id(263567475)
    assert_nil expected
  end

  def test_delete_on_unknown_item_does_nothing
    expected = @items.delete(270000000)
    assert_nil expected
  end
end
