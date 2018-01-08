###
# Compass
###

require './lib/helpers.rb'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

data.posts.each do |slug, post|
  proxy "/#{permalink(slug)}", "/notes/single.html", locals: { post: post , slug: slug}, ignore: true, layout: :post
end

data.labs.each do |slug, post|
  proxy "/labs/#{permalink(slug)}", "/labs/single.html", locals: { post: post, slug: slug }, ignore: true, layout: :labs
end

data.quotes.each do |slug, quote|
  proxy "/quotes/#{permalink(slug)}", "/quotes/show.html", locals: { quote: quote, title: quote.title }, ignore: true, layout: :full
end

data.talks.each do |talk|
  proxy talk.href, "/talks/show.html", locals: { talk: talk }, ignore: true, layout: :talk
end

page '/books/*', layout: :books
page '/sitemap.xml', layout: false

configure :build do
  ignore 'labs/data/*.html'
  ignore 'talks/talks/*'
  ignore 'stylesheets/theme/**'
  activate :minify_css
  activate :asset_hash
end
