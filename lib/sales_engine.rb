require_relative 'repository'
require_relative 'merchant_repository'
require_relative 'item_repository'
require_relative 'invoice_repository'
require_relative 'invoice_item_repository'
require_relative 'transaction_repository'
require_relative 'customer_repository'
require_relative 'sales_analyst'
require 'bigdecimal'
require 'bigdecimal/util'
require 'time'
require 'csv'

class SalesEngine
  attr_reader :merchants,
              :items,
              :invoices,
              :invoice_items,
              :transactions,
              :customers,
              :analyst

  def self.from_csv(sales_data)
    engine = SalesEngine.new
    engine.create_merchant_repository(sales_data)
    engine.create_item_repository(sales_data)
    engine.create_invoice_repository(sales_data)
    engine.create_invoice_item_repository(sales_data)
    engine.create_transaction_repository(sales_data)
    engine.create_customer_repository(sales_data)
    engine.create_sales_analyst(engine)
    return engine
  end

  def parse_data(data_file)
    CSV.open(data_file, headers: true, header_converters: :symbol)
  end

  def create_merchant_repository(sales_data)
    @merchants = MerchantRepository.new
    merchant_data = parse_data(sales_data[:merchants])
    merchant_data.each do |merchant|
      @merchants.create(id: merchant[:id],
                        name: merchant[:name],
                        created_at: Time.parse(merchant[:created_at]),
                        updated_at: Time.parse(merchant[:updated_at]))
    end
  end

  def create_item_repository(sales_data)
    @items = ItemRepository.new
    item_data = parse_data(sales_data[:items])
    item_data.each do |item|
      @items.create(id: item[:id],
                    name: item[:name],
                    description: item[:description],
                    unit_price: item[:unit_price],
                    merchant_id: item[:merchant_id],
                    created_at: Time.parse(item[:created_at]),
                    updated_at: Time.parse(item[:updated_at]))
    end
  end

  def create_invoice_repository(sales_data)
    @invoices = InvoiceRepository.new
    invoice_data = parse_data(sales_data[:invoices])
    invoice_data.each do |invoice|
      @invoices.create(id: invoice[:id],
                       customer_id: invoice[:customer_id],
                       merchant_id: invoice[:merchant_id],
                       status: invoice[:status],
                       created_at: Time.parse(invoice[:created_at]),
                       updated_at: Time.parse(invoice[:updated_at]))
    end
  end

  def create_invoice_item_repository(sales_data)
    @invoice_items = InvoiceItemRepository.new
    invoice_item_data = parse_data(sales_data[:invoice_items])
    invoice_item_data.each do |invoice_item|
      @invoice_items.create(id: invoice_item[:id],
                            item_id: invoice_item[:item_id],
                            invoice_id: invoice_item[:invoice_id],
                            quantity: invoice_item[:quantity],
                            unit_price: invoice_item[:unit_price],
                            created_at: Time.parse(invoice_item[:created_at]),
                            updated_at: Time.parse(invoice_item[:updated_at]))
    end
  end

  def create_transaction_repository(sales_data)
    @transactions = TransactionRepository.new
    transaction_data = parse_data(sales_data[:transactions])
    transaction_data.each do |transaction|
      @transactions.create(id: transaction[:id],
                           invoice_id: transaction[:invoice_id],
                           credit_card_number: transaction[:credit_card_number],
                           credit_card_expiration_date: transaction[:credit_card_expiration_date],
                           result: transaction[:result],
                           created_at: Time.parse(transaction[:created_at]),
                           updated_at: Time.parse(transaction[:updated_at]))
    end
  end

  def create_customer_repository(sales_data)
    @customers = CustomerRepository.new
    customer_data = parse_data(sales_data[:customers])
    customer_data.each do |customer|
      @customers.create(id: customer[:id],
                        first_name: customer[:first_name],
                        last_name: customer[:last_name],
                        created_at: Time.parse(customer[:created_at]),
                        updated_at: Time.parse(customer[:updated_at]))
    end
  end

  def create_sales_analyst(engine)
    @analyst = SalesAnalyst.new(engine)
  end
end
