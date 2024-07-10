# Agamotto

Agamotto is an opinionated tool to check that the dependencies in your `Package.swift` file are up to date. I wrote about it on my personal website:

* [Keeping my dependencies up to date](https://romain.codes/2022/04/28/keeping-my-dependencies-up-to-date/)
* [Keeping on keeping my dependencies up to date](https://romain.codes/2024/02/20/keeping-on-keeping-my-dependencies-up-to-date/)

> [!IMPORTANT]  
> Agamotto shells out to the swift packager manager (via `swift package dump-package`) to get the list of all your dependencies because I didn't want to parse it myself.
> Additionaly, it uses [jq](https://jqlang.github.io/jq/) to filter and transform the JSON output of the [swift package manager](https://www.swift.org/documentation/package-manager/) command line tool. I have plans to remove dependencies on both eventually.

## Installation 

### Using Homebrew 

```shell
brew tap palleas/homebrew-formulas https://github.com/Palleas/homebrew-formulas.git
brew install agamotto
agamotto --version
```

## Usage

```shell
agamotto check /path/to/your/project
```

Example output from this repo:
```
[swift-log...............] Should be updated from 1.5.4 to 1.6.1
```

Using the `--verbose` option will print the list of all your dependencies, including the ones that are already up to date:

```
[swift-log...............] Should be updated from 1.5.4 to 1.6.1
[swift-openapi-urlsession] Up to date.
[swift-openapi-runtime...] Up to date.
[swift-openapi-generator.] Up to date.
[swift-argument-parser...] Up to date.
```

## Known Issues

* This project started as a fun project, so shelling out to `swift package...` and using `jq` are not the most stable approaches, especially with new version of the Swift command line tools that might change the output of the `dump-package` subcommand. Please [file an issue](https://github.com/Palleas/Agamotto/issues/new) if you notice something weird.
* Agamotto only handle dependencies with **exact** versions, using ranges or branches will be ignored.
* Only urls to repositories hosted on GitHub are supported right now.

## Acknowledgement

Agamotto relies on a bunch of open-source libraries to work: 
* [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
* [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)
* [Swift Log](https://github.com/apple/swift-log)

## Why Agamotto

I'm a pretty nerdy guy with a thing for comic books and back when I started working on this project, I decided to use codenames coming from the Marvel universe. For more informations, I guess [the official character page](https://marvel.fandom.com/wiki/Agamotto_(Earth-616)) on the Marvel website is a good place to start. It goes without saying that the name Agamotto is (probably?) the property of Marvel.