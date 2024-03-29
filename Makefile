IMAGE_TAG=wildducktheories/quora-spam
VERSION=$(shell ./quora-spam version)

build:
	docker build --build-arg VERSION=$(VERSION) -t $(IMAGE_TAG):$(VERSION) .
	docker tag $(IMAGE_TAG):$(VERSION) $(IMAGE_TAG):latest

publish: build
	docker push $(IMAGE_TAG):$(VERSION)

publish-as-latest: publish
	docker push $(IMAGE_TAG):latest
