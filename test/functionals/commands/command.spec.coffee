require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

withBundledProject 'foo', ->

  describe 'setting hooks on commands', ->
    afterEach ->
      run 'rm', ['-rf', @projectPath]

    beforeEach ->

      commandPath = inProject('src/commands/foo.cmd.coffee')
      commandContent =  """
        Neat = require 'neat'
        fs = require 'fs'
        {run, aliases} = Neat.require 'utils/commands'
        {error, info, green, red, puts} = Neat.require 'utils/logs'

        exports['foo'] = (pr) ->
          aliases 'foo', (args..., callback) ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "command called\\n"
            callback?()
        """

      hooksPath = inProject('src/config/initializers/hooks.coffee')
      hooksContent = """
        Neat = require 'neat'
        fs = require 'fs'

        module.exports = (config) ->
          fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            .write "hooks added\\n"

          Neat.beforeCommand.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "beforeCommand called\\n"
          Neat.afterCommand.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "afterCommand called\\n"
        """

      ended = false
      runs ->
        withCompiledFile commandPath, commandContent, ->
          withCompiledFile hooksPath, hooksContent, ->
            ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

    describe 'and running neat foo', ->
      it 'should trigger the hooks', (done) ->
        run 'node', [NEAT_BIN, 'foo'], (status) ->
          expect(status).toBe(0)
          expect(inProject 'test.log')
            .toContain("""hooks added
                          beforeCommand called
                          command called
                          afterCommand called""")
          done()

    describe 'and running neat help', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'help'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate command foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'command', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate task foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate initializer foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'initializer', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate generator foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'generator', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate spec foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'spec', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat generate package', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'package'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

    describe 'and running neat install', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'install'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 50000

, noCleaning: true
