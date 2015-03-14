class ReviewJournalsController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @journals = ReviewJournal.all

    authorize! :index, Ability

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @journals }
    end
  end

end
