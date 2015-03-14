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

class ArticlesController < ApplicationController
  
  
  before_filter :authenticate_user!, except: :download
  
  # GET /articles/new
  # GET /articles/new.json
  def new
    @organism = Organism.find(params[:organism_id])
    @associated_model = AssociatedModel.find(params[:associated_model_id])
    @article = @associated_model.articles.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end
  
  def download
    @organism = Organism.find(params[:organism_id])
    @associated_model = AssociatedModel.find(params[:associated_model_id])
    @article = Article.find(params[:id])
    
    send_file @article.file.path,
            :filename => @article.file_file_name,
            :type => @article.file_content_type,
            :disposition => 'attachment'
  end
  
  # POST /articles
  # POST /articles.json
  def create
    @organism = Organism.find(params[:organism_id])
    @associated_model = AssociatedModel.find(params[:associated_model_id])
    @article = @associated_model.articles.build(params[:article])

    respond_to do |format|
      if @article.save
        format.html { redirect_to [@organism,@associated_model], notice: 'Model version was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @organism = Organism.find(params[:organism_id])
    @associated_model = AssociatedModel.find(params[:associated_model_id])
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to [@organism,@associated_model], notice: "Model was successfully removed" }
      format.json { head :no_content }
    end
  end
end
