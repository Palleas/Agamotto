run-test-on-linux:
	docker run --rm -it --name agamotto -v $PWD:/app -w /app swift swift test

generate-github-client:
	swift run swift-openapi-generator generate \
		--mode types --mode client \
		--output-directory Sources/GitHubClient \
		--config Sources/GithubClient/openapi-generator-config.yaml \
		Sources/GitHubClient/github-openapi-spec.yaml
