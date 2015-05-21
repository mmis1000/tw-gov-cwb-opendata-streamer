require('coffee-script/register');

var config = require('./config.js');

var http = require('http');
var path = require('path');

var express = require('express');

var Detector = require('./lib/opendata_update_detector');
var Comet = require("comet-server")

var router = express();
var server = http.createServer(router);



router.set('views', path.resolve(__dirname, 'views'));
router.set('view engine', 'ejs');

var apikey, listenFor, detect, url, currentItems = [];
listenFor = config.listen;
apikey = config.apikey;

var listenTypes = Object.keys(listenFor)

//url = "http://opendata.cwb.gov.tw/opendataapi?dataid=" + dataid + "&authorizationkey=" + apikey;

var comet = new Comet(listenTypes);
router.use( '/comet', comet.getMiddleWare() );

detect = new Detector;

for (var i = 0; i < listenTypes.length; i++) {
  url = "http://opendata.cwb.gov.tw/opendataapi?dataid=" + listenFor[listenTypes[i]].id + "&authorizationkey=" + apikey;
  detect.addURL(listenTypes[i], url, listenFor[listenTypes[i]].interval);
}



detect.on('update', function (ev) {
  currentItems.push(ev);
  
  if (currentItems.length > config.maxBacklog) {
    currentItems.shift();
  }
  
  comet.pushData(ev.name, ev);
  
  console.log('got new (' + ev.name + ') data at ' + new Date);
})




router.get('/', function(req, res, next) {
  res.render('index', {items : currentItems, types : listenTypes});
})

router.get('/backlog.json', function(req, res, next) {
  res.jsonp(currentItems);
})

router.use(express.static(path.resolve(__dirname, 'client')));

server.listen(config.port, config.ip, function(){
  var addr = server.address();
  console.log("Server listening at", addr.address + ":" + addr.port);
});
