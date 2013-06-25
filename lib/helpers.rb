def categories 
  collection = []
  sitemap.resources.each do |r|
    collection << r.metadata[:page]["category"] if !r.metadata[:page]["category"].nil?
  end
  collection.sort.uniq
end

def tags category
  collection = []
  posts = filter_content "category", category
  posts.each do |post|
    collection << post.metadata[:page]["tag"]
  end
  collection.uniq.sort {|a,b| a.downcase <=> b.downcase}
end

def categorized_as str
  filter_content "category", str
end

def tagged_as str
  filter_content "tag", str
end

def all_pages
  filter_content "layout", "page"
end

def all_posts
  filter_content "layout", "post"
end

def blog_path 
  '/notes.html'
end

def recent_posts n = 5
  all_posts[0..n-1]
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
  posts = []
  collection = []
  sitemap.resources.each {|r| posts << r unless r.metadata[:page][key].nil?}
  posts.each do |post|
    if value.kind_of? Array
      value.each do |s|
        collection << post unless post.metadata[:page][key].index( s ).nil?
      end
    else
      collection << post if post.metadata[:page][key] == value
    end
  end
  collection.uniq.reverse
end
