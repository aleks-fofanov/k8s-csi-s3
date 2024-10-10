# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
.PHONY: test build container push clean

REGISTRY_NAME=cr.selcloud.ru
IMAGE_NAME ?= csi-s3
VERSION ?= 0.41.1
REPO=$(REGISTRY_NAME)/$(IMAGE_NAME)
IMAGE_TAG=$(REPO):$(VERSION)

CWD=$(shell pwd)
export BUILD_CTX?=$(CWD)

build:
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o _output/s3driver ./cmd/s3driver

test:
	docker build -t $(TEST_IMAGE_TAG) -f test/Dockerfile .
	docker run --rm --privileged -v $(PWD):/build --device /dev/fuse $(TEST_IMAGE_TAG)

container:
	docker buildx build \
		$(if $(PUSH_IMAGE),--push,--load) \
		-f $(BUILD_CTX)/Dockerfile \
		--tag $(IMAGE_TAG) \
		$(BUILD_CTX)

push: container
	docker push $(IMAGE_TAG)

clean:
	go clean -r -x
	-rm -rf _output
