
require "spec_helper"

include Warden::Test::Helpers

feature "Associated Models" do

  given(:user)        { create :user }
  given(:second_user) { create :user }
  given(:admin)       { create :admin }

  given(:t1) { create :type_param, title: "metabolites at steady-state", type_small: "metabolites" }
  given(:t2) { create :type_param, title: "time-series data of metabolites", type_small: "metabolites" }
  given(:t3) { create :type_param, title: "metabolic fluxes", type_small: "fluxes" }
  given(:t4) { create :type_param, title: "enzyme/protein levels", type_small: "proteomic" }

  background do
    Warden.test_mode!
    # need to confirm users
    user.confirm!
    second_user.confirm!
    admin.confirm!
  end

  given(:organism)         { create :organism, type_param: t1, user: user }
  #
  given(:associated_model)         { create :associated_model, organism: organism, user: user }
  given(:associated_model_link)    { create :associated_model_with_link, organism: organism, user: user }
  given(:private_associated_model) { create :private_associated_model, organism: organism, user: user, is_private: true }


  scenario "Show public Associated Model without a user" do
    Warden.test_reset!
    #
    visit url_for([organism,associated_model])
    expect(page).to have_content associated_model.main_organism
  end

  scenario "Show public Associated Model with link" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit url_for([organism,associated_model_link])
    expect(page).to have_link associated_model_link.software.strip[0]
  end

  scenario "Show public Associated Model" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit url_for([organism,associated_model])
    expect(page).to have_content associated_model.main_organism
  end

  scenario "Show public Associated Model with different user" do
    Warden.test_reset!
    login_as(user, :scope => :second_user)
    #
    visit url_for([organism,associated_model])
    expect(page).to have_content associated_model.main_organism
  end

  scenario "Show private Associated Model that is viewable" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit url_for([organism,private_associated_model])
    expect(page).to have_content private_associated_model.main_organism
  end

  scenario "Show private Associated Model that is not viewable" do
    Warden.test_reset!
    login_as(user, :scope => :second_user)
    #
    visit organism_associated_model_path(organism,private_associated_model)
    expect(page).to have_content private_associated_model.main_organism
  end


  #
  #
  #
  # Download all files
  #
  scenario "Should not download all files with user from private model" do
    Warden.test_reset!
    login_as(second_user, :scope => :user)
    #
    visit download_all_organism_associated_model_path(organism,private_associated_model)
    expect(page.response_headers["Content-Disposition"]).not_to have_content("attachment")
    expect(page).to have_content "not authorized"
  end

  scenario "Download all files with user of a model" do
    Warden.test_reset!
    login_as(second_user, :scope => :user)
    #
    visit download_all_organism_associated_model_path(organism,associated_model)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

  scenario "Download all files with owner from private model" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit download_all_organism_associated_model_path(organism,private_associated_model)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

  scenario "Should not download all files from private model without user" do
    Warden.test_reset!
    #
    visit download_all_organism_associated_model_path(organism,private_associated_model)
    expect(page.response_headers["Content-Disposition"]).not_to have_content("attachment")
    expect(page).to have_content "not authorized"
  end

  scenario "Should download all files of a public model without user" do
    Warden.test_reset!
    #
    visit download_all_organism_associated_model_path(organism,associated_model)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

end
