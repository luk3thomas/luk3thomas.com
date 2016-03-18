.PHONY: build
help:
	@cat Makefile | grep '^[A-z]' | column -t -s '#' | sed 's/://' | egrep '^[A-z]+ '

start: # Start the web server
	bundle exec middleman server --port 4568

deploy: # Deploy to S3 and push to github
	@git stash
	@make build
	@make sync
	@git push origin master
	@git push origin --tags
	@git stash pop

build: # Run middleman build
	bundle exec middleman build

sync: # Sync everything to s3
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --cache-control="max-age=1576800000" --exclude "*.html"
	@aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --cache-control="max-age=0, no-cache" --exclude "*" --include "*.html"
