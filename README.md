### create broadcast channel for data update from http://opendata.cwb.gov.tw/

[![Greenkeeper badge](https://badges.greenkeeper.io/mmis1000/tw-gov-cwb-opendata-streamer.svg)](https://greenkeeper.io/)

####How to use

1. clone the repo with either zip from web-page or git
2. switch to the repo and run `npm install`
3. add your api key to `config.example.js`
4. rename it to `config.js`
5. fire the server with `node index.js`

data entries :

1. `/comet/(youe listenTargets seperate by ,)`, it will return new path to fetch and probably new datas if exist
2. `/backlog.json`, back log of the newest data fetched
