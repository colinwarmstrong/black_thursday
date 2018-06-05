require_relative 'customer'

class CustomerRepository < Repository
  def find_all_by_first_name(first_name)
    @repository.find_all do |customer|
      customer.first_name.downcase.include?(first_name.downcase)
    end
  end

  def find_all_by_last_name(last_name)
    @repository.find_all do |customer|
      customer.last_name.downcase.include?(last_name.downcase)
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_customer = Customer.new(attributes)
    @repository << new_customer
    new_customer
  end

  def update(id, attributes)
    if find_by_id(id).nil?
      return
    else
      customer = find_by_id(id)
      customer.first_name = attributes[:first_name] unless attributes[:first_name].nil?
      customer.last_name = attributes[:last_name] unless attributes[:last_name].nil?
      customer.updated_at = Time.now
    end
  end
end
