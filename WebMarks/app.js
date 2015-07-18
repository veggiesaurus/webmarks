var express = require('express');
var favicon = require('serve-favicon');
var dbConfig = require('./secrets.json');
var http = require('http');
var path = require('path');
var sassMiddleware = require('node-sass-middleware');

var mysql      = require('mysql');

var db_config = {
  host: '127.0.0.1',
  user     : dbConfig.webmarksUser,
  password : dbConfig.webmarksPassword,
  database: 'webapp'
};

var port=process.env.PORT || 80;

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

//sass config
app.use(sassMiddleware({
    /* Options */
    src: path.join(__dirname, 'sass'),
    dest: path.join(__dirname, 'public/css'),
    debug: true,
    outputStyle: 'compressed',
    response: true,
    prefix: '/css'
}));


//routes
require('./routes/redirects')(app);
require('./routes/selectStudent')(app, connection);
require('./routes/marks')(app, connection);
require('./routes/randomNames')(app, connection);

app.get('*', function (req, res) {
    res.redirect("/");
});

if (process.env.LISTEN_HOST)
	app.listen(port, process.env.LISTEN_HOST, function(){
	console.log('Listening on port '+port+' and address '+process.env.LISTEN_HOST);
});
else
	app.listen(port, function(){
	console.log('Listening on port '+port);
});
