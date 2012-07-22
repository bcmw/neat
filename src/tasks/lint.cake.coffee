path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{
  error, info, green, red, puts, print, yellow, missing
} = Neat.require 'utils/logs'
{find, findSiblingFile} = Neat.require 'utils/files'
{queue} = Neat.require 'async'

COFFEE_LINT = "#{Neat.neatRoot}/node_modules/.bin/coffeelint"

exports['lint'] = neatTask
  name:'lint'
  description: 'Lint the sources with coffee-lint'
  environment: 'default'
  action: (callback) ->
    unless path.existsSync COFFEE_LINT
      error """#{red "Can't find coffeelint module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback?()

    path = __filename
    dir = 'lib/config'
    findSiblingFile path, Neat.paths, dir, 'json', asyncErrorTrap (conf) ->
      unless conf?
        error missing "lint configuration"
        return callback?()

      errors = []
      # Generates a command function that lint the specified `file`.
      lint = (file) -> (callback) ->
        params = ["-f", conf, file]

        logs = []
        opts =
          noStdout: true
          stderr: (data) -> logs.push -> print data

        run 'coffeelint', params, opts, (status) ->
          if status is 0
            print green '.'
          else
            print red 'F'
            errors.push ->
              puts red "#{file.replace "#{Neat.root}/", ''} is not ok"
              log() for log in logs

          callback?()

      paths = ["#{Neat.root}/src", "#{Neat.root}/test"]

      files = find 'coffee', paths, (err, files) ->
        queue (lint file for file in files), ->
          puts ''

          if errors.length is 0
            info green 'All files linted'
          else
            error() for error in errors

          callback?()