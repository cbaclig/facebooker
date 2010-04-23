require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../rails_test_helper')

class FooController < ActionController::Base
  include Facebooker::Rails::Controller
  before_filter :set_facebook_session

  def index
	render :text => 'hi'
  end
end

class FooControllerTest < ActionController::TestCase


  def setup
    ENV['FACEBOOK_APP_ID'] = '3873874' 
    ENV['FACEBOOK_API_KEY'] = '1234567'
    ENV['FACEBOOK_SECRET_KEY'] = '7654321'
  end

  def test_can_parse_session_from_new_style_cookies
    expected_uid = '1234'
    expected_session_key = '1234'
    expected_expires = (Time.now + 100000).to_i.to_s
    expected_secret = '234'
    expected_access_token = '120843857929094%7C2.ajT42K4m7n_u668NE_mvYQ__.3600.1271898000-216743%7Cbe913fezYRUUCEjvja28KZiTe0w.'
    expected_base_domain = 'testing.com'

    cookie_params = {
	:access_token => expected_access_token,
	:base_domain => expected_base_domain,
	:expires => expected_expires,
	:secret => expected_secret,
	:session_key => expected_session_key,
	:uid => expected_uid
    }
	
    raw_string = cookie_params.map{ |*args| args.join('=') }.sort.join
    expected_sig = Digest::MD5.hexdigest([raw_string, Facebooker::Session.secret_key].join)
    cookie_params[:sig] = expected_sig

    session_mock = mock('session')
    session_mock.expects('secure_with!').with(expected_session_key, expected_uid, expected_expires, expected_secret)
    @controller.stubs(:new_facebook_session).returns(session_mock)
    
    cookie = %Q{"#{cookie_params.map{|args| args.join('=') }.join('&')}"}
    key = "fbs_#{ENV['FACEBOOK_APP_ID']}"
    @request.cookies[key] = cookie
    get :index
  end

end

