class << ActiveRecord::Base
  def paginated_each(options = {}, &block)
    page = 1
    records = [nil]
    until records.empty? do 
      records = paginate(options.update(:page => page, :count => {:select => '*'}))
      records.each &block
      page += 1
    end
  end
end