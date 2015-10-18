{CompositeDisposable} = require 'atom'
raml = require 'raml-parser'
pathUtils = require './pathUtils'

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
    enableNotice:
      type: 'boolean'
      title: 'Enable Notice Messages'
      default: false
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
        isInternalError = true
        if err.message.message
          err = err.message
        if err.problem_mark && err.problem_mark.name != filePath
          isInternalError = false

        if isInternalError
          message =
            line: err.problem_mark.line
            column: err.problem_mark.column
            text: err.message
            filePath: err.problem_mark.name
        else
          includePosition = pathUtils.searchIncludeStatementPosition text, err.problem_mark.name, filePath
          fileName = err.problem_mark.name
          text = 'Error in file ' + fileName + ': ' + err.message

          trace =
            type: 'Trace'
            text: 'Incriminated file: ' + fileName
            filePath: fileName
            range: [[ err.problem_mark.line, err.problem_mark.column ], [ err.problem_mark.line, err.problem_mark.column ]]

          message =
            line: includePosition.line
            column: includePosition.column
            text: text
            filePath: err.problem_mark.name
            trace: trace

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
            trace = if message.trace then [ message.trace ] else undefined
            messages.push
              type: 'error'
              filePath: filePath
              range: [ [lineStart, colStart], [lineEnd, colEnd] ]
              text: message.text
              trace: trace

          return messages
