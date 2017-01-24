
build:
	docker build -t bee42/docker-1-13:docker-meetup-bochum-20170125 .

test: build
	@docker run -it --rm -p 8000:8000 bee42/docker-1-13:docker-meetup-bochum-20170125

publish: build
	@docker push bee42/docker-1-13:docker-meetup-bochum-20170125

develop:
	@docker run -it --rm -p 8000:8000 -p 35729:35729 \
	-v $$(pwd)/index.html:/reveal.js/index.html:ro \
	-v $$(pwd)/media:/reveal.js/media:ro \
	-v $$(pwd)/md:/reveal.js/md:ro \
	-v $$(pwd)/menu:/reveal.js/plugin/menu:ro \
	-v $$(pwd)/images:/reveal.js/images:ro \
	nbrown/revealjs:3.3.0
