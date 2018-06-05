require_relative 'invoice'

class InvoiceRepository < Repository
  def find_all_by_customer_id(customer_id)
    @repository.find_all do |invoice|
      invoice.customer_id == customer_id
    end
  end

  def find_all_by_merchant_id(merchant_id)
    @repository.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def find_all_by_status(status)
    @repository.find_all do |invoice|
      invoice.status == status
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_invoice = Invoice.new(attributes)
    @repository << new_invoice
    return new_invoice
  end

  def update(id, attributes)
    if find_by_id(id).nil?
      return
    else
      updated_invoice = find_by_id(id)
    end
    updated_invoice.status = attributes[:status]
    updated_invoice.updated_at = Time.now
  end
end
