run-test-on-linux:
	docker run --rm -it --name agamotto -v $PWD:/app -w /app swift swift test

