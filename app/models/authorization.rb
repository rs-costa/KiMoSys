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

class Authorization < ActiveRecord::Base
  attr_accessible :user_id, :authorizable_id, :authorizable_type, :email
  
  attr_accessor :email
 
  belongs_to :user
  belongs_to :authorizable, :polymorphic => true
  
  validates_uniqueness_of :user_id, :scope => [:authorizable_id,:authorizable_type]
  validate :validate_user_email
  validates :authorizable, :presence => {:message => 'Group must not be empty. contact site administrator.'} 

  def email=(value)
    self.user = User.where( User.arel_table[:email].eq(value)).uniq.first
  end
  
  def user_email
    return nil if user.nil?
    user.email 
  end

  private
    def validate_user_email
      self.user.nil? || self.authorizable.user == self.user 
      errors.add(:email, "User does not exist.") if self.user.nil?
      errors.add(:email, "User is already owner of #{self.authorizable.model_name.downcase}.") if self.authorizable.user == self.user
    end
end
