class Invoice
  attr_accessor :status,
                :updated_at

  attr_reader   :id,
                :customer_id,
                :merchant_id,
                :created_at

  def initialize(attributes)
    @id          = attributes[:id].to_i
    @customer_id = attributes[:customer_id].to_i
    @merchant_id = attributes[:merchant_id].to_i
    @status      = attributes[:status].to_sym
    @created_at  = attributes[:created_at]
    @updated_at  = attributes[:updated_at]
  end
end
