class Resources 
  ALL_RESOURCES = <<-eos
    {
      "resources": [
        {
          "name": "Computadora",
          "description": "Notebook con 4GB de RAM y 256 GB de espacio en disco con Linux",
          "links": [
            {
              "rel": "self",
              "uri": "http://localhost:9292/resources/1"
            }
          ]
        },
        {
          "name": "Monitor",
          "description": "Monitor de 24 pulgadas SAMSUNG",
          "links": [
            {
              "rel": "self",
              "uri": "http://localhost:9292/resources/2"
            }
          ]
        },
        {
          "name": "Sala de reuniones",
          "description": "Sala de reuniones con máquinas y proyector",
          "links": [
            {
              "rel": "self",
              "uri": "http://localhost:9292/resources/3"
            }
          ]
        },
        {
          "name": "ventilador",
          "description": "Ventilador de pie con astas metálicas",
          "links": [
            {
              "rel": "self",
              "uri": "http://localhost:9292/resources/10"
            }
          ]
        }
      ],
      "links": [
        {
          "rel": "self",
          "uri": "http://localhost:9292/resources"
        }
      ]
  }
  eos

  FIRST_RESOURCE = <<-eos
    {
      "resource": {
        "name": "Computadora",
        "description": "Notebook con 4GB de RAM y 256 GB de espacio en disco con Linux",
        "links": [
          {
            "rel": "self",
            "uri": "http://localhost:9292/resources/1"
          },
          {
            "rel": "bookings",
            "uri": "http://localhost:9292/resources/1/bookings"
          }
        ]
      }
    }
    eos

  LAST_RESOURCE = <<-eos
    {
      "resource": {
        "name": "ventilador",
        "description": "Ventilador de pie con astas metálicas",
        "links": [
          {
            "rel": "self",
            "uri": "http://localhost:9292/resources/10"
          },
          {
            "rel": "bookings",
            "uri": "http://localhost:9292/resources/10/bookings"
          }
        ]
      }
    }
    eos
  RESOURCE_RESERVED = <<-eos
    {
      "bookings": [
        {
          "start": "2013-11-13T10:00:00Z",
          "end": "2013-11-13 T11:00:00Z",
          "status": "approved",
          "user": "sorgentini@gmail.com",
          "links": [
            {
              "rel": "self",
              "uri": "http://localhost:9292/resources/2/bookings/100"
            },
            {
              "rel": "resource",
              "uri": "http://localhost:9292/resources/2"
            },
            {
              "rel": "accept",
              "uri": "http://localhost:9292/resource/2/bookings/100",
              "method": "PUT"
            },
            {
              "rel": "reject",
              "uri": "http://localhost:9292/resource/2/bookings/100",
              "method": "DELETE"
            }
          ]
        },
        { 
          "start": "2013-11-13T11:00:00Z",
          "end": "2013-11-13T12:30:00Z",
          "status": "approved",
          "user": "robertoX@gmail.com",
          "links": [
              {
                "rel": "self",
                "uri": "http://localhost:9292/resources/2/bookings/102"
              },
              {
                "rel": "resource",
                "uri": "http://localhost:9292/resources/2"
              },          
              {
                "rel": "accept",
                "uri": "http://localhost:9292/resource/2/bookings/102",
                "method": "PUT"
              },
              {
                "rel": "reject",
                "uri": "http://localhost:9292/resource/2/bookings/102",
                "method": "DELETE"
              } 
           ]
        }
      ],
      "links": [
        {
          "rel": "self",
          "uri": "http://localhost:9292/resources/2/bookings?date=2013-11-14&limit=1&status=approved"
        }
      ]
    }
    eos
end
