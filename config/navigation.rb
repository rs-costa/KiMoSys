# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_class = 'menu'
    primary.item :home, 'Home', root_path
    primary.item :organisms, 'Repository', organisms_path
    primary.item :organisms, 'My Repository', my_repository_path, :if => Proc.new { current_user }
    primary.item :dynamic, 'Tools', new_dynamic_path
	primary.item :documentation, 'Documentation', documentation_index_path
	primary.item :links, 'Links', links_path
	primary.item :contact, 'Contact Us', contact_documentation_index_path
	primary.item :type_params, 'Type Params', type_params_path, :if => Proc.new { current_user && current_user.admin }
	primary.item :statuses, 'Status', statuses_path, :if => Proc.new { current_user && current_user.admin }
  primary.item :review_journals, 'Journals', review_journals_path, :if => Proc.new { current_user && current_user.admin }
  end

end
