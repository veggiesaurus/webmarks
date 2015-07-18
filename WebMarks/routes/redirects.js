module.exports = function (app){
	app.get("/webmarks/:afterURL(*)", function (req, res) {
    	res.redirect("/"+req.params.afterURL);    
	});
	
	app.get("/webmarks", function (req, res) {
	    res.redirect("/");
	});
	
	app.get("/poll", function (req, res) {
	    res.redirect('http://polling.uct.ac.za');    
	});
	
	app.get("/poll/:afterURL(*)", function (req, res) {
	    res.redirect('http://polling.uct.ac.za/'+req.params.afterURL)    
	});
	
};