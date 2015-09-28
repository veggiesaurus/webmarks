function displayRandomNames(connection, res, courseCode, seed, numNames) {
    console.log('selecting ' + numNames + ' names from ' + courseCode + ' using seed of ' + seed);
    //heading
    var headings = ["The Chosen Few", "Today's Contestants", "This Week's Winners"];
    var index = Math.floor((Math.random() * headings.length));
    
    connection.query("SELECT * FROM (SELECT DISTINCT studentID, name FROM `" + courseCode + "_students` ORDER BY RAND(" + seed + ") LIMIT " + numNames + ") AS randomNames ORDER BY studentID ", function (err, rows, fields) {
        if (err)
            res.render("errorDatabase");
        if (rows && rows.length) {
            res.render("randomNames", { names: rows, headingText: headings[index] });
        }
        else {
            res.render("errorDatabase");
        }
    });
}



module.exports = function (app, connection) {      
    app.get("/rand/:id([0-9]+):courseType(w|f|h|s)\/seed/:seedVal([0-9]+)", function (req, res) {
        var urlCourseCode = req.params.id + req.params.courseType;
        var seed = req.params.seedVal;
        displayRandomNames(connection, res, urlCourseCode, seed, 10);
    });
    
    app.get("/rand/:id([0-9]+):courseType(w|f|h|s)\/num/:numVal([0-9]+)/seed/:seedVal([0-9]+)", function (req, res) {
        var urlCourseCode = req.params.id + req.params.courseType;
        var seed = req.params.seedVal;
        var numNames = req.params.numVal;
        displayRandomNames(connection, res, urlCourseCode, seed, numNames);
    });        
}