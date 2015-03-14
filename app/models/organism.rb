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

class Organism < ActiveRecord::Base
  belongs_to :user

  belongs_to :type_param_obj, class_name: "TypeParam", foreign_key: :type_param
  has_many :organism_associations
  has_many :users, :through => :organism_associations
#  has_many :associated_models
  has_many :organisms_associated_models, dependent: :destroy
  has_many :associated_models, :through => :organisms_associated_models
  #
  has_many :statuses, as: :statusable, dependent: :destroy

  has_many :attached_files, as: :attachable

  belongs_to :review_journal

  accepts_nested_attributes_for :attached_files, allow_destroy: true, :reject_if => proc { |a| a['src'].blank? }

  has_attached_file :parameters, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"
  has_attached_file :article, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"

  scope :add_metabolites, ->() {
   joins(:type_param_obj)
   .where( TypeParam.arel_table[:title].lower().matches('%steady%'.downcase))
  }

  scope :reduction, ->() {
   fluxes()
  }

  scope :fluxes, ->() {
   joins(:type_param_obj)
   .where( TypeParam.arel_table[:title].lower().matches('%flux%'.downcase))
  }

  scope :user_organisms, ->(user) {
    includes(:organism_associations)
    .includes(:organisms_associated_models)
    .where(
      Organism.arel_table[:user_id].eq(user.id)
      .or(OrganismAssociation.arel_table[:user_id].eq(user.id))
      .or(OrganismsAssociatedModel.arel_table[:user_id].eq(user.id))
      )
    .uniq
  }

  #scope :related, lambda { |organism| where(project: organism.project, organism: organism.organism , strain: organism.strain).where( Organism.arel_table[:id].not_eq(organism.id)) }
  # Same Main Organism
  # Same Project name
  # Same PubmedID
  scope :related, lambda { |model|
   where(
     Organism.arel_table[:project].eq(model.project)
      .and(Organism.arel_table[:project].not_eq(""))
     .or(Organism.arel_table[:pubmed_id].eq(model.pubmed_id)
      .and(Organism.arel_table[:pubmed_id].not_eq("")))
    .or(Organism.arel_table[:organism].eq( model.organism )
      .and(Organism.arel_table[:organism].not_eq("")))
   )
   .where(
     Organism.arel_table[:id].not_eq(model.id)
   )
  }

  scope :show_public, lambda{ |name|
      if name.nil?
      where(arel_table[:is_public].eq(true))
    elsif name.admin?
      all
    else
        where(arel_table[:is_public].eq(true).or(arel_table[:user_id].eq(name.id)))
    end
  }

  has_paper_trail :only => [:parameters,:parameters_updated_at]

  attr_accessor :delete_article

  before_validation { article.clear if delete_article == '1' }

  attr_accessible :organism, :pubmed_id, :strain, :type_param,
	  :parameters, :journal, :manuscript_title, :project,
	  :author, :affiliation, :temperature, :ph, :carbonsource,
	  :growthcondition, :dilutionrate, :comments, :article,
	  :medium, :is_public, :experiment, :volume, :biomass,
	  :execution ,:sampling_method,:quenching,:extraction,
	  :analysis,:type_analysis,:platform,:extraction_list,
	  :analysis_list,:type_analysis_list,:platform_list, :conditions,
	  :measurement_method_list,:measurement_method, :data_units,
	  :keywords, :is_private, :delete_article,
	  :chebi_id, :attached_files_attributes, :updated_at,
	  :year, :review_journal_id, :visibility



  VISIBILITY = { public: "1", private: "2", review_journal: "3"}

  def visibility()
    if is_public?
      VISIBILITY[:public]
    elsif is_private?
      VISIBILITY[:private]
    elsif !review_journal.nil? || @visibility == VISIBILITY[:review_journal]
      VISIBILITY[:review_journal]
    else
      -1
    end
  end

  def visibility=(val)
    if val == VISIBILITY[:public]
      self.is_public = true
      self.is_private = false
      self.review_journal = nil
    elsif val == VISIBILITY[:private]
      self.is_public = false
      self.is_private = true
      self.review_journal = nil
    elsif val == VISIBILITY[:review_journal]
      self.is_public = false
      self.is_private = false
      # review journal is set in the form directly
    end
    @visibility = val
  end

  validates_numericality_of :year,
    :greater_than_or_equal_to => 1800,
    :lesser_than_or_equal_to => Time.now.year + 5,
    :only_integer => true, allow_nil: true

  validates_attachment :parameters, :presence => true,
  :content_type => { :content_type => ["application/zip", "application/octet-stream","application/vnd.ms-excel","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"] },
  :size => { :in => 0..200.megabytes }

  validates_attachment :article,
  :content_type => { :content_type => "application/pdf" },
  :size => { :in => 0..200.megabytes }

  validates_presence_of :organism,:strain,:parameters, :type_param,
  :manuscript_title,:author, :temperature, :ph,:growthcondition # required field

  validate :protocol_information_exists, :chebi_id_valid, :review_journal_presence

  validates_with AttachmentPresenceValidator, :attributes => :parameters
  #validates_uniqueness_of :organism, :scope => [:strain,:type_param]

  attr_accessor :extraction_list,:analysis_list,:type_analysis_list,:platform_list

  before_save :init

  # para o caso de querermos de o artigo em PDF ser obrigatorio o upload para conseguirmos criar novos dados: : validates_attachment :article, :presence => true, :content_type => {:content_type =>"application/pdf"}

  def is_reviewed?
    if self.status.nil?
      s = self.build_status
      s.save
      self.save
    end
    s.is_reviewed?
  end

  def extraction_list() common_list(:extraction) end
  def analysis_list() common_list(:analysis) end
  def type_analysis_list() common_list(:type_analysis) end
  def platform_list() common_list(:platform) end
  def measurement_method_list() common_list(:measurement_method) end

  def extraction_list=(value) set_common_list(value,:extraction) end
  def analysis_list=(value) set_common_list(value,:analysis) end
  def type_analysis_list=(value) set_common_list(value,:type_analysis) end
  def platform_list=(value) set_common_list(value,:platform) end
  def measurement_method_list=(value) set_common_list(value,:measurement_method) end


  def can_remove?(user_p,force_admin=false)

    perm = force_admin ? is_admin?(user_p) : can_edit?(user_p)

    perm && ( self.is_private? || !self.is_public? || user_p.admin)
  end

  def is_admin?(user_p)
    user_p && ((self.user &&  user_p.id == self.user.id ) || user_p.admin)
  end

  def can_edit?(user_p)
    !user_p.nil? && ((self.user && self.users.include?(user_p) ) || is_admin?(user_p))
  end

   def related_organism
    Organism.related(self)
  end

  def status
    self.statuses.last
  end

  private

  def chebi_id_valid
    return if self.chebi_id.blank? # do nothing if is empty

    self.chebi_id.split(",").each do |s|

      regexp = /CHEBI:([[:digit:]]+)/
      #
      result = regexp.match(s.strip)
      is_number = true if Integer(s.strip) rescue false

      if (!is_number && result.blank? ) || !is_number && !result.blank? && result[0] != s.strip
        errors.add(:chebi_id, "must be an in an integer number format or CHEBI:&lt;id&gt; (for example: 17634 or CHEBI:17634 for D-glucose)")
        return
      end
    end

  end

  def protocol_information_exists
    error_msg = "can't be blank"

   if can_show?("metabolites")
     errors.add(:sampling_method, error_msg) if self.sampling_method.blank?
     errors.add(:quenching, error_msg) if self.quenching.blank?
     errors.add(:extraction_list, error_msg) if self.extraction_list.blank?
     errors.add(:analysis_list, error_msg) if self.analysis_list.blank?
   elsif can_show?("fluxes")
     errors.add(:type_analysis_list, error_msg) if self.type_analysis_list.blank?
     errors.add(:platform_list, error_msg) if self.platform_list.blank?
   elsif can_show?("proteomic")
     errors.add(:measurement_method, error_msg) if self.measurement_method_list.blank?
   end

  end

  def common_list(attribute)
      if read_attribute(attribute).nil?
        ""
      else
        YAML::load(read_attribute(attribute))
      end
  end

  def set_common_list(value,attribute)
      write_attribute(attribute, YAML::dump(value.delete_if{|m|m.blank?}) )
  end

def get_type_params
    {"metabolites at steady-state" => 0 , "time course metabolites data"=> 1 ,"metabolic fluxes"=> 2 , "proteomic data"=> 3}
  end

  def type_params_mapping
    ["metabolites","metabolites","fluxes","proteomic"]
  end

  def t_organism
    return "" unless self.type_param.kind_of?(Integer)
    type_params_mapping[self.type_param]
  end

  def can_show?(value)
    t_organism == value
  end

  def init
    if self.statuses.last.nil?
      s = self.statuses.build
      s.save unless self.new_record?
    end
  end

  def review_journal_presence
    errors.add(:review_journal, "must be assigned if \"Sharing\" is set to \"Review Journal\"" ) if @visibility == VISIBILITY[:review_journal] && ( self.review_journal.nil? || self.review_journal.blank? )

    errors.add(:sharing, "settings must be set to a value") if self.review_journal.nil? && self.review_journal.blank? && !self.is_public? && !self.is_private?
  end

end
