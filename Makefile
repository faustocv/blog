override PROJECT_NAME = my-blog
override JEKYLL_IMAGE = jekyll/jekyll:3.8.5
override JEKYLL_GEMS = faustocv_github_io_gems:/usr/local/bundle

install:
	docker container run \
	    --rm \
	    --name $(PROJECT_NAME)-install \
	    -it \
	    -v $(shell pwd):/srv/jekyll \
	    -v $(JEKYLL_GEMS) \
	    $(JEKYLL_IMAGE) \
	    bundle install

run:
	docker container run \
	    --rm \
	    --name $(PROJECT_NAME)-run \
	    -it \
	    -v $(shell pwd):/srv/jekyll \
	    -v $(JEKYLL_GEMS) \
	    -p 4000:4000 \
	    $(JEKYLL_IMAGE) \
	    bundle exec jekyll serve --host 0.0.0.0


ssh:
	docker container run \
	    --rm \
	    --name $(PROJECT_NAME)-ssh \
	    -it \
	    -v $(shell pwd):/srv/jekyll \
	    -v $(JEKYLL_GEMS) \
	    $(JEKYLL_IMAGE) \
	    bash


build:
	docker container run \
	    --rm \
	    --name $(PROJECT_NAME)-build \
	    -it \
	    -v $(shell pwd):/srv/jekyll \
	    -v $(JEKYLL_GEMS) \
	    $(JEKYLL_IMAGE) \
	    bundle exec jekyll build -t


htmlproofer: build
	docker container run \
	    --rm \
	    --name $(PROJECT_NAME)-htmlproofer \
	    -it \
	    -v $(shell pwd):/srv/jekyll \
	    -v $(JEKYLL_GEMS) \
	    $(JEKYLL_IMAGE) \
	    sh -c "htmlproofer ./_site --disable-external --trace"
