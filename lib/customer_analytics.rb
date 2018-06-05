module CustomerAnalytics
  def top_buyers(x = 20)
    @ranked_customers[0..(x - 1)]
  end

  def rank_customers_by_money_spent
    @engine.customers.all.sort_by do |customer|
      money_spent_by_customer(customer.id)
    end.reverse
  end

  def money_spent_by_customer(customer_id)
    invoices = @engine.invoices.find_all_by_customer_id(customer_id)
    invoices.inject(0) do |money_spent, invoice|
      if invoice_paid_in_full?(invoice.id)
        money_spent += invoice_total(invoice.id)
        money_spent
      else
        money_spent
      end
    end
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
    invoice_items.inject(0) do |total, invoice_item|
      if invoice_paid_in_full?(invoice_item.invoice_id)
        total += invoice_item.quantity
        total
      else
        total
      end
    end
  end

  def one_time_buyers
    @engine.customers.all.find_all do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id).length == 1
    end
  end

  def one_time_buyers_top_item
    top_item = item_quantities(one_time_buyer_invoices).max_by { |item| item.last }
    @engine.items.find_by_id(top_item.first)
  end

  def item_quantities(invoices)
    invoices.inject(Hash.new(0)) do |quantities, invoice|
      if invoice_paid_in_full?(invoice.id)
        invoice_items = @engine.invoice_items.find_all_by_invoice_id(invoice.id)
        invoice_items.each do |invoice_item|
          quantities[invoice_item.item_id] += total_items_sold_per_invoice(invoice.id)
        end
        quantities
      else
        quantities
      end
    end
  end

  def one_time_buyer_invoices
    one_time_buyers.map do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id)
    end.flatten
  end

  def items_bought_in_year(customer_id, year)
    invoice_items = customer_invoice_items(customer_id).find_all do |invoice_item|
      @engine.invoices.find_by_id(invoice_item.invoice_id).created_at.strftime('%Y') == year.to_s
    end
    invoice_items.map do |invoice_item|
      @engine.items.find_by_id(invoice_item.item_id)
    end
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

  def find_max_quantity_sold(quantity_sold_per_item)
    quantity_sold_per_item.max_by do |item|
      item[1]
    end
  end

  def highest_volume_items(customer_id)
    quantity_sold_per_item = determine_quantity_sold_for_each_item(customer_id)
    max_quantity = find_max_quantity_sold(quantity_sold_per_item)
    highest_volume = max_quantity[1]
    best_sellers = quantity_sold_per_item.find_all do |item|
      item[1] == highest_volume
    end
    best_sellers.map do |best_seller|
      @engine.items.find_by_id(best_seller[0])
    end
  end

  def customers_with_unpaid_invoices
    @engine.customers.all.find_all do |customer|
      @engine.invoices.find_all_by_customer_id(customer.id).any? do |invoice|
        !invoice_paid_in_full?(invoice.id)
      end
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

  def best_invoice_by_quantity
    max_quantity_invoice = invoices_by_quantity.max_by do |invoice|
      invoice[1]
    end
    @engine.invoices.find_by_id(max_quantity_invoice[0])
  end

  def invoices_by_quantity
    group_invoice_items_by_invoice.inject(Hash.new(0)) do |quantities, invoice|
      if invoice_paid_in_full?(invoice[0])
        quantities[invoice[0]] += quantity_per_invoice(invoice[1])
        quantities
      else
        quantities
      end
    end
  end

  def quantity_per_invoice(invoice_items)
    invoice_items.inject(0) do |quantity, invoice_item|
      quantity += invoice_item.quantity
      quantity
    end
  end

  def best_invoice_by_revenue
    max_revenue_invoice = invoices_by_revenue.max_by do |invoice|
      invoice[1]
    end
    @engine.invoices.find_by_id(max_revenue_invoice[0])
  end

  def invoices_by_revenue
    group_invoice_items_by_invoice.inject(Hash.new(0)) do |revenues, invoice|
      if invoice_paid_in_full?(invoice[0])
        revenues[invoice[0]] += revenue_per_invoice(invoice[1])
        revenues
      else
        revenues
      end
    end
  end
end
