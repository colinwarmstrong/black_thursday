class Item
  attr_accessor :name,
                :description,
                :unit_price,
                :updated_at
  attr_reader   :id,
                :merchant_id,
                :created_at

  def initialize(attributes)
    @id = attributes[:id].to_i
    @name = attributes[:name]
    @description = attributes[:description]
    @unit_price = attributes[:unit_price].to_d / 100
    @merchant_id = attributes[:merchant_id].to_i
    @created_at = attributes[:created_at]
    @updated_at = attributes[:updated_at]
  end

  def unit_price_to_dollars
    @unit_price.to_f.round(2)
  end
end
