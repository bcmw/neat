op = require '../../../tasks/package/operators'

module.exports = (config) ->
  config.tasks.package.merge
    operatorsMap:
      'annotate:class': op.annotateClass
      'annotate:file': op.annotateFile
      'compile': op.compile
      'create:directory': op.createDirectory
      'create:file': op.saveToFile
      'exports:package': op.exportsToPackage
      'join': op.join
      'strip:requires': op.stripRequires
      'uglify': op.uglify
