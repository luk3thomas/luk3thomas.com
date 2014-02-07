.PHONY: build
start:
	bundle exec middleman server --reload-paths="data/,lib/"

build:
	bundle exec middleman build

deploy:
	@bundle exec middleman build
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=1576800000" --exclude "*.html"
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=0, no-cache" --exclude "*" --include "*.html"

release:
	@git flow release start $(R)
	@git flow release finish $(R)
	@git checkout develop

push:
	@git push origin
	@git push origin --tags
