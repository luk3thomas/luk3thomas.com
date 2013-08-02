class GzipSitemap < Middleman::Extension
  def initialize(app, options={}, &block)
    super
    app.after_build do |builder|
      builder.run 'gzip -c ./build/sitemap.xml > ./build/sitemap.xml.gz'
    end
  end
end

::Middleman::Extensions.register :gzip_sitemap, GzipSitemap
