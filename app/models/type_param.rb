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

class TypeParam < ActiveRecord::Base
  attr_accessible :title, :type_small
  
  attr_accessible :image
  has_attached_file :image, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"
  
  validates_presence_of :title,:type_small
  validates_attachment :image, :presence => true
  
end
