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

class AssociatedModel < ActiveRecord::Base


  ## Used to convert from old association to new one
  #AssociatedModel.all.collect { |m|
  #  new_link = OrganismsAssociatedModel.new
  #  new_link.organism_id = m.organism_id
  #  new_link.associated_model = m
  #  new_link.original = true
  #  new_link.user = m.user ? m.user : User.where( email: "kimosys@kdbio.inesc-id.pt").first
  #  new_link.user_email = new_link.user.email
  #  new_link.save
  #  new_link
  #}

  has_many :organisms_associated_models, dependent: :destroy
  has_many :organisms, :through => :organisms_associated_models
  #  belongs_to :organism
  has_many :articles, dependent: :destroy
  belongs_to :user

  has_paper_trail :only => [:control]

  has_many :authorizations, as: :authorizable
  has_many :users, through: :authorizations, :as => :user

  has_many  :statuses, as: :statusable, dependent: :destroy

  belongs_to :review_journal

  #  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :articles, allow_destroy: true, :reject_if => proc { |a| a['file'].blank? }

  has_attached_file :sbml, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"
  has_attached_file :article, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"
  has_attached_file :combine_archive, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"

  #
  #
  #
  # ATENTION ARTICLE IS RENAMED WITH SBML
  #
  #
  #
  scope :remove_private, lambda { |user|
    if user.nil?
      where(AssociatedModel.arel_table[:is_private].not_eq(true))
    else
      where(AssociatedModel.arel_table[:is_private].not_eq(true)
        .or(AssociatedModel.arel_table[:user_id].eq(user.id)))
    end
  }

  scope :similar, lambda { |param1,param2|
    where(
      AssociatedModel.arel_table[:manuscript_title].lower.eq(param1.downcase)
        .and(AssociatedModel.arel_table[:manuscript_title].not_eq(""))
      .or(AssociatedModel.arel_table[:pubmed_id].not_eq("")
        .and(AssociatedModel.arel_table[:pubmed_id].lower.eq(param2.downcase)))
    )
  }

  # Same Main Organism
  # Same Project name
  # Same PubmedID
  scope :related, lambda { |model|
   where(
     AssociatedModel.arel_table[:project_name].eq(model.project_name)
      .and(AssociatedModel.arel_table[:project_name].not_eq(""))
     .or(AssociatedModel.arel_table[:pubmed_id].eq(model.pubmed_id)
      .and(AssociatedModel.arel_table[:pubmed_id].not_eq("")))
    .or(AssociatedModel.arel_table[:main_organism].eq( model.main_organism )
      .and(AssociatedModel.arel_table[:main_organism].not_eq("")))
   )
   .joins(:organisms_associated_models)
   .where(
     AssociatedModel.arel_table[:id].not_eq(model.id)
     .and(OrganismsAssociatedModel.arel_table[:original].eq(true))
   )
  }

  attr_accessible :comments, :compartments, :parameters,
    :reactions, :species, :sbml, :article, :organism_id,
    :used_for_list,:pubmed_id,:dilution_rate,:category,:model_type,:public,
    :model_name,:manuscript_title, :journal, :authors,
    :affiliation, :project_name, :biomodels_id, :regulators, :articles_attributes,
    :keywords, :is_private, :software, :control, :main_organism, :delete_article,
	  :year, :combine_archive, :review_journal_id, :visibility

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

  attr_accessor :used_for_list,:delete_article
  before_validation { sbml.clear if delete_article == '1' }

  validate :check_version # presence of version
  validate :review_journal_presence

  validates_numericality_of :year,
    :greater_than_or_equal_to => 1800,
    :lesser_than_or_equal_to => Time.now.year + 5,
    :only_integer => true,allow_nil: true

  validates_numericality_of :reactions,
    :greater_than_or_equal_to => 0,
    :only_integer => true

  validates_numericality_of :parameters,
    :greater_than_or_equal_to => 0,
    :only_integer => true

  validates_numericality_of :compartments,
    :greater_than_or_equal_to => 0,
    :only_integer => true, allow_nil: true

  validates_presence_of :manuscript_title, :authors, :model_name, :model_type, :reactions, :species, :parameters, :used_for_list, :category

  validates_format_of :sbml_file_name, :with => %r{\.(pdf)$}i, allow_nil: true, allow_blank: true

  validates_format_of :combine_archive_file_name, :with => %r{\.(omex)$}i, allow_nil: true, allow_blank: true

  before_save :init

  def add_organism(organism,user=nil,original=true)
    oma = self.organisms_associated_models.build
    oma.organism = organism
    oma.original = original
    oma.user = user
    oma.user_email = user.email
    self.user = user
    self.user_email = user.email
    oma
  end

  def used_for_list() common_list(:used_for) end
  def used_for_list=(value) set_common_list(value,:used_for) end

  def can_remove?(user_p, force_admin = false)
    perm = force_admin ? is_admin?(user_p) : can_edit?(user_p)

    perm && ( self.is_private? || !self.public? || user_p.admin)
  end

  def can_edit?(user_p)
    user_p && (self.user && self.users.include?(user_p)) || is_admin?(user_p)
  end

  def is_admin?(user_p)
    user_p && (self.user && ( user_p.id == self.user.id ) || user_p.admin )
  end

  def related_models(user)
    AssociatedModel.related(self).remove_private(user)
  end

  def get_created_organism
    o = self.organisms_associated_models.where(original: true)
    if o.count > 0
      return o.first.organism
    elsif self.organisms.count > 0
      return self.organisms.first
    else
      return nil
    end
  end

  # return last status
  def status
    self.statuses.last
  end

  def is_public
    self.public
  end

  def is_public?
    self.public
  end

  def is_public=(value)
    self.public=value
  end

  private

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

  def check_version
    #not working
    errors.add(:models,"must add at least one model version") if self.articles.size == 0
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
