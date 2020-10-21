# sqlite> .schema movies
# CREATE TABLE movies (
#   movieId INTEGER PRIMARY KEY,
#   imdbId TEXT NOT NULL,
#   title TEXT NOT NULL,
#   overview TEXT,
#   productionCompanies TEXT,
#   releaseDate TEXT,
#   budget INTEGER,
#   revenue INTEGER,
#   runtime REAL,
#   language TEXT,
#   genres TEXT,
#   status TEXT);
class MoviesIndexOrchestrator
  attr_reader :errors, :results, :limit, :offset

  def initialize(page:, per_page: 50)
    @errors = []
    @results = {}
    sanitize_limit_offset(page, per_page)
  end

  def sanitize_limit_offset(page, per_page)
    page ||= "1"
    if !(page =~ /^\d+$/)
      @errors << "Bad page number '#{page}' provided"
    end
    @offset = (page.to_i * per_page) - 1
    @limit = per_page
  end

  def execute
    return false if errors.present?

    fetcher = MovieFetcher.new(limit: limit, offset: offset)

    if fetcher.get_movies
      @results = { movies: fetcher.results }
    else
      @errors.concat(fetcher.errors)
      false
    end
  end
end
