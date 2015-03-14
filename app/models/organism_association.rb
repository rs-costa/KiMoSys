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

class OrganismAssociation < ActiveRecord::Base
  self.table_name = "associations"

  attr_accessible :organism_id, :user_id, :email
  
  attr_accessor :email
  
  belongs_to :organism
  belongs_to :user
   
  validates_uniqueness_of :user_id, :scope => [:organism_id]
  validate :validate_user_email
  validates :organism, :presence => {:message => 'Group must not be empty. contact site administrator.'} 
   
  def email=(value)
    self.user = User.where( User.arel_table[:email].eq(value)).uniq.first
  end
  
  def user_email
    return nil if user.nil?
    user.email 
  end
  
  private
    def validate_user_email
      self.user.nil? || self.organism.user == self.user 
      errors.add(:email, "User does not exist.") if self.user.nil?
      errors.add(:email, "User is already owner of the organism.") if self.organism.user == self.user
    end
end