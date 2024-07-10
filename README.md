# Agamotto

Agamotto is an opinionated tool to check that the dependencies in your `Package.swift` file are up to date.

## Installation 

Right now, the easiest way is probably to use Mint to install the command line tool. I have plans to add support for homebrew.

```shell
mint install https://github.com/Palleas/Agamotto.git
agamotto --version # 1.0.0
```

## Usage

```shell
agamotto check /path/to/your/project
```

Example output from this repo:
```
agamotto check . --verbose
[swift-log...............] Should be updated from 1.5.4 to 1.6.1
[swift-openapi-urlsession] Up to date.
[swift-openapi-runtime...] Up to date.
[swift-openapi-generator.] Up to date.
[swift-argument-parser...] Up to date.
```

## Why Agamotto

I'm a pretty nerdy guy with a thing for comic books and back when I started working on this project, I decided to use codenames coming from the Marvel universe. For more informations, I guess [the official character page](https://marvel.fandom.com/wiki/Agamotto_(Earth-616)) on the Marvel website is a good place to start. It goes without saying that the name Agamotto is (probably?) the property of Marvel.