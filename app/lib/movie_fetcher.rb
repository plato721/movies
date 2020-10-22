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
  attr_reader :results, :limit, :offset, :errors, :sql_runner, :movies_db

  def initialize(movies_db: nil, limit:, offset:, sql_runner: nil)
    @movies_db = movies_db || default_movies_db
    @errors = []
    @limit = limit
    @offset = offset
    @sql_runner = sql_runner || SqliteRunner
  end

  def default_movies_db
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
    raw_results = sql_runner.execute(
      connector: movies_db,
      sql: sql,
      error_receiver: self
    )
    return if errors.present?

    @results = results_to_hash( raw_results )
  end

  def get_movies
    sql = get_movies_sql + limit_offset_sql
    raw_results = sql_runner.execute(
      connector: movies_db,
      sql: sql,
      error_receiver: self
    )
    return if errors.present?

    @results = results_to_hash( raw_results )
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
