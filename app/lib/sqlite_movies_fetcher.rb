# frozen_string_literal: true

class SqliteMoviesFetcher
  attr_reader :results, :limit, :offset, :errors, :sql_runner, :movies_db,
              :transformer

  def initialize(limit:, offset:, sql_runner: nil, movies_db: nil)
    @movies_db = movies_db || default_movies_db
    @errors = []
    @limit = limit
    @offset = offset
    @sql_runner = sql_runner || SqliteRunner
    @transformer = transformer || MovieArrayTransformer
  end

  def default_movies_db
    SqliteMoviesConnector.get_connector
  end

  def sql
    <<~SQL
      select imdbId, title, genres, releaseDate, budget
      from movies
      limit #{limit}
      offset #{offset}
    SQL
  end

  def execute
    raw_results = sql_runner.execute(
      connector: movies_db,
      sql: sql,
      error_receiver: self
    )
    return if errors.present?

    @results = transformer.execute(raw_results)
  end
end
