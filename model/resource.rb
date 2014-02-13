class Resource < ActiveRecord::Base

  def to_json(link)
    res = to_hash link
    res[:links] = [
      { rel: 'self', uri: link + "/resources/#{id}" },
      { rel: 'requests', uri: link + "/resources/#{id}/requests" }
    ]
    
  end

  def self.to_json(link)
    links = [rel: 'self', uri: link + '/resources']

    resources = Resource.all.map do |r|
      r.to_hash link
    end
    res = { resources: resources, links: links }
    JSON.pretty_generate(res)
  end

  def to_hash(link)
    {
      name: name, description: description,
      links: [rel: 'self', uri: link + "/resources/#{id}"]
    }
  end
end
