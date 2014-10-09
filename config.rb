###
# Compass
###

require './lib/helpers.rb'

scripts = Dir.entries('./source/javascripts/canvas/')
  .select {|f| !(/^\./ =~ f) }  # exclude vim swp files and . .. directories
  .map { |f| Canvas.new(f) }

arts = Dir.entries('./source/javascripts/art/')
  .select {|f| !(/^\./ =~ f) }  # exclude vim swp files and . .. directories
  .map { |f| Art.new(f) }

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

data.posts.each do |slug, post|
  proxy "/#{permalink(slug)}", "/notes/single.html", locals: { post: post , slug: slug}, ignore: true, layout: :post
end

data.labs.each do |slug, post|
  proxy "/labs/#{permalink(slug)}", "/labs/single.html", locals: { post: post, slug: slug }, ignore: true, layout: :labs
end

data.books.each do |slug, book|
  proxy "/books/#{permalink(slug)}", "/books/show.html", locals: { book: book, title: book.title }, ignore: true, layout: :full
end

# Dynamic canvas labs
#
proxy "/canvas/index.html", "/canvas/list.html", ignore: true, locals: {pages: scripts}, layout: :full
proxy "/art/index.html", "/art/list.html", ignore: true, locals: {pages: arts}, layout: :full

scripts.each do |script|
  proxy script.permalink, "/canvas/single.html", locals: { script: script }, ignore: true, layout: :canvas
end

page '/sitemap.xml', layout: false

configure :build do
  ignore 'labs/data/*.html'
  ignore 'stylesheets/theme/**'
  activate :minify_css
  activate :asset_hash
end
