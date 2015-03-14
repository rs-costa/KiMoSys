class AttachedFilesController < ApplicationController
  
  before_filter :authenticate_user!, except: :download
  
  # GET /articles/new
  # GET /articles/new.json
  def new
    @attachable = find_attachable
    
    @attached_file = @attachable.attachables.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attached_file }
    end
  end
  
  def download
    @attachable = find_attachable
    @attached_file = AttachedFile.find(params[:id])
    
    send_file @attached_file.src.path,
            :filename => @attached_file.src_file_name,
            :type => @attached_file.src_content_type,
            :disposition => 'attachment'
  end
  
  # POST /articles
  # POST /articles.json
  def create
    @attachable = find_attachable
    @attached_file = @attachable.attachables.build(params[:attached_file])

    respond_to do |format|
      if @attached_file.save
        format.html { redirect_to [@attachable], notice: 'Attached file was successfully created.' }
        format.json { render json: @attachable, status: :created, location: @attachable }
      else
        format.html { render action: "new" }
        format.json { render json: @attached_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @attachable = find_attachable
    @attached_file = AttachedFile.find(params[:id])
    @attached_file.destroy

    respond_to do |format|
      format.html { redirect_to [@attachable], notice: "Model was successfully removed" }
      format.json { head :no_content }
    end
  end
  
  private

  def find_attachable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
end
