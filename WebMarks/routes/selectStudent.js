module.exports = function (app, connection) {
        
    app.get("/:id([0-9]+):courseType(w|f|h|s)\?", function (req, res) {
        res.render("selectStudent");
    });
    
    app.get("/", function (req, res) {
        var urlCourseCode = req.params.id + req.params.courseType;
        var studentID = req.params.studentID;
        //get course info
        connection.query("SELECT coursePrefix, courseName FROM `info`", function (err, rows, fields) {
            if (err) throw err;
            if (rows && rows.length) {
                res.render("selectCourse", { courseInfo: rows });
            }
            else {
                res.render("errorDatabase");
            }
        });
    });
};