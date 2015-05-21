AbstractDetector = require './abstract_update_detector'
request = require 'request'
AdmZip = require 'adm-zip'
{parseString} = require 'xml2js'

hash = (str)->
  crypto.createHash 'md5'
  .update xmlStr
  .digest 'hex'

isExist = (item)->
  return item?

inspectXML = (xmlStr)->
  try
    item = null
    
    parseString xmlStr, {trim: true}, (err, result)->
      #console.log result.cwbopendata.identifier[0]
      if not err
        item = result
      else
        item = null
    
    return item
  catch e
    console.error e
    return null
  

class UpdateDetector extends AbstractDetector
  constructor: ()->
    super
  
  fetch: (name, url)->
    @urlMap[name]._request = request {
      url,
      encoding: null
    }, (error, response, body)=>
      @urlMap[name]._request = null
      if not error
        @handle name, {response, body}
    
  parse: ({response, body})->
    #console.log response, body
    try
      return null if not response.headers['content-type']
      
      type = (response.headers['content-type'].match /zip|xml/ig)
      
      return null if not (type?)#well... seems fail to get a parseable response
      
      type = type[0].toLowerCase()
      
      datas = []
      
      if type is 'zip'
        zip = new AdmZip(body);
        zipEntries = zip.getEntries();
        zipEntries.forEach (zipEntry)->
          if 0 > zipEntry.name.search /\.(xml)$/i
            return null
          xml = zip.readAsText zipEntry, 'utf8'
          datas.push xml
      else if type is 'xml'
        datas.push body
      
      return datas
    catch e
      console.error e
      return null

  itemDiff: (newItems, datas)->
    datas.current = [] if not datas.current
    
    currentItems = datas.current
    
    diffItems = []
    
    if newItems is null
      #console.log 0
      return # no new item ,so nothing to do
    
    parsedItems = newItems.map inspectXML
    .filter isExist
    
    identifiers = parsedItems.map (item)->
      try item.cwbopendata.identifier[0]
    .filter isExist
    
    if identifiers.length is 0
      #console.log 1
      return # no any parseable item...
    
    for identifier in identifiers
      if not (identifier in currentItems)
        diffItems.push (parsedItems.filter (i)-> 
          #console.log i.cwbopendata.identifier[0], identifier
          i.cwbopendata.identifier[0] is identifier
        )[0]
    if diffItems.length is 0
      #console.log 2, parsedItems, identifiers, currentItems
      return
    
    datas.current = identifiers
    
    #console.log diffItems, identifiers
    
    #console.log 3
    return diffItems
    
    #return (null|undefined) or (array of)? item
  
  _destroy: (name, datas)->
    try
      datas._request.abort()
    catch e
      console.error e
    # shutdown all connection here
    #return (null|undefined) or (array of)? item

module.exports = UpdateDetector