class AlexaInterfaceController < ApplicationController

  @lookup_hash = {
        'Concerts' => 'music',
        'Tour Dates' => 'music',
        'Conferences' => 'conference',
        'Tradeshows' => 'conference',
        'Comedy' => 'comedy',
        'Education' => 'learning_education',
        'Kids' => 'learning_education',
        'Family' => 'family_fun_kids',
        'Festivals' => 'festivals_parades',
        'Film' => 'movies_film',
        'Food' => 'food',
        'Wine' => 'food',
        'Fundraising' => 'fundraisers',
        'Charity' => 'fundraisers',
        'Art Galleries' => 'art',
        'Exhibits' => 'art',
        'Health' => 'support',
        'Wellness' => 'support',
        'Holiday' => 'holiday',
        'Literary' => 'books',
        'Books' => 'books',
        'Museums' => 'attractions',
        'Attractions' => 'attractions',
        'Neighborhood'=> 'community',
        'Business' => 'business',
        'Networking' => 'business',
        'Nightlife' => 'singles_social',
        'Singles' => 'singles_social',
        'University' => 'schools_alumni',
        'Alumni' => 'schools_alumni',
        'Organizations' => 'clubs_associations',
        'Meetups' => 'clubs_associations',
        'Outdoors' => 'outdoors_recreation',
        'Recreation' => 'outdoors_recreation',
        'Performing Arts' => 'performing_arts',
        'Pets' => 'animals',
        'Politics' => 'politics_activism',
        'Activism' => 'politics_activism',
        'Sales' => 'sales',
        'Retail' => 'sales',
        'Science' => 'science',
        'Religion' => 'religion_spirituality',
        'Spirituality' => 'religion_spirituality',
        'Sports' => 'sports',
        'Technology' => 'technology',
        'Other' => 'other',
        'Miscellaneous' => 'other'
  }

  def recommend
    respond_to do |f|

      f.json do
        if params["request"]["intent"]
          case params["request"]["intent"]["name"]

          when "WingItIntent"
            render json: create_response(get_location)
          when "SetCityIntent"
            city = get_city_from_json
            user_id = get_user_id
            @user = User.find_or_initialize_by(user_id: user_id)
            @user.city = city
            @user.save
            render json: build_city_set_response(@user)
          when "AMAZON.HelpIntent"
            render json: ask_help
          when 'SetCategoryIntent'
            render json: category_search_response
          when "CategoryHelpIntent"
            render json: category_help_response
          end
        else
          render json: create_response(get_location)
        end
      end
    end
  end

end
