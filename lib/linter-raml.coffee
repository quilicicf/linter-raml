{CompositeDisposable} = require 'atom'
raml = require 'raml-parser'

parser = new (raml.RamlParser)(reader: new (raml.FileReader)((file) ->
  deferred = @q.defer()
  require('fs').readFile file, (err, data) ->
    if err
      return deferred.reject 'File not found: ' +  err.path
    deferred.resolve data.toString('utf8')
    return
  deferred.promise
))

module.exports =
  config:
    lintOnFly:
      type: 'boolean'
      title: 'Lint on fly'
      default: true

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-raml.lintOnFly',
      (lintOnFly) =>
        @lintOnFly = lintOnFly

  deactivate: ->
    @subscriptions.dispose()

  # Public: Validates the given RAML definition.
  # * `text`      The {String} content of the definition's main file
  # * `filePath`  The {String} path to the definition's main file, used to resolve includes
  #
  # Returns `undefined` if the RAML definition is valid, an error object describing the first error encountered otherwise:
  # Error object's structure:
  # ```yaml
  # line:   the {Integer} line containing an error
  # column: the {Integer} column where the error was spotted
  # text:   a {String} explanation of the error
  # ```
  validate: (text, filePath) ->
    parser.load(text, filePath)
      .then (data) ->
        return
      .catch (err) ->
        message =
          line: err.problem_mark.line
          column: err.problem_mark.column
          text: err.message
        return message

  provideLinter: ->
    helpers = require('atom-linter')
    provider =
      name: 'RAML'
      grammarScopes: ['source.raml']
      scope: 'file'
      lintOnFly: @lintOnFly
      lint: (textEditor) =>
        showAll = @enableNotice
        filePath = textEditor.getPath()
        return @validate(textEditor.getText(), filePath).then (message) ->
          messages = []
          if message
            lineStart = message.line
            lineEnd = lineStart
            colStart = message.column
            colEnd = textEditor.getBuffer().lineLengthForRow(lineStart)
            messages.push
              type: 'error'
              filePath: filePath
              range: [ [lineStart, colStart], [lineEnd, colEnd] ]
              text: message.text

          return messages
