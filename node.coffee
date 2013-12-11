http = require 'http'
spawn = require('child_process').spawn
jsdom = require 'jsdom'

showIdFloor = 100
latestShowId = 1300
updateMsg = "Dead end"
jqueryCdn = 'http://code.jquery.com/jquery-1.6.1.min.js'

updateLatestShowId = () ->
  urls = []
  latestShowPageUrl = ""
  phantomjs = spawn 'phantomjs',
    ["phantom.coffee", "--load-images=no"]
    { cwd: __dirname, env: process.env }
  console.log "Getting latest slideshow page (phantomjs #{phantomjs.pid})..."
  phantomjs.stdout.on 'data', (data) ->
    slideshowUrls = JSON.parse(data)
    updateLatestShowIdFromPage(url) for url in slideshowUrls
  phantomjs.on 'exit', (code) ->
    phantomjs = null

updateLatestShowIdFromPage = (pageUrl) ->
  jsdom.env pageUrl, [jqueryCdn], (e, w) ->
    showId = parseInt w.$("iframe:first").prop("src").match(new RegExp(/[0-9]+/))[0]
    if showId > latestShowId
      latestShowId = showId
      console.log "Newest slideshow ID: #{latestShowId}"

getImages = (showId, res) ->
  imgUrls = []
  currentShowUrl = "http://www.americanapparel.net/flash/src/auto/" + showId + "/"
  console.log "Getting show: #{currentShowUrl}"
  jsdom.env "#{currentShowUrl}slidedata.xml", [jqueryCdn], (e, w) ->
    w.$("slide").each () ->
      imgUrls.push currentShowUrl + w.$(this).attr("src")
    if imgUrls.length % 2 != 0
      imgUrls.push imgUrls[0] #repeat the first image to keep the layout even
    res.end JSON.stringify imgUrls
    imgUrls = null
    if latestShowId >= showIdFloor
      res.end JSON.stringify imgUrls
    else
      updateLatestShowId()
      res.end JSON.stringify {'updateMsg':updateMsg}
      
randomShowId = () ->
  Math.floor( Math.random() * (latestShowId - showIdFloor) ) + showIdFloor

blacklist =
  [ 1284, 360, 1218, 264, 1232, 782, 389, 673, 541, 935, 800, 952,
  878, 415, 216, 1309, 537, 295, 1228, 637 ]

isBlacklisted = (id) ->
  blacklist.indexOf(id) > -1

process = (req, res) ->
  if req.url.indexOf("random") > -1
    id = randomShowId()
    while isBlacklisted(id)
      console.log "Skipping blacklisted ID #{id}"
      id = randomShowId()
    getImages(id, res)
  else
    getImages(latestShowId, res)
    latestShowId-- if latestShowId > showIdFloor


server = (req, res) ->
  res.writeHead 200,
    'Content-Type': 'application/javascript'
    'Access-Control-Allow-Origin': '*'
  process(req, res)

port = 1337
http.createServer(server).listen(port)
console.log "[Node running at http://127.0.0.1:#{port}/]"

updateLatestShowId()  
  