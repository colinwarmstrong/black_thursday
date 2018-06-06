require './test/test_helper'
require './lib/sales_engine'
require './lib/sales_analyst'

class SalesAnalystTest < Minitest::Test
  def setup
    sales_data = { items: './mock_data/mock_items.csv',
                   merchants: './mock_data/mock_merchants.csv',
                   customers: './mock_data/mock_customers.csv',
                   invoices: './mock_data/mock_invoices.csv',
                   invoice_items: './mock_data/mock_invoice_items.csv',
                   transactions: './mock_data/mock_transactions.csv' }
    engine = SalesEngine.new
    engine.create_merchant_repository(sales_data)
    engine.create_item_repository(sales_data)
    engine.create_invoice_repository(sales_data)
    engine.create_invoice_item_repository(sales_data)
    engine.create_transaction_repository(sales_data)
    engine.create_customer_repository(sales_data)
    engine.create_sales_analyst(engine)

    @sales_analyst = engine.analyst
  end

  def test_it_exists
    # skip
    assert_instance_of SalesAnalyst, @sales_analyst
  end

  def test_average_items_per_merchant_returns_average_items_per_merchant
    # skip
    expected = @sales_analyst.average_items_per_merchant
    assert_equal 2.88, expected
    assert_instance_of Float, expected
  end

  def test_average_items_per_merchant_standard_deviation_returns_the_standard_deviation
    # skip
    expected = @sales_analyst.average_items_per_merchant_standard_deviation
    assert_equal 3.26, expected
    assert_instance_of Float, expected
  end

  def test_merchants_with_high_item_count_returns_correct_merchants
    # skip
    expected = @sales_analyst.merchants_with_high_item_count
    assert_equal 52, expected.length
    assert_instance_of Merchant, expected.first
  end

  def test_average_item_price_for_merchant_returns_average_item_price_for_merchant
    # skip
    merchant_id = 12334105
    expected = @sales_analyst.average_item_price_for_merchant(merchant_id)
    assert_equal 16.66, expected
    assert_instance_of BigDecimal, expected
  end

  def test_average_average_price_per_merchant_returns_average_item_price
    # skip
    expected = @sales_analyst.average_average_price_per_merchant
    assert_equal 350.29, expected
    assert_instance_of BigDecimal, expected
  end

  def test_golden_items_returns_correct_items
    # skip
    expected = @sales_analyst.golden_items
    assert_equal 5, expected.length
    assert_instance_of Item, expected.first
  end

  def test_average_invoices_per_merchant_returns_average_number_of_invoices
    # skip
    expected = @sales_analyst.average_invoices_per_merchant
    assert_equal 10.49, expected
    assert_instance_of Float, expected
  end

  def test_average_invoices_per_merchant_standard_deviation_finds_std_deviation
    # skip
    expected = @sales_analyst.average_invoices_per_merchant_standard_deviation
    assert_equal 3.29, expected
    assert_instance_of Float, expected
  end

  def test_top_merchants_by_invoice_count_returns_correct_merchants
    # skip
    expected = @sales_analyst.top_merchants_by_invoice_count
    assert_equal 12, expected.length
    assert_instance_of Merchant, expected.first
  end

  def test_bottom_merchants_by_invoice_count_returns_correct_merchants
    # skip
    expected = @sales_analyst.bottom_merchants_by_invoice_count
    assert_equal 4, expected.length
    assert_instance_of Merchant, expected.first
  end

  def test_top_days_by_invoice_count_returns_correct_dats
    # skip
    expected = @sales_analyst.top_days_by_invoice_count
    assert_equal ['Wednesday'], expected
  end

  def test_invoice_status_reuturns_correct_percentage_of_given_status
    # skip
    expected = @sales_analyst.invoice_status(:pending)
    assert_equal 29.55, expected
    expected = @sales_analyst.invoice_status(:shipped)
    assert_equal 56.95, expected
    expected = @sales_analyst.invoice_status(:returned)
    assert_equal 13.50, expected
  end

  def test_SalesAnalystis_paid_in_full_returns_true_if_the_invoice_is_paid_in_full
    # skip
    expected = @sales_analyst.invoice_paid_in_full?(1)
    assert expected

    expected = @sales_analyst.invoice_paid_in_full?(200)
    assert expected

    expected = @sales_analyst.invoice_paid_in_full?(203)
    refute expected

    expected = @sales_analyst.invoice_paid_in_full?(204)
    refute expected
  end

  def test_sales_analyst_total_returns_the_total_dollar_amount_if_the_invoice_is_paid_in_full
    # skip
    expected = @sales_analyst.invoice_total(1)

    assert_equal 21067.77, expected
    assert_equal BigDecimal, expected.class
  end

  def test_total_revenue_by_date_returns_total_revenue_for_given_date
    # skip
    date = Time.parse("2009-02-07")
    expected = @sales_analyst.total_revenue_by_date(date)

    assert_equal 21067.77, expected
    assert_equal BigDecimal, expected.class
  end

  def test_top_revenue_earners_returns_the_top_x_merchants_ranked_by_revenue
    # skip
    expected = @sales_analyst.top_revenue_earners(10)
    first = expected.first
    last = expected.last

    assert_equal 9, expected.length

    assert_equal Merchant, first.class
    assert_equal 12334634, first.id

    assert_equal Merchant, last.class
    assert_equal 12335747, last.id
  end

  def test_top_revenue_earners_returns_by_default_the_top_20_merchants
    # skip
    expected = @sales_analyst.top_revenue_earners
    first = expected.first
    last = expected.last

    assert_equal 20, expected.length

    assert_equal Merchant, first.class
    assert_equal 12334634, first.id

    assert_equal Merchant, last.class
    assert_equal 12334159, last.id
  end

  def test_merchants_ranked_by_revenue_returns_the_merchants_ranked_by_total_revenue
    # skip
    expected = @sales_analyst.merchants_ranked_by_revenue

    assert_equal Merchant, expected.first.class

    assert_equal 12334634, expected.first.id
    assert_equal 12336175, expected.last.id
  end

  def test_merchants_with_pending_invoices_returns_merchants_with_pending_invoices
    # skip
    expected = @sales_analyst.merchants_with_pending_invoices

    assert_equal 467, expected.length
    assert_equal Merchant, expected.first.class
  end

  def test_merchants_with_only_one_item_returns_merchants_with_only_one_item
    # skip
    expected = @sales_analyst.merchants_with_only_one_item

    assert_equal 2, expected.length
    assert_equal Merchant, expected.first.class
  end

  def test_merchants_with_only_one_item_registered_in_month_returns_merchants_with_only_one_invoice_in_given_month
    # skip
    expected = @sales_analyst.merchants_with_only_one_item_registered_in_month("March")

    assert_equal 21, expected.length
    assert_equal Merchant, expected.first.class

    expected = @sales_analyst.merchants_with_only_one_item_registered_in_month("June")

    assert_equal 18, expected.length
    assert_equal Merchant, expected.first.class
  end

  def test_revenue_by_merchant_returns_the_revenue_for_given_merchant
    # skip
    expected = @sales_analyst.revenue_by_merchant(12334194)

    assert_equal BigDecimal.new(expected), expected
    assert_equal BigDecimal, expected.class
  end

  def test_most_sold_item_for_merchant_returns_the_most_sold_item
    # skip
    merchant_id = 12334189
    expected = @sales_analyst.most_sold_item_for_merchant(merchant_id)

    assert expected.map(&:id).include?(263524984)
    assert expected.map(&:name).include?("Adult Princess Leia Hat")
    assert_equal Item, expected.first.class

    merchant_id = 12334768
    expected = @sales_analyst.most_sold_item_for_merchant(merchant_id)

    assert expected.map(&:id).include?(263549386)

    merchant_id = 12337105
    expected = @sales_analyst.most_sold_item_for_merchant(merchant_id)

    assert_equal 4, expected.length
  end

  def test_best_item_for_merchant_returns_the_best_item
    # skip
    merchant_id = 12334189
    expected = @sales_analyst.best_item_for_merchant(merchant_id)

    assert_equal 263516130, expected.id
    assert_equal Item, expected.class

    merchant_id = 12337105
    expected = @sales_analyst.best_item_for_merchant(merchant_id)

    assert_equal 263463003, expected.id
    assert_equal Item, expected.class
  end

  def test_top_buyers_returns_the_top_customers_that_spent_the_most_money
    # skip
    x = 5
    expected = @sales_analyst.top_buyers(5)

    assert_equal 5, expected.length
    assert_equal 313, expected.first.id
    assert_equal 478, expected.last.id

    expected.each { |c| expect(c.class).to eq Customer }
  end

  def test_top_buyers_returns_the_top_20_customers_by_default_if_no_number_is_given
    # skip
    expected = @sales_analyst.top_buyers

    assert_equal 20, expected.length
    assert_equal 313, expected.first.id
    assert_equal 250, expected.last.id

    expected.each { |c| expect(c.class).to eq Customer }
  end

  def test_top_merchant_for_customer_returns_the_favorite_merchant_for_given_customer
    # skip
    customer_id = 100
    expected = @sales_analyst.top_merchant_for_customer(customer_id)

    assert_equal Merchant, expected.class
    assert_equal 12336753, expected.id
  end

  def test_one_time_buyers_returns_customers_with_only_one_invoice
    # skip
    expected = @sales_analyst.one_time_buyers

    assert_equal 76, expected.length
  end

  def test_one_time_buyers_top_item_returns_the_item_bought_by_one_time_buyers
    # skip
    expected = @sales_analyst.one_time_buyers_top_item

    assert_equal 263396463, expected.id
    assert_equal Item, expected.class
  end

  def test_items_bought_in_year_returns_the_correct_items
    # skip
    customer_id = 400
    year = 2000
    expected = @sales_analyst.items_bought_in_year(customer_id, year)

    assert_equal 0, expected.length
    assert_equal Array, expected.class

    customer_id = 400
    year = 2002
    expected = @sales_analyst.items_bought_in_year(customer_id, year)

    assert_equal 2, expected.length
    assert_equal 263549742, expected.first.id
    assert_equal "Necklace: V Tube", expected.first.name
    assert_equal Item, expected.first.class
  end

  def test_highest_volume_items_returns_correct_item
    # skip
    expected = @sales_analyst.highest_volume_items(200)

    assert_equal 0, expected.length
    assert_equal 263420195, expected.first.id
    assert_equal 263448547, expected.last.id
    assert_equal Item, expected.first.class
  end

  def test_customers_with_unpaid_invoices_returns_customers_with_unpaid_invoices
    # skip
    expected = @sales_analyst.customers_with_unpaid_invoices

    assert_equal 786, expected.length
    assert_equal 1, expected.first.id
    assert_equal 999, expected.last.id
    assert_equal Customer, expected.first.class
  end

  def test_best_invoice_by_revenue_returns_the_invoice_with_the_highest_dollar_amount
    # skip
    expected = @sales_analyst.best_invoice_by_revenue

    assert_equal 3394, expected.id
    assert_equal Invoice, expected.class
  end

  def test_best_invoice_by_quantity_returns_the_invoice_with_the_highest_item_count
    # skip
    expected = @sales_analyst.best_invoice_by_quantity

    assert_equal 1281, expected.id
    assert_equal Invoice, expected.class
  end
end
