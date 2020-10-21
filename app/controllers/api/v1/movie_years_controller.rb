class Api::V1::MovieYearsController < ApplicationController
  def index
    orchestrator = MoviesYearOrchestrator.new(page: params[:page], year: params[:year])
    if orchestrator.execute
      render json: orchestrator.results, status: :ok
    else
      render json: orchestrator.errors, status: :bad_request
    end
  end
end
