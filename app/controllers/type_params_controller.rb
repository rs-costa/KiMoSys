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

class TypeParamsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /type_params
  # GET /type_params.json
  def index
    @type_params = TypeParam.all

    authorize! :index, Ability

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @type_params }
    end
  end

  # GET /type_params/1
  # GET /type_params/1.json
  def show
    @type_param = TypeParam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @type_param }
    end
  end

  # GET /type_params/new
  # GET /type_params/new.json
  def new
    @type_param = TypeParam.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @type_param }
    end
  end

  # GET /type_params/1/edit
  def edit
    @type_param = TypeParam.find(params[:id])
  end

  # POST /type_params
  # POST /type_params.json
  def create
    @type_param = TypeParam.new(params[:type_param])

    respond_to do |format|
      if @type_param.save
        format.html { redirect_to @type_param, notice: 'Type param was successfully created.' }
        format.json { render json: @type_param, status: :created, location: @type_param }
      else
        format.html { render action: "new" }
        format.json { render json: @type_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /type_params/1
  # PUT /type_params/1.json
  def update
    @type_param = TypeParam.find(params[:id])

    respond_to do |format|
      if @type_param.update_attributes(params[:type_param])
        format.html { redirect_to @type_param, notice: 'Type param was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @type_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type_params/1
  # DELETE /type_params/1.json
  def destroy
    @type_param = TypeParam.find(params[:id])
    @type_param.destroy

    respond_to do |format|
      format.html { redirect_to type_params_url }
      format.json { head :no_content }
    end
  end
end
