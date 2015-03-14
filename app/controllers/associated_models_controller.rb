# KiMoSys - web-based platform for Kinetic Models of biological Systems.
# Copyright (C) 2013-2013 Rafael Costa

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of

# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software


# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

require 'zip/zip'

class AssociatedModelsController < ApplicationController

  before_filter :authenticate_user!, except:[:index, :show, :download_all]
  before_filter :get_associated_model, except:[:index,:new,:create,:associate]
  before_filter :get_associated_model_by_id, only:[:associate]

  load_and_authorize_resource

  # GET /associated_models
  # GET /associated_models.json
  def index
    @organism = Organism.find(params[:organism_id])
    redirect_to organism_path(@organism)
  end

  # GET /associated_models/1
  # GET /associated_models/1.json
  def show
    @oma = OrganismsAssociatedModel.where(organism_id: @organism.id,associated_model_id: @associated_model.id).first
    @list_users = @associated_model.authorizations.delete_if{|ass| ass.user.id == @associated_model.user.id}

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: [@organism,@associated_model] }
    end
  end

  def download_all

    new_zip = Tempfile.new(["result",".zip"])
    new_zip_path = new_zip.path
    new_zip.close!

    Zip::ZipFile.open( new_zip_path, Zip::ZipFile::CREATE) do |zipfile|
      @associated_model.organisms.each do |o|
        next if !can?(:show,o ) || !(@organism.can_edit?(current_user) || @organism.is_public)
        #
        zipfile.add(File.join("KIMODATAID_#{o.id}",o.article_file_name), o.article.path) if o.article.present? && can?(:see_id,o)
        zipfile.add(File.join("KIMODATAID_#{o.id}",o.parameters_file_name), o.parameters.path) if o.parameters.present?
        #
        o.attached_files.sort_by(&:created_at).each do |a|
          zipfile.add File.join("KIMODATAID_#{o.id}",a.src_file_name), a.src.path if a.src.present?
        end
        #
      end
      # adds article
      zipfile.add(@associated_model.sbml_file_name, @associated_model.sbml.path) if @associated_model.sbml.present? && can?(:see_id,@associated_model)
      # adds only latest version
      #  if is public or user has permission to edit it
      if (@associated_model.can_edit?(current_user) || @associated_model.is_public)
        latest = @associated_model.articles.sort_by(&:created_at).last
        zipfile.add(latest.file_file_name, latest.file.path) if (!latest.nil? && latest.present?)

        # write history to folder
        articles = @associated_model.articles.sort_by(&:created_at)

        articles.each_with_index do |a,i|
          zipfile.add File.join("model_history", "#{i == (articles.size - 1) ? 'LATEST' : "1." + i.to_s}-" + a.file_file_name ), a.file.path
        end
      end

    end

    send_file new_zip_path,
            :filename => "KIMOMODELID#{@associated_model.id}_all.zip",
            :disposition => 'attachment'
  end

  def associate
    @oma = @associated_model.add_organism( @organism, current_user, false)
    @oma.user_email = @oma.user.email if @oma.user

    authorize! :edit, @organism, message: 'User does not have permission to associate model to this AccessId.'

    if @oma.save
      send_email
      redirect_to [@organism,@associated_model], notice: "This model was successfully associated with Data EntryID #{@organism.id}"
    else
      render :new
    end
  end

  # GET /associated_models/new
  # GET /associated_models/new.json
  def new
    @organism = Organism.find(params[:organism_id])

    @associated_model = @organism.associated_models.build(params[:associated_model])
    @associated_model.articles.build
    @associated_model.user = current_user
    @list_users = []
    @associated_model.visibility = AssociatedModel::VISIBILITY[:private]

    if params[:manuscript_title].present?
      param1 = params[:manuscript_title]
    else
      param1 = @associated_model.manuscript_title
    end

    if params[:pubmed_id].present?
      param2 = params[:pubmed_id]
    else
      param2 = @associated_model.pubmed_id
    end

    param1 = "" if param1.nil?
    param2 = "" if param2.nil?

    @duplicate_list = AssociatedModel.similar( param1.strip, param2.strip )

    # duplicate models already associated is handled in view
    #models_in_organism = @organism.associated_models.map(&:id)
    #@duplicate_list = @duplicate_list.reject do |dup|
    #  models_in_organism.include?(dup.id)
    #end

    respond_to do |format|
      format.html # new.html.erb
      format.js # new.html.erb
      format.json { render json: [@organism,@associated_model] }
    end
  end

  # GET /associated_models/1/edit
  def edit
    @list_users = @associated_model.authorizations.delete_if{|ass| ass.user.id == @associated_model.user.id}
  end

  # POST /associated_models
  # POST /associated_models.json
  def create
    @organism = Organism.find(params[:organism_id])
    @associated_model = @organism.associated_models.build(params[:associated_model])
    @associated_model.add_organism( @organism, current_user)
    @list_users = []

    respond_to do |format|
      if @associated_model.valid?
        @associated_model.save
        send_email
        format.html { redirect_to [@organism,@associated_model], notice: 'Associated model was successfully created.' }
        format.json { render json: [@organism,@associated_model], status: :created, location: [@organism,@associated_model] }
      else
        format.html { render :new }
        format.json { render json: [@organism,@associated_model].errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /associated_models/1
  # PUT /associated_models/1.json
  def update
    @list_users = @associated_model.authorizations.delete_if{|ass| ass.user.id == @associated_model.user.id}

    respond_to do |format|
      if @associated_model.update_attributes(params[:associated_model])
        format.html { redirect_to [@organism,@associated_model], notice: 'Associated model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render  "edit" }
        format.json { render json: [@organism,@associated_model].errors, status: :unprocessable_entity }
      end
    end


  end

  # DELETE /associated_models/1
  # DELETE /associated_models/1.json
  def destroy

    @oma = @associated_model.organisms_associated_models.where( organism_id: @organism.id )
    @oma.first.destroy

    respond_to do |format|
      format.html { redirect_to organism_path(@organism) }
      format.json { head :no_content }
    end
  end

  private

  def get_associated_model
    @organism = Organism.find(params[:organism_id])
    @associated_model = @organism.associated_models.find(params[:id])
  end

  def get_associated_model_by_id
    @associated_model = AssociatedModel.find(params[:id])
    @organism = Organism.find(params[:organism_id])
  end

  def send_email
    @oma = @associated_model.organisms_associated_models.where( organism_id: @organism.id ).first
    build_users(@oma.user).each do |u|
      mail = Emailer.notification_new_associated_model(u,@associated_model,@organism)
      begin
        mail.deliver
      rescue Exception => e
        logger.error e.to_s
      end
    end

  end
end
