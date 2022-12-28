var express = require('express');
var router = express.Router();

/* GET home page. */
app.get('/', function(req,res){
  console.log('page render requestsed');
  exec('curl "https://api.airtable.com/v0/appNly6KQtUVC2Mot/covidFrance?view=Grid%20view" -H "Authorization: Bearer keyb8gsvTJ7gwCm8n"', function(error, stdout, stderr) {
    if (error) {
      // Handle errors
      console.error(error);
      return;
    }
    let data = JSON.parse(stdout);
    res.render(path.join(__dirname+'/views/page.ejs'), {data: data});
  });
  //__dirname : It will resolve to your project folder.
});
app.post('/send', function(req, res){
  console.log('Send requested');
  sendReq();
  res.sendStatus(200);
});

module.exports = router;
