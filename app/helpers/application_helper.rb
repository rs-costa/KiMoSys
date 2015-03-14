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

module ApplicationHelper

  def hyperlink_parser(string, link_class="")
    return string.gsub(/(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/) do |x|
      "<a href='#{x}' class='#{link_class} blue' target=\"_blank\" title='link to this publication'>#{x}</a>"
    end
  end

  #
  #
  #
  #
  def parse_it(str)
    return nil if str.nil?
    str = str.gsub /([Bb][Ii][Oo][Mm][Oo][Dd][Ee][Ll][Ss])/,  link_to('\1', 'http://www.ebi.ac.uk/biomodels-main/', class: "link_out blue")
    str = str.gsub /([Jj][Ww][Ss][ ]?[Oo][Nn][Ll][Ii][Nn][Ee])/, link_to('\1', 'http://jjj.bio.vu.nl:8080/', class: "link_out blue")
    str.html_safe
  end

  #
  #
  # Generalize method to show a simple message
  def show_message(obj, message, additional=nil)
    if obj.visibility == Organism::VISIBILITY[:review_journal]
      content_tag( :div, class: "message") do
        content_tag( :span ) do
          message + ( !additional.nil? && !obj.review_journal.nil? && obj.review_journal.protect_id? ? " " + additional + "." : "." )
        end
      end
    else
      ""
    end
  end

  #
  #
  # show user name with a tooltip
  #
  def show_user(user,alt_string=nil,link=true,show_user=true)
    result = []
    if !show_user
      result << content_tag(:span, t("hidden") , class: "red" )
    elsif user
      result << content_tag( :span, class: "tooltip") do
        if current_user && link
          mail_to user.email, "#{user.first_name} #{user.last_name}"
        else
          "#{user.first_name} #{user.last_name}"
        end.html_safe + user_tooltip(user).html_safe
      end
    elsif alt_string
      result << content_tag( :span, alt_string.gsub(/@/,' (at) ') )
    end
    result.join.html_safe
  end

  #
  #
  # html information that describes an organims
  #
  def describe_organism( tag, organism, long=false )
    content_tag tag.to_sym, class: "tooltiptext" do
  	  s = ''
  	  if long
  	    s += "<strong><i>Data EntryID: </i></strong>#{organism.id}<br/><br/>"
  	    s += "<strong><i>Organism: </i></strong>#{organism.organism}<br/><br/>"
  	    s += "<strong><i>Strain: </i></strong>#{organism.strain}<br/><br/>"
  	    s += "<strong><i>Data Type: </i></strong>#{organism.type_param_obj.title}<br/><br/>"
  	    s += "<strong><i>Project Name: </i></strong>#{organism.project}<br/><br/>"
  	  end
  	  s += "<strong><i>Authors: </i></strong>#{organism.author}<br/><br/>"
  	  s += "<strong><i>Original paper: </i></strong>#{organism.manuscript_title}<br/><br/>"
  	  s += "<strong><i>Keywords: </i></strong>#{organism.keywords}"
  	  s.html_safe
  	end
  end

  def describe_model( tag, associated_model, long=false )
    content_tag tag.to_sym, class: "tooltiptext" do
  	  s = ''
  	  if long
  	    s += "<strong><i>Model EntryID: </i></strong>#{associated_model.id}<br/><br/>"
  	    s += "<strong><i>Model Name: </i></strong>#{associated_model.model_name}<br/><br/>"
  	    s += "<strong><i>Category: </i></strong>#{associated_model.category}<br/><br/>"
  	    s += "<strong><i>Model Type: </i></strong>#{associated_model.model_type}<br/><br/>"
  	    s += "<strong><i>Data used for: </i></strong>#{show_list(associated_model.used_for_list," and ")}<br/><br/>"
  	  end
  	  s += "<strong><i>Authors: </i></strong>#{associated_model.authors}<br/><br/>"
  	  s += "<strong><i>Original paper: </i></strong>#{associated_model.manuscript_title}<br/><br/>"
  	  s.html_safe
  	end
  end

  #
  #
  #
  #
  def link_to_chebi_id_iteration(id,search)
    regexp = /CHEBI:([[:digit:]]+)/
    #
    result = regexp.match(id)
    is_number = true if Integer(id) rescue false
    #
    if id.blank? || (!is_number && result.nil?) && (!is_number && result[0] != id)
      search
    else

      link_id = if is_number
            Integer(id)
      else
        result[1]
      end
      link_to( search, "http://www.ebi.ac.uk/chebi/searchId.do?chebiId=#{link_id}", target: "_blank", class: "blue link_out", title: "ChEBI")
    end
  end

  #
  #
  #
  #
  def link_to_chebi_id(id,search)

    return search if id.nil? || id.empty?
    result = ""
    splited = id.split(",")
    splited.each_with_index do |s,i|

      search_ary = search.split(",")

      search_aux = if splited.size > 1 && i > 0 && search_ary.size >= i + 1
        search_ary[i]
      elsif splited.size > 1 && i == 0 && !search_ary.empty?
        search_ary.first
      elsif splited.size == 1
        search
      else
        s.strip
      end

      result += link_to_chebi_id_iteration(s.strip, search_aux)
      result += ", "
    end
    result.html_safe
  end

  # link search terms to ncbi taxonomy
  def link_to_taxonomy(search)
    return '' if search.nil? || search.blank?
    query = CGI.escape search
    link_to( search , "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Undef&name=#{query}&lvl=0&srchmode=1&keep=1&unlock", target: '_blank', class: "blue link_out", title: "NCBI taxonomy" )
  end


  def parse_link(string)
    return nil if string.blank?
    name = string.strip
    str = name.split
    is_valid = false
    return "" if str.size == 0
    if str[0] =~ /^#{URI::regexp}$/
      is_valid = true
    #elsif !is_valid && ("http://" + string) =~ /^#{URI::regexp}$/
    #  is_valid = true
    #  string = "http://" + string
    else
      return name
    end
    # create link
    if str.size > 1
      link_to(str[0], str[0], class: "blue link_out", target: "_blank") + " " + str[1..str.size].join(" ")
    else
      link_to(str[0], str[0], class: "blue link_out", target: "_blank")
    end

  end

  #
  #
  # gets associated_model link
  #
  def link_to_associated_model_or_organism(obj)
    case obj.class.model_name
      when AssociatedModel.model_name
        return obj.id if obj.organisms.count == 0
        oma = obj.organisms_associated_models.where( original: true ).first
        return link_to obj.id , oma && oma.organism ? [oma.organism,obj] : [obj.organisms.first, obj]
      when Organism.model_name
        return link_to obj.id , obj
    end
  end

  #
  #
  # format Status in organism and associated_model
  #
  def unreviewed(obj, user)
    unless obj.status.is_reviewed?
      concat content_tag :span, "(unreviewed)", class: "red"
      concat " "
      concat link_to( "approve!", [:reviewed, obj.status] )  if can?(:review,obj) && !obj.status.is_reviewed?
    else
      concat content_tag :span, "(reviewed) #{obj.status.updated_at}"
    end
    concat " "
    concat link_to( "edit status manually", [:edit, obj.status] ) if can?(:review,obj)
  end

  #
  #
  # content for user tooltip
  #
  def user_tooltip(user)
    return "" if user.nil?
    result = []
    result << "First name: #{user.first_name}" if user.first_name
    result << "Affiliation: #{user.affiliation}" if user.affiliation
    result << "Homepage: #{user.home_page}" if user.home_page
    result << "Interests: #{user.research_interests}" if user.research_interests

    content_tag :span,class:"tooltiptext" do
      result.collect do |item|
        concat item
        concat tag("br")
      end
    end

  end

  #
  #
  #
  #
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields block M-top-2em", data: {id: id, fields: fields.gsub("\n", "")})
  end

  #
  #
  #
  #
  def goto_model(prefix,id, html_options={})
   unless id.blank?
    html_options[:class] = "blue link_out"
    html_options[:target] = "_blank"
    link_to(id, (prefix + id.to_s) , html_options)
    else
      notspecified
    end
  end

  #
  #
  #
  #
  def notspecified (text=nil,default="not specified")
    if text.blank?
      default
    else
      text
    end
  end

  #
  #
  #
  #
  def version_list(file_list,field)
    list = []
    size = file_list.size

    file_list.sort_by(&:created_at).each_with_index do |f,index|
      value = {}
      value[:filename] = string_trim(f.send( (field + "_file_name").to_sym) , true , 70)
      value[:version] = version(index , size)
      value[:obj] = f
      value[:user] = begin
        User.find(f.versions.last.whodunnit)
      rescue Exception
        User.where(admin: true).last
      end
      list << value
    end
    list
  end

  #
  #
  #
  #
  def version(number,size)
    if number +1 == size
      "LATEST"
    else
      "version #{(1+(number / 10))}.#{number%10}"
    end
  end

  #
  #
  #
  #
  def form_errors(form_object)
    return "" if form_object.object.errors.blank?
    content_tag :div,class:"form_errors" do
       form_object.semantic_errors *form_object.object.errors.keys
     end
  end

  #
  #
  #
  #
  def show_list(value,sep=", ")
    if value.nil? || value.blank?
      ""
    else
      value.join(sep)
    end
  end

  #
  #
  #
  #
  def string_trim(string,keep_ext=false,size=30)
    result = if string && string.size> size
      string[0..(size-5)] + "(...)"
    else
      string
    end
    if keep_ext
      result.to_s + string[(string.length-5)..(string.length[string.length-1])].to_s
    end
    result
  end

end
