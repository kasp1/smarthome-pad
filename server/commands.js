import fs from 'fs'
import YAML from 'yaml'
import util from 'util'

import log from './log.js'
import core from './core.js'

YAML.defaultOptions.simpleKeys = true
YAML.scalarOptions.null.nullStr = ''

const readFile = util.promisify(fs.readFile)
const writeFile = util.promisify(fs.writeFile)

export default {
  async modules (request) {
    let data = {}

    let module

    for (let m in core.modules) {
      module = core.modules[m]
      data[m] = {}

      data[m].title = module.title
      data[m].events = module.events
      data[m].actions = {}

      for (let a in module.actions) {
        data[m].actions[a] = { params: module.actions[a].params }
      }
    }

    core.send('INFO', data, 'modules', request)
  },

  async flowUpdate (request) {
    if (request.data) {
      try {
        core.updateFlow(request.data)
        core.send('INFO', { code: 7, data: 'Successfully updated flow.' }, 'flowSave', request)
      } catch (error) {
        core.send('ERRO', { code: 4, data: error }, 'flowUpdate', request)
      }
    }
  },

  async updateDefaultLocalFlow (request) {
    if (request.data) {
      log.i('Updating default local flow')

      try {
        await writeFile('defaultLocalFlow.yml', YAML.stringify(request.data))
        core.send('INFO', { code: 8, data: 'Successfully updated default local flow.' }, 'updateDefaultLocalFlow', request)
      } catch (error) {
        core.send('ERRO', { code: 9, data: error }, 'updateDefaultLocalFlow', request)
      }
    }
  },

  async loadDefaultLocalFlow (request) {
    log.i('Loading default local flow')

    try {
      let flow = await readFile('defaultLocalFlow.yml')
      flow = YAML.parse(flow.toString('utf8'))
      core.send('INFO', { code: 10, data: flow }, 'loadDefaultLocalFlow', request)
    } catch (error) {
      log.e('Failed to load flow', error)
    }
  },

  async flowLoad (request) {
    core.send('INFO', { code: 3, data: core.flow }, 'flowLoad', request)
  },

  async modulesLoad (request) {
    let mods = {}

    for (let i in core.modules) {
      mods[i] = {
        title: core.modules[i].title
      }

      if (core.modules[i].actions)
        mods[i].actions = core.modules[i].actions

      if (core.modules[i].events)
        mods[i].events = core.modules[i].events
    }

    core.send('INFO', { code: 6, data: mods }, 'modulesLoad', request)
  },

  async doStep (request) {
    if (request.data.step) {
      core.doStep(request.data.step, request.data.params)
    } else {
      core.send('ERRO', { code: 5, data: 'Step ID and params must be specified.' }, 'doStep', request)
    }
  }
}