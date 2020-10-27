class MoviesShowOrchestrator
  attr_accessor :id, :errors
  attr_reader :result, :fetch_class

  def initialize(id:, fetch_class: nil)
    @id = id
    @result = {}
    @errors = []
    @fetch_class = fetch_class || SqliteMovieFetcher
  end

  def execute
    return false if errors.present?

    fetcher = fetch_class.new(id: id)

    if fetcher.execute
      @result = { movie: fetcher.result }
    else
      self.errors = fetcher.errors
      false
    end
  end
end
