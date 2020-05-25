import YAML from 'yaml'
import fs from 'fs'
import util from 'util'

YAML.defaultOptions.simpleKeys = true
YAML.scalarOptions.null.nullStr = ''

const readFile = util.promisify(fs.readFile)
const writeFile = util.promisify(fs.writeFile)

import log from './log.js'
import api from './api.js'
import cfg from './cfg.js'

export default {
  modules: {},
  userSockets: [],
  flow: null,

  send (type, data, command, request) {
    let response = {
      type: type,
      data: data,
      timestamp: Math.round(new Date().getTime() / 1000)
    }

    if (command) {
      response.command = command
    }

    if (request) {
      if (request.id) {
        response.id = request.id
      }
    }

    for (let i in this.userSockets) {
      this.userSockets[i].send(JSON.stringify(response))
    }
  },

  async trigger (event, module) {
    log.i2('Received event', event, 'from module', module)
    let eventId = module + '_' + event

    for (let i in this.flow) {
      if (i == eventId) {
        if (typeof this.flow[i] == 'object') {
          for (let step in this.flow[i]) {
            this.doStep(step, this.flow[i][step])
          }
        } else {
          log.i2('Event', eventId, 'was called but had empty timeline, skipped.')
        }
      }
    }
  },

  async doStep (step, params) {
    // it's an action
    if (step.indexOf('_') >= 0) {
      let args = step.split('_')
      await this.doAction(args[0], args[1], params)
    // it's a group of actions
    } else {
      for (let i in this.flow) {
        if (i == step) {
          for (let s in this.flow[i]) {
            this.doStep(s, this.flow[i][s])
          }
        }
      }
    }
  },

  async doAction (moduleId, action, params) {
    if (this.modules[moduleId]) {
      let module = this.modules[moduleId]

      if (module.actions[action]) {
        if (api.checkParams(params, module.actions[action].params)) {
          try {
            await module.actions[action].handler(module, params)
            this.send('INFO', 'Action ' + action + ' called from module ' + moduleId + ' was successful.', 'doAction')
            log.i2('Action call was successful:', moduleId, action)
          } catch (error) {
            this.send('ERRO', 'Action ' + action + ' from module ' + moduleId + ' failed: ' + error, 'doAction')
            log.e('Action ' + action + ' from module ' + moduleId + ' failed: ' + error)
          }
        } else {
          this.send('ERRO', 'Action ' + action + ' from module ' + moduleId + ' failed because of invalid parameters.', 'doAction')
          log.e('Calling an action from user client failed because of invalid params:', action)
        }
      } else {
        this.send('ERRO', 'No such action', 'doAction')
        log.e('Calling an action from module', moduleId ,'failed because the action does not exist:', action)
      }
    } else {
      this.send('ERRO', 'No such module', 'doAction')
      log.e('Calling an action from module failed because the module does not exist:', module)
    }
  },

  async importModules () {
    log.i('Loading modules')

    if (fs.existsSync(cfg.modulesDir)) {
      fs.readdirSync(cfg.modulesDir).forEach((fileName) => {
        let name = fileName.split('.')[0]
        
        log.i2('Loading module', name)

        import('./' + cfg.modulesDir + '/' + fileName).then((module) => {
          this.modules[name] = module.default
          
          if (this.modules[name]['start']) {
            this.modules[name]['start']()
          }
        })
      })
    } else {
      fs.mkdirSync('./', cfg.modulesDir)
    }
  },

  async loadFlow () {
    log.i('Loading flow')

    try {
      this.flow = await readFile('flow.yml')
      this.flow = YAML.parse(this.flow.toString('utf8'))
    } catch (error) {
      log.e('Failed to load flow', error)
    }
  },

  async updateFlow (flow) {
    log.i('Updating flow')

    this.flow = flow

    try {
      await writeFile('flow.yml', YAML.stringify(flow))
      log.i('Successfully updated flow.')
    } catch (error) {
      log.e('Failed to update flow', error)
    }
  }
}