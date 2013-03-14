#!
# * Connect - BYO Body Parser
#            as in "Bring your own"
# * Copyright(c) 2010 Sencha Inc.
# * Copyright(c) 2011 TJ Holowaychuk
# * MIT Licensed
#
# * Copyright(c) 2013 Chris Continanza

###
Module dependencies.
###

###
noop middleware.
###
noop = (req, res, next) ->
  next()
utils = require("express/node_modules/connect/lib/utils")
_limit = require("express/node_modules/connect/lib/middleware/limit")

###
JSON:

Parse logplex request bodies, providing the
parsed object as `req.body`.

Options: none

@param content_type {String} use when Content-Type matches this string
@param parser {Function} parsing function takes String body and returns new body
@return {Function}
@api public
###
exports = module.exports = (options = {}) ->
  limit = (if options.limit then _limit(options.limit) else noop)
  logplex = (req, res, next) ->
    return next()  if req._body
    req.body = req.body or {}
    return next()  unless utils.hasBody(req)

    # check Content-Type
    return next()  unless options.content_type is utils.mime(req)

    # flag as parsed
    req._body = true

    # parse
    limit req, res, (err) ->
      return next(err)  if err
      buf = ""
      req.setEncoding "utf8"
      req.on "data", (chunk) ->
        buf += chunk

      req.on "end", ->
        first = buf.trim()
        try
          req.body = options.parser(buf)
        catch err
          err.body = buf
          err.status = 400
          return next(err)
        next()

