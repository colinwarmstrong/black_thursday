module MerchantAnalytics
  def rank_merchants_by_revenue
    invoices = @paid_invoices.group_by { |invoice| invoice.merchant_id }
    @engine.merchants.all.sort_by do |merchant|
      -revenue_generated_in_merchant_invoices(invoices[merchant.id])
    end
  end

  def revenue_generated_in_merchant_invoices(invoices)
    return 0 if invoices.nil?
    invoices.inject(0) do |revenue, invoice|
      revenue += invoice_total(invoice.id)
      revenue
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
    revenue_generated_in_merchant_invoices(invoices)
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
    items_by_quantity = group_items_by_quantity(merchant_id)
    highest_volume_item = items_by_quantity.max_by { |item| item.last }
    max_amount_sold = highest_volume_item.last
    items_by_quantity.find_all do |item|
      item.last == max_amount_sold
    end.map { |item| @engine.items.find_by_id(item.first) }
  end

  def group_items_by_quantity(merchant_id)
    invoices = paid_invoices(merchant_id)
    find_invoice_items(invoices).inject(Hash.new(0)) do |quantities, invoice_item|
      quantities[invoice_item.item_id] += invoice_item.quantity
      quantities
    end
  end

  def find_invoice_items(invoices)
    invoices.map do |paid_invoice|
      @engine.invoice_items.find_all_by_invoice_id(paid_invoice.id)
    end.flatten
  end

  def paid_invoices(merchant_id)
    @engine.invoices.find_all_by_merchant_id(merchant_id).find_all do |invoice|
      invoice_paid_in_full?(invoice.id)
    end
  end

  def best_item_for_merchant(merchant_id)
    items_by_revenue = group_items_by_revenue(merchant_id)
    highest_revenue_item = items_by_revenue.max_by { |item| item.last }
    @engine.items.find_by_id(highest_revenue_item.first)
  end

  def group_items_by_revenue(merchant_id)
    invoices = paid_invoices(merchant_id)
    find_invoice_items(invoices).inject(Hash.new(0)) do |revenues, invoice_item|
      revenues[invoice_item.item_id] += invoice_item.quantity * invoice_item.unit_price
      revenues
    end
  end
end
