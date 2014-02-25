###
# Compass
###

require './lib/helpers.rb'
require './lib/gzip_assets.rb'

activate :gzip_assets

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

data.posts.each do |slug, post|
  proxy "/#{permalink(slug)}", "/notes/single.html", locals: { post: post , slug: slug}, ignore: true, layout: :post
end

data.labs.each do |slug, post|
  proxy "/labs/#{permalink(slug)}", "/labs/single.html", locals: { post: post, slug: slug }, ignore: true, layout: :labs
end

set :haml, { ugly: true }

page '/sitemap.xml', layout: false

configure :build do
  ignore 'labs/data/*.html'
  activate :minify_css
  activate :asset_hash
end
