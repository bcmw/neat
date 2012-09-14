Neat = require '../../neat'

{writeFile} = require 'fs'
{compile} = require 'coffee-script'
{chain} = Neat.require 'async'
{readFiles, ensure} = Neat.require 'utils/files'

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
PACKAGE_RE = -> ///^(#{LITERAL_RE})(\.#{LITERAL_RE})*$///
NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-]*$/

class Packager
  @asCommand: (conf, operators) ->
    (callback) -> new Packager(conf, operators).process callback

  constructor: (@conf, @operators) ->
    validate = (key, re, expect) =>
      unless re.test @conf[key]
        throw new Error "Malformed string for #{key}, expect #{expect}"

    malformedConf = (key, type) =>
      new Error "Malformed configuration for #{key}, expect #{type}"

    preventMissingConf = (key) =>
      throw new Error "Missing configuration #{key}" unless @conf[key]?

    preventMissingConf 'name'
    preventMissingConf 'includes'
    malformedConf 'includes', 'Array' unless Array.isArray @conf['includes']
    validate 'name', NAME_RE(), 'a file name such foo_bar of foo-bar'
    validate 'package', PACKAGE_RE(), 'a path such com.exemple.foo'

  process: (callback) ->
    @conf.merge Neat.config.tasks.package
    files = @conf.includes.map (p) -> "#{Neat.root}/#{p}.coffee"
    readFiles files, (err, res) =>
      chain.call null, @operators, res, @conf, (buffer) =>
        @result = buffer
        callback?()

module.exports = Packager
