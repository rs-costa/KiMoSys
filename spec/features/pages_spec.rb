require "spec_helper"

include Warden::Test::Helpers

feature "Visits to pages that do not require authentication or data" do

  scenario "Visit Home page" do
      visit root_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      visit home_index_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      expect(page).not_to have_content "You are not authorized to access this page"
  end

  scenario "Visit Documentation page" do
      visit documentation_index_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      expect(page).not_to have_content "You are not authorized to access this page"
  end

  scenario "Visit Tools page" do
      visit new_dynamic_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      expect(page).not_to have_content "You are not authorized to access this page"
  end

  scenario "Visit Links page" do
      visit links_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      expect(page).not_to have_content "You are not authorized to access this page"
  end

  scenario "Visit Contact page" do
      visit contact_documentation_index_path
      expect(page.status_code).to be(200)
      expect(page).not_to have_content "You must be logged"
      expect(page).not_to have_content "You are not authorized to access this page"
  end

end
