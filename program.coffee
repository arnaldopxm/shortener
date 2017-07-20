express = require 'express'
url = require 'url'
path = require 'path'
mongo = require('mongodb').MongoClient
app = express()
uri = 'mongodb://arnaldopxm:'+ '130796' + '@ds137197.mlab.com:37197/freecodecamp'
host = 'https://petal-shrimp.glitch.me/'

app.set 'view engine', 'pug'
app.set 'views', path.join __dirname, 'views'

app.get '/', (req,res) ->
  res.render 'index'

app.get '/:id', (req,res) ->
  id = req.params.id

  mongo.connect uri, (err,db) ->
    collection = db.collection('uris')

    query =
      short : host + id

    collection.find(query).toArray (err,doc) ->
      throw err if err
      if doc.length > 0
        dir = if doc[0].url[0..3] != 'http' then 'http://' + doc[0].url  else doc[0].url
        res.redirect dir
        db.close()
      else
        res.render '404'

app.get '/new/*', (req,res) ->
  dir = req.params[0]
  mongo.connect uri, (err,db) ->
    throw err if err
    collection = db.collection('uris')

    collection.count {}, (err,count) ->
      throw err if err
      sol =
        url : dir
        short : host + count

      query =
        url : dir

      projection =
        _id : 0
        url : 1
        short : 1

      collection.find(query,projection).toArray (err,doc) ->
        throw err if err

        if doc.length > 0
          res.send doc[0]
          db.close()
        else
          collection.insert sol, (err,data) ->
            throw err if err
            result =
              url : dir
              short : host + count
            res.send result
            db.close()

app.get '*', (req,res) ->
  res.render '404'

listener = app.listen 50532, ->
  console.log 'Your app is listening on port ' + listener.address().port
