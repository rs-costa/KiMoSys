require "spec_helper"
require 'zip'

feature "Tools" do

  scenario "Model Reduction" do
    visit new_dynamic_path

    parent = File.join( Rails.root, "spec/support/tools_files" )
    prefix = File.join( parent, "reduction" )

    files = [{ field: "sbml_file", suffix: "sbml.xml"} , {field: "fluxes_file", suffix: "fluxes.txt" }]

    files.each do |f|
      f[:path] = prefix + "_" + f[:suffix]
    end

    metabolites_text = ""
    File.open( prefix + "_" + "metabolites.txt" ) do |file|
      metabolites_text = file.read
    end

    within("//form[@id='reduction']") do
      files.each do |f|
          attach_file(f[:field] , f[:path])
      end
      fill_in 'places', with: metabolites_text
      click_button "Reduction"
    end
    #
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
    expect(page.status_code).to be(200)

    File.open(File.join(parent, 'output', "reduction.zip"), "w+:#{Encoding::ASCII_8BIT}") { |f| ;f.write(page.body) }

  end

  scenario "Substitutions (Metabolites)" do
    visit new_dynamic_path

    parent = File.join( Rails.root, "spec/support/tools_files" )
    prefix = File.join( parent, "metabolites" )

    files = [{ field: "substitutions_file", suffix: "sbml.xml"} , {field: "values_file", suffix: "metabolites.txt" }]

    within("//form[@id='substitutions']") do
      files.each do |f|
        f[:path] = prefix + "_" + f[:suffix]
        attach_file(f[:field] , f[:path])
      end
      click_button "Set"
    end
    #
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
    expect(page.status_code).to be(200)
    File.open(File.join(parent, 'output', "metabolites.xml"), "w+") { |f| f.write(page.body) }
  end

  scenario "Translate kinetic equations" do
    visit new_dynamic_path

    parent = File.join( Rails.root, "spec/support/tools_files" )
    prefix = File.join( parent, "kinetic" )

    files = [{ field: "kinetic_file", suffix: "sbml.xml"}]

    within("//form[@id='kinetic']") do
      files.each do |f|
        f[:path] = prefix + "_" + f[:suffix]
        attach_file(f[:field] , f[:path])
      end
      click_button "Convert"
    end
    #
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
    expect(page.status_code).to be(200)
    File.open(File.join(parent, 'output', "kinetic.xml"), "w+") { |f| f.write(page.body) }
  end

  scenario "Fluxes" do
    visit new_dynamic_path
    parent = File.join( Rails.root, "spec/support/tools_files" )
    prefix = File.join( parent, "fluxes" )

    files = [{ field: "substitutions_file", suffix: "sbml.xml"} , {field: "values_file", suffix: "fluxes.txt" }]

    within("//form[@id='fluxes']") do
      files.each do |f|
        f[:path] = prefix + "_" + f[:suffix]
        attach_file(f[:field] , f[:path])
      end
      click_button "Set"
    end
    #
    expect(page.response_headers["Content-Disposition"]).to have_content("attachment")
    expect(page.status_code).to be(200)
    File.open(File.join(parent, 'output', "fluxes.xml"), "w+") { |f| f.write(page.body) }
  end

end
