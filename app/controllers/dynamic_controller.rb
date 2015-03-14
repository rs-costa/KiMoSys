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

require 'net/http'
require 'zip'

class DynamicController < ApplicationController

  def new
    @reduction_files = Organism.reduction.reject do |o|
      !o.is_public? && !o.can_edit?(current_user) || o.attached_files.last.nil? || o.attached_files.last.src.blank?
    end

    @substitutions_files = Organism.add_metabolites.reject do |o|
      !o.is_public? && !o.can_edit?(current_user)
    end

    @reduction_files     = @reduction_files.collect { |o| o.attached_files }.flatten
    @substitutions_files = @substitutions_files.collect { |o| o.attached_files }.flatten

    @sbml_files = AssociatedModel.all.reject do |m|
      !m.public? && !m.can_edit?(current_user) || m.articles.last.blank? || m.organisms_associated_models.size == 0
    end




  end

  def fluxes

    sbml_file = load_sbml(:substitutions_file , :sbml_model)
    values_file = load_txt(:values_file, :fluxes_organism)

    if sbml_file.nil? || values_file.nil?
      flash[:fluxes] = "Fluxes input: No SBML or text file loaded"
      redirect_to new_dynamic_path
      return
    end

    subs_path = sbml_file.path
  	values_path = values_file.path

    output_file = Tempfile.new(["fluxes",".output"])
  	output_file.close

    # chamar funcao
    begin
      load_jvm
  	  subs_new = Rjb::import('sbml.Substitutions_New')
  	  subs_new.substitute(subs_path,values_path,output_file.path,subs_new.PARAMETERS)
      #Java::sbml.Substitutions_New.substitute(subs_path,values_path,output_file,Java::sbml.Substitutions_New::PARAMETERS)
      unload_jvm
    rescue Exception => e

    end

    results = output_file.open.read
    output_file.close!
    send_data results , type: 'application/xml', :filename => 'output_file.xml'
  end

  # add metabolites
  def substitutions

    sbml_file = load_sbml(:substitutions_file , :sbml_model)
    values_file = load_txt(:values_file, :fluxes_organism)

    if sbml_file.nil? || values_file.nil?
      flash[:substitutions] = "Metabolites input: No SBML or text file loaded"
      redirect_to new_dynamic_path
      return
	  end

  	subs_path = sbml_file.path
  	values_path = values_file.path

  	output_file = Tempfile.new(["substitutions",".output"])
  	output_file.close
  	# chamar funcao
  	begin
  	  load_jvm
  	  subs_new = Rjb::import('sbml.Substitutions_New')
  	  subs_new.substitute(subs_path,values_path,output_file.path,subs_new.CONCENTRATIONS)
  	  #Java::sbml.Substitutions_New.substitute(subs_path,values_path,output_file,Java::sbml.Substitutions_New::CONCENTRATIONS)
  		#Java::sbml.Substitutions.substitute(subs_path,values_path,output_file)
  		unload_jvm
  	rescue Exception => e
  	  logger.debug( "Error: " + e.message )
  	end

  	results = output_file.open.read
  	output_file.close!
  	send_data results , type: 'application/xml', :filename => 'output_file.xml'

  end

  def kinetic

    sbml_file = load_sbml(:kinetic_file , :sbml_model)

	  if sbml_file.nil?
	    flash[:kinetic] = "Generate kinetic equations: No SBML file loaded"
	    redirect_to new_dynamic_path
	    return
	  end

    load_jvm
    kinetic_new = Rjb::import('sbml.KineticCreator_new')
    unless params[:type].present?
      #string = kinetic_new.addKinetics(tempfile.open.read)
      string = kinetic_new._invoke('addKinetics','Ljava.lang.String;',sbml_file.read)
    	#string = Java::sbml.KineticCreator_new.addKinetics(tempfile.open.read)
    else
    	string = kinetic_new._invoke('addKinetics','Ljava.lang.String;Ljava.lang.Integer;',sbml_file.read,Integer(params[:type]))
    	#string = kinetic_new.addKinetics(tempfile.open.read,Integer(params[:type]))
    	#string = Java::sbml.KineticCreator_new.addKinetics(tempfile.open.read,Integer(params[:type]))
    end
		unload_jvm
    #File::delete(tempfile)

    send_data string , type: 'application/xml', :filename => 'kinetic_model.xml'
  end


  def reduction

    sbml_file = load_sbml(:sbml_file , :sbml_model)
    fluxes_file = load_txt(:fluxes_file, :fluxes_organism)

    # check if there are missing input data
    if sbml_file.nil? || fluxes_file.nil? || params[:places].blank?
	    flash[:reduction] = "Some parameters are not set, please fill all fields for this action."
	    redirect_to new_dynamic_path
	    return
	  end

	  # split the input for places
	  places = params[:places].split(",")

	  # creates new temporary files for outputs
	  new_fluxes_file = Tempfile.new(["new_fluxes",".txt"])
	  output_file     = Tempfile.new(["reduced_model",".xml"])
	  new_sbml_file   = Tempfile.new(["split_irreversible",".xml"])
	  new_zip_file    = Tempfile.new(["result",".zip"]); new_zip_file_path = new_zip_file.path; new_zip_file.close!

	  # chamada a funcao java
	  load_jvm
	  reduction = Rjb::import('sbml.Reduction')
    reduction.modelReduction(sbml_file.path , fluxes_file.path , places, new_fluxes_file.path , output_file.path, new_sbml_file.path)
		unload_jvm
    #Java::sbml.Reduction.modelReduction(sbml_file , fluxes_file , places, params[:sbml_file].tempfile.path + new_fluxes_file , params[:sbml_file].tempfile.path + output_file, params[:sbml_file].tempfile.path + new_sbml_file)

    Zip::ZipFile.open( new_zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(File.basename(new_fluxes_file), new_fluxes_file.path)
      zipfile.add(File.basename(output_file), output_file.path)
      #zipfile.add(new_sbml_file, params[:sbml_file].tempfile.path + new_sbml_file)
	  end

    [ new_fluxes_file, output_file, new_sbml_file ].each { |f| f.close! } # deletes the temporary files from disk
    # retorno de um ficheiro
    send_data File.open( new_zip_file_path , "rb").read , type: 'application/zip', :filename => 'my_model.zip'
  end

  protected

  def load_txt(param1, param2)
    if params[param1.to_sym].present?
  	  params[param1.to_sym].tempfile
  	elsif params[param2.to_sym].present?
	    File.open(Organism.find(params[param2.to_sym]).attached_files.last.src.path)
	  else
	    nil
  	end
  end

  def load_sbml( param1, param2 )
    # priortity to param1
    if params[param1.to_sym].present?
      params[param1.to_sym].tempfile
    elsif params[param2.to_sym].present?
      File.open(AssociatedModel.find( params[param2.to_sym] ).articles.last.file.path)
    else
      nil
    end
  end

  def load_jvm
    unless Rjb::loaded?
      lib_path = File.join(Rails.root.realpath, 'lib','*.jar')
      path = Dir.glob(lib_path).join(':')
      Rjb::load(path, ['-Xmx512M'])
    end
  end

  def unload_jvm
    nil
    #Rjb::unload()
  end

end
