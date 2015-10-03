linter-raml
=========================

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) validates your [RAML](http://raml.org) files in [Atom](https://atom.io/).

It detects RAML files by extension (expects file name to be *.raml).

![linter-raml in action](./linter-raml-in-action.png)

The underlying validation tool is [RAML JS parser](https://github.com/raml-org/raml-js-parser).

For a full RAML editing experience, install the [RAML package](https://atom.io/packages/raml).

## Installation

Install linter and linter-raml:
- __Linter:__ If Linter is not installed, please follow the instructions [here](https://github.com/AtomLinter/Linter).
- __Linter-raml:__ run `apm install linter-raml`

## Configuration 

You can configure this package by opening its settings view (`ctrl+,` then select the package) or by editing the entries below 'linter-raml' in _~/.atom/config.cson_.

## Contributing

You think it lacks a feature ? Spot a bug ? Unsufficient documentation ?
Any contribution is welcome, below are a few contribution guidelines but first get a look at [atom contribution guidelines](https://atom.io/docs/v0.186.0/contributing):

1. Git
  1. Fork the plugin repository.
  1. Hack on a separate topic branch created from the latest `master`.
  1. Commit and push the topic branch.
  1. Make a pull request.
1. Code style
  1. Indent is 2 spaces.
  1. Code should pass coffeelint linter.
1. Other
  1. Let me know by mail before contributing (don't want to waste your time on something already being done)
  1. You don't know how or don't have the time to contribute ? Don't hesitate to share your ideas in issues


Thank you for helping out!
