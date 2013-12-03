start:
	bundle exec middleman server --reload-paths="data/,lib/"

deploy:
	@bundle exec middleman build
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=1576800000" --exclude "*.html"
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=0, no-cache" --exclude "*" --include "*.html"

push:
	@git push origin
	@git push origin --tags
