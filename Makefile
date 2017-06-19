.PHONY = update build test bootstrap sourcery
SOURCERY ?= ./.build/debug/sourcery
MODULE_NAME = cmdshelf
PARAM = SWIFTPM_DEVELOPMENT=YES

test:
	$(PARAM) swift test

update:
	$(PARAM) swift package update

build:
	$(PARAM) swift build
bootstrap: build
	$(PARAM) swift package generate-xcodeproj

sourcery:
	$(SOURCERY) --templates Resources/SourceryTemplates/AutoEquatables.stencil --sources Sources/$(MODULE_NAME)/ --output Sources/$(MODULE_NAME)/AutoEquatables.out.swift
	# $(SOURCERY) --templates Resources/SourceryTemplates/LinuxMain.stencil --sources Tests/PbxprojTests/ --output Tests/LinuxMain.swift
