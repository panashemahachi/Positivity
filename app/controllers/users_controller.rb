class UsersController < ApplicationController
  def index
  end

  def login
  	token = request.env['omniauth.auth']['credentials']['token']
  	@user = User.koala(request.env['omniauth.auth']['credentials'])

  	@graph = Koala::Facebook::API.new(request.env['omniauth.auth']['credentials']['token'])
  	#@sentiment_score = User.post_sentiment(request.env['omniauth.auth']['credentials']['token'])
  	@pic = User.large_pic(request.env['omniauth.auth']['credentials']['token'])

  	sentiment_data = User.post_sentiment(request.env['omniauth.auth']['credentials']['token'])
  	@user_score = sentiment_data[0]
  	@user_score_description = sentiment_data[1]
  	@best_post = sentiment_data[2]
  	@worst_post = sentiment_data[3]
  end
end
