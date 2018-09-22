require_relative 'item'

class ItemRepository < Repository
  def find_by_name(name)
    @repository.find do |item|
      item.name.downcase == name.downcase
    end
  end

  def find_all_with_description(description)
    @repository.find_all do |item|
      item.description.downcase == description.downcase
    end
  end

  def find_all_by_price(price)
    @repository.find_all do |item|
      item.unit_price_to_dollars == price
    end
  end

  def find_all_by_price_in_range(price_range)
    @repository.find_all do |item|
      price_range.include?(item.unit_price_to_dollars)
    end
  end

  def find_all_by_merchant_id(merchant_id)
    @repository.find_all do |item|
      item.merchant_id == merchant_id
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_item = Item.new(attributes)
    @repository << new_item
    new_item
  end

  def update(id, attributes)
    return if find_by_id(id).nil?
    item = find_by_id(id)
    item.name = attributes[:name] unless attributes[:name].nil?
    item.description = attributes[:description] unless attributes[:description].nil?
    item.unit_price = attributes[:unit_price] unless attributes[:unit_price].nil?
    item.updated_at = Time.now
  end
end
