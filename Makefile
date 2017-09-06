.PHONY = update build test bootstrap sourcery
SOURCERY ?= ./.build/debug/sourcery
MODULE_NAME = cmdshelf
PARAM = SWIFTPM_DEVELOPMENT=YES

test:
	$(PARAM) swift build
	./tests/main.sh

update:
	$(PARAM) swift package update

build:
	$(PARAM) swift build
bootstrap: build
	$(PARAM) swift package generate-xcodeproj

sourcery:
	$(SOURCERY) --templates Resources/SourceryTemplates/AutoEquatables.stencil --sources Sources/$(MODULE_NAME)/ --output Sources/$(MODULE_NAME)/AutoEquatables.out.swift
	# $(SOURCERY) --templates Resources/SourceryTemplates/LinuxMain.stencil --sources Tests/PbxprojTests/ --output Tests/LinuxMain.swift

# Needs toshi0383/scripts to be added to cmdshelf's remote
install:
	cmdshelf run "swiftpm/install.sh toshi0383/cmdshelf"

release:
	rm -rf .build/release
	swift build -c release -Xswiftc -static-stdlib
	cmdshelf run "swiftpm/release.sh cmdshelf libCYaml.dylib"
