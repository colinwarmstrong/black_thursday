require_relative 'merchant'

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
    new_merchant
  end

  def update(id, attributes)
    if find_by_id(id).nil?
      return
    else
      merchant = find_by_id(id)
      merchant.name = attributes[:name] unless attributes[:name].nil?
      merchant.updated_at = Time.now
    end
  end
end
