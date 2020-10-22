class MoviesByYearIndexOrchestrator
  include ActiveModel::Validations

  attr_reader :results, :fetcher_class
  attr_accessor :page, :per_page, :year

  validates :page, numericality: { only_integer: true }
  validates :per_page, numericality: { only_integer: true }
  validates :year, numericality: { only_integer: true }

  def initialize(page:, per_page: 50, year: nil, fetcher_class: nil)
    @page = page || "1"
    @per_page = per_page
    @results = {}
    @year = year
    @fetcher_class = fetcher_class || SqliteMoviesByYearFetcher
    validate
  end

  def offset
    (page.to_i * per_page) - 1
  end

  def limit
    per_page
  end

  def execute
    return false if errors.present?

    fetcher = fetcher_class.new(limit: limit, offset: offset, year: year.to_i)
    movies = fetcher.execute
    if !movies
      errors.add(:fetcher, fetcher.errors.join(", "))
      return false
    else
      @results = { movies: movies }
    end
  end
end
