class InvoiceItem
  attr_accessor :quantity,
                :unit_price,
                :updated_at

  attr_reader   :id,
                :item_id,
                :invoice_id,
                :created_at

  def initialize(attributes)
    @id         = attributes[:id].to_i
    @item_id    = attributes[:item_id].to_i
    @invoice_id = attributes[:invoice_id].to_i
    @quantity   = attributes[:quantity].to_i
    @unit_price = attributes[:unit_price].to_d / 100
    @created_at = attributes[:created_at]
    @updated_at = attributes[:updated_at]
  end

  def unit_price_to_dollars
    @unit_price.to_f.round(2)
  end
end
