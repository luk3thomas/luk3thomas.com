###
# Compass
###

require './lib/helpers.rb'
require './lib/gzip_sitemap.rb'

activate :gzip_sitemap

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

data.posts.each do |name, post|
  proxy "/#{name.gsub(/^([0-9]{4})-([0-9]{2})-([0-9]{2})-/, '\1/\2/\3/')}.html", "/posts/single.html", locals: { post: post }, ignore: true, layout: :post
end

set :haml, { ugly: true }
activate :syntax

configure :build do
  activate :minify_css
  activate :syntax
  activate :asset_hash
end
