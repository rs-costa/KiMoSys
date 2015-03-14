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

class OrganismsController < ApplicationController

  before_filter :authenticate_user!, except:[:index, :show, :download, :download_all]
  before_filter :get_organism, except: [:index,:new,:create,:my_organisms]
  load_and_authorize_resource

  # GET /organisms
  # GET /organisms.json
  def index
  	@organisms = Organism.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisms }
    end
  end

  def my_organisms
    @organisms = Organism.user_organisms(current_user)
    respond_to do |format|
      format.html
      format.json { render json: @organisms }
    end
  end

  def download_all

    new_zip = Tempfile.new(["result",".zip"])
    new_zip_path = new_zip.path
    new_zip.close!

    Zip::ZipFile.open( new_zip_path, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(@organism.article_file_name, @organism.article.path) if @organism.article.present? && can?(:see_id, @organism)
      zipfile.add(@organism.parameters_file_name, @organism.parameters.path) if @organism.parameters.present?
      @organism.attached_files.each do |a|
        zipfile.add a.src_file_name, a.src.path if a.src.present?
      end

    end

    send_file new_zip_path,
            :filename => "KIMODATAID#{@organism.id}_all.zip",
            :disposition => 'attachment'
  end

  def download

    send_file @organism.parameters.path,
            :filename => @organism.parameters_file_name,
            :type => @organism.parameters_content_type,
            :disposition => 'attachment'
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
	  @associated_models = @organism.associated_models
    @list_users = @organism.organism_associations.delete_if{|ass| ass.user.id == @organism.user.id}

    respond_to do |format|
      format.html # show.html.erb
      format.csv {
      	output = render_to_string :csv => @organism
        send_data output, :filename => @organism.id.to_s + '.csv'
      }
      format.json { render json: @organism }
    end
  end

  # GET /organisms/new
  # GET /organisms/new.json
  def new
    @organism = Organism.new
    @organism.attached_files.build
    @organism.visibility = Organism::VISIBILITY[:private]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/1/edit
  def edit
    @organism.attached_files.build
    @list_users = @organism.organism_associations.delete_if{|ass| ass.user.id == @organism.user.id}
    authorize! :edit, @organism
  end

  # POST /organisms
  # POST /organisms.json
  def create
	  @organism = Organism.create(params[:organism])
	  @organism.user = current_user if current_user
	  @organism.user_email = current_user.email if current_user
	  respond_to do |format|
		  if @organism.save
			  build_users(@organism.user).each do |u|
			    mail = Emailer.notification_new_organism(u,@organism)
			    begin
            mail.deliver
          rescue Exception => e
            logger.error e.to_s
          end
			  end
        format.html { redirect_to @organism, notice: 'Data was successfully submitted.' }
        format.json { render json: @organism, status: :created, location: @organism }
      else
        format.html { render action: "new" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @list_users = @organism.organism_associations.delete_if{|ass| ass.user.id == @organism.user.id}
    unless @organism.can_edit?(current_user)
  		redirect_to organisms_path, notice: 'User cannot edit this data.'
  		return
  	end
	  @organism.user = current_user if @organism.user.nil? && current_user
    respond_to do |format|
      if @organism.update_attributes(params[:organism])

        format.html { redirect_to @organism, notice: 'Data was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisms/1
  # DELETE /organisms/1.json
  def destroy

    unless @organism.can_remove?(current_user,true)
  		redirect_to organisms_path, notice: 'User cannot edit this data.'
  		return
	  end
    @organism.destroy

    respond_to do |format|
      format.html { redirect_to organisms_url }
      format.json { head :no_content }
    end
  end

  private

  def get_organism
    @organism = Organism.find(params[:id])
  end

end
