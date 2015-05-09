class User < ActiveRecord::Base

	def self.koala(auth)
    access_token = auth['token']
    facebook = Koala::Facebook::API.new(access_token)
    facebook.get_object("me?fields=name,picture")
  end

  def self.large_pic(auth)
  	@graph = Koala::Facebook::API.new(auth)
  	@pic = @graph.get_picture("me", type: "large")
  end

  def self.likes(auth)
  	@graph = Koala::Facebook::API.new(auth)
  	@graph.get_connections("me", "likes")
  end

  # Returns: first elem is the user's score, second is word stating score, third is best statemene, fourth is worst
  def self.post_sentiment(auth)
  	@graph = Koala::Facebook::API.new(auth)
  	posts = @graph.get_connection("me", "posts", {limit: 100, fields: ['message']})

  	return_arr = []
  	total_sentiment = 0
  	posts_assesed = 0
  	returned_msg = []
  	score_description = ""
  	best_post = ""
  	worst_post = ""
  	best_post_score = -100
  	worst_post_score = 100

  	posts.each do |p|
  		p = p['message']

  		# Remove quotes
  		p = p.to_s.gsub(/[^0-9a-z ]/i, '')
  		#p = p.gsub(/!|!/, '').gsub(/\s/, '')
  		#p = p.gsub(/.|./, '').gsub(/\s/, '')
	  	response = Unirest.get "https://loudelement-free-natural-language-processing-service.p.mashape.com/nlp-text/?text=#{p.split(" ").join("+")}",
	  headers:{
	    "X-Mashape-Key" => "ghqVuuYYTkmshAIuFs6Fi6vqcgd5p12KTmTjsnGi1UPXLMYHDl",
	    "Accept" => "application/json"
	  }

	  if response.body['sentiment-score'] != nil

	  	if response.body['sentiment-score'] > best_post_score
	  		best_post = p
	  		best_post_score = response.body['sentiment-score']
	  	end

	  	if response.body['sentiment-score'] < worst_post_score
	  		worst_post = p
	  		worst_post_score = response.body['sentiment-score']
	  	end

	  	if response.body['sentiment-score'] > 5
	  		total_sentiment += 5
	  	else
	  	total_sentiment += response.body['sentiment-score']
	  end
	  	posts_assesed += 1
	  	returned_msg << p
	  end
	end
	#return posts_assesed
	user_score = ((Float(total_sentiment) / Float(posts.count)) * 10) + 5

	if user_score <= 3
		score_description = "Horrible"
	elsif user_score <= 5
		score_description = "Decent Person"
	elsif user_score <= 7
		score_description = "Kinda Nice"
	elsif user_score <= 8
		score_description = "Really Nice"
	elsif user_score < 9.5
		score_description = "Extremely Nice"
	else
		score_description = "Everyone's BFF"
	end

	return_arr[0] = user_score
	return_arr[1] = score_description
	return_arr[2] = best_post
	return_arr[3] = worst_post

	return return_arr
  end

end
