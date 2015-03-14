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

class AuthorizationsController < ApplicationController
  respond_to :html
  before_filter :find_authorizable
  
  def new
    @authorizable = find_authorizable
    @authorization = @authorizable.authorizations.build()
    
    unless @authorizable.can_edit?(current_user)
      redirect_to [@organism,@authorizable], notice: "User cannot edit this #{@authorizable.class.model_name.human.downcase}."
      return
    end
    
    respond_with([@authorization])
  end
  
  def create
    @authorizable = find_authorizable
    @authorization = Authorization.new(params[:authorization])
    @authorization.authorizable = @authorizable
    
    unless @authorizable.can_edit?(current_user)
      redirect_to [@organism,@authorizable], notice: "User cannot edit this #{@authorizable.class.model_name.human.downcase}."
      return
    end

    respond_with do |format|
      if @authorization.save
        mail = Emailer.notification_invite_user_to_associated_model(@authorization.user,@authorizable,@authorization.user,current_user,@organism)
        begin
          mail.deliver
        rescue Exception => e
          logger.error e.to_s
        end  
        
        format.html { redirect_to [@organism,@authorizable], notice: "User '#{@authorization.user.email_dot}' was successfully associated." }
        format.json { render json: [@organism,@authorizable], status: :created, location: [@authorization] }
      else
        format.html { render action: "new" }
        format.json { render json: @authorization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @authorizable = find_authorizable

    @authorization = Authorization.find(params[:id])
    @authorization.destroy

    redirect_to [@organism,@authorizable]
  end
  
  
  private
  
  def find_authorizable
    @organism = Organism.find( params[:organism_id])
    params.each do |name, value|
      next if name == "organism_id"
      if name =~ /(.+)_id$/ 
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
  
end
