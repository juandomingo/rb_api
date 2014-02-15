# encoding: UTF-8
require 'test_helper'

# se testean las funcionalidades de la aplicación app.rb en /
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

  tomorrow = Date.today.next.iso8601
  next_month =  Date.today.next_day(30).iso8601
  next_year =  Date.today.next_day(365).iso8601

  #Test for get '/resources' test
  #
  #
  def test_get_all_resources
    server_response = get '/resources'
    assert_equal 200, last_response.status   #Check wheather the server response is 200 OK
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    # This is what we expect the returned JSON to look like
    pattern = {
      resources: {
        name:         string,                    # Simple string
        description:  string,                    # Simple string
        links: [
          {
            rel:  "self"                   # The word 'self'
            uri:  /^\S*\/resources\/\d+$/,      # The uri of the resource, regEx "URL"/resources/"resource_id"
            }
          ]
        }
      ],
            links: [
        {
          rel: "self",                         # The word 'self'
          uri: /^\S*\/resources\//             # The uri of the resource, regEx
        }
      ]
    }
    assert_json_match pattern, server_response.body    # Chech wheather the server response folow the response pattern expected.
  end

  #Test for get '/resources/:id' test
  #
  #
  def test_get_one_resource
    server_response = get '/resources/1'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    # This is what we expect the returned JSON to look like
    pattern = {
      resource: {
        name:          String,                 # Simple string
        description:   String,                 # Simple string
        links: [
          {
            rel:  "self",                      # The word 'self'
            uri:  /^\S*\/resources\/1$/        # The uri of the resource, regEx  "URL"/resources/1
          },
          {
            rel:  "bookings",                  # The word 'bookings'
            uri:  /^\S*\/resources\/1\/bookings$/ # The uri of the resource, regEx  "URL"/resources/1/bookings
          }
        ]
      }
    }
    assert_json_match pattern, server_response.body    # Chech wheather the server response folow the response pattern expected.
  end

  def test_get_inexistent_resource         
    server_response = get '/resources/100000'             
    assert_equal 404, last_response.status
    assert_equal 'Not Found', last_response.body 
  end


  #Test for get GET /resources/1/bookings?date='YYYY-MM-DD&limit=30&status=all' test
  #
  #
  def test_get_bookings_arg_limit_date_status
    server_response = get %q(/resources/1/bookings)
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    server_response = get %q(/resources/1/bookings)
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
    assert_block( matcher.captures[:from] >= tomorrow )
    assert_block( matcher.captures[:to] <= next_month )
    
    assert_json_match(pattern, server_response.body)
  end
    date: fecha a partir de la cuál se debe verificar la disponibilidad. Si no se especifica se asume la fecha de mañana.
    limit: cantidad de días para los cuales considerar la búsqueda. Si no se especifica se asume 30. Este valor no podrá ser mayor que 365.
    status: pending|approved|all por defecto se asume approved.

  def test_get_bookings_the_bookings_exists_all_parameters
    server_response = get %q(/resources/1/bookings?date=2013-11-13&limit=30&status=all)
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    
      pattern = {
      bookings: [
        {
          from:     2013-11-13,
          to:       2013-12-13,
          status:   ['approved' , 'pending' , 'rejected']
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
          uri: /^\S*\/resources\/\d+\/bookings\?date=\d+\-\d+\-\d+\&limit=\d+\&status=(approved|pending|rejected))$/
        }
      ]
    }
    assert_json_match(pattern, server_response.body)
  end

  def test_get_bookings_the_bookings_exists_pending
    server_response = get %q(/resources/1/bookings?date=2013-11-13&limit=30&status=pending)
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    pattern = {
      bookings: [
        {
          from:     2013-11-13,
          to:       2013-12-13,
          status:   "pending"
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
    wrong_arguments = ['asdfsd','date=2013-11-13&limit=333&status=pending','?date=2013-11-13&limit=366&status=pending','?date=&limit=&status=','?&limit=344&status=pending','?date=2013-11-13&limit=0status=asda','?date=201-11-13&limit=10&status=pending','?datfkdfg&limit=1sfdfeqpending' ]
    wrong_arguments.each { |x|  get "/resources/1/bookings#{x}";assert_equal 400, last_response.status;assert_equal 'Bad request', last_response.body }
  end

  def test_get_availability_wrong_argument
    Wrong_arguments = ['asdfsd','date=2013-11-13&limit=333&status=pending','?date=2013-11-13&limit=366&','?date=&limit=&status=','?&limit=366','?date=2013-1','?datfkdfg&limit=1sfdfeqpending' ]
    wrong_arguments.each { |x|  get "/resources/1/availability#{x}";assert_equal 400, last_response.status;assert_equal 'Bad request', last_response.body }
  end

  def test_get_bookings_the_bookings_exists_all_parameters
    server_response = get '/resources/1/availability?date=2013-11-12&limit=3'
    assert_equal 200, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    pattern = {
      availability: [
        {
          from:    "2013-11-12",
          to:      "2013-11-15"
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
          from:     :from1,
          to:       :to1,
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
          from:     :from2,
          to:       :to2,
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
    [1,2].each { |x| ssert_block( matcher.captures[":from#{x}"] >= tomorrow, assert_block( matcher.captures[":to#{x}"] <= next_month ) )
    assert_json_match(pattern, server_response.body)
  end

  def test_add_new_booking_wrogn_args
    Wrong_arguments = ['asdfsd','date=2013-11-13&limit=333&status=pending','from:2013-11-12T00:00:00Zto:2013-11-13T11:00:00Z','?from:2013-11-12T00:00:00Zto:2013-11-13T11:00:00Z','?date=2013-1','?datfkdfg&limit=1sfdfeqpending' ]
    wrong_arguments.each { |x|  get "/resources/1/availability#{x}";assert_equal 400, last_response.status;assert_equal 'Bad request', last_response.body }
  end    
  def test_add_new_booking
    server_response = post'/resources/1/bookings?from:2013-11-12T00:00:00Zto:2013-11-13T11:00:00Z'
    assert_equal 201, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    pattern = {
      "book":
        {
          "from":    "2013-11-12T00:00:00Z",
          "to":      "2013-11-13T11:00:00Z",
          "status": "pending",
          "links": [
            {
              "rel": "self",
              "url": /^\S*\/resources\/1\/\d/
            },
            {
              "rel": "accept",
              "uri": /^\S*\/resources\/1\/booking\/\d/,
              "method": "PUT"
            },
            {
              "rel": "reject",
              "uri": "/^\S*\/resources\/1\/booking\/\d/",
              "method": "DELETE"
            }
          ]
        }
      }
      assert_json_match(pattern, server_response.body)
  end

  def test_cancel_booking
    POST '/resources/1/bookings?from:2000-11-12T00:00:00Z&to:2000-11-13T00:00:00Z'
    Request.last
    DELETE '/resources/1/bookings/#{bk1.id}'
    assert_equal 200, last_response.status
    assert_equal '', last_response.body
  end
  def test_cancel_inexsistent
    DELETE '/resources/1/bookings/3000'
    assert_equal 404, last_response.status
    assert_equal 'Not Found', last_response.body
  end
  
  def test_accept_booking
    POST '/resources/1/bookings?from:2000-11-12T00:00:00Z&to:2000-11-13T00:00:00Z'
    Request.last
    PUT '/resources/1/bookings/#{bk1.id}'
    server_response = PUT /resources/1/bookings/100
    assert_equal 201, last_response.status
    assert_equal 'application/json;charset=utf-8', last_response.headers['Content-Type']   #Check wheather the server response is json stuff codded as utf-8
    pattern = {
    "book":
    {
        "from": "2000-11-12T00:00:00Z",
        "to": "2000-11-13T11:00:00Z",
        "status": "apporved",
        "links": [
        {
          "rel": "self",
          "url": /^\S*\/resources\/1\/booking\/\d/
        },
        {
          "rel": "accept",
          "uri": /^\S*\/resources\/1\/booking\/\d/,
          "method": "PUT"
        },
        {
          "rel": "reject",
          "uri": /^\S*\/resources\/1\/booking\/\d/,
          "method": "DELETE"
        },
        {
          "rel": "resource",
          "url": /^\S*\/resources\/1/
        }      
      ]
    }
    }
    assert_json_match(pattern, server_response.body)
  end

end