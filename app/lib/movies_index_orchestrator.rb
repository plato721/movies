# frozen_string_literal: true

class MoviesIndexOrchestrator
  include ActiveModel::Validations

  attr_reader :results, :fetcher_class
  attr_accessor :page, :per_page

  validates :page, numericality: { only_integer: true }
  validates :per_page, numericality: { only_integer: true }

  def initialize(page:, per_page: 50, fetcher_class: nil)
    @page = page || '1'
    @per_page = per_page
    @results = {}
    @fetcher_class = fetcher_class || SqliteMoviesFetcher
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

    fetcher = fetcher_class.new(limit: limit, offset: offset)

    if fetcher.execute
      @results = { movies: fetcher.results }
    else
      errors.add(:fetcher, fetcher.errors.join(', '))
      false
    end
  end
end
