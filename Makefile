# Thanks, CoreDNS team!
VERSION := $(shell git describe --dirty --always)
TIMESTAMP := $(shell date +%s)
CGO_ENABLED := 1
BUILDPKG := github.com/mdlayher/corerad/internal/build
PREFIX := /usr/local
ETCDIR := /etc

all:
	CGO_ENABLED=$(CGO_ENABLED) \
	go build \
		-ldflags=" \
			-X $(BUILDPKG).linkTimestamp=$(TIMESTAMP) \
			-X $(BUILDPKG).linkVersion=$(VERSION) \
		" \
	-o ./cmd/corerad/corerad \
	./cmd/corerad

nocgo: VERSION := $(VERSION)-no-cgo
nocgo: CGO_ENABLED := 0
nocgo: all

install-bin:
	install -Dm755 "cmd/corerad/corerad" "$(PREFIX)/sbin/corerad"

install-init:
	install -Dm755 "etc/init.d/corerad"  "$(ETCDIR)/init.d/corerad"

CONFIG_FILES := default/corerad logrotate.d/corerad
install-configs:
	$(foreach file, $(CONFIG_FILES), \
		test -e "$(ETCDIR)/$(file)" || install -v -Dm644 "etc/$(file)" "$(ETCDIR)/$(file)";)

install: install-bin install-init install-configs
