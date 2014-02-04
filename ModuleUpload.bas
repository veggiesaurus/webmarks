Attribute VB_Name = "Module5"
' Connection variables
Dim conn As New ADODB.Connection
Dim server_name As String
Dim database_name As String
Dim user_id As String
Dim password As String

Dim start_time, end_time

Public Declare PtrSafe Function GetTickCount Lib "kernel32.dll" () As Long


Sub CreateTablesMySQL()

    'server_name = "webapp-phy.uct.ac.za" ' Enter your server name here - if running from a local computer use 127.0.0.1
    server_name = "127.0.0.1" ' Enter your server name here - if running from a local computer use 127.0.0.1
    database_name = "webapp" ' Enter your database name here
    user_id = "webapp_writer" ' enter your user ID here
    password = "quantumWriter" ' Enter your password here
    
    On Error GoTo ErrorMySQLConn
    Set conn = New ADODB.Connection
    conn.Open "DRIVER={MySQL ODBC 5.2 Unicode Driver}" _
    & ";SERVER=" & server_name _
    & ";DATABASE=" & database_name _
    & ";UID=" & user_id _
    & ";PWD=" & password _
    & ";OPTION=16427" ' Option 16427 = Convert LongLong to Int: This just helps makes sure that large numeric results get properly interpreted
    'todo: check that database connection is working
    
   
    'check if sheet exists
    On Error GoTo ErrorWebappSheet
    Sheets("WEBAPP CONFIG").Select
    
    'check if course name exists
    On Error GoTo ErrorCourseName
    courseName = Range("COURSE_NAME").Value
    
    'check if table prefix exists
    On Error GoTo ErrorTablePrefix
    tablePrefixTrunk = Range("TABLE_PREFIX").Value + "_trunk_"
    tablePrefix = Range("TABLE_PREFIX").Value + "_"
    
    On Error GoTo ErrorDropTables
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "categories`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "categories`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "entries`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "entries`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "histograms`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "histograms`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "marks`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "marks`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "students`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "students`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefix + "averages`"
    conn.Execute "DROP TABLE IF EXISTS `" + tablePrefixTrunk + "averages`"
    
    On Error GoTo ErrorBaseTables
    conn.Execute "CREATE TABLE `" + tablePrefix + "categories` LIKE `base_categories`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "categories` LIKE `base_categories`"
    conn.Execute "CREATE TABLE `" + tablePrefix + "entries` LIKE `base_entries`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "entries` LIKE `base_entries`"
    conn.Execute "CREATE TABLE `" + tablePrefix + "histograms` LIKE `base_histograms`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "histograms` LIKE `base_histograms`"
    conn.Execute "CREATE TABLE `" + tablePrefix + "marks` LIKE `base_marks`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "marks` LIKE `base_marks`"
    conn.Execute "CREATE TABLE `" + tablePrefix + "students` LIKE `base_students`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "students` LIKE `base_students`"
    conn.Execute "CREATE TABLE `" + tablePrefix + "averages` LIKE `base_averages`"
    conn.Execute "CREATE TABLE `" + tablePrefixTrunk + "averages` LIKE `base_averages`"

    MsgBox ("Tables created")
    Exit Sub
    
ErrorMySQLConn:
    MsgBox ("Connection to MySQL database failed! Do you have the correct password?")
    Exit Sub

ErrorWebappSheet:
    MsgBox ("Could not find webapp config sheet!")
    Exit Sub

ErrorCourseName:
    MsgBox ("Course name not defined! Check the webapp config sheet for 'COURSE_NAME'")
    Exit Sub

ErrorTablePrefix:
    MsgBox ("Table prefix not defined! Check the webapp config sheet for 'TABLE_PREFIX'")
    Exit Sub
    
ErrorDropTables:
    MsgBox ("Error dropping tables. Check the MySQL configuration")
    Exit Sub
    
ErrorBaseTables:
    MsgBox ("Error creating tables from base tables. Check that MySQL base tables exist")
    Exit Sub

End Sub

