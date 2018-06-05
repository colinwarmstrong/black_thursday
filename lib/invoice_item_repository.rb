require_relative 'invoice_item'

class InvoiceItemRepository < Repository
  def find_all_by_item_id(item_id)
    @repository.find_all do |invoice_item|
      invoice_item.item_id == item_id
    end
  end

  def find_all_by_invoice_id(invoice_id)
    @repository.find_all do |invoice_item|
      invoice_item.invoice_id == invoice_id
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_invoice_item = InvoiceItem.new(attributes)
    @repository << new_invoice_item
    new_invoice_item
  end

  def update(id, attributes)
    if find_by_id(id).nil?
      return
    else
      invoice_item = find_by_id(id)
      invoice_item.quantity = attributes[:quantity] unless attributes[:quantity].nil?
      invoice_item.unit_price = attributes[:unit_price] unless attributes[:unit_price].nil?
      invoice_item.updated_at = Time.now
    end
  end
end
