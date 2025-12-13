# Proto Repository

## Overview

Proto is a repository designed to provide utilities and tools for working with protocol buffers and managing collections of proto definitions.

## Purpose

1. **Proto Collections** - Manage and organize collections of protocol buffer definitions
2. **Generate Proto** - Generate protocol buffer code for Go using buf

## Getting Started

### Prerequisites

- Go installed on your system
- System packages: `protobuf-compiler`, `curl`, `unzip`, `git`

### Initialization Steps

To initialize the project, use the following commands from the Makefile:

1. **Setup the development environment** (installs all dependencies and initializes the project):

   ```bash
   make setup
   ```

2. **Generate proto files:**

   ```bash
   make generate
   ```

3. **Clean generated artifacts:**
   ```bash
   make clean-gen
   ```

### Additional Commands

- `make install-deps` - Install system and Go dependencies
- `make install-go` - Install Go protoc plugins
- `make repo` - Create repository structure with default proto files
- `make buf-ci` - Initialize and validate buf configuration

## Features

- **Proto Collections Management**: Organize protocol buffer definitions with versioning support
- **Go Code Generation**: Generate Go code from proto files using buf
- **Build Automation**: Makefile-driven setup and generation workflows
- **buf Integration**: Automated linting and breaking change detection
- **Default Templates**: Auto-generated `entity.proto` and `service.proto` starter files

## Configuration

The project uses `buf.yaml` for protocol buffer configuration and code generation settings. Customize `APP_NAME` and `APP_VERSION` variables when running `make repo` to structure your proto files.
