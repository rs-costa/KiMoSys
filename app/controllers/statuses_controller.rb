class StatusesController < ApplicationController
  before_filter :get_status, except: [:index]
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @unreviewed = Status.where(is_reviewed: false).collect do |obj|
      if obj.statusable.is_public?
        obj
      else
        nil
      end
    end.compact
    @reviewed = Status.where is_reviewed: true
  end

  def reviewed
    @status.transaction do
      @status.is_reviewed = true
      @status.comment = "aprove!"
      @status.user = current_user
      @status.save
    end
    case @status.statusable.class.model_name
      when Organism.model_name
        redirect_to @status.statusable, notice: "Status was successfully reviewed"
      when AssociatedModel.model_name
        if @status.statusable.organisms.count > 0
          redirect_to [@status.statusable.organisms.first,@status.statusable], notice: "Status was successfully reviewed"
        else
          redirect_to root_path, notice: "Status was successfully reviewed"
        end
      end
  end

  def edit
  end

  def update
    respond_to do |format|
      @status.user = current_user
      if @status.update_attributes(params[:status])
        format.html {
          case @status.statusable.class.model_name
            when Organism.model_name
              redirect_to @status.statusable, notice: "Status was successfully updated"
            when AssociatedModel.model_name
              if @status.statusable.organisms.count > 0
                redirect_to [@status.statusable.organisms.first,@status.statusable], notice: 'Status was successfully updated.'
              else
                redirect_to root_path, notice: "Status was successfully reviewed"
              end
          end
        }
        format.json { head :no_content }
      else
        format.html { render  "edit" }
        format.json { render json: [@status].errors, status: :unprocessable_entity }
      end
    end

  end

  protected

  def get_status
    @status = Status.find( params[:id] )
  end

end
