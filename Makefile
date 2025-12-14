REPO_NAME=proto
REPO_GEN_NAME=gen
BUF_VERSION=v1.61.0

GOPATH := $(shell go env GOPATH)
GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

APP_NAME ?= service
APP_VERSION ?= v1

.PHONY: setup install-deps install-go repo buf-ci generate clean-gen

setup: install-deps repo buf-ci
	@echo "Setup Started"
	make install-go
	@echo "Setup completed successfully."

install-deps:
	@echo "Installing dependencies..."
	sudo apt update
	sudo apt install -y protobuf-compiler curl unzip git

	@echo "Installing buf for $(GOOS)-$(GOARCH) into $(GOPATH)/bin ..."
	@if [ -x "$(GOPATH)/bin/buf" ]; then \
		echo "buf already installed, skipping..."; \
	else \
		mkdir -p $(GOPATH)/bin; \
		curl -sSL https://github.com/bufbuild/buf/releases/download/$(BUF_VERSION)/buf-$(GOOS)-x86_64 \
			-o $(GOPATH)/bin/buf; \
		chmod +x $(GOPATH)/bin/buf; \
		echo "buf installed."; \
	fi

	@echo "Dependencies installed."

install-go:
	@echo Installing go dependencies...
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/yoheimuta/protolint/cmd/protolint@latest

repo:
	@echo "Creating repository structure..."
	@echo "APP_NAME=$(APP_NAME)"
	@echo "APP_VERSION=$(APP_VERSION)"

	mkdir -p ./proto/$(APP_NAME)/$(APP_VERSION)
	@echo "Creating generated repository for golang..."
	mkdir -p ./gen/go

	@echo "Creating default proto files..."
	@if [ ! -f "./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto" ]; then \
		echo "syntax = \"proto3\";" > ./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto; \
		echo "package $(APP_NAME).$(APP_VERSION);" >> ./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto; \
		echo "option go_package = \"gen/go/$(APP_NAME)/$(APP_VERSION);$(APP_NAME)$(APP_VERSION)\";" >> ./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto; \
		echo "" >> ./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto; \
		echo "// Define your entity messages here" >> ./proto/$(APP_NAME)/$(APP_VERSION)/entity.proto; \
		echo "entity.proto created."; \
	else \
		echo "entity.proto already exists, skipping."; \
	fi

	@if [ ! -f "./proto/$(APP_NAME)/$(APP_VERSION)/service.proto" ]; then \
		echo "syntax = \"proto3\";" > ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "package $(APP_NAME).$(APP_VERSION);" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "option go_package = \"gen/go/$(APP_NAME)/$(APP_VERSION);$(APP_NAME)$(APP_VERSION)\";" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "import \"$(APP_NAME)/$(APP_VERSION)/entity.proto\";" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "// Define your service RPCs here" >> ./proto/$(APP_NAME)/$(APP_VERSION)/service.proto; \
		echo "service.proto created."; \
	else \
		echo "service.proto already exists, skipping."; \
	fi

	@echo "Repository directories created."

buf-ci:
	@echo "Initializing buf..."
	@if [ ! -f "./buf.yaml" ]; then \
		$(GOPATH)/bin/buf config init; \
	else \
		echo "buf.yaml already exists, skipping init"; \
	fi

	@echo "Fixing buf.yaml roots..."
	@if ! grep -q "^modules:" ./buf.yaml; then \
		printf "\nmodules:\n  - path: proto\n" >> ./buf.yaml; \
	fi

	@echo "Running buf CI (lint + breaking checks)..."
	$(GOPATH)/bin/buf lint
	$(GOPATH)/bin/buf breaking --against .

	@echo "buf initialized."

generate:
	@echo "Running buf generate..."
	$(GOPATH)/bin/buf generate
	@echo "Code generated."

clean-gen:
	rm -rf ./$(REPO_GEN_NAME)
	@echo "Repository Gen removed."