Sub ExportToMySQL()
    start_time = GetTickCount
    'server_name = "webapp-phy.uct.ac.za" ' Enter your server name here - if running from a local computer use 127.0.0.1
    server_name = "127.0.0.1" ' Enter your server name here - if running from a local computer use 127.0.0.1
    database_name = "webapp" ' Enter your database name here
    user_id = "webapp_writer" ' enter your user ID here
    password = "quantumWriter" ' Enter your password here
    
    On Error GoTo ErrorMySQLConn
    Set conn = New ADODB.Connection
    conn.Open "DRIVER={MySQL ODBC 5.2 Unicode Driver}" _
    & ";SERVER=" & server_name _
    & ";DATABASE=" & database_name _
    & ";UID=" & user_id _
    & ";PWD=" & password _
    & ";OPTION=16427" ' Option 16427 = Convert LongLong to Int: This just helps makes sure that large numeric results get properly interpreted
    'todo: check that database connection is working
    
   
    'check if sheet exists
    On Error GoTo ErrorWebappSheet
    Sheets("WEBAPP CONFIG").Select
    
    'check if course name exists
    On Error GoTo ErrorCourseName
    courseName = Range("COURSE_NAME").Value
    
    'check if table prefix exists
    On Error GoTo ErrorTablePrefix
    tablePrefixTrunk = Range("TABLE_PREFIX").Value + "_trunk_"
    tablePrefix = Range("TABLE_PREFIX").Value + "_"
    
    On Error GoTo ErrorTableTrunc
    'truncate student table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "students"
    'truncate categories table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "categories"
    'truncate entries table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "entries"
    'truncate marks table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "marks"
    'truncate marks table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "histograms"
    'truncate averages table
    conn.Execute "TRUNCATE " + tablePrefixTrunk + "averages"
    
    On Error GoTo ErrorStudentIDCell
    
    studentIDCellCoordinate = Range("STUDENT_ID_CELL").Value
    On Error GoTo ErrorMasterSheet
    Sheets("MASTER").Select
    
    On Error GoTo ErrorStudentNames
    'read names and student ID
    Set studentIDCell = Range(studentIDCellCoordinate).Offset(1, 0)
    Set studentNameCell = Range(studentIDCellCoordinate).Offset(1, 1)
    
    sqlStrInsertName = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "students` VALUES "
    validSQL = False
    
    While Not IsEmpty(studentIDCell.Value) And Not IsEmpty(studentNameCell.Value)
        sqlStrInsertName = sqlStrInsertName & "('" + studentIDCell.Value + "','" + studentNameCell.Value + "'),"
        validSQL = True
        'move to next student
        Set studentIDCell = studentIDCell.Offset(1, 0)
        Set studentNameCell = studentNameCell.Offset(1, 0)
    Wend
    'finished reading names
    'only insert data if there is at least one entry!
    On Error GoTo ErrorInsertStudentNames
    If validSQL Then
        'remove trailing ","
        sqlStrInsertName = Left(sqlStrInsertName, Len(sqlStrInsertName) - 1)
        sqlStrInsertName = sqlStrInsertName & ";"
        conn.Execute sqlStrInsertName
    End If
    
    On Error GoTo ErrorWebappSheet
    Sheets("WEBAPP CONFIG").Select
    'important cells for categories
    On Error GoTo ErrorCategoriesCells
    numCategories = Range("NUM_CATS").Value
    Set categoryNameCell = Range("CATEGORY_NAME_CELL")
    Set typeCell = Range("TYPE_CELL")
    Set displayHistogramCell = Range("DISPLAY_HISTOGRAM_CELL")
    Set singleSheetCell = Range("SINGLE_SHEET_CELL")
    Set multiSheetCell = Range("MULTI_SHEET_CELL")
    
    'loop through categories
    entryID = 0
    For i = 1 To numCategories
        On Error GoTo ErrorCategoriesFormat
        currentName = categoryNameCell.Offset(i, 0).Value
        currentType = typeCell.Offset(i, 0).Value
        displayHistogram = displayHistogramCell.Offset(i, 0).Value
        bDisplayHistogram = False
        If displayHistogram = "Y" Or displayHistogram = "y" Then
            bDisplayHistogram = True
        End If
        typeID = i
        'todo: check for correct format
                
        If currentType = "M" Or currentType = "m" Then
            'if multi entries on a single sheet
            marksSheet = singleSheetCell.Offset(i, 0).Value
            idCellCoordinates = singleSheetCell.Offset(i, 1).Value
            firstEntryCellCoordinates = singleSheetCell.Offset(i, 2).Value
            averageMarkCellCoordinates = singleSheetCell.Offset(i, 3).Value
            
            'switch to correct sheet
            On Error GoTo ErrorMarksSheet
            Sheets(marksSheet).Select
            
            On Error GoTo ErrorMarksSheetCells
            Set idCell = Range(idCellCoordinates)
            Set firstEntryCell = Range(firstEntryCellCoordinates)
            
            
            Set currentEntryCell = firstEntryCell
            While Not IsEmpty(currentEntryCell.Value)
                includeInAverage = currentEntryCell.Offset(-3, 0).Value
                If includeInAverage = 1 Then
                    entryName = currentEntryCell.Value
                    On Error GoTo ErrorMaxMarks
                    maxMarks = currentEntryCell.Offset(-4, 0).Value
                    
                    On Error GoTo ErrorInsertEntries
                    'insert entry info via sql
                    sqlStrInsertEntry = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "entries` VALUES (" + CStr(entryID) + "," + CStr(typeID) + ",'" + entryName + "'," + CStr(maxMarks) + ");"
                    conn.Execute sqlStrInsertEntry
                    
                    On Error GoTo ErrorIDCell
                    Set currentIDCell = idCell.Offset(1, 0)
                    Set currentMarkCell = currentEntryCell.Offset(1, 0)
                    currentMarkCell.Select
                    'batching SQL calls for efficiency
                    sqlStrInsertMark = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "marks` VALUES"
                    validSQL = False
                    While Not IsEmpty(currentIDCell.Value)
                        currentStudentID = currentIDCell.Value
                        currentMark = currentMarkCell.Value
                        'treat absents as zero
                        If currentMark = "ABS" Or currentMark = "abs" Then
                            currentMark = 0
                        End If
                        
                        'check if valid mark
                        If IsNumeric(currentMark) And Not IsEmpty(currentMark) Then
                            'check if mark is positive
                            If currentMark >= 0 Then
                                'mark entry is valid, insert into SQL
                                sqlStrInsertMark = sqlStrInsertMark & "('" + currentStudentID + "'," + CStr(entryID) + "," + CStr(currentMark) + "),"
                                validSQL = True
                            End If
                        ElseIf IsEmpty(currentMark) Then
                            MsgBox ("Empty input for " + currentStudentID + " in cell " + marksSheet + ": " + currentMarkCell.Address)
                        ElseIf currentMark <> "exc" And currentMark <> "EXC" Then
                            MsgBox ("Invalid input for " + currentStudentID + " in cell " + marksSheet + ": " + currentMarkCell.Address)
                        End If
                        'move to next student
                        Set currentIDCell = currentIDCell.Offset(1, 0)
                        Set currentMarkCell = currentMarkCell.Offset(1, 0)
                    Wend
                    
                    If validSQL Then
                        'remove trailing ","
                        On Error GoTo ErrorInsertMarks
                        sqlStrInsertMark = Left(sqlStrInsertMark, Len(sqlStrInsertMark) - 1)
                        sqlStrInsertMark = sqlStrInsertMark & ";"
                        conn.Execute sqlStrInsertMark
                    End If
                    'increase entry ID
                    entryID = entryID + 1
                End If
                'move to next entry
                Set currentEntryCell = currentEntryCell.Offset(0, 1)
            Wend
            
            'calculate averages if there is an average mark cell
            If Not IsEmpty(averageMarkCellCoordinates) Then
                On Error GoTo ErrorStudentAverages
                
                'switch to master sheet
                Sheets("MASTER").Select
                Set studentIDCell = Range(studentIDCellCoordinate).Offset(1, 0)
                Set studentAverageCell = Range(averageMarkCellCoordinates).Offset(1, 0)
               
                
                sqlStrInsertAverages = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "averages` VALUES "
                validSQL = False
                While Not IsEmpty(studentIDCell.Value)
                    sqlStrInsertAverages = sqlStrInsertAverages & "( " + CStr(typeID) + ",'" + studentIDCell.Value + "'," + CStr(studentAverageCell.Value) + "),"
                    validSQL = True
                    'move to next student
                    Set studentIDCell = studentIDCell.Offset(1, 0)
                    Set studentAverageCell = studentAverageCell.Offset(1, 0)
                Wend
                    'only insert data if there is at least one entry!
                On Error GoTo ErrorInsertStudentAverages
                If validSQL Then
                    'remove trailing ","
                    sqlStrInsertAverages = Left(sqlStrInsertAverages, Len(sqlStrInsertAverages) - 1)
                    sqlStrInsertAverages = sqlStrInsertAverages & ";"
                    conn.Execute sqlStrInsertAverages
                End If
            Else
                'insert dummy averages
                On Error GoTo ErrorStudentAverages
                'switch to master sheet
                Sheets("MASTER").Select
                Set studentIDCell = Range(studentIDCellCoordinate).Offset(1, 0)
                sqlStrInsertAverages = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "averages` VALUES "
                validSQL = False
                While Not IsEmpty(studentIDCell.Value)
                    sqlStrInsertAverages = sqlStrInsertAverages & "( " + CStr(typeID) + ",'" + studentIDCell.Value + "'," + CStr(-1) + "),"
                    validSQL = True
                    'move to next student
                    Set studentIDCell = studentIDCell.Offset(1, 0)
                Wend
                    'only insert data if there is at least one entry!
                On Error GoTo ErrorInsertStudentAverages
                If validSQL Then
                    'remove trailing ","
                    sqlStrInsertAverages = Left(sqlStrInsertAverages, Len(sqlStrInsertAverages) - 1)
                    sqlStrInsertAverages = sqlStrInsertAverages & ";"
                    conn.Execute sqlStrInsertAverages
                End If
            End If
            
            
        ElseIf currentType = "S" Or currentType = "s" Then
            'if single entry per sheet (multi sheets allowed)
            Set marksSheetCell = multiSheetCell.Offset(i, 0)
            Set idCellCoordinatesCell = multiSheetCell.Offset(i, 1)
            Set entryCellCoordinatesCell = multiSheetCell.Offset(i, 2)
                                   
            While Not IsEmpty(marksSheetCell.Value) And Not IsEmpty(idCellCoordinatesCell.Value) And Not IsEmpty(entryCellCoordinatesCell.Value)
                'switch to correct sheet
                Sheets(marksSheetCell.Value).Select
                'todo: check if sheet exists
                Set idCell = Range(idCellCoordinatesCell.Value)
                Set entryCell = Range(entryCellCoordinatesCell.Value)
                'todo: check if cells are valid
                
                'for multi-sheet categories, the entry is the sheet name
                entryName = marksSheetCell.Value
                'NOTE: for multi-sheet categories, there is no "include in average" cell, so the offset of maxMarks differs
                maxMarks = entryCell.Offset(-3, 0).Value
                'todo: check that cell is valid
                    
                'insert entry info via sql
                sqlStrInsertEntry = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "entries` VALUES (" + CStr(entryID) + "," + CStr(typeID) + ",'" + entryName + "'," + CStr(maxMarks) + ");"
                conn.Execute sqlStrInsertEntry
                
                Set currentIDCell = idCell.Offset(1, 0)
                Set currentMarkCell = entryCell.Offset(1, 0)
                                
                sqlStrInsertMark = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "marks` VALUES"
                validSQL = False
                While Not IsEmpty(currentIDCell.Value)
                    currentStudentID = currentIDCell.Value
                    currentMark = currentMarkCell.Value
                    'treat absents as zero
                    If currentMark = "ABS" Or currentMark = "abs" Then
                        currentMark = 0
                    End If
                    
                    'check if valid mark
                    If IsNumeric(currentMark) Then
                        'check if mark is positive
                        If currentMark >= 0 And Not IsEmpty(currentMark) Then
                            'mark entry is valid, insert into SQL
                            sqlStrInsertMark = sqlStrInsertMark & "('" + currentStudentID + "'," + CStr(entryID) + "," + CStr(currentMark) + "),"
                            validSQL = True
                        End If
                    ElseIf IsEmpty(currentMark) Then
                            MsgBox ("Empty input for " + currentStudentID + " in cell " + marksSheet + ": " + currentMarkCell.Address)
                    ElseIf currentMark <> "exc" And currentMark <> "EXC" Then
                            MsgBox ("Invalid input for " + currentStudentID + " in cell " + marksSheet + ": " + currentMarkCell.Address)
                    End If
                    'move to next student
                    Set currentIDCell = currentIDCell.Offset(1, 0)
                    Set currentMarkCell = currentMarkCell.Offset(1, 0)
                Wend
                
                If validSQL Then
                    'remove trailing ","
                    sqlStrInsertMark = Left(sqlStrInsertMark, Len(sqlStrInsertMark) - 1)
                    sqlStrInsertMark = sqlStrInsertMark & ";"
                    conn.Execute sqlStrInsertMark
                End If
                
                'increase entry ID
                entryID = entryID + 1
                'move to next sheet
                Set marksSheetCell = marksSheetCell.Offset(0, 3)
                Set idCellCoordinatesCell = idCellCoordinatesCell.Offset(0, 3)
                Set entryCellCoordinatesCell = entryCellCoordinatesCell.Offset(0, 3)
            Wend
            
            'insert dummy averages
            On Error GoTo ErrorStudentAverages
            'switch to master sheet
            Sheets("MASTER").Select
            Set studentIDCell = Range(studentIDCellCoordinate).Offset(1, 0)
            sqlStrInsertAverages = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "averages` VALUES "
            validSQL = False
            While Not IsEmpty(studentIDCell.Value)
                sqlStrInsertAverages = sqlStrInsertAverages & "( " + CStr(typeID) + ",'" + studentIDCell.Value + "'," + CStr(-1) + "),"
                validSQL = True
                'move to next student
                Set studentIDCell = studentIDCell.Offset(1, 0)
            Wend
                'only insert data if there is at least one entry!
            On Error GoTo ErrorInsertStudentAverages
            If validSQL Then
                'remove trailing ","
                sqlStrInsertAverages = Left(sqlStrInsertAverages, Len(sqlStrInsertAverages) - 1)
                sqlStrInsertAverages = sqlStrInsertAverages & ";"
                conn.Execute sqlStrInsertAverages
            End If
            
            
        Else
            'todo: error handling
        End If
        
        'insert category
        sqlStrInsertCategory = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "categories` VALUES (" + CStr(typeID) + ",'" + currentName + "','nodesc'," + CStr(bDisplayHistogram) + ");"
        conn.Execute sqlStrInsertCategory
        
        
        'switch back to webapp config sheet
        Sheets("WEBAPP CONFIG").Select
    Next i
    
    
    'todo: histograms
    On Error GoTo ErrorHistograms
    Dim histVals(9) As Integer
    For i = 1 To numCategories
        'reset histograms
        For j = 0 To 9
            histVals(j) = 0
        Next j
        sqlStrGetAverages = "SELECT typeID, average, count(average) FROM ((SELECT CAST(10*sum(mark)/sum(maxMarks) AS UNSIGNED) AS average, typeID FROM `webapp`.`" + tablePrefixTrunk + "marks` tabMarks, `webapp`.`" + tablePrefixTrunk + "entries` tabEntries WHERE (tabMarks.entryID = tabEntries.entryID AND typeID=" + CStr(i) + ") GROUP BY studentID) AS tabAverages) group by average"
        Set rs = conn.Execute(sqlStrGetAverages)
        If Not rs.EOF Then
            rs.MoveFirst
            Debug.Print
            Debug.Print
            For Each fld In rs.Fields
                Debug.Print fld.Name,
            Next
            Debug.Print
            
            Do Until rs.EOF
                For Each fld In rs.Fields
                    Debug.Print fld.Value,
                Next
                histIndex = rs.Fields(1).Value
                histVal = rs.Fields(2).Value
                If histIndex >= 1 And histIndex <= 10 Then
                    histVals(histIndex - 1) = rs.Fields(2).Value
                End If
                rs.MoveNext
                Debug.Print
            Loop
            rs.Close
            
            'insert hists in mysql
            sqlStrInsertHist = "INSERT INTO `webapp`.`" + tablePrefixTrunk + "histograms` VALUES (" + CStr(i) + "," + CStr(histVals(0)) + "," + CStr(histVals(1)) + "," + CStr(histVals(2)) + "," + CStr(histVals(3)) + "," + CStr(histVals(4)) + "," + CStr(histVals(5)) + "," + CStr(histVals(6)) + "," + CStr(histVals(7)) + "," + CStr(histVals(8)) + "," + CStr(histVals(9)) + ");"
            conn.Execute sqlStrInsertHist
        End If
    Next i
        
     'copy trunk to actual table
    conn.Execute "TRUNCATE " + tablePrefix + "students"
    conn.Execute "INSERT INTO " + tablePrefix + "students SELECT * FROM " + tablePrefixTrunk + "students"
    conn.Execute "TRUNCATE " + tablePrefix + "categories"
    conn.Execute "INSERT INTO " + tablePrefix + "categories SELECT * FROM " + tablePrefixTrunk + "categories"
    conn.Execute "TRUNCATE " + tablePrefix + "entries"
    conn.Execute "INSERT INTO " + tablePrefix + "entries SELECT * FROM " + tablePrefixTrunk + "entries"
    conn.Execute "TRUNCATE " + tablePrefix + "marks"
    conn.Execute "INSERT INTO " + tablePrefix + "marks SELECT * FROM " + tablePrefixTrunk + "marks"
    conn.Execute "TRUNCATE " + tablePrefix + "histograms"
    conn.Execute "INSERT INTO " + tablePrefix + "histograms SELECT * FROM " + tablePrefixTrunk + "histograms"
    conn.Execute "TRUNCATE " + tablePrefix + "averages"
    conn.Execute "INSERT INTO " + tablePrefix + "averages SELECT * FROM " + tablePrefixTrunk + "averages"
    
    conn.Execute "REPLACE INTO info VALUES ('" + Range("TABLE_PREFIX").Value + "','" + courseName + "'," + CStr(numCategories) + ",CURDATE());"
    conn.Close
    
    end_time = GetTickCount
    MsgBox ("Database update completed in " & CStr(end_time - start_time) & " ms")
    Exit Sub
    
