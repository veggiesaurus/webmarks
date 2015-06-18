/**
 * Module dependencies.
 */

var port=80;

var express = require('express');
var favicon = require('serve-favicon');
var routes = require('./routes');
var user = require('./routes/user');
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

app.get("/:id([0-9]+):courseType(w|f|h|s)\/:studentID", function(req, res)
{	
    var urlCourseCode=req.params.id+req.params.courseType;
    var studentID=req.params.studentID;
    //get course info
    connection.query("SELECT * FROM info WHERE `coursePrefix` = '"+urlCourseCode+"'",function(err, rows, fields)
    {
        if (err)
        {
            res.render("errorDatabase", {errorInfo:"Error getting course info",urlCourseCode:urlCourseCode});
            return;
        }
        if (rows && rows.length)
        {
            //get the student info
            connection.query("SELECT * FROM `"+urlCourseCode+"_students` WHERE studentID = '"+studentID+"'",function(errStudent, rowsStudent, fieldsStudent)
            {
                if (errStudent)
                {
                    res.render("errorDatabase", {errorInfo:"Error getting student info",urlCourseCode:urlCourseCode,studentID:studentID});
                    return;
                }
                if (rowsStudent && rowsStudent.length)
                {
                    //get the categories
                    connection.query("SELECT * FROM `"+urlCourseCode+"_categories`",function(errCats, rowsCats, fieldsCats)
                    {                 
                        if (errCats)
                        {
                            res.render("errorDatabase", {errorInfo:"Error getting categories",urlCourseCode:urlCourseCode,studentID:studentID});
                            return;
                        }
                        if (rowsCats && rowsCats.length)
                        {   
                            //get all the marks                   
                            connection.query("SELECT mark,maxMarks,entryName,typeID FROM ?? tabMarks, ?? tabEntries WHERE (studentID=? AND tabMarks.entryID = tabEntries.entryID) ORDER BY tabMarks.entryID",[urlCourseCode+"_marks",urlCourseCode+"_entries",studentID],function(errMarks, rowsMarks, fieldsMarks)
                            {                 
                                if (errMarks)
                                {
                                    res.render("errorDatabase", {errorInfo:"Error getting marks",urlCourseCode:urlCourseCode,studentID:studentID});
                                    return;
                                }
                                if (rowsMarks && rowsMarks.length)
                                {

                                    //get averages
                                    connection.query("SELECT CAST(average as SIGNED) as average,typeID FROM ?? tabAverages WHERE (studentID=?) ORDER BY typeID",[urlCourseCode+"_averages",studentID],function(errAverages, rowsAverages, fieldsAverages)
                                    {
                                        if (errAverages)
                                        {
                                            res.render("errorDatabase", {errorInfo:"Error getting averages",urlCourseCode:urlCourseCode,studentID:studentID});
                                            return;
                                        }
                                        if (rowsAverages && rowsAverages.length)
                                        {
                                            //get histograms
                                            connection.query("SELECT tabCategories.categoryName, tabHistograms.*  FROM ?? tabHistograms, ?? tabCategories WHERE (tabHistograms.typeID = tabCategories.typeID AND tabCategories.displayHistogram = True)",[urlCourseCode+"_histograms",urlCourseCode+"_categories"],function(errHists, rowsHists, fieldsHists)
                                            {
                                                if (errHists)
                                                {
                                                    res.render("errorDatabase", {errorInfo:"Error getting histograms",urlCourseCode:urlCourseCode,studentID:studentID});
                                                    return;
                                                }
                                                if (rowsHists && rowsHists.length)
                                                    res.render("marks", {courseCode:urlCourseCode, courseName:rows[0].courseName, numCategories:rows[0].numCategories, updateDate:rows[0].updateDate.toDateString(), cats:rowsCats, averages:rowsAverages,studentID:rowsStudent[0].studentID, studentName:rowsStudent[0].name, marks:rowsMarks, hists:JSON.stringify(rowsHists)});
                                                else
                                                    res.render("marks", {courseCode:urlCourseCode, courseName:rows[0].courseName, numCategories:rows[0].numCategories, updateDate:rows[0].updateDate.toDateString(), cats:rowsCats, averages:rowsAverages,studentID:rowsStudent[0].studentID, studentName:rowsStudent[0].name, marks:rowsMarks, hists:-1});
                                            
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
                else
                {
                    res.render("invalidStudent", {courseCode:rows[0].coursePrefix, courseName:rows[0].courseName, studentID:studentID});
                }

            });            
        }
        else
        {
            res.render("invalidCourse");
        }
    });	
});

function displayRandomNames(res, courseCode, seed, numNames)
{
	console.log('selecting '+numNames+' names from '+courseCode + ' using seed of ' + seed);
	//heading
	var headings=["The Chosen Few", "Today's Contestants", "This Week's Winners"];	
	var index=Math.floor((Math.random() * headings.length));
	
    connection.query("SELECT * FROM (SELECT DISTINCT studentID, name FROM `"+courseCode+"_students` ORDER BY RAND("+seed+") LIMIT " + numNames+") AS randomNames ORDER BY studentID ",function(err, rows, fields)
    {
        if (err) throw err;
        if (rows && rows.length)
        {
            res.render("randomNames", {names:rows, headingText:headings[index]});
        }
        else
        {
            res.render("errorDatabase");
        }
    });
	
}

app.get("/rand/:id([0-9]+):courseType(w|f|h|s)\/seed/:seedVal", function(req, res)
{
	var urlCourseCode=req.params.id+req.params.courseType;
	var seed=req.params.seedVal;
	displayRandomNames(res, urlCourseCode, seed,  10);
});

app.get("/rand/:id([0-9]+):courseType(w|f|h|s)\/num/:numVal/seed/:seedVal", function(req, res)
{
	var urlCourseCode=req.params.id+req.params.courseType;
	var seed=req.params.seedVal;
	var numNames=req.params.numVal;	
	displayRandomNames(res, urlCourseCode, seed,  numNames);
});

app.get("/:id([0-9]+):courseType(w|f|h|s)\?", function(req, res)
{
    res.render("selectStudent");
});


app.get("/", function(req, res)
{	
    var urlCourseCode=req.params.id+req.params.courseType;
    var studentID=req.params.studentID;
    //get course info
    connection.query("SELECT coursePrefix, courseName FROM `info`",function(err, rows, fields)
    {
        if (err) throw err;
        if (rows && rows.length)
        {
            res.render("selectCourse", {courseInfo:rows});
        }
        else
        {
            res.render("errorDatabase");
        }
    });
});

app.get('*', function (req, res) {
    res.redirect("/");
});

app.listen(port);
