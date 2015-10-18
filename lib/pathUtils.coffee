module.exports =

  # Public: Retrieves the line and column of the include statement in mainFilePath for the
  # file specified by errorFilePath.
  # * `text`      The {String} content of the definition's main file
  # * `errorFilePath`  The {String} path to the file where an error has been found
  # * `mainFilePath`  The {String} path to the definition's main file
  #
  # Returns the {integer} line of the include from main file to error file
  # if there is one, 0 otherwise
  searchIncludeStatementPosition: (text, errorFilePath, mainFilePath) ->
    splitErrorFilePath = errorFilePath.split '/'
    splitMainFilePath = mainFilePath.split '/'
    splitMainFilePath.splice splitMainFilePath.length - 1, 1

    includeRegexText = '^[^!]*!include:?\\s*(\\.\\/)?'
    hasRelativized = false
    for i in [1..splitErrorFilePath.length - 1]
      errorPathPart = splitErrorFilePath[i]
      mainPathPart = splitMainFilePath[i]

      if errorPathPart != mainPathPart
        if hasRelativized == false && mainPathPart
          for j in [i..splitMainFilePath.length - 1]
            includeRegexText += '\\.\\.\\/'
          hasRelativized = true

        includeRegexText += errorPathPart
        if i < splitErrorFilePath.length - 1
          includeRegexText += '\\/'

    lines = text.split '\n'

    includeRegex = new RegExp(includeRegexText)
    for k in [0..lines.length - 1]
      line = lines[k]
      if includeRegex.test(line)
        position =
          line: k
          column: line.indexOf '!include'
        return position

    position =
      line: 0
      column: 0
    return position