ErrorMySQLConn:
    MsgBox ("Connection to MySQL database failed! Do you have the correct password?")
    Exit Sub

ErrorWebappSheet:
    MsgBox ("Could not find webapp config sheet!")
    Exit Sub

ErrorCourseName:
    MsgBox ("Course name not defined! Check the webapp config sheet for 'COURSE_NAME'")
    Exit Sub

ErrorTablePrefix:
    MsgBox ("Table prefix not defined! Check the webapp config sheet for 'TABLE_PREFIX'")
    Exit Sub
        
ErrorTableTrunc:
    MsgBox ("Error clearing MySQL database tables! Check if the table prefix is correct and that the tables have been created.")
    Exit Sub

ErrorMasterSheet:
    MsgBox ("Could not find master sheet!")
    Exit Sub

ErrorStudentIDCell:
    MsgBox ("Student ID cell not defined! Check the webapp config sheet for 'STUDENT_ID_CELL'")
    Exit Sub
    
ErrorStudentNames:
    MsgBox ("Error reading student names from master spreadsheet. Check if 'STUDENT_ID_CELL' is correct")

ErrorInsertStudentNames:
    MsgBox ("Error inserting student information into database. Do you have the correct password?")
    
ErrorCategoriesCells:
    MsgBox ("Cannot find category definition cells. Check the webapp config sheet for 'NUM_CATS' and 'TYPE_CELL'")
    Exit Sub

ErrorCategoriesFormat:
    MsgBox ("Error in categories definition formating")
    Exit Sub
    
ErrorMarksSheetCells:
    MsgBox ("Error locating marks sheet starting cells. Check your webapp config for correct entry cells")
    Exit Sub
    
ErrorMarksSheet:
    MsgBox ("Error switching to marks sheet. Check your webapp config")
    Exit Sub
    
ErrorMaxMarks:
    MsgBox ("Error finding max marks. Check spreadsheet formatting. Max marks should be 4 rows above the entry title.")
    Exit Sub

ErrorInsertEntries:
    MsgBox ("Error inserting entries into MySQL database!")
    Exit Sub

ErrorStudentAverages:
    MsgBox ("Error finding averages! Ensure that the average mark cell is correct.")
    Exit Sub
    
ErrorInsertStudentAverages:
    MsgBox ("Error inserting averages into MySQL database!")
    Exit Sub
    
ErrorHistograms:
    MsgBox ("Error creating histograms")
    Exit Sub
    
ErrorIDCell:
    MsgBox ("Error locating ID cell. Check your webapp config!")
    Exit Sub
    
ErrorInsertMarks:
    MsgBox ("Error inserting marks into MySQL database")
    Exit Sub
    
End Sub





