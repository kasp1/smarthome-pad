import fs from 'fs'
import YAML from 'yaml'
import log from './log.js'

export default {
  name: 'Smart System',
  port: 80,
  modulesDir: 'modules',
  logLevel: 5,
  logTime: false,
  logDate: false,

  load () {
    log.i('Loading configuration')

    // load the config file
    let cfg = YAML.parse(fs.readFileSync('config.yml', 'utf8'))

    if (cfg == null) {
      cfg = {}
    }

    let properties = Object.getOwnPropertyNames(this)

    for (let i in properties) {
      if (typeof this[properties[i]] != 'function') {
        if (cfg.hasOwnProperty(properties[i])) {
          this[properties[i]] = cfg[properties[i]]
        }
      }
    }
  }
}