import cfg from './cfg.js'
import core from './core.js'

export default {
  msg (type, args, func) {
    args.sort(function (a, b) { return a - b; })

    // send to remote connection
    core.send(type, args.join(' '))

    let stamp = [ type ]

    let now = new Date()

    if (cfg.logTime) {
      stamp.push(
        this.prependZero(now.getHours())
        + ':'
        + this.prependZero(now.getMinutes())
        + ':'
        + this.prependZero(now.getSeconds())
        + '.'
        + this.prependZero(now.getMilliseconds())
      )
    }

    if (cfg.logDate) {
      stamp.push(
        now.getFullYear()
        + '-'
        + this.prependZero(now.getMonth() + 1)
        + '-'
        + this.prependZero(now.getDate())
      )
    }

    args.unshift('[ ' + stamp.join(' ') + ' ]')

    // send to console
    console[func].apply(console, args)
  },

  e (...args) {
    if (cfg.logLevel >= 1) {
      this.msg('ERRO', args, 'info')
    }
  },

  w (...args) {
    if (cfg.logLevel >= 2) {
      this.msg('WARN', args, 'info')
    }
  },

  i (...args) {
    if (cfg.logLevel >= 3) {
      this.msg('INFO', args, 'info')
    }
  },

  i2 (...args) {
    if (cfg.logLevel >= 4) {
      this.msg('INFO', args, 'info')
    }
  },

  i3 (...args) {
    if (cfg.logLevel >= 5) {
      this.msg('INFO', args, 'info')
    }
  },

  prependZero(num) {
    return num.toString().length == 1 ? '0' + num : num.toString()
  }
}