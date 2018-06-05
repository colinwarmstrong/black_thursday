require_relative 'merchant'
require_relative 'repository'

class MerchantRepository < Repository
  def find_by_name(name)
    @repository.find do |merchant|
      merchant.name.downcase == name.downcase
    end
  end

  def find_all_by_name(name)
    @repository.find_all do |merchant|
      merchant.name.downcase.include?(name.downcase)
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_merchant = Merchant.new(attributes)
    @repository << new_merchant
    return new_merchant
  end

  def update(id, attributes)
    updated_merchant = find_by_id(id)
    if updated_merchant.nil?
      return
    else
      updated_merchant.name = attributes[:name]
    end
  end
end
