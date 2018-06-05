class Repository
  def initialize
    @repository = []
  end

  def all
    @repository
  end

  def find_by_id(id)
    @repository.find do |element|
      element.id == id
    end
  end

  def delete(id)
    @repository.delete(find_by_id(id))
  end

  def new_id(attributes)
    if attributes[:id].nil?
      @repository[-1].id + 1
    else
      attributes[:id]
    end
  end

  def inspect
    "#<#{self.class} #{@merchants.size} rows>"
  end
end
