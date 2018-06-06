require_relative 'merchant_analytics'
require_relative 'customer_analytics'

class SalesAnalyst
  include MerchantAnalytics
  include CustomerAnalytics

  def initialize(engine)
    @engine = engine
    @paid_invoices = all_paid_invoices
    @ranked_merchants = rank_merchants_by_revenue
    @ranked_customers = rank_customers_by_money_spent
  end

  def group_items_by_merchant
    @engine.items.all.group_by(&:merchant_id)
  end

  def average_items_per_merchant
    (@engine.items.all.length.to_f / @engine.merchants.all.length.to_f).round(2)
  end

  def average_items_per_merchant_standard_deviation
    average_items = average_items_per_merchant
    sum_of_squared_differences = group_items_by_merchant.inject(0) do |sum, merchant|
      difference = merchant[1].length - average_items
      sum += (difference ** 2)
      sum
    end
    quotient = sum_of_squared_differences / (@engine.merchants.all.length - 1)
    standard_deviation_long = Math.sqrt(quotient)
    BigDecimal(standard_deviation_long, 3).to_f
  end

  def merchants_with_high_item_count
    standard_deviation = average_items_per_merchant_standard_deviation
    high_item_count = average_items_per_merchant + standard_deviation
    group_items_by_merchant.map do |merchant|
      if merchant[1].length > high_item_count
        @engine.merchants.find_by_id(merchant[0])
      end
    end.compact
  end

  def sum_of_item_prices(merchant_id)
    @engine.items.find_all_by_merchant_id(merchant_id).inject(0) do |sum, item|
      sum += item.unit_price
      sum
    end
  end

  def average_item_price_for_merchant(merchant_id)
    sum = sum_of_item_prices(merchant_id)
    total_items = @engine.items.find_all_by_merchant_id(merchant_id).length
    average = sum / total_items
    BigDecimal(average).round(2)
  end

  def sum_of_averages
    group_items_by_merchant.inject(0) do |sum, merchant|
      sum += average_item_price_for_merchant(merchant[0])
      sum
    end
  end

  def average_average_price_per_merchant
    sum = sum_of_averages
    total_merchants = @engine.merchants.all.length
    average = sum / total_merchants
    BigDecimal(average).round(2)
  end

  def item_price_standard_deviation(average_item_price)
    sum_of_squared_differences = @engine.items.all.inject(0) do |sum, item|
      difference = item.unit_price - average_item_price
      sum += (difference**2)
      sum
    end
    quotient = sum_of_squared_differences / (@engine.items.all.length - 1)
    standard_deviation_long = Math.sqrt(quotient)
    BigDecimal(standard_deviation_long, 4)
  end

  def golden_items
    average_item_price = average_average_price_per_merchant
    standard_deviation = item_price_standard_deviation(average_item_price)
    golden_price = standard_deviation * 2 + average_item_price
    @engine.items.all.find_all do |item|
      item.unit_price > golden_price
    end
  end

  def average_invoices_per_merchant
    BigDecimal(@engine.invoices.all.length.to_f / @engine.merchants.all.length.to_f, 4).to_f
  end

  def group_invoices_by_merchant
    @engine.invoices.all.group_by(&:merchant_id)
  end

  def average_invoices_per_merchant_standard_deviation
    average_invoices = average_invoices_per_merchant
    sum_of_squared_differences = group_invoices_by_merchant.inject(0) do |sum, merchant|
      difference = merchant[1].length - average_invoices
      sum += (difference**2)
      sum
    end
    quotient = sum_of_squared_differences / (@engine.merchants.all.length - 1)
    standard_deviation_long = Math.sqrt(quotient)
    BigDecimal(standard_deviation_long, 3).to_f
  end

  def top_merchants_by_invoice_count
    standard_deviation = average_invoices_per_merchant_standard_deviation
    high_invoice_count = average_invoices_per_merchant + standard_deviation * 2
    group_invoices_by_merchant.map do |merchant|
      if merchant[1].length > high_invoice_count
        @engine.merchants.find_by_id(merchant[0])
      end
    end.compact
  end

  def bottom_merchants_by_invoice_count
    standard_deviation = average_invoices_per_merchant_standard_deviation
    low_invoice_count = average_invoices_per_merchant - standard_deviation * 2
    group_invoices_by_merchant.map do |merchant|
      if merchant[1].length < low_invoice_count
        @engine.merchants.find_by_id(merchant[0])
      end
    end.compact
  end

  def group_by_day
    @engine.invoices.all.group_by do |invoice|
      invoice.created_at.strftime('%A')
    end
  end

  def average_invoices_per_day
    @engine.invoices.all.length / 7
  end

  def invoice_standard_deviation
    average_invoices = average_invoices_per_day
    invoices_by_day = group_by_day
    sum_of_squared_differences = invoices_by_day.inject(0) do |sum, day|
      difference = day[1].length - average_invoices
      sum += (difference**2)
      sum
    end
    quotient = sum_of_squared_differences / 6
    standard_deviation_long = Math.sqrt(quotient)
    BigDecimal(standard_deviation_long, 3).to_f
  end

  def top_days_by_invoice_count
    top_invoice_count = average_invoices_per_day + invoice_standard_deviation
    group_by_day.map do |day|
      day[0] if day[1].length > top_invoice_count
    end.compact
  end

  def invoice_status(status)
    invoices = @engine.invoices.find_all_by_status(status)
    ((invoices.length.to_f / @engine.invoices.all.length.to_f) * 100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
    @engine.transactions.find_all_by_invoice_id(invoice_id).any? do |transaction|
      transaction.result == :success
    end
  end

  def invoice_total(invoice_id)
    invoices = @engine.invoice_items.find_all_by_invoice_id(invoice_id)
    invoices.inject(0) do |total, invoice_item|
      total += invoice_item.quantity * invoice_item.unit_price
      total
    end
  end

  def all_paid_invoices
    @engine.invoices.all.find_all do |invoice|
      invoice_paid_in_full?(invoice.id)
    end
  end
end
