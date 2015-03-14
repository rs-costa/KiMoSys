class AttachedFile < ActiveRecord::Base
  attr_accessible :src

  has_paper_trail

  belongs_to :attachable, polymorphic: true

#  before_create :touch_control
#  before_destroy :touch_control

  has_attached_file :src, url: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/system/:class/:attachment/:id_partition/:style/:filename"

  validates_format_of :src_file_name, :with => %r{\.(txt|csv|zip)$}i, :message => "file format is invalid"

  validate :check_unique

  private

  def touch_control
    self.attachable.update_attributes :updated_at => Time.now if self.attachable
    true
  end

  def check_unique
    errors.add(:alternate_data_formats, "file name already exists, please change the file name or check if it is the same.") if self.attachable.attached_files.map(&:src_file_name).include?(self.src_file_name)
  end


end
