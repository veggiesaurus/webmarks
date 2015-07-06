/**
 * Module dependencies.
 */

var port=80;

var express = require('express');
var favicon = require('serve-favicon');
var dbConfig = require('./secrets.json');
var http = require('http');
var path = require('path');

var mysql      = require('mysql');

var db_config = {
  host: '127.0.0.1',
  user     : dbConfig.webmarksUser,
  password : dbConfig.webmarksPassword,
  database: 'webapp'
};

var connection;

function handleDisconnect() {
  connection = mysql.createConnection(db_config); // Recreate the connection, since
                                                  // the old one cannot be reused.

  connection.connect(function(err) {              // The server is either down
    if(err) {                                     // or restarting (takes a while sometimes).
      console.log('error when connecting to db:', err);
      setTimeout(handleDisconnect, 2000); // We introduce a delay before attempting to reconnect,
    }                                     // to avoid a hot loop, and to allow our node script to
  });                                     // process asynchronous requests in the meantime.
                                          // If you're also serving http, display a 503 error.
  connection.on('error', function(err) {
    console.log('db error', err);
    if(err.code === 'PROTOCOL_CONNECTION_LOST') { // Connection to the MySQL server is usually
      handleDisconnect();                         // lost due to either server restart, or a
    } else {                                      // connnection idle timeout (the wait_timeout
      throw err;                                  // server variable configures this)
    }
  });
}

handleDisconnect();

var app = express();

// all environments
app.set('views', __dirname + '/views');
app.set('view engine', "jade");
app.engine('jade', require('jade').__express);
app.set('view options', { pretty: true });
app.use(express.static(__dirname + '/public'));
app.use(favicon(__dirname + '/public/images/favicon.png'));

//redirects
app.get("/webmarks/:afterURL(*)", function (req, res) {
    res.redirect("/"+req.params.afterURL);    
});

app.get("/webmarks", function (req, res) {
    res.redirect("/");
});

app.get("/poll", function (req, res) {
    res.render("errorGeneric", { errorInfo: "The polling app has moved to polling.uct.ac.za" });
});

app.get("/poll/:afterURL(*)", function (req, res) {
    res.render("errorGeneric", { errorInfo: "The polling app has moved to polling.uct.ac.za"});
});

require('./routes/selectStudent')(app, connection);
require('./routes/marks')(app, connection);


require('./routes/randomNames')(app, connection);

app.get('*', function (req, res) {
    res.redirect("/");
});

app.listen(port);
