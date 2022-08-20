.PHONY: build build-release-tar build-release-zip check fmt install-local publish-all run-integration

build:
	cargo build

build-release-tar:
	mkdir -p $(target)
	mv $(target)-bin $(target)/cargo-lambda
	cd $(target) && \
		tar czvf cargo-lambda-$(tag).$(target).tar.gz cargo-lambda && \
		shasum -a 256 cargo-lambda-$(tag).$(target).tar.gz > cargo-lambda-$(tag).$(target).tar.gz.sha256 && \
		mv *.tar.gz* .. && cd ..

build-release-zip:
	mkdir -p $(target)
	mv $(target)-bin $(target)/cargo-lambda.exe
	cd $(target) && \
		zip cargo-lambda-$(tag).$(target).zip cargo-lambda.exe && \
		shasum -a 256 cargo-lambda-$(tag).$(target).zip > cargo-lambda-$(tag).$(target).zip.sha256 && \
		mv *.zip* .. && cd ..

check:
	cargo check
	cargo +nightly udeps

fmt:
	cargo +nightly fmt --all

install-local:
	cargo install --path crates/cargo-lambda-cli

publish-all:
	cargo publish --package cargo-lambda-interactive
	sleep 10
	cargo publish --package cargo-lambda-metadata
	sleep 10
	cargo publish --package cargo-lambda-remote
	sleep 10
	cargo publish --package cargo-lambda-build
	sleep 10
	cargo publish --package cargo-lambda-deploy
	sleep 10
	cargo publish --package cargo-lambda-invoke
	sleep 10
	cargo publish --package cargo-lambda-new
	sleep 10
	cargo publish --package cargo-lambda-watch
	sleep 10
	cd crates/cargo-lambda-cli && cargo publish

run-integration: build
	@rm -rf test/integration
	@mkdir -p test/integration

	@echo "testing HTTP functions" && \
		cd test/integration && \
		../../target/debug/cargo-lambda lambda new --http test-fun && \
		cd test-fun && \
		../../../target/debug/cargo-lambda lambda build --quiet --release && \
		test -x target/lambda/test-fun

	@echo "testing extensions" && \
		cd test/integration && \
		../../target/debug/cargo-lambda lambda new --extension test-ext && \
		cd test-ext && \
		../../../target/debug/cargo-lambda lambda build --quiet --release --extension && \
		test -x target/lambda/extensions/test-ext

	@echo "testing logs extensions" && \
		cd test/integration && \
		rm -rf test-ext && \
		../../target/debug/cargo-lambda lambda new --extension --logs test-ext && \
		cd test-ext && \
		../../../target/debug/cargo-lambda lambda build --quiet --release --extension && \
		test -x target/lambda/extensions/test-ext
