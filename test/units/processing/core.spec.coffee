require '../../test_helper'
Q = require 'q'
fs = require 'fs'
path = require 'path'

core = require '../../../lib/processing/core'

describe 'processing promise', ->
  beforeEach ->
    addPromiseMatchers this
    addFileMatchers this

  describe 'readFiles', ->
    it 'should exists', ->
      expect(core.readFiles).toBeDefined()

    describe 'when called with paths that exists', ->
      beforeEach ->
        @readFiles = core.readFiles [
          fixture 'processing/file.coffee'
          fixture 'processing/file.js'
        ]
        @expectedResult = {}
        @expectedResult[fixture 'processing/file.coffee'] = "# this is file.coffee\n"
        @expectedResult[fixture 'processing/file.js'] = "// this is file.js\n"

      it 'should return a promise', ->
        expect(@readFiles).toBePromise()

      promise(-> @readFiles)
      .should.beFulfilled()
      .should.returns 'a hash with the paths content', -> @expectedResult

    describe 'when called with paths that does not exists', ->
      beforeEach ->
        @readFiles = core.readFiles [
          fixture 'processing/foo.coffee'
          fixture 'processing/bar.js'
        ]

      promise(-> @readFiles).should.beRejected()

  describe 'writeFiles', ->
    it 'should exists', ->
      expect(core.writeFiles).toBeDefined()

    describe 'when called with a files buffer', ->
      beforeEach ->
        @files = {}
        @files[tmp 'processing/foo.coffee'] = 'foo.coffee'
        @files[tmp 'processing/foo.js'] = 'foo.js'
        @writeFiles = core.writeFiles @files

      afterEach -> clearTmp 'processing'

      it 'should return a promise', ->
        expect(@writeFiles).toBePromise()

      promise(-> @writeFiles)
      .should.beFulfilled()
      .should 'have written the files on the file system', ->
        expect(tmp 'processing/foo.coffee').toContain('foo.coffee')
        expect(tmp 'processing/foo.js').toContain('foo.js')

  describe 'processExtension', ->
    it 'should exists', ->
      expect(core.processExtension).toBeDefined()

    describe 'when called with an extension and a promise returning function', ->
      beforeEach ->
        @processor = core.processExtension 'coffee', (buffer) ->
          Q.fcall ->
            newBuffer = {}
            buffer.each (k,v) -> newBuffer["#{k}_foo"] = 'I want coffee'
            newBuffer

      it 'should return a promise return function', ->
        expect(typeof @processor).toBe('function')

      describe 'and the returned function called with a buffer', ->
        beforeEach ->
          @files = {}
          @files[tmp 'processing/foo.coffee'] = 'foo.coffee'
          @files[tmp 'processing/foo.js'] = 'foo.js'
          @processCoffee = @processor @files

        it 'should return a promise', ->
          expect(@processCoffee).toBePromise()

        promise(-> @processCoffee)
        .should.beFulfilled()
        .should 'have processed the file with corresponding extension', (r) ->
          expect(r[tmp 'processing/foo.coffee']).toBeUndefined()
          expect(r[tmp 'processing/foo.js_foo']).toBeUndefined()

          expect(r[tmp 'processing/foo.coffee_foo']).toBe('I want coffee')
          expect(r[tmp 'processing/foo.js']).toBe('foo.js')

