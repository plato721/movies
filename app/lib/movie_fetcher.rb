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
class MovieFetcher
  attr_reader :results, :limit, :offset, :errors

  def initialize(connection: nil, limit:, offset:)
    @connection ||= default_connector
    @errors = []
    @limit = limit
    @offset = offset
  end

  def default_connector
    SqliteMoviesConnector.get_connector
  end

  def get_movies_sql
    <<~SQL
      select imdbId, title, genres, releaseDate, budget
      from movies
    SQL
  end

  def get_movies_year_sql(year)
    get_movies_sql +
    "where releaseDate like '#{year}%'"
  end

  def limit_offset_sql
    <<~SQL
      limit #{limit}
      offset #{offset}
    SQL
  end

  def get_movies_year(year)
    sql = get_movies_year_sql(year) + limit_offset_sql
    @results = results_to_hash( @connection.execute(sql) )
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    @errors << "Retrieval error"
  end

  def get_movies
    sql = get_movies_sql + limit_offset_sql
    @results = results_to_hash( @connection.execute(sql) )
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    @errors << "Retrieval error"
  end

  def results_to_hash(results)
    results.map do |row|
      {
        imdbId: row[0],
        title: row[1],
        genres: row[2],
        releaseDate: row[3],
        budget: row[4]
      }
    end
  end
end
