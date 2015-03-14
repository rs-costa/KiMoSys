# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_class = 'menu'
    primary.item :sign_up, t('devise.sign_up'), new_user_registration_path,:unless => Proc.new {user_signed_in?}
    primary.item :login,t('devise.login'), new_user_session_path, :unless => Proc.new { user_signed_in? }
    primary.item :user, Proc.new{ user_signed_in? ? current_user.email : 'user' }.call, edit_user_registration_path, :if => Proc.new { user_signed_in? }
    primary.item :edit, t('devise.edit'), edit_user_registration_path,:if => Proc.new { user_signed_in? }
    primary.item :logout, t('devise.logout'), destroy_user_session_path, :if => Proc.new { user_signed_in? }, :method => :delete
  end

end
