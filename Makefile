.PHONY = clean update build test bootstrap sourcery
SOURCERY ?= sourcery # Please install appropriate version on your own.
MODULE_NAME = cmdshelf
PARAM = SWIFTPM_DEVELOPMENT=YES

test:
	$(PARAM) swift build
	./tests/main.sh

clean:
	rm Package.resolved

update:
	$(PARAM) swift package update

build:
	$(PARAM) swift build

bootstrap: build
	$(PARAM) swift package generate-xcodeproj

# Needs toshi0383/scripts to be added to cmdshelf's remote
install:
	cmdshelf run "swiftpm/install.sh toshi0383/cmdshelf"

release:
	rm -rf .build/release
	swift build -c release -Xswiftc -static-stdlib
	cmdshelf run "swiftpm/release.sh cmdshelf libCYaml.dylib"
