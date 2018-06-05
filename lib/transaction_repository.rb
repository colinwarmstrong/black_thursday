require_relative 'transaction'

class TransactionRepository < Repository
  def find_all_by_invoice_id(invoice_id)
    @repository.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def find_all_by_credit_card_number(credit_card_number)
    @repository.find_all do |transaction|
      transaction.credit_card_number == credit_card_number
    end
  end

  def find_all_by_result(result)
    @repository.find_all do |transaction|
      transaction.result == result
    end
  end

  def create(attributes)
    attributes[:id] = new_id(attributes)
    new_transaction = Transaction.new(attributes)
    @repository << new_transaction
    new_transaction
  end

  def update(id, attributes)
    if find_by_id(id).nil?
      return
    else
      transaction = find_by_id(id)
      transaction.credit_card_number = attributes[:credit_card_number] unless attributes[:credit_card_number].nil?
      transaction.credit_card_expiration_date = attributes[:credit_card_expiration_date] unless attributes[:credit_card_expiration_date].nil?
      transaction.result = attributes[:result] unless attributes[:result].nil?
      transaction.updated_at = Time.now
    end
  end
end
