

require "spec_helper"

include Warden::Test::Helpers

feature "Organisms" do


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
  given(:private_organism) { create :private_organism, type_param: t1, user: user }
  #

  scenario "Visit My Repository index page without a user" do
      Warden.test_reset!
      visit my_repository_path
      expect(page.status_code).to be(200)
      expect(page).to have_content "You must be logged"
  end

  scenario "Visit My Repository index page with a user" do
      Warden.test_reset!
      login_as(user, :scope => :user)
      #
      o = organism
      visit my_repository_path
      expect(page.status_code).to be(200)
      expect(page).to     have_content o.organism
  end

  scenario "See all Organisms" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    o = organism
    p = private_organism
    visit organisms_path()
    expect(page).to have_content o.organism
    expect(page).to have_content p.organism
  end
  scenario "See all organisms without a user" do
    Warden.test_reset!
    #
    o = organism
    p = private_organism
    visit organisms_path()
    expect(page).to     have_content o.organism
    expect(page).not_to have_content p.organism
  end

  scenario "Go to new organism page" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit new_organism_path()
    expect(page).to have_content "Data-submission form"
  end

  scenario "Show public Organism without a user" do
    Warden.test_reset!
    #
    visit organism_path(organism)
    expect(page).to have_content organism.organism
  end

  scenario "Show public Organism" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit organism_path(organism)
    expect(page).to have_content organism.organism
  end

  scenario "Show private Organism that is not viewable" do
    Warden.test_reset!
    login_as(second_user, :scope => :user)
    #
    visit organism_path( private_organism )
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "Show private Organism that is viewable" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    visit organism_path( private_organism )
    expect(page).to have_content private_organism.organism
  end

  scenario "Show private Organism that is viewable by admin" do
    Warden.test_reset!
    login_as(admin, :scope => :user)
    #
    visit organism_path( private_organism )
    expect(page).to have_content private_organism.organism
  end

  #
  #
  #
  # Download all files
  #
  scenario "Should not download all files with user from private organism" do
    Warden.test_reset!
    login_as(second_user, :scope => :user)
    #
    o = private_organism
    visit download_all_organism_path(o)
    expect(page.response_headers["Content-Disposition"]).not_to have_content("attachment")
    expect(page).to have_content "not authorized"
  end

  scenario "Download all files with user from an organism" do
    Warden.test_reset!
    login_as(second_user, :scope => :user)
    #
    o = organism
    visit download_all_organism_path(o)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

  scenario "Download all files with owner from private organism" do
    Warden.test_reset!
    login_as(user, :scope => :user)
    #
    o = private_organism
    visit download_organism_path(o)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

  scenario "Should not download all files without from private organism" do
    Warden.test_reset!
    #
    o = private_organism
    visit download_all_organism_path(o)
    expect(page.response_headers["Content-Disposition"]).not_to have_content("attachment")
    expect(page).to have_content "not authorized"
  end

  scenario "Download all files without user from an organism" do
    Warden.test_reset!
    #
    o = organism
    visit download_all_organism_path(o)
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
  end

end
