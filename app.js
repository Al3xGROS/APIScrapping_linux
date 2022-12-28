var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const { exec } = require('child_process');
const { stdout } = require('process');

var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

function sendReq() {
  console.log("Function send() called !");
  exec('./public/bashscripts/scrappingAPI.sh', (error, stdout) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log(`${stdout}`);
  });
}

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

module.exports = app;
