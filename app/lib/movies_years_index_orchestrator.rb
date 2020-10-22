class MoviesYearsIndexOrchestrator
  include ActiveModel::Validations

  attr_reader :results
  attr_accessor :page, :per_page, :year

  validates :page, numericality: { only_integer: true }
  validates :per_page, numericality: { only_integer: true }
  validates :year, numericality: { only_integer: true }

  def initialize(page:, per_page: 50, year: nil)
    @page = page || "1"
    @per_page = per_page
    @results = {}
    @year = year
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

    fetcher = MovieFetcher.new(limit: limit, offset: offset)
    movies = fetcher.get_movies_year(year.to_i)
    if !movies
      errors.add(:fetcher, fetcher.errors.join(", "))
      return false
    else
      @results = { movies: movies }
    end
  end
end
