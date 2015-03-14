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

module AssociatedModelsHelper

  def goto_biomodel(search)
    regexp = /BIOMD[[:digit:]]+/
    result = regexp.match( search )

    if search.blank?
      ""
    elsif result.present? && result[0] == search
      link_to search, "http://www.ebi.ac.uk/biomodels-main/" + URI.escape(search), class: "blue link_out", title: "access to the original BioModels model (source)", target: "_blank" 
    else
      link_to search, "http://jjj.bio.vu.nl:8080/models/" + URI.escape(search), class: "blue link_out", title: "access to the original JWS model (source)" , target: "_blank"
    end
      
  end

end
