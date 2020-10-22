class MovieArrayTransformer
  class << self
    def movie_keys
      %i(imdbId title genres releaseDate budget)
    end

    def execute(results)
      results.map do |row|
        hashed_row = movie_keys.zip(row).to_h
        transform(hashed_row)
      end
    end

    def transform(hashed_row)
      budget = hashed_row[:budget]
      budget = budget / 100 rescue 0
      hashed_row[:budget] = "$#{budget.to_s(:delimited)}"
      hashed_row
    end
  end
end
