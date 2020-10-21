class MoviesYearOrchestrator
  attr_reader :errors, :results, :limit, :offset

  def initialize(page:, per_page: 50, year: nil)
    @errors = []
    @results = {}
    sanitize_limit_offset(page, per_page)
    @year = sanitize_year(year)
  end

  def sanitize_limit_offset(page, per_page)
    page ||= "1"
    if !(page =~ /^\d+$/)
      @errors << "Bad page number '#{page}' provided"
    end
    @offset = (page.to_i - 1) * per_page
    @limit = per_page # not coming from user right now
  end

  def sanitize_year(year)
    @errors << "Year is required" unless year.present?
    if !(year =~ /^\d+$/)
      @errors << "Bad year '#{year}' provided"
    else
      year.to_i
    end
  end

  def execute
    return false if errors.present?
    fetcher = MovieFetcher.new(limit: limit, offset: offset)
    movies = fetcher.get_movies_year(@year)
    if !movies
      @errors.concat(fetcher.errors)
      return false
    else
      @results = { movies: movies }
    end
  end
end
