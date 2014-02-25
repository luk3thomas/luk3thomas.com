class GzipAssets < Middleman::Extension
  def initialize(app, options={}, &block)
    super
    app.after_build do |builder|
      builder.run %q!find build | egrep '(css|js|xml|html|htm)$' | awk '{print "gzip -c -9 "$1" > "$1".gz"}' | sh!
    end
  end
end

::Middleman::Extensions.register :gzip_assets, GzipAssets
