class MoviesShowOrchestrator
  include ActiveModel::Validations

  attr_accessor :id
  attr_reader :result, :fetch_class

  validates :id, numericality: { only_integer: true }

  def initialize(id:, fetch_class: nil)
    @id = id
    @result = {}
    @fetch_class = fetch_class || SqliteMovieFetcher
    validate
  end

  def execute
    return false if errors.present?

    fetcher = fetch_class.new(id: id)

    if fetcher.execute
      @result = { movie: fetcher.result }
    else
      errors.add(:fetcher, fetcher.errors.join(", "))
      false
    end
  end
end
