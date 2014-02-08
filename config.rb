###
# Compass
###

require './lib/helpers.rb'
require './lib/gzip_sitemap.rb'

activate :gzip_sitemap

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

data.posts.each do |name, post|
  proxy "/#{permalink(name)}", "/posts/single.html", locals: { post: post }, ignore: true, layout: :post
end

data.labs.each do |name, post|
  proxy "/labs/#{permalink(name)}", "/labs/single.html", locals: { post: post }, ignore: true, layout: :labs
end

set :haml, { ugly: true }

page '/sitemap.xml', layout: false

configure :build do
  ignore 'labs/data/*.html'
  activate :minify_css
  activate :asset_hash
end
