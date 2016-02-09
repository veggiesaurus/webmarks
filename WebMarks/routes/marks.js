module.exports = function (app, connection) {

    app.get("/:id([0-9]+):courseType(w|f|h|s)\/:studentID", function (req, res) {
        var urlCourseCode = req.params.id + req.params.courseType;
        var studentID = req.params.studentID;
        //get course info
        connection.query("SELECT * FROM info WHERE `coursePrefix` = '" + urlCourseCode + "'", function (err, rows, fields) {
            if (err) {
                res.render("errorDatabase", { errorInfo: "Error getting course info", urlCourseCode: urlCourseCode });
                return;
            }
            if (rows && rows.length) {
                //get the student info
                connection.query("SELECT * FROM `" + urlCourseCode + "_students` WHERE studentID = '" + studentID + "'", function (errStudent, rowsStudent, fieldsStudent) {
                    if (errStudent) {
                        res.render("errorDatabase", { errorInfo: "Error getting student info", urlCourseCode: urlCourseCode, studentID: studentID });
                        return;
                    }
                    if (rowsStudent && rowsStudent.length) {
                        //get the categories
                        connection.query("SELECT * FROM `" + urlCourseCode + "_categories`", function (errCats, rowsCats, fieldsCats) {
                            if (errCats) {
                                res.render("errorDatabase", { errorInfo: "Error getting categories", urlCourseCode: urlCourseCode, studentID: studentID });
                                return;
                            }
                            if (rowsCats && rowsCats.length) {
                                //get all the marks                   
                                connection.query("SELECT mark,maxMarks,entryName,typeID FROM ?? tabMarks, ?? tabEntries WHERE (studentID=? AND tabMarks.entryID = tabEntries.entryID) ORDER BY tabMarks.entryID", [urlCourseCode + "_marks", urlCourseCode + "_entries", studentID], function (errMarks, rowsMarks, fieldsMarks) {
                                    if (errMarks) {
                                        res.render("errorDatabase", { errorInfo: "Error getting marks", urlCourseCode: urlCourseCode, studentID: studentID });
                                        return;
                                    }
                                    if (rowsMarks && rowsMarks.length) {
                                        
                                        //get averages
                                        connection.query("SELECT CAST(average as SIGNED) as average,typeID FROM ?? tabAverages WHERE (studentID=?) ORDER BY typeID", [urlCourseCode + "_averages", studentID], function (errAverages, rowsAverages, fieldsAverages) {
                                            if (errAverages) {
                                                res.render("errorDatabase", { errorInfo: "Error getting averages", urlCourseCode: urlCourseCode, studentID: studentID });
                                                return;
                                            }
                                            if (rowsAverages && rowsAverages.length) {
                                                //get histograms
                                                connection.query("SELECT tabCategories.categoryName, tabHistograms.*  FROM ?? tabHistograms, ?? tabCategories WHERE (tabHistograms.typeID = tabCategories.typeID AND tabCategories.displayHistogram = True)", [urlCourseCode + "_histograms", urlCourseCode + "_categories"], function (errHists, rowsHists, fieldsHists) {
                                                    if (errHists) {
                                                        res.render("errorDatabase", { errorInfo: "Error getting histograms", urlCourseCode: urlCourseCode, studentID: studentID });
                                                        return;
                                                    }
                                                    if (rowsHists && rowsHists.length)
                                                        res.render("marks", { courseCode: urlCourseCode, courseName: rows[0].courseName, numCategories: rows[0].numCategories, updateDate: rows[0].updateDate.toDateString(), cats: rowsCats, averages: rowsAverages, studentID: rowsStudent[0].studentID, studentName: rowsStudent[0].name.replace(',', ', '), dpStatus: rowsStudent[0].DP, marks: rowsMarks, hists: JSON.stringify(rowsHists) });
                                                    else
                                                        res.render("marks", { courseCode: urlCourseCode, courseName: rows[0].courseName, numCategories: rows[0].numCategories, updateDate: rows[0].updateDate.toDateString(), cats: rowsCats, averages: rowsAverages, studentID: rowsStudent[0].studentID, studentName: rowsStudent[0].name.replace(',', ', '), dpStatus: rowsStudent[0].DP, marks: rowsMarks, hists: -1 });
                                            
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                    else {
                        res.render("invalidStudent", { courseCode: rows[0].coursePrefix, courseName: rows[0].courseName, studentID: studentID });
                    }
                });
            }
            else {
                res.render("invalidCourse");
            }
        });
    });

};