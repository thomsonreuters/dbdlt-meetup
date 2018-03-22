'use strict';

var express = require('express'),
    bodyParser = require('body-parser'),
    app     = express(),
    port    = process.env.PORT || 3000,
    config  = require('./config'),
    hl      = require('./hyperledger');

app.set('views', __dirname+'/views');
app.engine('html', require('ejs').renderFile);
app.use(bodyParser.urlencoded({ extended: false }))

app.route('/').get((req, res) => {
  hl.all(config, config.channel)
    .then(data => { 
      res.render('index.html', { channel: config.channel, data: data });
    });
});

app.route('/history/:id').get((req, res) => {
  let id = req.params.id;
  hl.history(config, config.channel, id)
    .then(data => {
      res.render('history.html', { id: id, data: data });
    });
});

app.route('/add/:id').post((req, res) => {
  let id = req.params.id;
  let data = req.body;
  hl.sendTransaction('add', config, config.channel, id, data)
    .then(data => {
      res.end();
    });
});

app.route('/update/:id').post((req, res) => {
  let id = req.params.id;
  let data = req.body;
  hl.sendTransaction('update', config, config.channel, id, data)
    .then(data => {
      res.end();
    });
});

app.route('/delete/:id').get((req, res) => {
  let id = req.params.id;
  hl.sendTransaction('delete', config, config.channel, id, '')
    .then(data => {
      res.end();
    })
});


app.listen(port);
console.log('Service running @ http://localhost:' + port);