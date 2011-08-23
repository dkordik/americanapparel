page = new WebPage()
page.onConsoleMessage = (msg) ->
  console.log msg
page.open encodeURI("http://www.americanapparel.net/whatsnew/"), (status) ->
  if status != "success"
    console.log "Unable to access network"
  else
    page.evaluate () ->
      list = document.querySelectorAll '[src$="icon_media.gif"]'
      urls = []
      urls.push "\"#{icon.parentNode}\"" for icon in list
      console.log "[#{urls}]"
  phantom.exit()

