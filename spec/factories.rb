FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "droid#{n}@example.com"}
    password "notthedroidyouarelookingfor"
    first_name "droid"
    last_name "not the one"
    affiliation "ist"

    admin false
    factory :admin do
      admin true
    end
  end

  factory :organism do
    manuscript_title "test manuscript"
    pubmed_id "817625"
    author "Yoda; Skywalker"
    organism { |n| "Organism #{n}" }
    strain "Not the strain"
    temperature "12"
    ph "7"
    year 1990
    growthcondition "12345"
    #
    is_public true
    is_private false
    # metabolites
    sampling_method "12345"
    quenching "12345"
    extraction_list ["perchloric acid"]
    analysis_list ["enzymatic", "HPLC/HIC"]
    #
    type_analysis_list ["123"]
    platform_list ["123"]
    measurement_method ["12345"]
    # proteomic
    #measurement_method "1234"
    #
    article { File.new "#{Rails.root}/spec/support/fixtures/pdf_file.pdf" }
    parameters { File.new "#{Rails.root}/spec/support/fixtures/excel_file.xlsx" }
    #
    type_param
    user
    factory :private_organism do
      is_public false
      is_private true
    end
  end

  factory :type_param do
    title { |n| "metabolites" }
    type_small { |n| "metabolites" }
    image { File.new "#{Rails.root}/app/assets/images/Add.jpg" }
  end

  factory :article do
    file { File.new "#{Rails.root}/public/documentation/Ec_core_flux1_model.xml" }
  end

  factory :associated_model do
    manuscript_title "Manuscript title :)"
    authors "authors"
    model_name "model name"
    model_type "model type"
    reactions 1
    species "species"
    parameters 1
    used_for_list ["Model validation"]
    category "category"
    #
    main_organism { |n| "main organism #{n}" }
    #
    is_private false
    public true
    #
    ignore do
      user { FactoryGirl.create :user }
      organism { FactoryGirl.create :organism }
    end
    #
    after(:build) do |associated_model, evaluator|
      associated_model.articles << FactoryGirl.build( :article )
      #
      associated_model.add_organism( evaluator.organism, evaluator.user )
    end
    #
    factory :private_associated_model do
      is_private true
      public false
    end
    factory :associated_model_with_link do
      software "http://www.google.com (Google)"
    end
  #
  end

end
