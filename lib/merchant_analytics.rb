module MerchantAnalytics
  def rank_merchants_by_revenue
    @engine.merchants.all.sort_by do |merchant|
      -revenue_by_merchant(merchant.id)
    end
  end

  def top_revenue_earners(x = 20)
    @ranked_merchants[0..(x - 1)]
  end

  def merchants_ranked_by_revenue
    @ranked_merchants
  end

  def revenue_by_merchant(merchant_id)
    invoices = @engine.invoices.find_all_by_merchant_id(merchant_id)
    invoices.delete_if { |invoice| !invoice_paid_in_full?(invoice.id) }
    invoices.inject(0) do |revenue, invoice|
      revenue += invoice_total(invoice.id)
      revenue
    end
  end

  def total_revenue_by_date(date)
    invoices_created_on_date(date).inject(0) do |total_revenue, invoice|
      total_revenue += invoice_total(invoice.id)
      total_revenue
    end
  end

  def invoices_created_on_date(date)
    @engine.invoices.all.find_all do |invoice|
      invoice.created_at.strftime('%F') == date.strftime('%F')
    end
  end

  def merchants_with_pending_invoices
    @engine.merchants.all.find_all do |merchant|
      @engine.invoices.find_all_by_merchant_id(merchant.id).any? do |invoice|
        !invoice_paid_in_full?(invoice.id)
      end
    end
  end

  def merchants_with_only_one_item
    @engine.merchants.all.find_all do |merchant|
      @engine.items.find_all_by_merchant_id(merchant.id).length == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      merchant.created_at.strftime('%B').downcase == month.downcase
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    paid_invoices = @engine.invoices.find_all_by_merchant_id(merchant_id).find_all do |invoice|
      invoice_paid_in_full?(invoice.id)
    end
    invoice_items = paid_invoices.map do |paid_invoice|
      @engine.invoice_items.find_all_by_invoice_id(paid_invoice.id)
    end.flatten
    items_by_quantity = invoice_items.inject(Hash.new(0)) do |quantities, invoice_item|
      quantities[invoice_item.item_id] += invoice_item.quantity
      quantities
    end
    max_quantity = items_by_quantity.max_by do |item|
      item[1]
    end.last
    most_sold_item_ids = items_by_quantity.find_all do |item|
      item[1] == max_quantity
    end
    most_sold_item_ids.map do |item|
      @engine.items.find_by_id(item[0])
    end
  end

  def best_item_for_merchant(merchant_id)
    paid_invoices = @engine.invoices.find_all_by_merchant_id(merchant_id).find_all do |invoice|
      invoice_paid_in_full?(invoice.id)
    end
    invoice_items = paid_invoices.map do |paid_invoice|
      @engine.invoice_items.find_all_by_invoice_id(paid_invoice.id)
    end.flatten
    items_by_revenue = invoice_items.inject(Hash.new(0)) do |quantities, invoice_item|
      quantities[invoice_item.item_id] += invoice_item.quantity * invoice_item.unit_price
      quantities
    end
    best_item = items_by_revenue.max_by do |item|
      item[1]
    end.first
    @engine.items.find_by_id(best_item)
  end
end
