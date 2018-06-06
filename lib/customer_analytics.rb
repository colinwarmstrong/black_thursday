module CustomerAnalytics
  def rank_customers_by_money_spent
    invoices = @paid_invoices.group_by { |invoice| invoice.customer_id }
    @engine.customers.all.sort_by do |customer|
      -money_spent_by_customer(invoices[customer.id])
    end
  end

  def money_spent_by_customer(invoices)
    return 0 if invoices.nil?
    invoices.inject(0) do |money_spent, invoice|
      money_spent += invoice_total(invoice.id)
      money_spent
    end
  end

  def top_buyers(x = 20)
    @ranked_customers[0..(x - 1)]
  end

  def top_merchant_for_customer(customer_id)
    @engine.merchants.find_by_id(find_top_merchant(customer_id).first)
  end

  def find_top_merchant(customer_id)
    invoices = @engine.invoices.find_all_by_customer_id(customer_id)
    invoices.inject(Hash.new(0)) do |purchases, invoice|
      purchases[invoice.merchant_id] += total_items_sold_per_invoice(invoice.id)
      purchases
    end.max_by { |merchant| merchant.last }
  end

  def total_items_sold_per_invoice(invoice_id)
    invoice_items = @engine.invoice_items.find_all_by_invoice_id(invoice_id)
    invoice_items.delete_if { |invoice_item| !invoice_paid_in_full?(invoice_item.invoice_id) }
    invoice_items.inject(0) do |total, invoice_item|
      total += invoice_item.quantity
      total
    end
  end

  def one_time_buyers
    @engine.customers.all.find_all do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id).length == 1
    end
  end

  def one_time_buyers_top_item
    top_item = item_quantities(one_time_invoices).max_by { |item| item.last }
    @engine.items.find_by_id(top_item.first)
  end

  def item_quantities(invoices)
    invoices.delete_if { |invoice| !invoice_paid_in_full?(invoice.id)}
    invoices.inject(Hash.new(0)) do |quantities, invoice|
      invoice_items = @engine.invoice_items.find_all_by_invoice_id(invoice.id)
      invoice_items.each do |invoice_item|
        quantities[invoice_item.item_id] += invoice_item.quantity
      end
      quantities
    end
  end

  def one_time_invoices
    one_time_buyers.map do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id)
    end.flatten
  end

  def items_bought_in_year(customer_id, year)
    customer_invoice_items(customer_id).find_all do |invoice_item|
      @engine.invoices.find_by_id(invoice_item.invoice_id).created_at.strftime('%Y') == year.to_s
    end.map { |invoice_item| @engine.items.find_by_id(invoice_item.item_id) }
  end

  def customer_invoice_items(customer_id)
    @engine.invoices.find_all_by_customer_id(customer_id).map do |invoice|
      @engine.invoice_items.find_all_by_invoice_id(invoice.id)
    end.flatten
  end

  def determine_quantity_sold_for_each_item(customer_id)
    customer_invoice_items(customer_id).inject(Hash.new(0)) do |quantity, invoice_item|
      quantity[invoice_item.item_id] += invoice_item.quantity
      quantity
    end
  end

  def find_highest_quantity(quantity_sold_per_item)
    quantity_sold_per_item.max_by do |item, quantity|
      quantity
    end
  end

  def highest_volume_items(customer_id)
    quantity_sold_per_item = determine_quantity_sold_for_each_item(customer_id)
    highest_volume = find_highest_quantity(quantity_sold_per_item.values)
    quantity_sold_per_item.find_all do |item|
      item.last == highest_volume
    end.map { |best_seller| @engine.items.find_by_id(best_seller.first) }
  end

  def customers_with_unpaid_invoices
    @engine.customers.all.find_all do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id).any? do |invoice|
        !invoice_in_paid_invoices?(invoice.id)
      end
    end
  end

  def best_invoice_by_revenue
    max_revenue_invoice = invoices_by_revenue.max_by do |invoice, revenue|
      revenue
    end
    @engine.invoices.find_by_id(max_revenue_invoice.first)
  end

  def invoices_by_revenue
    invoices = group_invoice_items_by_invoice
    invoices.delete_if { |invoice_id| !invoice_in_paid_invoices?(invoice_id) }
    invoices.inject(Hash.new(0)) do |revenues, invoice|
      revenues[invoice.first] += revenue_per_invoice(invoice.last)
      revenues
    end
  end

  def revenue_per_invoice(invoice_items)
    invoice_items.inject(0) do |revenue, invoice_item|
      revenue += invoice_item.quantity * invoice_item.unit_price
      revenue
    end
  end

  def group_invoice_items_by_invoice
    @engine.invoice_items.all.group_by do |invoice_item|
      invoice_item.invoice_id
    end
  end

  def invoice_in_paid_invoices?(invoice_id)
    @paid_invoices.include?(@engine.invoices.find_by_id(invoice_id))
  end

  def best_invoice_by_quantity
    max_quantity_invoice = invoices_by_quantity.max_by do |invoice, quantity|
      quantity
    end
    @engine.invoices.find_by_id(max_quantity_invoice[0])
  end

  def invoices_by_quantity
    invoices = group_invoice_items_by_invoice
    invoices.delete_if { |invoice_id| !invoice_in_paid_invoices?(invoice_id) }
    invoices.inject(Hash.new(0)) do |quantities, invoice|
      quantities[invoice.first] += quantity_per_invoice(invoice.last)
      quantities
    end
  end

  def quantity_per_invoice(invoice_items)
    invoice_items.inject(0) do |quantity, invoice_item|
      quantity += invoice_item.quantity
      quantity
    end
  end
end
