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

module OrganismsHelper


  def type_param_menu_class(value)
    TypeParam.where(:type_small => value).map {|el| "menu_#{el.id}" }.join(" ")
  end

  # internal mapping that is only used in view and has no direct relation with TypeParam#id
  def get_type_params
    {"metabolites at steady-state" => 0 , "time-series data of metabolites"=> 1 ,"metabolic fluxes"=> 2 , "proteomic data"=> 3} 
  end
  
  # backward compatibility method
  def type_params_mapping
    self.class.type_params_mapping
  end
  
  # public method of module that is required to be accessed from outside helper
  def self.type_params_mapping
    ["metabolites","metabolites","fluxes","proteomic"]
  end
  
  def t_organism(value=nil)
    begin
      if value.nil?
        get_type_params.rassoc(@organism.type_param.to_i)[0]
      else
        get_type_params.rassoc(value.type_param.to_i)[0]
      end
      
    rescue
      return ""
    end
  end
  
  #
  # function that dictates which "10. Protocol Information" shows
  def can_show?(value)
    begin
      @organism.type_param_obj.type_small == value
    rescue
      return false
    end
  end

end
