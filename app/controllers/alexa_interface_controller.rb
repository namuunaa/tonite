class AlexaInterfaceController < ApplicationController


  def recommend

    @lookup_hash = {
          'music' => 'music',
          'concerts' => 'music',
          'tour dates' => 'music',
          'conferences' => 'conference',
          'tradeshows' => 'conference',
          'comedy' => 'comedy',
          'education' => 'learning_education',
          'kids' => 'family_fun_kids',
          'family' => 'family_fun_kids',
          'festivals' => 'festivals_parades',
          'film' => 'movies_film',
          'movies' => 'movies_film',
          'food' => 'food',
          'restaurants' => 'food',
          'fundraising' => 'fundraisers',
          'fundraisers' => 'fundraisers',
          'charity' => 'fundraisers',
          'art' => 'art',
          'art galleries' => 'art',
          'galleries' => 'art',
          'exhibits' => 'art',
          'health' => 'support',
          'wellness' => 'support',
          'holiday' => 'holiday',
          'literary' => 'books',
          'literature' => 'books',
          'books' => 'books',
          'museums' => 'attractions',
          'attractions' => 'attractions',
          'neighborhood'=> 'community',
          'community' => 'community',
          'business' => 'business',
          'networking' => 'business',
          'nightlife' => 'singles_social',
          'clubbing' => 'singles_social',
          'singles' => 'singles_social',
          'university' => 'schools_alumni',
          'alumni' => 'schools_alumni',
          'organizations' => 'clubs_associations',
          'meetups' => 'clubs_associations',
          'outdoors' => 'outdoors_recreation',
          'recreation' => 'outdoors_recreation',
          'performing Arts' => 'performing_arts',
          'pets' => 'animals',
          'politics' => 'politics_activism',
          'activism' => 'politics_activism',
          'sales' => 'sales',
          'retail' => 'sales',
          'science' => 'science',
          'religion' => 'religion_spirituality',
          'spirituality' => 'religion_spirituality',
          'sports' => 'sports',
          'technology' => 'technology',
          'tech' => 'technology',
          'other' => 'other',
          'miscellaneous' => 'other'
    }

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
            render json: general_help_response
          when 'SetCategoryIntent'
            render json: category_search_response(@lookup_hash)
          when "CategoryHelpIntent"
            render json: category_help_response(@lookup_hash)
          when 'CityHelpIntent'
            render json: city_help_response(params["session"]["user"]["userId"])
          end
        else
          render json: create_response(get_location)
        end
      end
    end
  end

end
