.DEFAULT_GOAL := default
.PHONY: test

# Get dependencies
pubget:
	dart pub get

# Run Unit tests
test:
	dart test

# Dry run publish
publish-dry:
	dart pub publish --dry-run

# Publish package
publish:
	dart pub publish

# Evaluate package with pana
# https://pub.dev/packages/pana
pana:
	dart pub global activate pana
	dart pub global run pana

default:
	@echo target not specified.
