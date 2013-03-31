fs = require 'fs'
Q = require 'q'
path = require 'path'
require '../../../test_helper'
Neat = require '../../../../lib/neat'

Watcher = require '../../../../lib/tasks/watch/watcher'

describe 'Watcher', ->
  withWatchSpies ->
    subject 'watcher', -> new Watcher

    it 'should exist', ->
      expect(@watcher).toBeDefined()

    describe '#init', ->

      given 'value', -> @promise.valueOf()
      given 'paths', -> fs.watch.argsForCall.map (a) -> a[0]

      subject 'promise', -> @watcher.init()
      waiting -> @promise

      it 'should return a promise', ->
        expect(@promise).toBePromise()

      promise().should.beFulfilled()

      it 'should returns a list of ignored path', ->
        ['.git', 'node_modules', 'lib'].forEach (p) =>
          expect(@value.ignoredPaths).toContain(Neat.resolve p)

      it 'should returns a list of watched path', ->
        [
          '.neat'
          'Cakefile'
          'Nemfile'
          'Watchfile'
          '.watchignore'
        ].forEach (p) =>
          expect(@value.watchedPaths).toContain(Neat.resolve p)

      it 'should have stored the promise as a queue bootstrap', ->
        expect(@watcher.promise).toBe(@promise)

      it 'should have registered watchers for all the watched paths', ->
        for path in @value.watchedPaths
          expect(@paths).toContain(path)

      it 'should not have registered doublons', ->
        uniqPaths = @paths.uniq()
        expect(@paths.length).toBe(uniqPaths.length)

      it 'should have evaluated the Watchfile and initialized the plugins', ->
        expect(@watcher.plugins.mockPlugin).toBeDefined()

      describe 'once called,', ->
        given 'plugin', -> @watcher.plugins.mockPlugin
        given 'watches', -> @plugin.watches
        given 'watch', -> @watches.first()
        given 'watchOptions', -> @watch.options
        given 'pluginOptions', -> @plugin.options

        describe 'the instanciated plugin', ->
          subject -> @plugin

          it 'should have been initialized
              with the watches defined in the Watchfile'.squeeze(), ->
            expect(@watches)
            .toContainWatchFor(///#{Neat.root}/src/(.*)\.coffee$///)

          it 'should have registered the given options', ->
            expect(@pluginOptions.option).toBeDefined()
            expect(@watchOptions.anotherOption).toBeDefined()

          describe 'when a watch contains a block', ->
            given 'promise', ->
              @watch.outputPathsFor Neat.resolve 'src/neat.coffee'

            waiting -> @promise

            promise()
            .should.beFulfilled()
            .should 'have registered the given block', (paths) ->
              expect(paths).toContain(Neat.resolve 'lib/neat.js')

          it 'should confirm if it is concerned by changes in a given path', ->
            expect(@plugin.match Neat.resolve 'src/neat.coffee').toBeTruthy()
            expect(@plugin.match Neat.resolve 'foo').toBeFalsy()

          describe 'when a file concerned by the plugin changed', ->
            beforeEach -> spyOn(@plugin, 'pathChanged').andCallThrough()

            subject 'promise', ->
              @watcher.pathChanged Neat.resolve('src/neat.coffee'), 'change'

            waiting -> @promise

            promise().should.beFulfilled()

            it 'should have called the plugin pathChanged method', ->
              expect(@plugin.pathChanged).toHaveBeenCalled()

            it 'should have stored the promise in the promiseS queue', ->
              expect(@watcher.promise).toBe(@promise)


        ['Watchfile', '.watchignore'].forEach (name) =>
          describe "when #{name} file changed", ->
            beforeEach ->
              spyOn(@watcher, 'init').andCallThrough()
              spyOn(@watcher, 'dispose').andCallThrough()
              spyOn(@plugin, 'dispose').andCallThrough()

            subject 'promise', ->
              @watcher.pathChanged Neat.resolve(name), 'change'

            waiting -> @promise

            promise()
            .should.beFulfilled()
            .should 'dispose itself and its plugins', ->
              expect(@watcher.dispose).toHaveBeenCalled()
              expect(@plugin.dispose).toHaveBeenCalled()
            .should 'reinitialize the watcher by calling init again', ->
              expect(@watcher.init).toHaveBeenCalled()

            it 'should have stored a promise as a queue bootstrap', ->
              expect(@watcher.promise).toBe(@promise)





