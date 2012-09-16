# A bunch of functions to deals with asynchronous process.
# @toc

#### parallel

# Execute an array of functions `fns` in parallel. The passed-in `callback`
# will only be called when the all functions have call back.
#
#     f1 = (cb) -> setTimeout cb, 100
#     f2 = (cb) -> setTimeout cb, 200
#     parallel [f1, f2], ->
#       # called after both f1 and f2 have call back
parallel = (fns, callback) ->
  count = 0
  cb = -> count += 1; if count is fns.length then callback?()
  if fns.empty() then callback() else fn cb for fn in fns

#### queue

# Execute an array of function `fns` one after the other.
# The passed-in `callback` will only be called when the queue
# is empty.
#
#     f1 = (cb) -> setTimeout cb, 100
#     f2 = (cb) -> setTimeout cb, 200
#     queue [f1, f2], ->
#       # called after at least 300ms
queue = (fns, callback) ->
  next = -> if fns.empty() then callback() else fns.shift() next
  next()

#### chain

# Execute an array of function `fns` on after the other, like a `queue`,
# but the different between them lies in the fact that a `chain` pass
# the arguments receive from a function to the next.
#
#     f1 = (a, cb) -> setTimeout cb, 100, a+10
#     f2 = (a, cb) -> setTimeout cb, 200, a+20
#     chain [f1, f2], 0, (a) ->
#       # a is 30
chain = (fns, args..., callback) ->
  next = (args...) ->
    if fns.empty()
      callback.apply null, args
    else
      fns.shift().apply null, args.concat next

  next.apply null, args

module.exports = {queue, parallel, chain}
