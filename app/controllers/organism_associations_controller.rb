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

class OrganismAssociationsController < ApplicationController
  before_filter :get_organism
  
  def index
    respond_to do |format|
      format.html { redirect_to [@organism], notice: 'Association was successfully created.' }
      format.json { render json: [@organism] }
    end
  end
  
  def new
    @association = @organism.organism_associations.build(params[:organism_association])
    
    unless @organism.is_admin?(current_user)
      redirect_to organisms_path, notice: "You don't have permissions to add users."
      return
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: [@association] }
    end  
  end
  
  def create
    @association = @organism.organism_associations.build(params[:organism_association])
    
    unless @organism.is_admin?(current_user)
      redirect_to organisms_path, notice: "You don't have permissions to add users."
      return
    end

    respond_to do |format|
      if @association.save
        mail = Emailer.notification_invite_user_to_organism(@association.user,@organism,@association.user,current_user)
        begin
          mail.deliver
        rescue Exception => e
          logger.error e.to_s
        end  
        
        format.html { redirect_to [@organism], notice: "User '#{@association.user.email_dot}' was successfully associated with this data." }
        format.json { render json: [@organism], status: :created, location: [@association] }
      else
        format.html { render action: "new" }
        format.json { render json: @association.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @association = OrganismAssociation.find(params[:id])
    
    unless @organism.is_admin?(current_user)
      redirect_to organisms_path, notice: "You don't have permissions to add users."
      return
    end
    
    @association.destroy

    respond_to do |format|
      format.html { redirect_to organism_path(@organism) }
      format.json { head :no_content }
    end
  end
  
  
  private
  
  def get_organism
    @organism = Organism.find(params[:organism_id])
  end
  
end
