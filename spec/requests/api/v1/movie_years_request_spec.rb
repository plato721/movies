require 'rails_helper'

RSpec.describe "Api::V1::MovieYears", type: :request do
  def year_from_release_date(date)
    DateTime.parse(date).year
  end

  it "gets the movies from 1996" do
    get '/api/v1/movie_years', params: { page: 1, year: 1996 }

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    movies = body["movies"]
    expect(movies.count).to eq(50)

    movie = movies[0]
    expected_keys = ["imdbId", "title", "genres", "releaseDate", "budget"]
    expect(movie.keys).to match_array(expected_keys)

    correct_year = movies.all? do |movie|
      1996 == year_from_release_date(movie["releaseDate"])
    end
  end

  it "fails on a bad year" do
    get '/api/v1/movie_years', params: { page: "8", year: "not really a year" }

    expect(response).to have_http_status(400)
  end
end
