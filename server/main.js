import fs from 'fs'
import WebSocket from 'ws'
import http from 'http'
import path from 'path'
import url from 'url'

// import core
import log from './log.js'
import cfg from './cfg.js'
import core from './core.js'

// import commands
import commands from './commands.js'

// load the configuration
cfg.load()

// import modules (asynchronous)
core.importModules()

// load flow
core.loadFlow()

// start HTTP server to serve the UI
let server = http.createServer((req, res) => {
  // CORS, so mobile apps can connect as well
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE')
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type')
  //response.setHeader('Access-Control-Allow-Credentials', true);

  // parse URL
  const parsedUrl = url.parse(req.url)
  // extract URL path
  let pathname = `ui/${parsedUrl.pathname}`
  // based on the URL path, extract the file extention. e.g. .js, .doc, ...
  const ext = path.parse(pathname).ext
  // maps file extention to MIME typere
  const map = {
    '.ico': 'image/x-icon',
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.css': 'text/css',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml',
  }

  fs.exists(pathname, (exist) => {
    if (!exist) {
      // if the file is not found, return 404
      res.statusCode = 404
      return
    }

    // if is a directory search for index file matching the extention
    if (fs.statSync(pathname).isDirectory()) pathname = 'ui/index.html'

    console.log(pathname)

    // read file from file system
    fs.readFile(pathname, (err, data) => {
      if (err) {
        res.statusCode = 500
        res.end(`Error getting the file: ${err}.`)
      } else {
        // if the file is found, set Content-type and send data
        res.setHeader('Content-type', map[ext] || 'text/html' )
        res.end(data)
      }
    })
  })
})

// start communication
const wss = new WebSocket.Server({ server })

// handle communication, restrict to a single client only
wss.on('connection', (ws) => {
  log.i2('Incoming user connection.')

  /*if (core.userSocket == null) {
    core.userSocket = ws
    core.send('INFO', { code: 1, message: 'Established connection with a user.'})
    log.i('Established connection with a user.')
  } else {
    core.send('ERRO', { code: 2, message: 'Rejecting connection, because a client is already connected.'})
    log.i2('Incoming connection rejected, because a client is already connected.')
    ws.close()
  }*/

  core.userSockets.push(ws);

  core.send('INFO', { code: 1, message: 'Established a connection.'})

  log.i3('Connections:', core.userSockets)

  ws.on('message', (message) => {
    let request = JSON.parse(message)

    log.i3('Incoming request', request)
    
    if (commands[request.command]) {
      log.i2('Running command:', request.command)
      commands[request.command](request)
    }
  })

  ws.on('close', () => {
    /*if (ws == core.userSocket) {
      core.userSocket = null
      log.i2('User disconnected')
    }*/
    
    core.userSockets.splice(core.userSockets.indexOf(ws), 1)

    log.i2('Connection closed')
  })
})

server.listen(cfg.port)
log.i(cfg.name, 'running @', cfg.port)