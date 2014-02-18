# encoding: UTF-8
require 'test_helper'
# se testean las funcionalidades de la aplicación app.rb
class AppTest < Minitest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_get_all_resources
    server_response = get '/resources'
    assert_equal 200, last_response.status # Check wheather the server response is 200 OK
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8
    # This is what we expect the returned JSON to look like
    pattern = {
      resources: [
        {
          name:         /\S/,                    # Simple string
          description:  /\S/,                    # Simple string
          links: [
            {
              rel:  "self",                   # The word 'self'
              uri:  /^\S*\/resources\/\d+$/,     # The uri of the resource, regEx "URL"/resources/"resource_id"
            }
          ]
        },
        {
          name:         /\S/,                    # Simple string
          description:  /\S/,                    # Simple string
          links: [
            {
              rel:  "self",                   # The word 'self'
              uri:  /^\S*\/resources\/\d+$/,     # The uri of the resource, regEx "URL"/resources/"resource_id"
            }
          ]
        },
        {
          name:         /\S/,                    # Simple string
          description:  /\S/,                    # Simple string
          links: [
            {
              rel:  "self",                   # The word 'self'
              uri:  /^\S*\/resources\/\d+$/,     # The uri of the resource, regEx "URL"/resources/"resource_id"
            }
          ]
        },
        {
          name:         /\S/,                    # Simple string
          description:  /\S/,                    # Simple string
          links: [
            {
              rel:  "self",                   # The word 'self'
              uri:  /^\S*\/resources\/\d+$/,     # The uri of the resource, regEx "URL"/resources/"resource_id"
            }
          ]
        },
      ],
      links: [
        {
          rel: "self",                         # The word 'self'
          uri: /^\S*\/resources/             # The uri of the resource, regEx
        }
      ]
    }
    assert_json_match pattern, server_response.body    # Chech wheather the server response folow the response pattern expected.
  end

  def test_get_one_resource
    server_response = get '/resources/2'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    # This is what we expect the returned JSON to look like
    pattern = {
      resource: {
        name:          /\S/,                 # Simple string
        description:   /\S/,                 # Simple string
        links: [
          {
            rel:  "self",                      # The word 'self'
            uri:  /^\S*\/resources\/2$/        # The uri of the resource, regEx  "URL"/resources/1
          },
          {
            rel:  "bookings",                  # The word 'bookings'
            uri:  /^\S*\/resources\/2\/bookings$/ # The uri of the resource, regEx  "URL"/resources/1/bookings
          }
        ]
      }
    }
    assert_json_match pattern, server_response.body    # Chech wheather the server response folow the response pattern expected.
  end

  def test_get_inexistent_resource
    get '/resources/100000'
    assert_equal 404, last_response.status
  end

  def test_get_bookings_arg_limit_date_status
    server_response = get '/resources/1/bookings'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8
    pattern = {
      bookings: [
        {
          from:     :from,
          to:       :to,
          status:   "approved",
          user:     /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
          links: [
            {
              rel:  "self",
              uri:  /^\S*\/resources\/\d\/bookings$/
            },
            {
              rel: "resource",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/
            },
            {
              rel: "accept",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "PUT"
            },
            {
              rel: "reject",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "DELETE"
            }
          ]
        }
      ],
      links: [
        {
          rel: "self",
          uri: /^\S*\/resources\/\d+\/bookings\?date=\d+\-\d+\-\d+\&limit=\d+\&status=approved$/
        }
      ]
    }

    assert_json_match(pattern, server_response.body)
  end

  def test_get_bookings_the_bookings_exists_all_parameters
    server_response = get %q(/resources/1/bookings?date=2013-11-13&limit=30&status=all)
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8

    pattern = {
      bookings: [
        {
          from:     '2013-11-13',
          to:       '2013-12-13',
          status:   ['approved' , 'pending' , 'canceled'],
          user:     /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
          links: [
            {
              rel:  "self",
              uri:  /^\S*\/resources\/\d\/bookings$/
            },
            {
              rel: "resource",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/
            },
            {
              rel: "accept",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "PUT"
            },
            {
              rel: "reject",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "DELETE"
            }
          ]
        }
      ],
      links: [
        {
          rel: "self",
          uri: /^\S*\/resources\/\d+\/bookings\?date=\d+\-\d+\-\d+\&limit=\d+\&status=(approved|pending|canceled)$/
        }
      ]
    }
    assert_json_match(pattern, server_response.body)
  end

  def test_get_bookings_the_bookings_exists_pending
    server_response = get 'resources/2/bookings?date=2013-11-13&limit=30&status=pending'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8
    pattern = {
      bookings: [
        {
          from:     "2013-11-13",
          to:       "2013-12-13",
          status:   "pending",
          user:     /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
          links: [
            {
              rel:  "self",
              uri:  /^\S*\/resources\/\d\/bookings$/
            },
            {
              rel: "resource",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/
            },
            {
              rel: "accept",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "PUT"
            },
            {
              rel: "reject",
              uri: /^\S*\/resources\/\d\/bookings$\/\d$/,
              method: "DELETE"
            }
          ]
        }
      ],
      links: [
        {
          rel: "self",
          uri: /^\S*\/resources\/\d+\/bookings\?date=\d+\-\d+\-\d+\&limit=\d+\&status=pending$/
        }
      ]
    }
    assert_json_match(pattern, server_response.body)
  end

  def test_get_bookings_wrong_argument
    wrong_arguments = ['?date=2013-11-13&limit=366&status=pending', '?date=&limit=&status=', '?&limit=344&status=pendingh', '?date=2013-11-13&limit=0status=asda', '?datfkdfg&limit=1sfdfeqpending']
    wrong_arguments.each do |x|
      get "/resources/1/bookings#{x}"
      assert_equal 404, last_response.status
    end
  end

  def test_get_availability_wrong_argument
    wrong_arguments = ['?date=2013-11-13&limit=366', '?date=&limit=&status=', '?&limit=366', '?date=2013-1', '?datfkdfg&limit=1sfdfeqpending']
    wrong_arguments.each do |x|
      get "/resources/1/availability#{x}"
      assert_equal 404, last_response.status
    end
  end

  def test_get_bookings_the_bookings_exists_all_parameters
    server_response = get '/resources/1/availability?date=2013-11-12&limit=3'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8
    pattern = {
      availability: [
        {
          start:    "2013-11-12",
          end:      "2013-11-15",
          links: [
            {
              rel: "book",
              uri: /^\S*\/resources\/\d\/bookings$/,
              method: "POST"
            },
            {
              rel: "resource",
              uri: /.+\/resources\/\d$/
            }
          ]
        },
        {
          start:     wildcard_matcher,
          end:       wildcard_matcher,
          links: [
            {
              rel: "book",
              uri: /^\S*\/resources\/\d\/bookings$/,
              method: "POST"
            },
            {
              rel: "resource",
              uri: /.+\/resources\/1$/
            }
          ]
        },
        {
          start:     wildcard_matcher,
          end:       wildcard_matcher,
          links: [
            {
              rel: "book",
              uri: /^\S*\/resources\/\d\/bookings$/,
              method: "POST"
            },
            {
              rel: "resource",
              uri: /.+\/resources\/1$/
            }
          ]
        }
      ],
      links: [
        {
          rel: "self",
          uri:  /^\S*\/resources\/\d\/availability\?date=2013-11-12&limit=3$/
        }
      ]
    }
    assert_json_match(pattern, server_response.body)
  end

  def test_add_new_booking_wrogn_args
    wrong_arguments = ['?date=2013-1', '?datfkdfg&limit=1sfdfeqpending']
    wrong_arguments.each do |x|
      get "/resources/1/availability#{x}"
      assert_equal 404, last_response.status
    end
  end

  def test_add_new_booking
    server_response = post'/resources/2/bookings', from: '2013-11-12T00:00:00Z', to: '2013-11-13T11:00:00Z'
    assert_equal 201, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type'] # Check wheather the server response is json stuff codded as utf-8
    pattern = {
      book:
        {
          start:    "2013-11-12T00:00:00Z",
          end:      "2013-11-13T11:00:00Z",
          status: "pending",
          user: /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
          links: [
            {
              rel: "self",
              url: /^\S*\/resources\/1\/\d/
            },
            {
              rel: "accept",
              uri: /^\S*\/resources\/1\/bookings\/\d/,
              method: "PUT"
            },
            {
              rel: "reject",
              uri: /^\S*\/resources\/1\/bookings\/\d/,
              method: "DELETE"
            }
          ]
        }
      }
    assert_json_match(pattern, server_response.body)
  end

  def test_cancel_booking
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z', to: '2000-11-13T00:00:00Z'
    last_booking = Request.last
    delete "/resources/1/bookings/#{last_booking.id}"
    assert_equal 200, last_response.status
    assert_equal '', last_response.body
  end

  def test_cancel_inexsistent
    delete '/resources/1/bookings/3000'
    assert_equal 404, last_response.status
    assert_equal '', last_response.body
  end

  def test_accept_booking
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z', to: '2000-11-13T00:00:00Z'
    last_booking = Request.last
    server_response = put "/resources/1/bookings/#{last_booking.id}"
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   # Check wheather the server response is json stuff codded as utf-8
    pattern = {
    book:
    {
        start: "2000-11-12T00:00:00Z",
        end: "2000-11-13T00:00:00Z",
        status: "approved",
        user: /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
        links: [
        {
          rel: "self",
          url: /^\S*\/resources\/1\/bookings\/\d/
        },
        {
          rel: "accept",
          uri: /^\S*\/resources\/1\/bookings\/\d/,
          method: "PUT"
        },
        {
          rel: "reject",
          uri: /^\S*\/resources\/1\/bookings\/\d/,
          method: "DELETE"
        },
        {
          rel: "resource",
          url: /^\S*\/resources\/1/
        }
      ]
    }
    }
    assert_json_match(pattern, server_response.body)
    Delete '/resources/1/bookings/#{last_booking.id}'
  end

  def test_accept_inexistent_booking
    put '/resources/1/bookings/100000'
    assert_equal 404, last_response.status
  end

  def test_accept_booking_with_conficts
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z', to: '2000-11-13T00:00:00Z'
    first_booking = Request.last
    put "/resources/1/bookings/#{first_booking .id}"
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z', to: '2000-11-13T00:00:00Z'
    assert_equal 404, last_response.status
  end

  def test_accept_booking_and_cancel_the_others
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z',to: '2000-12-13T00:00:00Z'
    first_booking = Request.last
    post '/resources/1/bookings', from: '2000-11-13T00:00:00Z',to: '2000-11-16T00:00:00Z'
    second_booking = Request.last
    put "/resources/1/bookings/#{first_booking.id}"
    assert_equal 'rejected', second_booking.status
  end

  def test_booking_show
    post '/resources/1/bookings', from: '2000-11-12T00:00:00Z',to: '2000-11-13T00:00:00Z'
    last_booking = Request.last
    server_response = get "/resources/1/bookings/#{last_booking.id}"
    pattern = {
      start: "2000-11-12T00:00:00Z",
      end: "2000-11-13T00:00:00Z",
      status: "pending",
      user: /^[a-zA-Z,_,\d,\.]+\@.+\..+/,
      links: [
        {
          rel: "self",
          uri: /^\S*\/resources\/1\/bookings\/\d/
        },
        {
          rel: "resource",
          uri: /^\S*\/resources\/1/        
        },
        {
          rel: "accept",
          uri: /^\S*\/resources\/1\/bookings\/\d/,
          method: "PUT"
        },
        {
          rel: "reject",
          uri: /^\S*\/resources\/1\/bookings\/\d/,
          method: "DELETE"
        }
      ]
    }
    assert_json_match(pattern, server_response.body)
  end
end
