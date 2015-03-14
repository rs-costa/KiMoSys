class Status < ActiveRecord::Base
  attr_accessible :comment, :is_reviewed
  
  belongs_to :user
  belongs_to :statusable, polymorphic: true
  
  after_initialize :init
  
  def statusable_name
    case self.statusable.class.model_name
      when Organism.model_name
        self.statusable.organism
      when AssociatedModel.model_name
        self.statusable.model_name
    end
  end

  protected
  
  def init
#    if self.statusable.user.admin?
#      self.is_reviewed = true
#    else
      self.is_reviewed  ||= false  # will set the default value only if it's nil
#    end
  end

end
