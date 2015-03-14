class Ability
  include CanCan::Ability

  def initialize(user)

    cannot :access, :journals
    cannot :review, [:organisms, :associated_models]
    cannot :access, :statuses

    can :see_id, [:organisms, :associated_models] do |obj|
      obj.is_public? || obj.is_private? || obj.review_journal.nil? || !obj.review_journal.protect_id?
    end

    if user
      #
      # Organims

      #

      can [:index,:update,:edit, :see_id], :organisms do |obj|
        obj.can_edit?(user)
      end

      #
      can [:new, :create], :organisms

      #
      # Associated Models
      #
      can :associate, :associated_models # specific authorization in controller
      #
      can [:access], :associated_models do |obj|
        obj.can_edit?(user)
      end

      can [:new, :create], :associated_models

      can [:destroy], [:associated_models, :organisms] do |obj|
        obj.can_remove?(user,true)
      end

      # no restrictions
      can :access, :articles
      can :access, :authorizations

      can :access, :links
      can :access, :organism_associations

      #
      #
      # shared
      #
      can [:show], [:associated_models,:organisms] do |obj|
        obj.is_public? || obj.can_edit?(user) || (!obj.review_journal.nil? && obj.review_journal.is_reviewer?(user))
      end

      can [:download,:download_all], [:associated_models,:organisms] do |obj|
        obj.is_public? || obj.can_edit?(user) || (!obj.review_journal.nil? && obj.review_journal.is_reviewer?(user))
      end


      if user.admin?
        can :access, :all
      end
    else

      can [:show], [:associated_models,:organisms] do |obj|
        obj.is_public?
      end
      #
      can :new,:create, :quicks
      #
      can [:download,:download_all], [:organisms,:associated_models] do |obj|
        ( obj.is_public || obj.is_public.nil? ) && !obj.is_private
      end
      can :download, :articles do |obj|
        !obj.associated_model.is_private
      end
    end
    can [:new,:create], :quicks
    can :access, :home
    can :access, :dynamic
    can :show, :documentation

  end
end
