class Api::V1::MoviesByYearController < ApplicationController
  def index
    orchestrator = MoviesByYearIndexOrchestrator
                     .new(page: params[:page], year: params[:year])
    if orchestrator.execute
      render json: orchestrator.results, status: :ok
    else
      render json: orchestrator.errors, status: :bad_request
    end
  end
end
