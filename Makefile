.PHONY: build
start:
	bundle exec middleman server --port 4568

deploy: stash build sync push pop

build:
	bundle exec middleman build

sync:
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --cache-control="max-age=1576800000" --exclude "*.html"
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --cache-control="max-age=0, no-cache" --exclude "*" --include "*.html"

release:
	@git flow release start $(R)
	@git flow release finish $(R)
	@git checkout develop

push:
	git push origin master
	git push origin --tags

stash:
	git stash

pop:
	git stash pop
