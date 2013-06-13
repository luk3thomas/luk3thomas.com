def categories 
  collection = []
  sitemap.resources.each do |r|
    collection << r.metadata[:page]["category"] if !r.metadata[:page]["category"].nil?
  end
  collection.sort.uniq
end

def categorized_as str
  filter_content "category", str
end

def all_pages
  filter_content "layout", "page"
end

def all_posts
  filter_content "layout", "post"
end

def title resource
  resource.metadata[:page]["title"]
end

def date resource, format = "%b %d, %Y"
  date = Date.strptime resource.path.split('/')[0..2].join('-'), '%Y-%m-%d'
  date.strftime format
end

# returns all resources with a particular layout
def filter_content key, value
  collection = []
  sitemap.resources.each do |r|
    collection << r if r.metadata[:page][key] == value
  end
  collection.reverse
end
