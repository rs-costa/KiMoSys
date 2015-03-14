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

class QuicksController < ApplicationController
    
  before_filter :authenticate_user!, except:[:new,:create]
  
  load_and_authorize_resource

  # GET /organisms
  # GET /organisms.json
  def index
    @quicks = Quick.all
  
    unless current_user && current_user.admin
      redirect_to organisms_path, notice: 'User cannot edit this data.'
      return
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @quicks }
    end
    
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
    @quick = Quick.find(params[:id])
        
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @quick }
    end
    
    unless current_user && current_user.admin
      redirect_to organisms_path, notice: 'User cannot edit this data.'
      return
    end
    
  end

  # GET /organisms/new
  # GET /organisms/new.json
  def new
    @quick = Quick.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @quick }
    end
  end

  # GET /organisms/1/edit
  def edit
    @quick = Quick.find(params[:id])
    
    unless current_user && current_user.admin
      redirect_to organisms_path, notice: 'User cannot edit this data.'
      return
    end
  end

  # POST /organisms
  # POST /organisms.json
  def create
    @quick = Quick.create(params[:quick])
    

    respond_to do |format|
      if @quick.save
        # creates temporary user to send email
        # it is not save to the database
        temp_user = User.new
        temp_user.email = @quick.email
        
        build_users(temp_user).each do |u|
          mail = Emailer.notification_quick_submit(u,@quick)
          begin
            mail.deliver
          rescue Exception => e
            logger.error e.to_s
          end  
        end
        format.html { redirect_to organisms_path, notice: 'Your data was succesfully submitted.' }
        format.json { render json: @quick, status: :created, location: @quick }
      else
        format.html { render action: "new" }
        format.json { render json: @quick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @quick = Quick.find(params[:id]) 
    
    unless current_user && current_user.admin
      redirect_to organisms_path, notice: 'User cannot edit this data.'
      return
    end
     
    respond_to do |format|
      if @quick.update_attributes(params[:quick])
        format.html { redirect_to @quick, notice: 'Data was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @quick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisms/1
  # DELETE /organisms/1.json
  def destroy
    @quick= Quick.find(params[:id])
    
    unless current_user && current_user.admin
      redirect_to organisms_path, notice: 'User cannot edit this data.'
      return
    end
    @organism.destroy

    respond_to do |format|
      format.html { redirect_to organisms_url }
      format.json { head :no_content }
    end
  end


end
