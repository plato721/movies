require 'rails_helper'

RSpec.describe 'Api::V1::Movies', type: :request do
  it "gets the movies" do
    get '/api/v1/movies', params: { page: 1 }

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    movies = body["movies"]
    expect(movies.count).to eq(50)

    movie = movies[0]
    expected_keys = ["imdbId", "title", "genres", "releaseDate", "budget"]
    expect(movie.keys).to match_array(expected_keys)
  end

  it "fails on a bad page" do
    get '/api/v1/movies', params: { page: "not a number" }

    expect(response).to have_http_status(400)
  end
end
