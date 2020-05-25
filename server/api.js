import core from './core.js'

export default {

  checkParams (givenParams, definition) {
    return true
  },

  emit (event, module) {
    let moduleId = this.findModuleId(module)
    core.trigger(event, moduleId)
  },

  findModuleId (module) {
    return Object.keys(core.modules).find(key => core.modules[key] == module);
  }
}