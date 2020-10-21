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
    # TODO - move
    @connection = SQLite3::Database.new('./db/movies.db')
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
    get_movies
  end

  def get_movies_sql
    <<~SQL
      select imdbId, title, genres, releaseDate, budget
      from movies
      limit #{limit}
      offset #{offset}
    SQL
  end

  def get_movies
    @results[:movies] =  @connection.execute(get_movies_sql).map do |row|
      {
        imdbId: row[0],
        title: row[1],
        genres: row[2],
        releaseDate: row[3],
        budget: row[4]
      }
    end
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.error}\n#{backtrace}" }
    @errors << "Retrieval error"
  end
end
