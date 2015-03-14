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

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::Unauthorized do |exception|
    if request.referer.nil? || request.referer.blank? 
      redirect_to root_url, :alert => exception.message
    else
      redirect_to request.referer, :alert => exception.message
    end
  end
  
  def build_users(user)
    users = [user]
    users += User.where(admin: true)
    users.compact
  end
end
